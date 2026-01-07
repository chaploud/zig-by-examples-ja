//! # センチネル終端配列
//!
//! センチネル終端配列は配列の末尾に特定の値（センチネル）を持つ。
//! C言語のヌル終端文字列と互換性がある。
//!
//! ## 型の表記
//! - [N:S]T: サイズN、センチネルS、要素型T
//! - [:S]T: サイズ不明のセンチネル終端スライス
//!
//! ## 用途
//! - C言語との連携
//! - 終端を示す明示的なマーカー

const std = @import("std");

// ====================
// 基本的なセンチネル終端配列
// ====================

fn demoBasic() void {
    std.debug.print("--- 基本的なセンチネル終端配列 ---\n", .{});

    // 文字列リテラルはセンチネル終端配列へのポインタ
    const str = "Hello";

    // 型を確認: *const [5:0]u8
    std.debug.print("  文字列: {s}\n", .{str});
    std.debug.print("  型: {}\n", .{@TypeOf(str)});
    std.debug.print("  長さ: {d}\n", .{str.len});

    // センチネル値（0）にアクセス
    std.debug.print("  str[5] (センチネル): {d}\n", .{str[5]});

    // 明示的なセンチネル終端配列
    const arr: [3:0]u8 = .{ 'A', 'B', 'C' };
    std.debug.print("  配列: {s}, センチネル: {d}\n", .{ &arr, arr[3] });

    std.debug.print("\n", .{});
}

// ====================
// センチネル終端スライス
// ====================

fn demoSentinelSlice() void {
    std.debug.print("--- センチネル終端スライス ---\n", .{});

    const str = "Hello, World!";

    // 通常のスライスに変換（センチネル情報を失う）
    const slice: []const u8 = str;
    std.debug.print("  スライス: {s}\n", .{slice});

    // センチネル終端スライス（センチネル情報を保持）
    const sentinel_slice: [:0]const u8 = str;
    std.debug.print("  センチネル終端スライス: {s}\n", .{sentinel_slice});
    std.debug.print("  センチネル値: {d}\n", .{sentinel_slice[sentinel_slice.len]});

    std.debug.print("\n", .{});
}

// ====================
// カスタムセンチネル値
// ====================

fn demoCustomSentinel() void {
    std.debug.print("--- カスタムセンチネル値 ---\n", .{});

    // 0xFFをセンチネルとして使用
    const arr: [4:0xFF]u8 = .{ 1, 2, 3, 4 };
    std.debug.print("  配列: ", .{});
    for (arr) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});
    std.debug.print("  センチネル (0xFF): {d}\n", .{arr[4]});

    // -1をセンチネルとして使用（i32）
    const int_arr: [3:-1]i32 = .{ 10, 20, 30 };
    std.debug.print("  i32配列のセンチネル: {d}\n", .{int_arr[3]});

    std.debug.print("\n", .{});
}

// ====================
// センチネルでの反復
// ====================

fn demoIteration() void {
    std.debug.print("--- センチネルでの反復 ---\n", .{});

    const str: [:0]const u8 = "Zig";

    // 通常のfor（長さベース）
    std.debug.print("  長さベース: ", .{});
    for (str) |c| {
        std.debug.print("{c} ", .{c});
    }
    std.debug.print("\n", .{});

    // センチネルを含めたアクセス
    std.debug.print("  センチネル含む: ", .{});
    var i: usize = 0;
    while (str[i] != 0) : (i += 1) {
        std.debug.print("{c} ", .{str[i]});
    }
    std.debug.print("(終端: {d})\n", .{str[i]});

    std.debug.print("\n", .{});
}

// ====================
// Cとの互換性
// ====================

fn demoCCompatibility() void {
    std.debug.print("--- Cとの互換性 ---\n", .{});

    const zig_str: [:0]const u8 = "C compatible";

    // センチネル終端スライスからCポインタへ
    const c_str: [*:0]const u8 = zig_str.ptr;
    _ = c_str; // Cの関数に渡せる

    std.debug.print("  Zig文字列: {s}\n", .{zig_str});
    std.debug.print("  → C関数に渡す: [*:0]const u8\n", .{});

    // 逆変換も可能
    std.debug.print("  ← Cから受け取る: std.mem.span()\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スライスからセンチネル終端への変換
// ====================

fn demoConversion() !void {
    std.debug.print("--- スライスの変換 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 通常のスライス
    const slice: []const u8 = "Hello";

    // センチネル終端スライスに変換（allocatorが必要）
    const sentinel = try allocator.dupeZ(u8, slice);
    defer allocator.free(sentinel);

    std.debug.print("  元のスライス: {s}\n", .{slice});
    std.debug.print("  センチネル終端: {s}\n", .{sentinel});
    std.debug.print("  センチネル値: {d}\n", .{sentinel[sentinel.len]});

    std.debug.print("\n", .{});
}

// ====================
// 多次元センチネル配列
// ====================

fn demoMultiDimensional() void {
    std.debug.print("--- 多次元センチネル ---\n", .{});

    // 文字列リテラルの配列（各要素がセンチネル終端）
    const strings: []const [:0]const u8 = &.{
        "one",
        "two",
        "three",
    };

    for (strings, 0..) |s, i| {
        std.debug.print("  strings[{d}]: {s} (len={d})\n", .{ i, s, s.len });
    }

    std.debug.print("\n", .{});
}

// ====================
// @ptrCastとセンチネル
// ====================

fn demoPointerCast() void {
    std.debug.print("--- ポインタキャスト ---\n", .{});

    const str: [:0]const u8 = "Test";

    // センチネル終端ポインタ
    const sentinel_ptr: [*:0]const u8 = str.ptr;

    // 通常のポインタ（長さなし）
    const raw_ptr: [*]const u8 = str.ptr;

    std.debug.print("  センチネル終端ポインタ: 終端まで安全に読める\n", .{});
    std.debug.print("  通常のポインタ: 長さを別途管理が必要\n", .{});

    // sentinel_ptrは終端まで読める
    var len: usize = 0;
    while (sentinel_ptr[len] != 0) : (len += 1) {}
    std.debug.print("  計測した長さ: {d}\n", .{len});

    _ = raw_ptr;

    std.debug.print("\n", .{});
}

// ====================
// 実用例: コマンドライン引数
// ====================

fn demoCmdArgs() void {
    std.debug.print("--- コマンドライン引数の例 ---\n", .{});

    // 実際のコマンドライン引数は [][*:0]u8 型
    // 各引数がセンチネル終端

    // シミュレーション
    const args: []const [:0]const u8 = &.{
        "program",
        "--flag",
        "value",
    };

    std.debug.print("  argc: {d}\n", .{args.len});
    for (args, 0..) |arg, i| {
        std.debug.print("  argv[{d}]: {s}\n", .{ i, arg });
    }

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== センチネル終端配列 ===\n\n", .{});

    demoBasic();
    demoSentinelSlice();
    demoCustomSentinel();
    demoIteration();
    demoCCompatibility();
    try demoConversion();
    demoMultiDimensional();
    demoPointerCast();
    demoCmdArgs();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・[N:S]T: サイズN、センチネルS、要素型T\n", .{});
    std.debug.print("・[:S]T: センチネル終端スライス\n", .{});
    std.debug.print("・[*:S]T: センチネル終端ポインタ\n", .{});
    std.debug.print("・文字列リテラルは [N:0]u8\n", .{});
    std.debug.print("・C連携に便利\n", .{});
}

// --- テスト ---

test "string literal type" {
    const str = "Hello";
    try std.testing.expectEqual(*const [5:0]u8, @TypeOf(str));
    try std.testing.expectEqual(@as(u8, 0), str[5]);
}

test "sentinel array" {
    const arr: [3:0]u8 = .{ 'A', 'B', 'C' };
    try std.testing.expectEqual(@as(u8, 0), arr[3]);
    try std.testing.expectEqual(@as(usize, 3), arr.len);
}

test "custom sentinel" {
    const arr: [2:255]u8 = .{ 1, 2 };
    try std.testing.expectEqual(@as(u8, 255), arr[2]);
}

test "sentinel slice" {
    const str: [:0]const u8 = "Test";
    try std.testing.expectEqual(@as(usize, 4), str.len);
    try std.testing.expectEqual(@as(u8, 0), str[4]);
}

test "convert to sentinel terminated" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const slice: []const u8 = "abc";
    const sentinel = try allocator.dupeZ(u8, slice);
    defer allocator.free(sentinel);

    try std.testing.expectEqual(@as(usize, 3), sentinel.len);
    try std.testing.expectEqual(@as(u8, 0), sentinel[3]);
}

test "sentinel pointer iteration" {
    const str: [:0]const u8 = "Zig";
    const ptr: [*:0]const u8 = str.ptr;

    var len: usize = 0;
    while (ptr[len] != 0) : (len += 1) {}

    try std.testing.expectEqual(@as(usize, 3), len);
}

test "mem.span from sentinel pointer" {
    const str: [:0]const u8 = "Hello";
    const ptr: [*:0]const u8 = str.ptr;

    const span = std.mem.span(ptr);
    try std.testing.expect(std.mem.eql(u8, span, "Hello"));
}

test "negative sentinel" {
    const arr: [2:-1]i32 = .{ 10, 20 };
    try std.testing.expectEqual(@as(i32, -1), arr[2]);
}
