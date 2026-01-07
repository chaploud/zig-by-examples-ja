//! # 複数要素ポインタ（Multi-item Pointers）
//!
//! 複数要素ポインタ [*]T は、未知の長さの配列を指す。
//! C言語のポインタに相当し、ポインタ演算が可能。
//!
//! ## 種類
//! - [*]T: 複数要素へのポインタ
//! - [*:x]T: センチネル終端の複数要素ポインタ
//!
//! ## 特徴
//! - 長さ情報を持たない
//! - ポインタ演算が可能
//! - スライスへ変換可能

const std = @import("std");

// ====================
// 基本的な複数要素ポインタ
// ====================

fn demoBasicMultiPointer() void {
    std.debug.print("--- 基本的な複数要素ポインタ ---\n", .{});

    var arr = [_]i32{ 10, 20, 30, 40, 50 };

    // 配列から複数要素ポインタを取得
    const multi_ptr: [*]i32 = &arr;

    std.debug.print("  arr: ", .{});
    for (0..5) |i| {
        std.debug.print("{d} ", .{multi_ptr[i]});
    }
    std.debug.print("\n", .{});

    // インデックスアクセス
    std.debug.print("  multi_ptr[0] = {d}\n", .{multi_ptr[0]});
    std.debug.print("  multi_ptr[4] = {d}\n", .{multi_ptr[4]});

    std.debug.print("\n", .{});
}

// ====================
// ポインタ演算
// ====================

fn demoPointerArithmetic() void {
    std.debug.print("--- ポインタ演算 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr: [*]i32 = &arr;

    std.debug.print("  ptr[0] = {d}\n", .{ptr[0]});

    // ポインタを進める
    const ptr2 = ptr + 2;
    std.debug.print("  (ptr + 2)[0] = {d}\n", .{ptr2[0]});

    // ポインタを戻す
    const ptr3 = ptr2 - 1;
    std.debug.print("  (ptr + 2 - 1)[0] = {d}\n", .{ptr3[0]});

    // ポインタ間の差
    const diff = @intFromPtr(ptr2) - @intFromPtr(ptr);
    std.debug.print("  ポインタ間のバイト差: {d}\n", .{diff});

    std.debug.print("\n", .{});
}

// ====================
// スライスへの変換
// ====================

fn demoToSlice() void {
    std.debug.print("--- スライスへの変換 ---\n", .{});

    var arr = [_]i32{ 100, 200, 300, 400, 500 };
    const ptr: [*]i32 = &arr;

    // スライスに変換（長さを指定）
    const slice: []i32 = ptr[0..5];

    std.debug.print("  slice.len = {d}\n", .{slice.len});
    std.debug.print("  slice: ", .{});
    for (slice) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    // 部分スライス
    const partial = ptr[1..4];
    std.debug.print("  ptr[1..4]: ", .{});
    for (partial) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// センチネル終端ポインタ
// ====================

fn demoSentinelPointer() void {
    std.debug.print("--- センチネル終端ポインタ ---\n", .{});

    // null終端文字列
    const str: [*:0]const u8 = "Hello";

    std.debug.print("  文字列: ", .{});
    var i: usize = 0;
    while (str[i] != 0) : (i += 1) {
        std.debug.print("{c}", .{str[i]});
    }
    std.debug.print("\n", .{});

    // スライスに変換
    const slice = std.mem.span(str);
    std.debug.print("  span後: {s} (len={d})\n", .{ slice, slice.len });

    // センチネル終端配列
    const arr: [*:0]const i32 = &[_:0]i32{ 1, 2, 3 };
    std.debug.print("  センチネル配列: ", .{});
    var j: usize = 0;
    while (arr[j] != 0) : (j += 1) {
        std.debug.print("{d} ", .{arr[j]});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 単一要素ポインタとの違い
// ====================

fn demoSingleVsMulti() void {
    std.debug.print("--- 単一要素 vs 複数要素ポインタ ---\n", .{});

    var arr = [_]i32{ 10, 20, 30 };

    // 単一要素ポインタ（配列全体）
    const single: *[3]i32 = &arr;

    // 複数要素ポインタ
    const multi: [*]i32 = &arr;

    std.debug.print("  *[3]i32:\n", .{});
    std.debug.print("    - 長さが型に含まれる\n", .{});
    std.debug.print("    - single.len = {d}\n", .{single.len});
    std.debug.print("    - ポインタ演算不可\n", .{});

    std.debug.print("  [*]i32:\n", .{});
    std.debug.print("    - 長さ情報なし\n", .{});
    std.debug.print("    - ポインタ演算可能\n", .{});
    std.debug.print("    - multi[0] = {d}\n", .{multi[0]});

    std.debug.print("\n", .{});
}

// ====================
// @typeInfo で確認
// ====================

fn demoTypeInfo() void {
    std.debug.print("--- @typeInfo で確認 ---\n", .{});

    const SinglePtr = *i32;
    const MultiPtr = [*]i32;
    const SentinelPtr = [*:0]i32;

    const single_info = @typeInfo(SinglePtr).pointer;
    const multi_info = @typeInfo(MultiPtr).pointer;
    const sentinel_info = @typeInfo(SentinelPtr).pointer;

    std.debug.print("  *i32:\n", .{});
    std.debug.print("    size: {s}\n", .{@tagName(single_info.size)});

    std.debug.print("  [*]i32:\n", .{});
    std.debug.print("    size: {s}\n", .{@tagName(multi_info.size)});

    std.debug.print("  [*:0]i32:\n", .{});
    std.debug.print("    size: {s}\n", .{@tagName(sentinel_info.size)});
    std.debug.print("    sentinel: あり\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Cポインタとの関係
// ====================

fn demoCPointerRelation() void {
    std.debug.print("--- Cポインタとの関係 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3 };

    // Cポインタ型（C互換）
    const c_ptr: [*c]i32 = &arr;

    std.debug.print("  [*c]i32: C互換ポインタ\n", .{});
    std.debug.print("    - nullを許可\n", .{});
    std.debug.print("    - allowzeroと同等\n", .{});
    std.debug.print("    c_ptr[0] = {d}\n", .{c_ptr[0]});

    // [*]T への変換
    const multi: [*]i32 = c_ptr;
    std.debug.print("  [*c]i32 → [*]i32: 変換可能\n", .{});
    std.debug.print("    multi[0] = {d}\n", .{multi[0]});

    std.debug.print("\n", .{});
}

// ====================
// メモリ操作での使用
// ====================

fn demoMemoryOperations() void {
    std.debug.print("--- メモリ操作での使用 ---\n", .{});

    var src = [_]u8{ 'H', 'e', 'l', 'l', 'o' };
    var dst: [5]u8 = undefined;

    const src_ptr: [*]const u8 = &src;
    const dst_ptr: [*]u8 = &dst;

    // 手動コピー
    for (0..5) |i| {
        dst_ptr[i] = src_ptr[i];
    }

    std.debug.print("  コピー結果: {s}\n", .{&dst});

    // std.mem.copyForwards との比較
    var dst2: [5]u8 = undefined;
    @memcpy(&dst2, &src);
    std.debug.print("  @memcpy結果: {s}\n", .{&dst2});

    std.debug.print("\n", .{});
}

// ====================
// 配列との変換
// ====================

fn demoArrayConversion() void {
    std.debug.print("--- 配列との変換 ---\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    // 配列 → 複数要素ポインタ（暗黙的）
    const ptr: [*]const i32 = &arr;
    std.debug.print("  [5]i32 → [*]const i32: 暗黙的変換\n", .{});
    std.debug.print("    ptr[2] = {d}\n", .{ptr[2]});

    // 複数要素ポインタ → スライス（長さ指定）
    const slice = ptr[0..5];
    std.debug.print("  [*]const i32 → []const i32: 長さ指定で変換\n", .{});
    std.debug.print("    slice.len = {d}\n", .{slice.len});

    std.debug.print("\n", .{});
}

// ====================
// 安全性の注意点
// ====================

fn demoSafetyNotes() void {
    std.debug.print("--- 安全性の注意点 ---\n", .{});

    std.debug.print("  [*]T の危険性:\n", .{});
    std.debug.print("    - 境界チェックなし\n", .{});
    std.debug.print("    - オーバーランの可能性\n", .{});
    std.debug.print("    - 長さを別途管理する必要\n", .{});

    std.debug.print("  推奨:\n", .{});
    std.debug.print("    - 可能な限りスライス []T を使用\n", .{});
    std.debug.print("    - C連携時のみ [*]T を使用\n", .{});
    std.debug.print("    - センチネル終端で長さを確定\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== 複数要素ポインタ ===\n\n", .{});

    demoBasicMultiPointer();
    demoPointerArithmetic();
    demoToSlice();
    demoSentinelPointer();
    demoSingleVsMulti();
    demoTypeInfo();
    demoCPointerRelation();
    demoMemoryOperations();
    demoArrayConversion();
    demoSafetyNotes();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・[*]T は長さ不明の複数要素ポインタ\n", .{});
    std.debug.print("・ポインタ演算が可能\n", .{});
    std.debug.print("・ptr[0..n] でスライスに変換\n", .{});
    std.debug.print("・可能な限りスライスを優先\n", .{});
}

// --- テスト ---

test "multi pointer indexing" {
    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    const ptr: [*]i32 = &arr;

    try std.testing.expectEqual(@as(i32, 10), ptr[0]);
    try std.testing.expectEqual(@as(i32, 30), ptr[2]);
    try std.testing.expectEqual(@as(i32, 50), ptr[4]);
}

test "pointer arithmetic" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr: [*]i32 = &arr;

    const ptr2 = ptr + 2;
    try std.testing.expectEqual(@as(i32, 3), ptr2[0]);

    const ptr3 = ptr2 - 1;
    try std.testing.expectEqual(@as(i32, 2), ptr3[0]);
}

test "multi pointer to slice" {
    var arr = [_]i32{ 100, 200, 300 };
    const ptr: [*]i32 = &arr;

    const slice = ptr[0..3];
    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 100), slice[0]);
    try std.testing.expectEqual(@as(i32, 300), slice[2]);
}

test "sentinel pointer" {
    const str: [*:0]const u8 = "test";

    // null終端までの長さを計算
    var len: usize = 0;
    while (str[len] != 0) : (len += 1) {}

    try std.testing.expectEqual(@as(usize, 4), len);
}

test "multi pointer from array" {
    const arr = [_]i32{ 5, 10, 15 };
    const ptr: [*]const i32 = &arr;

    try std.testing.expectEqual(@as(i32, 5), ptr[0]);
    try std.testing.expectEqual(@as(i32, 10), ptr[1]);
    try std.testing.expectEqual(@as(i32, 15), ptr[2]);
}

test "c pointer to multi pointer" {
    var arr = [_]i32{ 1, 2, 3 };
    const c_ptr: [*c]i32 = &arr;
    const multi: [*]i32 = c_ptr;

    try std.testing.expectEqual(@as(i32, 1), multi[0]);
    try std.testing.expectEqual(@as(i32, 2), multi[1]);
}

test "typeinfo pointer size" {
    const SinglePtr = *i32;
    const MultiPtr = [*]i32;

    const single_info = @typeInfo(SinglePtr).pointer;
    const multi_info = @typeInfo(MultiPtr).pointer;

    try std.testing.expectEqual(std.builtin.Type.Pointer.Size.one, single_info.size);
    try std.testing.expectEqual(std.builtin.Type.Pointer.Size.many, multi_info.size);
}

test "partial slice from multi pointer" {
    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    const ptr: [*]i32 = &arr;

    const partial = ptr[1..4];
    try std.testing.expectEqual(@as(usize, 3), partial.len);
    try std.testing.expectEqual(@as(i32, 20), partial[0]);
    try std.testing.expectEqual(@as(i32, 40), partial[2]);
}
