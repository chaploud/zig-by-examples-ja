//! # SIMD の基礎
//!
//! @Vector を使った並列データ処理の入門。
//!
//! ## 実行方法
//! ```
//! zig run 12_simd/n106_simd_basics.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - SIMD (Single Instruction, Multiple Data) の概念
//! - @Vector の基本
//! - ベクトル演算
//! - 配列との相互変換

const std = @import("std");

// ====================
// 1. SIMD の概念
// ====================

fn demoSimdConcept() void {
    std.debug.print("=== 1. SIMD の概念 ===\n\n", .{});

    std.debug.print("【SIMD とは】\n", .{});
    std.debug.print("  Single Instruction, Multiple Data\n", .{});
    std.debug.print("  1つの命令で複数のデータを同時に処理\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  - 同じ操作を大量のデータに適用する場合に高速\n", .{});
    std.debug.print("  - 画像処理、音声処理、数値計算に最適\n", .{});
    std.debug.print("  - CPUのベクトル演算ユニット(SSE, AVX等)を活用\n", .{});

    std.debug.print("\n【Zigでの表現】\n", .{});
    std.debug.print("  @Vector(長さ, 型) でSIMDベクトルを定義\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. @Vector の基本
// ====================

fn demoVectorBasics() void {
    std.debug.print("=== 2. @Vector の基本 ===\n\n", .{});

    // ベクトルの作成（リテラル）
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    std.debug.print("【ベクトル作成】\n", .{});
    std.debug.print("  const v = @Vector(4, i32){{ 1, 2, 3, 4 }};\n", .{});
    std.debug.print("  v1 = {any}\n", .{v1});
    std.debug.print("  v2 = {any}\n", .{v2});

    // 要素アクセス
    std.debug.print("\n【要素アクセス】\n", .{});
    std.debug.print("  v1[0] = {d}\n", .{v1[0]});
    std.debug.print("  v1[2] = {d}\n", .{v1[2]});

    std.debug.print("\n", .{});
}

// ====================
// 3. ベクトル演算
// ====================

fn demoVectorOperations() void {
    std.debug.print("=== 3. ベクトル演算 ===\n\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    // 加算
    const sum = v1 + v2;
    std.debug.print("【加算】 v1 + v2 = {any}\n", .{sum});

    // 減算
    const diff = v2 - v1;
    std.debug.print("【減算】 v2 - v1 = {any}\n", .{diff});

    // 乗算
    const prod = v1 * v2;
    std.debug.print("【乗算】 v1 * v2 = {any}\n", .{prod});

    // 除算
    const quot = v2 / v1;
    std.debug.print("【除算】 v2 / v1 = {any}\n", .{quot});

    // スカラー演算
    const scaled = v1 * @as(@Vector(4, i32), @splat(3));
    std.debug.print("【スカラー乗算】 v1 * 3 = {any}\n", .{scaled});

    std.debug.print("\n", .{});
}

// ====================
// 4. @splat
// ====================

fn demoSplat() void {
    std.debug.print("=== 4. @splat ===\n\n", .{});

    std.debug.print("【@splat とは】\n", .{});
    std.debug.print("  スカラー値をベクトルの全要素に展開\n", .{});

    // splatの使用
    const zeros: @Vector(4, i32) = @splat(0);
    const tens: @Vector(8, f32) = @splat(10.0);
    const ones: @Vector(3, u8) = @splat(255);

    std.debug.print("\n【例】\n", .{});
    std.debug.print("  @splat(0)   → {any}\n", .{zeros});
    std.debug.print("  @splat(10.0) → {any}\n", .{tens});
    std.debug.print("  @splat(255) → {any}\n", .{ones});

    // スカラー演算での活用
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const result = v + @as(@Vector(4, i32), @splat(100));
    std.debug.print("\nv + @splat(100) = {any}\n\n", .{result});
}

// ====================
// 5. 浮動小数点ベクトル
// ====================

fn demoFloatVector() void {
    std.debug.print("=== 5. 浮動小数点ベクトル ===\n\n", .{});

    const v1 = @Vector(4, f32){ 1.0, 2.0, 3.0, 4.0 };
    const v2 = @Vector(4, f32){ 0.5, 1.5, 2.5, 3.5 };

    std.debug.print("v1 = {any}\n", .{v1});
    std.debug.print("v2 = {any}\n", .{v2});

    // 演算
    const sum = v1 + v2;
    const prod = v1 * v2;

    std.debug.print("\nv1 + v2 = {any}\n", .{sum});
    std.debug.print("v1 * v2 = {any}\n", .{prod});

    // @sqrt（要素ごと）
    const sqrt_v1 = @sqrt(v1);
    std.debug.print("@sqrt(v1) = {any}\n", .{sqrt_v1});

    std.debug.print("\n", .{});
}

// ====================
// 6. 配列との変換
// ====================

fn demoArrayConversion() void {
    std.debug.print("=== 6. 配列との変換 ===\n\n", .{});

    // 配列からベクトルへ
    const arr = [4]i32{ 10, 20, 30, 40 };
    const vec: @Vector(4, i32) = arr;

    std.debug.print("【配列 → ベクトル】\n", .{});
    std.debug.print("  const arr = [4]i32{{ 10, 20, 30, 40 }};\n", .{});
    std.debug.print("  const vec: @Vector(4, i32) = arr;\n", .{});
    std.debug.print("  vec = {any}\n", .{vec});

    // ベクトルから配列へ
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const back: [4]i32 = v;

    std.debug.print("\n【ベクトル → 配列】\n", .{});
    std.debug.print("  const v = @Vector(4, i32){{ 1, 2, 3, 4 }};\n", .{});
    std.debug.print("  const back: [4]i32 = v;\n", .{});
    std.debug.print("  back = {any}\n", .{back});

    // 部分変換
    const big_arr = [8]i32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const partial: @Vector(4, i32) = big_arr[2..6].*;

    std.debug.print("\n【部分変換】\n", .{});
    std.debug.print("  arr[2..6] → {any}\n", .{partial});

    std.debug.print("\n", .{});
}

// ====================
// 7. 比較演算
// ====================

fn demoComparison() void {
    std.debug.print("=== 7. 比較演算 ===\n\n", .{});

    const v1 = @Vector(4, i32){ 10, 20, 30, 40 };
    const v2 = @Vector(4, i32){ 15, 15, 35, 35 };

    // 比較（要素ごと、結果はboolベクトル）
    const eq = v1 == v2;
    const lt = v1 < v2;
    const gt = v1 > v2;

    std.debug.print("v1 = {any}\n", .{v1});
    std.debug.print("v2 = {any}\n", .{v2});

    std.debug.print("\n【比較演算】\n", .{});
    std.debug.print("  v1 == v2 → {any}\n", .{eq});
    std.debug.print("  v1 < v2  → {any}\n", .{lt});
    std.debug.print("  v1 > v2  → {any}\n", .{gt});

    // @select で条件分岐
    const mask = v1 > v2;
    const max_vals = @select(i32, mask, v1, v2);
    std.debug.print("\n【@select】 max(v1, v2) = {any}\n\n", .{max_vals});
}

// ====================
// 8. サポートされる型
// ====================

fn demoSupportedTypes() void {
    std.debug.print("=== 8. サポートされる型 ===\n\n", .{});

    std.debug.print("【整数型】\n", .{});
    std.debug.print("  i8, u8, i16, u16, i32, u32, i64, u64\n", .{});

    std.debug.print("\n【浮動小数点型】\n", .{});
    std.debug.print("  f16, f32, f64\n", .{});

    std.debug.print("\n【ブール型】\n", .{});
    std.debug.print("  bool（比較結果など）\n", .{});

    std.debug.print("\n【ベクトル長】\n", .{});
    std.debug.print("  任意の正の整数（CPUが対応していれば高速）\n", .{});
    std.debug.print("  一般的: 4, 8, 16, 32\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== SIMD の基礎 まとめ ===\n\n", .{});

    std.debug.print("【ベクトル作成】\n", .{});
    std.debug.print("  const v = @Vector(4, i32){{ 1, 2, 3, 4 }};\n", .{});
    std.debug.print("  const zeros: @Vector(4, i32) = @splat(0);\n", .{});

    std.debug.print("\n【演算】\n", .{});
    std.debug.print("  v1 + v2, v1 - v2, v1 * v2, v1 / v2\n", .{});
    std.debug.print("  @sqrt(v), @abs(v), ...\n", .{});

    std.debug.print("\n【変換】\n", .{});
    std.debug.print("  配列 ↔ ベクトル\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  同じ操作を複数データに並列適用\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoSimdConcept();
    demoVectorBasics();
    demoVectorOperations();
    demoSplat();
    demoFloatVector();
    demoArrayConversion();
    demoComparison();
    demoSupportedTypes();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n107_reduce: @reduce関数\n", .{});
}

// ====================
// テスト
// ====================

test "@Vector creation" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(i32, 1), v[0]);
    try std.testing.expectEqual(@as(i32, 4), v[3]);
}

test "@Vector addition" {
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };
    const sum = v1 + v2;
    try std.testing.expectEqual(@as(i32, 11), sum[0]);
    try std.testing.expectEqual(@as(i32, 44), sum[3]);
}

test "@splat" {
    const v: @Vector(4, i32) = @splat(42);
    try std.testing.expectEqual(@as(i32, 42), v[0]);
    try std.testing.expectEqual(@as(i32, 42), v[3]);
}

test "array to vector" {
    const arr = [4]i32{ 1, 2, 3, 4 };
    const v: @Vector(4, i32) = arr;
    try std.testing.expectEqual(@as(i32, 1), v[0]);
}

test "vector to array" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const arr: [4]i32 = v;
    try std.testing.expectEqual(@as(i32, 1), arr[0]);
}

test "@select" {
    const v1 = @Vector(4, i32){ 10, 20, 30, 40 };
    const v2 = @Vector(4, i32){ 15, 15, 35, 35 };
    const mask = v1 > v2;
    const result = @select(i32, mask, v1, v2);
    try std.testing.expectEqual(@as(i32, 15), result[0]); // 10 < 15
    try std.testing.expectEqual(@as(i32, 20), result[1]); // 20 > 15
}
