//! # ポインタ変換（Coercion）
//!
//! Zigでは異なるポインタ型間の変換にルールがある。
//! 安全な変換は暗黙的、危険な変換は明示的キャストが必要。
//!
//! ## 暗黙的変換
//! - *T → *const T（可変→定数）
//! - *[N]T → []T（配列→スライス）
//! - *[N]T → [*]T（配列→複数要素）
//!
//! ## 明示的変換
//! - @ptrCast: ポインタ型変換
//! - @alignCast: アライメント変換

const std = @import("std");

// ====================
// 暗黙的変換: *T → *const T
// ====================

fn demoMutableToConst() void {
    std.debug.print("--- *T → *const T ---\n", .{});

    var value: u32 = 42;
    const mutable_ptr: *u32 = &value;

    // *u32 → *const u32 は暗黙的に変換可能
    const const_ptr: *const u32 = mutable_ptr;

    std.debug.print("  mutable_ptr.* = {d}\n", .{mutable_ptr.*});
    std.debug.print("  const_ptr.* = {d}\n", .{const_ptr.*});

    // 関数に渡す場合も暗黙的に変換
    printValue(mutable_ptr); // *u32 → *const u32

    std.debug.print("  → 可変から定数への変換は常に安全\n", .{});

    std.debug.print("\n", .{});
}

fn printValue(ptr: *const u32) void {
    std.debug.print("  printValue: {d}\n", .{ptr.*});
}

// ====================
// 暗黙的変換: *[N]T → []T
// ====================

fn demoArrayToSlice() void {
    std.debug.print("--- *[N]T → []T ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const arr_ptr: *[5]i32 = &arr;

    // *[5]i32 → []i32 は暗黙的に変換可能
    const slice: []i32 = arr_ptr;

    std.debug.print("  arr_ptr: *[5]i32\n", .{});
    std.debug.print("  slice: []i32, len={d}\n", .{slice.len});

    // スライスを受け取る関数に渡せる
    printSlice(arr_ptr);

    std.debug.print("  → 配列からスライスへは長さ情報が保持される\n", .{});

    std.debug.print("\n", .{});
}

fn printSlice(s: []const i32) void {
    std.debug.print("  printSlice: ", .{});
    for (s) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});
}

// ====================
// 暗黙的変換: *[N]T → [*]T
// ====================

fn demoArrayToMultiPointer() void {
    std.debug.print("--- *[N]T → [*]T ---\n", .{});

    const arr = [_]i32{ 10, 20, 30 };
    const arr_ptr: *const [3]i32 = &arr;

    // *[3]i32 → [*]i32 は暗黙的に変換可能
    const multi_ptr: [*]const i32 = arr_ptr;

    std.debug.print("  arr_ptr: *const [3]i32\n", .{});
    std.debug.print("  multi_ptr: [*]const i32\n", .{});
    std.debug.print("  multi_ptr[0] = {d}\n", .{multi_ptr[0]});
    std.debug.print("  multi_ptr[2] = {d}\n", .{multi_ptr[2]});

    std.debug.print("  → 長さ情報は失われる（C互換）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スライス ↔ ポインタ
// ====================

fn demoSlicePointerConversion() void {
    std.debug.print("--- スライス ↔ ポインタ ---\n", .{});

    const arr = [_]u8{ 'H', 'e', 'l', 'l', 'o' };
    const slice: []const u8 = &arr;

    // スライスから複数要素ポインタを取得
    const ptr: [*]const u8 = slice.ptr;
    std.debug.print("  slice.ptr: [*]const u8\n", .{});
    std.debug.print("  ptr[0..3]: ", .{});
    for (0..3) |i| {
        std.debug.print("{c}", .{ptr[i]});
    }
    std.debug.print("\n", .{});

    // 複数要素ポインタからスライスを作成
    const restored: []const u8 = ptr[0..slice.len];
    std.debug.print("  restored: {s}\n", .{restored});

    std.debug.print("  → slice.ptrで内部ポインタにアクセス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @ptrCast: ポインタ型変換
// ====================

fn demoPtrCast() void {
    std.debug.print("--- @ptrCast ---\n", .{});

    // バイト配列を別の型として解釈
    const bytes align(@alignOf(u32)) = [_]u8{ 0x78, 0x56, 0x34, 0x12 };
    const u32_ptr: *const u32 = @ptrCast(&bytes);

    std.debug.print("  bytes: 0x78, 0x56, 0x34, 0x12\n", .{});
    std.debug.print("  u32として: 0x{x}\n", .{u32_ptr.*});

    // void*相当の操作
    var value: i32 = 12345;
    const any_ptr: *anyopaque = &value;
    const restored: *i32 = @ptrCast(@alignCast(any_ptr));
    std.debug.print("  anyopaque経由: {d}\n", .{restored.*});

    std.debug.print("  → 型を超えた再解釈、危険な操作\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @alignCast: アライメント変換
// ====================

fn demoAlignCast() void {
    std.debug.print("--- @alignCast ---\n", .{});

    // アライメントを緩和したポインタ
    var arr align(8) = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const aligned_ptr: *align(8) [8]u8 = &arr;

    // 低いアライメントへは暗黙的に変換可能
    const less_aligned: *align(1) [8]u8 = aligned_ptr;
    _ = less_aligned;
    std.debug.print("  align(8) → align(1): 暗黙的OK\n", .{});

    // 高いアライメントへは@alignCastが必要
    const low_ptr: *align(1) u8 = &arr[0];
    // 実際のアドレスがalign(4)を満たすか実行時チェック
    const high_ptr: *align(4) u8 = @alignCast(low_ptr);
    std.debug.print("  align(1) → align(4): @alignCast必要, value={d}\n", .{high_ptr.*});

    std.debug.print("  → アライメント保証が必要な場合に使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optional ↔ 非Optional
// ====================

fn demoOptionalConversion() void {
    std.debug.print("--- Optional ↔ 非Optional ---\n", .{});

    var value: u32 = 100;
    const ptr: *u32 = &value;

    // *T → ?*T は暗黙的に変換可能
    const opt_ptr: ?*u32 = ptr;
    std.debug.print("  *T → ?*T: 暗黙的OK\n", .{});

    // ?*T → *T はunwrapが必要
    if (opt_ptr) |p| {
        std.debug.print("  ?*T → *T: unwrapで {d}\n", .{p.*});
    }

    // orelse で非nullを保証
    const unwrapped = opt_ptr orelse unreachable;
    std.debug.print("  orelse: {d}\n", .{unwrapped.*});

    std.debug.print("\n", .{});
}

// ====================
// センチネル変換
// ====================

fn demoSentinelConversion() void {
    std.debug.print("--- センチネル変換 ---\n", .{});

    // ゼロ終端文字列
    const c_str: [:0]const u8 = "Hello";

    // [:0]T → []T は暗黙的に変換可能
    const slice: []const u8 = c_str;
    std.debug.print("  [:0]u8 → []u8: 暗黙的OK, len={d}\n", .{slice.len});

    // [:0]T → [*:0]T も可能
    const many_ptr: [*:0]const u8 = c_str.ptr;
    std.debug.print("  [:0]u8 → [*:0]u8: {s}\n", .{many_ptr});

    // []T → [:0]T は不可（センチネルの保証がない）
    // const sentinel: [:0]const u8 = slice; // エラー

    std.debug.print("  → センチネル付き→なしは安全、逆は不可\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 変換ルールまとめ
// ====================

fn demoConversionSummary() void {
    std.debug.print("--- 変換ルールまとめ ---\n", .{});

    std.debug.print("  暗黙的（安全）:\n", .{});
    std.debug.print("    *T → *const T\n", .{});
    std.debug.print("    *[N]T → []T\n", .{});
    std.debug.print("    *[N]T → [*]T\n", .{});
    std.debug.print("    [:s]T → []T\n", .{});
    std.debug.print("    *T → ?*T\n", .{});
    std.debug.print("    高align → 低align\n", .{});

    std.debug.print("  明示的（@ptrCast/@alignCast）:\n", .{});
    std.debug.print("    異なる型間のポインタ変換\n", .{});
    std.debug.print("    低align → 高align\n", .{});
    std.debug.print("    *anyopaque → *T\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ポインタ変換（Coercion） ===\n\n", .{});

    demoMutableToConst();
    demoArrayToSlice();
    demoArrayToMultiPointer();
    demoSlicePointerConversion();
    demoPtrCast();
    demoAlignCast();
    demoOptionalConversion();
    demoSentinelConversion();
    demoConversionSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・安全な変換は暗黙的に行われる\n", .{});
    std.debug.print("・危険な変換は@ptrCast/@alignCast\n", .{});
    std.debug.print("・センチネル付き→なしは安全\n", .{});
    std.debug.print("・アライメント緩和は安全、強化は危険\n", .{});
}

// --- テスト ---

test "mutable to const pointer" {
    var val: u32 = 42;
    const mutable_ptr: *u32 = &val;
    const const_ptr: *const u32 = mutable_ptr;

    try std.testing.expectEqual(@as(u32, 42), const_ptr.*);
}

test "array pointer to slice" {
    var arr = [_]i32{ 1, 2, 3 };
    const arr_ptr: *[3]i32 = &arr;
    const slice: []i32 = arr_ptr;

    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 1), slice[0]);
}

test "array pointer to multi pointer" {
    const arr = [_]i32{ 10, 20, 30 };
    const arr_ptr: *const [3]i32 = &arr;
    const multi_ptr: [*]const i32 = arr_ptr;

    try std.testing.expectEqual(@as(i32, 10), multi_ptr[0]);
    try std.testing.expectEqual(@as(i32, 30), multi_ptr[2]);
}

test "slice to multi pointer" {
    const arr = [_]u8{ 1, 2, 3, 4, 5 };
    const slice: []const u8 = &arr;
    const ptr: [*]const u8 = slice.ptr;

    try std.testing.expectEqual(@as(u8, 1), ptr[0]);
    try std.testing.expectEqual(@as(u8, 3), ptr[2]);
}

test "ptrCast bytes to u32" {
    const bytes align(@alignOf(u32)) = [_]u8{ 0x01, 0x00, 0x00, 0x00 };
    const u32_ptr: *const u32 = @ptrCast(&bytes);

    try std.testing.expectEqual(@as(u32, 1), u32_ptr.*);
}

test "alignCast" {
    var arr align(8) = [_]u8{ 42, 0, 0, 0, 0, 0, 0, 0 };
    const low_ptr: *align(1) u8 = &arr[0];
    const high_ptr: *align(4) u8 = @alignCast(low_ptr);

    try std.testing.expectEqual(@as(u8, 42), high_ptr.*);
}

test "optional pointer conversion" {
    var val: u32 = 100;
    const ptr: *u32 = &val;
    const opt_ptr: ?*u32 = ptr;

    try std.testing.expect(opt_ptr != null);
    try std.testing.expectEqual(@as(u32, 100), opt_ptr.?.*);
}

test "sentinel slice to regular slice" {
    const sentinel: [:0]const u8 = "test";
    const slice: []const u8 = sentinel;

    try std.testing.expectEqual(@as(usize, 4), slice.len);
    try std.testing.expect(std.mem.eql(u8, "test", slice));
}

test "anyopaque roundtrip" {
    var val: i32 = 999;
    const any_ptr: *anyopaque = &val;
    const restored: *i32 = @ptrCast(@alignCast(any_ptr));

    try std.testing.expectEqual(@as(i32, 999), restored.*);
}
