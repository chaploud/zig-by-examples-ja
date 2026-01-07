//! # スタックとヒープ
//!
//! Zigには2種類のメモリ領域がある：スタックとヒープ。
//! それぞれの特性を理解し、適切に使い分ける。
//!
//! ## スタック
//! - コンパイル時にサイズが決まる
//! - 関数スコープ終了時に自動解放
//! - 高速だがサイズ制限あり
//!
//! ## ヒープ
//! - 実行時にサイズを決定可能
//! - 明示的に解放が必要
//! - 柔軟だが管理が必要

const std = @import("std");

// ====================
// スタックメモリ
// ====================

fn demoStack() void {
    std.debug.print("--- スタックメモリ ---\n", .{});

    // ローカル変数はスタックに配置
    const x: i32 = 42;
    var y: i32 = 100;
    _ = &y;

    std.debug.print("  x = {d} (スタック上)\n", .{x});
    std.debug.print("  y = {d} (スタック上)\n", .{y});

    // 配列もコンパイル時にサイズが決まればスタック
    var arr: [5]i32 = .{ 1, 2, 3, 4, 5 };
    std.debug.print("  arr[2] = {d} (スタック上)\n", .{arr[2]});

    // 関数終了時に自動的に解放される
    _ = &arr;
    std.debug.print("  → 関数終了時に自動解放\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スタックのライフタイム問題
// ====================

fn badPointer() *i32 {
    var x: i32 = 42;
    return &x; // 危険！スタック変数へのポインタを返す
}

fn demoStackLifetime() void {
    std.debug.print("--- スタックのライフタイム ---\n", .{});

    // 注意: これはコンパイラに検出される
    // const ptr = badPointer();
    // std.debug.print("{d}\n", .{ptr.*}); // 未定義動作！

    std.debug.print("  スタック変数のポインタを返すと危険\n", .{});
    std.debug.print("  関数終了時にメモリが無効になる\n", .{});
    std.debug.print("  → Zigコンパイラが検出してエラー\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ヒープメモリ
// ====================

fn demoHeap() !void {
    std.debug.print("--- ヒープメモリ ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 単一値をヒープに割り当て
    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 42;
    std.debug.print("  ヒープ上の値: {d}\n", .{ptr.*});

    // 実行時にサイズを決定できる
    const runtime_size: usize = 10;
    const arr = try allocator.alloc(u8, runtime_size);
    defer allocator.free(arr);

    @memset(arr, 'Z');
    std.debug.print("  動的サイズ配列: {s}\n", .{arr});
    std.debug.print("  → deferで明示的に解放\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スタック vs ヒープの選択
// ====================

fn demoWhenToUse() !void {
    std.debug.print("--- スタック vs ヒープの選択 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // スタックを使う場合：
    // 1. サイズがコンパイル時に決まる
    const stack_buf: [100]u8 = undefined;
    std.debug.print("  スタック配列: {d} bytes\n", .{stack_buf.len});

    // 2. 関数内で一時的に使う
    var temp: i32 = 0;
    for (0..10) |i| {
        temp += @as(i32, @intCast(i));
    }
    std.debug.print("  一時変数: {d}\n", .{temp});

    // ヒープを使う場合：
    // 1. 実行時にサイズが決まる
    var input_size: usize = 50; // 実行時に変わりうる値
    _ = &input_size;
    const heap_buf = try allocator.alloc(u8, input_size);
    defer allocator.free(heap_buf);
    std.debug.print("  ヒープ配列: {d} bytes\n", .{heap_buf.len});

    // 2. データを関数外に返す必要がある
    std.debug.print("  → ヒープなら関数外でも有効\n", .{});

    // 3. 大きなデータ
    std.debug.print("  → 大きなデータはヒープへ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 関数から動的データを返す
// ====================

fn createString(allocator: std.mem.Allocator, text: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, text.len);
    @memcpy(result, text);
    return result; // ヒープなので安全に返せる
}

fn demoReturnFromFunction() !void {
    std.debug.print("--- 関数からデータを返す ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // ヒープに割り当てたデータは安全に返せる
    const str = try createString(allocator, "Hello from heap!");
    defer allocator.free(str);

    std.debug.print("  戻り値: {s}\n", .{str});
    std.debug.print("  → 呼び出し側で解放が必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// メモリリーク
// ====================

fn demoMemoryLeak() !void {
    std.debug.print("--- メモリリーク検出 ---\n", .{});

    // GPAはリーク検出機能付き
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();

    // わざとリークさせる
    _ = try allocator.alloc(u8, 10);
    // freeを呼ばない！

    // deinitでリークを検出
    const check = gpa.deinit();
    if (check == .leak) {
        std.debug.print("  メモリリーク検出！\n", .{});
    } else {
        std.debug.print("  リークなし\n", .{});
    }

    std.debug.print("  → freeを忘れずに\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// FixedBufferAllocatorでスタック活用
// ====================

fn demoFixedBuffer() !void {
    std.debug.print("--- FixedBufferAllocator（スタック活用） ---\n", .{});

    // スタック上のバッファをアロケータとして使う
    var buffer: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    // 動的割り当て風だがスタック上
    const data = try allocator.alloc(u8, 50);
    @memset(data, 'X');

    std.debug.print("  スタックバッファから割り当て: {s}...\n", .{data[0..10]});
    std.debug.print("  ヒープを使わず動的風に使える\n", .{});

    // 自動解放（バッファがスタックなので）
    std.debug.print("  → 関数終了時に自動解放\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体とメモリ
// ====================

const User = struct {
    id: u32,
    name: []const u8,

    const Self = @This();

    /// ヒープにUserを作成
    pub fn create(allocator: std.mem.Allocator, id: u32, name: []const u8) !*Self {
        const user = try allocator.create(Self);
        user.* = Self{ .id = id, .name = name };
        return user;
    }

    /// 解放
    pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
        allocator.destroy(self);
    }
};

fn demoStructMemory() !void {
    std.debug.print("--- 構造体とメモリ ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // スタック上の構造体
    const stack_user = User{ .id = 1, .name = "Stack User" };
    std.debug.print("  スタック: id={d}, name={s}\n", .{ stack_user.id, stack_user.name });

    // ヒープ上の構造体
    const heap_user = try User.create(allocator, 2, "Heap User");
    defer heap_user.destroy(allocator);

    std.debug.print("  ヒープ: id={d}, name={s}\n", .{ heap_user.id, heap_user.name });

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== スタックとヒープ ===\n\n", .{});

    demoStack();
    demoStackLifetime();
    try demoHeap();
    try demoWhenToUse();
    try demoReturnFromFunction();
    try demoMemoryLeak();
    try demoFixedBuffer();
    try demoStructMemory();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・スタック: 自動管理、高速、サイズ固定\n", .{});
    std.debug.print("・ヒープ: 手動管理、柔軟、サイズ可変\n", .{});
    std.debug.print("・小さい一時データ → スタック\n", .{});
    std.debug.print("・大きい/可変データ → ヒープ\n", .{});
    std.debug.print("・戻り値として渡す → ヒープ\n", .{});
}

// --- テスト ---

test "stack allocation" {
    var arr: [10]i32 = undefined;
    for (&arr, 0..) |*item, i| {
        item.* = @as(i32, @intCast(i));
    }
    try std.testing.expectEqual(@as(i32, 5), arr[5]);
}

test "heap allocation" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 42;
    try std.testing.expectEqual(@as(i32, 42), ptr.*);
}

test "heap array" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const arr = try allocator.alloc(u8, 20);
    defer allocator.free(arr);

    @memset(arr, 'A');
    try std.testing.expectEqual(@as(u8, 'A'), arr[0]);
    try std.testing.expectEqual(@as(usize, 20), arr.len);
}

test "createString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const str = try createString(allocator, "test");
    defer allocator.free(str);

    try std.testing.expect(std.mem.eql(u8, str, "test"));
}

test "FixedBufferAllocator" {
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const data = try allocator.alloc(u8, 50);
    try std.testing.expectEqual(@as(usize, 50), data.len);

    // 容量超過
    try std.testing.expectError(error.OutOfMemory, allocator.alloc(u8, 100));
}

test "User create and destroy" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const user = try User.create(allocator, 42, "TestUser");
    defer user.destroy(allocator);

    try std.testing.expectEqual(@as(u32, 42), user.id);
    try std.testing.expect(std.mem.eql(u8, user.name, "TestUser"));
}

test "GPA no leak" {
    // リークがないことを確認
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const data = try allocator.alloc(u8, 10);
    allocator.free(data); // 正しく解放

    const result = gpa.deinit();
    try std.testing.expectEqual(.ok, result);
}
