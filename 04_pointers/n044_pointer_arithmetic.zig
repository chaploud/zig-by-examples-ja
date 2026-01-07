//! # ポインタ演算
//!
//! Zigでは複数要素ポインタ [*]T でポインタ演算が可能。
//! 単一要素ポインタ *T ではポインタ演算は不可。
//!
//! ## 操作
//! - ptr + n: nバイト先へ移動
//! - ptr - n: nバイト前へ移動
//! - @intFromPtr: ポインタを整数に変換
//! - @ptrFromInt: 整数をポインタに変換
//!
//! ## 注意
//! - 境界チェックなし
//! - 型のサイズ分だけ移動

const std = @import("std");

// ====================
// 基本的なポインタ演算
// ====================

fn demoBasicArithmetic() void {
    std.debug.print("--- 基本的なポインタ演算 ---\n", .{});

    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    const ptr: [*]i32 = &arr;

    std.debug.print("  ptr[0] = {d}\n", .{ptr[0]});
    std.debug.print("  ptr[2] = {d}\n", .{ptr[2]});

    // ポインタを進める
    const ptr_plus_2 = ptr + 2;
    std.debug.print("  (ptr + 2)[0] = {d}\n", .{ptr_plus_2[0]});

    // ポインタを戻す
    const ptr_minus_1 = ptr_plus_2 - 1;
    std.debug.print("  (ptr + 2 - 1)[0] = {d}\n", .{ptr_minus_1[0]});

    std.debug.print("\n", .{});
}

// ====================
// ポインタの減算
// ====================

fn demoPointerSubtraction() void {
    std.debug.print("--- ポインタの減算 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const start: [*]i32 = &arr;
    const end: [*]i32 = start + 5;

    // ポインタ間の要素数を計算
    const diff_ptr = @intFromPtr(end) - @intFromPtr(start);
    const element_count = diff_ptr / @sizeOf(i32);

    std.debug.print("  start: 0x{x}\n", .{@intFromPtr(start)});
    std.debug.print("  end: 0x{x}\n", .{@intFromPtr(end)});
    std.debug.print("  バイト差: {d}\n", .{diff_ptr});
    std.debug.print("  要素数: {d}\n", .{element_count});

    std.debug.print("\n", .{});
}

// ====================
// @intFromPtr と @ptrFromInt
// ====================

fn demoIntPtrConversion() void {
    std.debug.print("--- @intFromPtr と @ptrFromInt ---\n", .{});

    var value: u32 = 0xDEADBEEF;
    const ptr: *u32 = &value;

    // ポインタ → 整数
    const addr = @intFromPtr(ptr);
    std.debug.print("  @intFromPtr: 0x{x}\n", .{addr});

    // 整数 → ポインタ
    const restored: *u32 = @ptrFromInt(addr);
    std.debug.print("  @ptrFromInt: 0x{x}\n", .{restored.*});

    // 計算して新しいアドレスを作成（危険な操作）
    std.debug.print("  → 通常は直接使用を避ける\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// バイト単位のアクセス
// ====================

fn demoByteAccess() void {
    std.debug.print("--- バイト単位のアクセス ---\n", .{});

    var value: u32 = 0x12345678;

    // バイトポインタとしてアクセス
    const bytes: [*]u8 = @ptrCast(&value);

    std.debug.print("  u32値: 0x{x}\n", .{value});
    std.debug.print("  バイト表現: ", .{});
    for (0..4) |i| {
        std.debug.print("0x{x} ", .{bytes[i]});
    }
    std.debug.print("\n", .{});
    std.debug.print("  → リトルエンディアン順\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 配列走査
// ====================

fn demoArrayTraversal() void {
    std.debug.print("--- 配列走査 ---\n", .{});

    var arr = [_]i32{ 100, 200, 300, 400, 500 };
    const ptr: [*]i32 = &arr;
    const end = ptr + arr.len;

    std.debug.print("  ポインタ演算で走査: ", .{});
    var current = ptr;
    while (@intFromPtr(current) < @intFromPtr(end)) {
        std.debug.print("{d} ", .{current[0]});
        current = current + 1;
    }
    std.debug.print("\n", .{});

    // 比較: forループ
    std.debug.print("  forループ: ", .{});
    for (&arr) |*item| {
        std.debug.print("{d} ", .{item.*});
    }
    std.debug.print("\n", .{});

    std.debug.print("  → forループの方が安全で推奨\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 型サイズとオフセット
// ====================

fn demoTypeSizeOffset() void {
    std.debug.print("--- 型サイズとオフセット ---\n", .{});

    const S = struct {
        a: u8,
        b: u32,
        c: u16,
    };

    std.debug.print("  struct S:\n", .{});
    std.debug.print("    @sizeOf(S) = {d}\n", .{@sizeOf(S)});
    std.debug.print("    @alignOf(S) = {d}\n", .{@alignOf(S)});
    std.debug.print("    @offsetOf(S, \"a\") = {d}\n", .{@offsetOf(S, "a")});
    std.debug.print("    @offsetOf(S, \"b\") = {d}\n", .{@offsetOf(S, "b")});
    std.debug.print("    @offsetOf(S, \"c\") = {d}\n", .{@offsetOf(S, "c")});

    // 配列の場合
    std.debug.print("  配列 [5]i32:\n", .{});
    std.debug.print("    要素サイズ: {d} bytes\n", .{@sizeOf(i32)});
    std.debug.print("    配列サイズ: {d} bytes\n", .{@sizeOf([5]i32)});

    std.debug.print("\n", .{});
}

// ====================
// スライスとの関係
// ====================

fn demoSliceRelation() void {
    std.debug.print("--- スライスとの関係 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr: [*]i32 = &arr;

    // ポインタ演算でスライスを作成
    const slice_0_3 = ptr[0..3];
    const slice_2_5 = ptr[2..5];

    std.debug.print("  ptr[0..3]: ", .{});
    for (slice_0_3) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    std.debug.print("  ptr[2..5]: ", .{});
    for (slice_2_5) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    // スライスのptr/len
    std.debug.print("  slice.ptr と slice.len:\n", .{});
    const slice = ptr[0..5];
    std.debug.print("    ptr: 0x{x}\n", .{@intFromPtr(slice.ptr)});
    std.debug.print("    len: {d}\n", .{slice.len});

    std.debug.print("\n", .{});
}

// ====================
// 安全でない操作
// ====================

fn demoUnsafeOperations() void {
    std.debug.print("--- 安全でない操作 ---\n", .{});

    std.debug.print("  危険な操作:\n", .{});
    std.debug.print("    - 境界外アクセス: ptr[out_of_bounds]\n", .{});
    std.debug.print("    - 無効なアドレス: @ptrFromInt(0)\n", .{});
    std.debug.print("    - ダングリングポインタ\n", .{});
    std.debug.print("    - 型の不整合キャスト\n", .{});

    std.debug.print("  安全な代替:\n", .{});
    std.debug.print("    - スライス []T で境界チェック\n", .{});
    std.debug.print("    - Optionalポインタ ?*T\n", .{});
    std.debug.print("    - forループで走査\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// C互換のポインタ演算
// ====================

fn demoCCompatible() void {
    std.debug.print("--- C互換のポインタ演算 ---\n", .{});

    var arr = [_]c_int{ 10, 20, 30 };

    // Cポインタ（nullを許容）
    const c_ptr: [*c]c_int = &arr;

    std.debug.print("  [*c]c_int:\n", .{});
    std.debug.print("    c_ptr[0] = {d}\n", .{c_ptr[0]});
    std.debug.print("    (c_ptr + 1)[0] = {d}\n", .{(c_ptr + 1)[0]});

    // Cライブラリとの連携パターン
    std.debug.print("  Cライブラリ連携:\n", .{});
    std.debug.print("    - 関数引数で [*c]T を使用\n", .{});
    std.debug.print("    - 長さは別途渡す\n", .{});
    std.debug.print("    - null終端を確認\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// メモリコピーでの使用
// ====================

fn demoMemoryCopy() void {
    std.debug.print("--- メモリコピーでの使用 ---\n", .{});

    var src = [_]u8{ 'H', 'e', 'l', 'l', 'o' };
    var dst: [5]u8 = undefined;

    // ポインタ演算でコピー
    const src_ptr: [*]const u8 = &src;
    const dst_ptr: [*]u8 = &dst;

    for (0..5) |i| {
        dst_ptr[i] = src_ptr[i];
    }

    std.debug.print("  手動コピー: {s}\n", .{&dst});

    // @memcpy を使う方が安全
    var dst2: [5]u8 = undefined;
    @memcpy(&dst2, &src);
    std.debug.print("  @memcpy: {s}\n", .{&dst2});

    std.debug.print("  → @memcpyを推奨\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ポインタ演算 ===\n\n", .{});

    demoBasicArithmetic();
    demoPointerSubtraction();
    demoIntPtrConversion();
    demoByteAccess();
    demoArrayTraversal();
    demoTypeSizeOffset();
    demoSliceRelation();
    demoUnsafeOperations();
    demoCCompatible();
    demoMemoryCopy();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・[*]T でのみポインタ演算可能\n", .{});
    std.debug.print("・*T では演算不可\n", .{});
    std.debug.print("・@intFromPtr/@ptrFromInt で変換\n", .{});
    std.debug.print("・可能な限りスライスを使用\n", .{});
}

// --- テスト ---

test "pointer addition" {
    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    const ptr: [*]i32 = &arr;

    try std.testing.expectEqual(@as(i32, 10), ptr[0]);
    try std.testing.expectEqual(@as(i32, 30), (ptr + 2)[0]);
    try std.testing.expectEqual(@as(i32, 50), (ptr + 4)[0]);
}

test "pointer subtraction" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr: [*]i32 = &arr;
    const ptr3 = ptr + 3;

    try std.testing.expectEqual(@as(i32, 4), ptr3[0]);
    try std.testing.expectEqual(@as(i32, 3), (ptr3 - 1)[0]);
}

test "intFromPtr and ptrFromInt" {
    var value: u32 = 12345;
    const ptr: *u32 = &value;

    const addr = @intFromPtr(ptr);
    const restored: *u32 = @ptrFromInt(addr);

    try std.testing.expectEqual(@as(u32, 12345), restored.*);
}

test "byte access" {
    var value: u32 = 0x01020304;
    const bytes: [*]const u8 = @ptrCast(&value);

    // リトルエンディアンを仮定
    try std.testing.expectEqual(@as(u8, 0x04), bytes[0]);
    try std.testing.expectEqual(@as(u8, 0x03), bytes[1]);
    try std.testing.expectEqual(@as(u8, 0x02), bytes[2]);
    try std.testing.expectEqual(@as(u8, 0x01), bytes[3]);
}

test "pointer to slice" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr: [*]i32 = &arr;

    const slice = ptr[1..4];
    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 2), slice[0]);
    try std.testing.expectEqual(@as(i32, 4), slice[2]);
}

test "offsetOf" {
    // extern structは確定的なレイアウト
    const S = extern struct {
        a: u8,
        _pad: [3]u8 = undefined,
        b: u32,
        c: u16,
    };

    try std.testing.expectEqual(@as(usize, 0), @offsetOf(S, "a"));
    // b は4バイト目から
    try std.testing.expectEqual(@as(usize, 4), @offsetOf(S, "b"));
}

test "pointer traversal" {
    var arr = [_]i32{ 1, 2, 3 };
    const ptr: [*]i32 = &arr;
    const end = ptr + 3;

    var sum: i32 = 0;
    var current = ptr;
    while (@intFromPtr(current) < @intFromPtr(end)) {
        sum += current[0];
        current = current + 1;
    }

    try std.testing.expectEqual(@as(i32, 6), sum);
}

test "c pointer arithmetic" {
    var arr = [_]c_int{ 100, 200, 300 };
    const c_ptr: [*c]c_int = &arr;

    try std.testing.expectEqual(@as(c_int, 100), c_ptr[0]);
    try std.testing.expectEqual(@as(c_int, 200), (c_ptr + 1)[0]);
    try std.testing.expectEqual(@as(c_int, 300), (c_ptr + 2)[0]);
}
