//! # アロケータ
//!
//! Zigはメモリ割り当てを明示的に行う。
//! アロケータを使ってヒープメモリを確保・解放する。
//!
//! ## アロケータの種類
//! - GeneralPurposeAllocator: 汎用
//! - page_allocator: ページ単位
//! - FixedBufferAllocator: 固定バッファ
//! - ArenaAllocator: 一括解放

const std = @import("std");

// ====================
// GeneralPurposeAllocator（汎用）
// ====================

fn demoGPA() !void {
    std.debug.print("--- GeneralPurposeAllocator ---\n", .{});

    // 汎用アロケータを作成
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            std.debug.print("  メモリリーク検出！\n", .{});
        }
    }
    const allocator = gpa.allocator();

    // 単一の値を割り当て
    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 42;
    std.debug.print("  単一値: {d}\n", .{ptr.*});

    // スライスを割り当て
    const slice = try allocator.alloc(u8, 10);
    defer allocator.free(slice);

    @memset(slice, 'A');
    std.debug.print("  スライス: {s}\n", .{slice});

    std.debug.print("\n", .{});
}

// ====================
// page_allocator（ページ単位）
// ====================

fn demoPageAllocator() !void {
    std.debug.print("--- page_allocator ---\n", .{});

    const allocator = std.heap.page_allocator;

    // ページ単位で割り当て（大きなメモリブロック向け）
    const buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    std.debug.print("  割り当てサイズ: {d} bytes\n", .{buffer.len});

    // 使用
    @memset(buffer[0..10], 'X');
    std.debug.print("  最初の10バイト: {s}\n", .{buffer[0..10]});

    std.debug.print("\n", .{});
}

// ====================
// FixedBufferAllocator（固定バッファ）
// ====================

fn demoFixedBufferAllocator() !void {
    std.debug.print("--- FixedBufferAllocator ---\n", .{});

    // 固定サイズのバッファを用意
    var buffer: [100]u8 = undefined;

    // バッファを使うアロケータ
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    // 割り当て
    const data1 = try allocator.alloc(u8, 20);
    std.debug.print("  data1: {d} bytes割り当て\n", .{data1.len});

    const data2 = try allocator.alloc(u8, 30);
    std.debug.print("  data2: {d} bytes割り当て\n", .{data2.len});

    // 容量超過はエラー
    const result = allocator.alloc(u8, 100);
    if (result) |_| {
        std.debug.print("  100 bytes割り当て成功\n", .{});
    } else |_| {
        std.debug.print("  100 bytes割り当て失敗（OutOfMemory）\n", .{});
    }

    // リセットして再利用
    fba.reset();
    std.debug.print("  リセット後、再割り当て可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ArenaAllocator（アリーナ）
// ====================

fn demoArenaAllocator() !void {
    std.debug.print("--- ArenaAllocator ---\n", .{});

    // 親アロケータを指定（通常はpage_allocator）
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit(); // 一括で解放

    const allocator = arena.allocator();

    // 複数回割り当て（個別にfreeする必要なし）
    const s1 = try allocator.alloc(u8, 100);
    const s2 = try allocator.alloc(u8, 200);
    const s3 = try allocator.alloc(u8, 300);

    @memset(s1, 'A');
    @memset(s2, 'B');
    @memset(s3, 'C');

    std.debug.print("  s1[0]: {c}\n", .{s1[0]});
    std.debug.print("  s2[0]: {c}\n", .{s2[0]});
    std.debug.print("  s3[0]: {c}\n", .{s3[0]});

    std.debug.print("  arena.deinit()で全て一括解放\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// アロケータを引数に取る関数
// ====================

/// アロケータを使って文字列を複製
fn duplicateString(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, s.len);
    @memcpy(result, s);
    return result;
}

/// アロケータを使って配列を作成
fn createArray(allocator: std.mem.Allocator, comptime T: type, size: usize, value: T) ![]T {
    const arr = try allocator.alloc(T, size);
    @memset(arr, value);
    return arr;
}

fn demoAllocatorParameter() !void {
    std.debug.print("--- アロケータを引数に取る関数 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 文字列複製
    const original = "Hello, Zig!";
    const copy = try duplicateString(allocator, original);
    defer allocator.free(copy);

    std.debug.print("  元: {s}\n", .{original});
    std.debug.print("  複製: {s}\n", .{copy});

    // 配列作成
    const arr = try createArray(allocator, i32, 5, 42);
    defer allocator.free(arr);

    std.debug.print("  配列: ", .{});
    for (arr) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ArrayList（動的配列）
// ====================

fn demoArrayList() !void {
    std.debug.print("--- ArrayList（動的配列） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // ArrayListの作成（Zig 0.15: 各操作でallocatorを渡す）
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(allocator);

    // 要素を追加
    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    std.debug.print("  要素数: {d}\n", .{list.items.len});
    std.debug.print("  要素: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    // スライスとしてアクセス
    const slice = list.items;
    std.debug.print("  slice[1]: {d}\n", .{slice[1]});

    std.debug.print("\n", .{});
}

// ====================
// allocPrint（フォーマット付き文字列）
// ====================

fn demoAllocPrint() !void {
    std.debug.print("--- allocPrint ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const name = "Zig";
    const version: u32 = 15;

    // フォーマット付きで文字列を生成
    const message = try std.fmt.allocPrint(allocator, "{s} version 0.{d}", .{ name, version });
    defer allocator.free(message);

    std.debug.print("  {s}\n", .{message});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== アロケータ ===\n\n", .{});

    try demoGPA();
    try demoPageAllocator();
    try demoFixedBufferAllocator();
    try demoArenaAllocator();
    try demoAllocatorParameter();
    try demoArrayList();
    try demoAllocPrint();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・allocator.create(T): 単一値を割り当て\n", .{});
    std.debug.print("・allocator.alloc(T, n): n個のTを割り当て\n", .{});
    std.debug.print("・allocator.destroy(): createで作成した値を解放\n", .{});
    std.debug.print("・allocator.free(): allocで作成した値を解放\n", .{});
    std.debug.print("・deferで解放を保証\n", .{});
}

// --- テスト ---

test "GPA create and destroy" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ptr = try allocator.create(i32);
    ptr.* = 123;
    try std.testing.expectEqual(@as(i32, 123), ptr.*);
    allocator.destroy(ptr);
}

test "GPA alloc and free" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const slice = try allocator.alloc(u8, 5);
    defer allocator.free(slice);

    try std.testing.expectEqual(@as(usize, 5), slice.len);
}

test "FixedBufferAllocator" {
    var buffer: [50]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const data = try allocator.alloc(u8, 20);
    try std.testing.expectEqual(@as(usize, 20), data.len);

    // 容量超過
    try std.testing.expectError(error.OutOfMemory, allocator.alloc(u8, 100));

    // リセット後は再割り当て可能
    fba.reset();
    const data2 = try allocator.alloc(u8, 40);
    try std.testing.expectEqual(@as(usize, 40), data2.len);
}

test "ArenaAllocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const s1 = try allocator.alloc(u8, 100);
    const s2 = try allocator.alloc(u8, 200);

    try std.testing.expectEqual(@as(usize, 100), s1.len);
    try std.testing.expectEqual(@as(usize, 200), s2.len);
    // deferでarena.deinit()が呼ばれ、全て解放
}

test "duplicateString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const original = "test";
    const copy = try duplicateString(allocator, original);
    defer allocator.free(copy);

    try std.testing.expect(std.mem.eql(u8, original, copy));
}

test "createArray" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const arr = try createArray(allocator, i32, 3, 42);
    defer allocator.free(arr);

    try std.testing.expectEqual(@as(usize, 3), arr.len);
    for (arr) |v| {
        try std.testing.expectEqual(@as(i32, 42), v);
    }
}

test "ArrayList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, 1);
    try list.append(allocator, 2);
    try list.append(allocator, 3);

    try std.testing.expectEqual(@as(usize, 3), list.items.len);
    try std.testing.expectEqual(@as(i32, 1), list.items[0]);
    try std.testing.expectEqual(@as(i32, 2), list.items[1]);
    try std.testing.expectEqual(@as(i32, 3), list.items[2]);
}

test "allocPrint" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const msg = try std.fmt.allocPrint(allocator, "Hello {s}!", .{"World"});
    defer allocator.free(msg);

    try std.testing.expect(std.mem.eql(u8, msg, "Hello World!"));
}
