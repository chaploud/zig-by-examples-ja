//! # SIMD 総まとめ
//!
//! SIMDの全機能を総括するリファレンス。
//!
//! ## 実行方法
//! ```
//! zig run 12_simd/n110_simd_summary.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - SIMDの全体像
//! - 主要なビルトイン関数
//! - ベストプラクティス
//! - チートシート

const std = @import("std");

// ====================
// 1. @Vector の基本
// ====================

fn demoVectorBasics() void {
    std.debug.print("=== 1. @Vector の基本 ===\n\n", .{});

    std.debug.print("【構文】\n", .{});
    std.debug.print("  @Vector(長さ, 型)\n", .{});

    std.debug.print("\n【作成方法】\n", .{});

    // リテラル
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    std.debug.print("  リテラル: {any}\n", .{v1});

    // @splat
    const v2: @Vector(4, i32) = @splat(42);
    std.debug.print("  @splat(42): {any}\n", .{v2});

    // 配列から
    const arr = [4]i32{ 10, 20, 30, 40 };
    const v3: @Vector(4, i32) = arr;
    std.debug.print("  配列から: {any}\n", .{v3});

    // スライスから
    const big_arr = [8]i32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const v4: @Vector(4, i32) = big_arr[2..6].*;
    std.debug.print("  スライスから: {any}\n", .{v4});

    std.debug.print("\n【要素アクセス】\n", .{});
    std.debug.print("  v[0] = {d}, v[3] = {d}\n", .{ v1[0], v1[3] });

    std.debug.print("\n【配列への変換】\n", .{});
    const back: [4]i32 = v1;
    std.debug.print("  const arr: [4]i32 = v;\n", .{});
    std.debug.print("  arr = {any}\n", .{back});

    std.debug.print("\n", .{});
}

// ====================
// 2. 演算子
// ====================

fn demoOperators() void {
    std.debug.print("=== 2. 演算子 ===\n\n", .{});

    const a = @Vector(4, i32){ 10, 20, 30, 40 };
    const b = @Vector(4, i32){ 3, 4, 5, 6 };

    std.debug.print("a = {any}\n", .{a});
    std.debug.print("b = {any}\n", .{b});

    std.debug.print("\n【算術】\n", .{});
    std.debug.print("  a + b = {any}\n", .{a + b});
    std.debug.print("  a - b = {any}\n", .{a - b});
    std.debug.print("  a * b = {any}\n", .{a * b});
    std.debug.print("  a / b = {any}\n", .{@divTrunc(a, b)});

    std.debug.print("\n【比較（結果はboolベクトル）】\n", .{});
    std.debug.print("  a > b: {any}\n", .{a > b});
    std.debug.print("  a == b: {any}\n", .{a == b});

    std.debug.print("\n【ビット演算】\n", .{});
    const x = @Vector(4, u8){ 0b1100, 0b1010, 0b1111, 0b0000 };
    const y = @Vector(4, u8){ 0b1010, 0b1010, 0b0101, 0b1111 };
    std.debug.print("  x & y: {any}\n", .{x & y});
    std.debug.print("  x | y: {any}\n", .{x | y});
    std.debug.print("  x ^ y: {any}\n", .{x ^ y});
    std.debug.print("  ~x: {any}\n", .{~x});

    std.debug.print("\n", .{});
}

// ====================
// 3. 主要なビルトイン関数
// ====================

fn demoBuiltins() void {
    std.debug.print("=== 3. 主要なビルトイン関数 ===\n\n", .{});

    const v = @Vector(4, f32){ 4.0, 9.0, 16.0, 25.0 };
    const neg = @Vector(4, f32){ -1.0, 2.0, -3.0, 4.0 };

    std.debug.print("【数学関数】\n", .{});
    std.debug.print("  @sqrt({any}) = {any}\n", .{ v, @sqrt(v) });
    std.debug.print("  @abs({any}) = {any}\n", .{ neg, @abs(neg) });

    const a = @Vector(4, f32){ 1.0, 5.0, 3.0, 8.0 };
    const b = @Vector(4, f32){ 2.0, 3.0, 7.0, 4.0 };
    std.debug.print("  @min(a, b) = {any}\n", .{@min(a, b)});
    std.debug.print("  @max(a, b) = {any}\n", .{@max(a, b)});

    std.debug.print("\n【@reduce】\n", .{});
    const int_v = @Vector(4, i32){ 10, 20, 30, 40 };
    std.debug.print("  v = {any}\n", .{int_v});
    std.debug.print("  .Add: {d}\n", .{@reduce(.Add, int_v)});
    std.debug.print("  .Mul: {d}\n", .{@reduce(.Mul, int_v)});
    std.debug.print("  .Max: {d}\n", .{@reduce(.Max, int_v)});
    std.debug.print("  .Min: {d}\n", .{@reduce(.Min, int_v)});

    const bool_v = @Vector(4, bool){ true, false, true, true };
    std.debug.print("  bool: {any}\n", .{bool_v});
    std.debug.print("  .And: {}\n", .{@reduce(.And, bool_v)});
    std.debug.print("  .Or: {}\n", .{@reduce(.Or, bool_v)});

    std.debug.print("\n【@splat】\n", .{});
    const zeros: @Vector(4, i32) = @splat(0);
    std.debug.print("  @splat(0) = {any}\n", .{zeros});

    std.debug.print("\n", .{});
}

// ====================
// 4. @shuffle と @select
// ====================

fn demoShuffleSelect() void {
    std.debug.print("=== 4. @shuffle と @select ===\n\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    std.debug.print("v1 = {any}\n", .{v1});
    std.debug.print("v2 = {any}\n", .{v2});

    std.debug.print("\n【@shuffle】\n", .{});
    std.debug.print("  正のインデックス → v1から\n", .{});
    std.debug.print("  ~n（負）→ v2から\n", .{});

    // 逆順
    const rev = @shuffle(i32, v1, undefined, @Vector(4, i32){ 3, 2, 1, 0 });
    std.debug.print("  逆順: {any}\n", .{rev});

    // 交互
    const mix = @shuffle(i32, v1, v2, @Vector(4, i32){ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });
    std.debug.print("  交互: {any}\n", .{mix});

    std.debug.print("\n【@select】\n", .{});
    const selector = @Vector(4, bool){ true, false, true, false };
    const selected = @select(i32, selector, v1, v2);
    std.debug.print("  selector = {any}\n", .{selector});
    std.debug.print("  結果: {any}\n", .{selected});

    std.debug.print("\n", .{});
}

// ====================
// 5. 実践パターン
// ====================

fn demoPracticalPatterns() void {
    std.debug.print("=== 5. 実践パターン ===\n\n", .{});

    std.debug.print("【配列処理の基本形】\n", .{});
    std.debug.print(
        \\  const VEC_SIZE = 4;
        \\  var i: usize = 0;
        \\  while (i + VEC_SIZE <= arr.len) : (i += VEC_SIZE) {{
        \\      const chunk: @Vector(VEC_SIZE, T) = arr[i..][0..VEC_SIZE].*;
        \\      // 処理
        \\  }}
        \\  // 残りの処理
        \\
    , .{});

    std.debug.print("\n【ドット積】\n", .{});
    const a = @Vector(4, f32){ 1.0, 2.0, 3.0, 4.0 };
    const b = @Vector(4, f32){ 5.0, 6.0, 7.0, 8.0 };
    const dot = @reduce(.Add, a * b);
    std.debug.print("  dot(a, b) = @reduce(.Add, a * b) = {d:.1}\n", .{dot});

    std.debug.print("\n【最大値】\n", .{});
    std.debug.print("  max = @reduce(.Max, v)\n", .{});

    std.debug.print("\n【クランプ】\n", .{});
    std.debug.print("  clamped = @max(@min(v, max_vec), min_vec)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. サポート型と注意点
// ====================

fn demoTypesAndNotes() void {
    std.debug.print("=== 6. サポート型と注意点 ===\n\n", .{});

    std.debug.print("【サポートされる要素型】\n", .{});
    std.debug.print("  整数: i8, u8, i16, u16, i32, u32, i64, u64\n", .{});
    std.debug.print("  浮動小数点: f16, f32, f64\n", .{});
    std.debug.print("  ブール: bool\n", .{});

    std.debug.print("\n【推奨ベクトルサイズ】\n", .{});
    std.debug.print("  4, 8, 16, 32（CPU依存）\n", .{});
    std.debug.print("  一般的には4か8を使用\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - 大きすぎるベクトルは避ける\n", .{});
    std.debug.print("    （メモリエラーの原因）\n", .{});
    std.debug.print("  - コンパイル時サイズが必要\n", .{});
    std.debug.print("  - 残り要素の処理を忘れない\n", .{});
    std.debug.print("  - CPUがSIMD非対応でも動作\n", .{});
    std.debug.print("    （パフォーマンスは低下）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. チートシート
// ====================

fn demoCheatSheet() void {
    std.debug.print("=== 7. チートシート ===\n\n", .{});

    std.debug.print("【作成】\n", .{});
    std.debug.print("  const v = @Vector(4, i32){{ 1, 2, 3, 4 }};\n", .{});
    std.debug.print("  const zeros: @Vector(4, i32) = @splat(0);\n", .{});
    std.debug.print("  const v: @Vector(4, i32) = arr;\n", .{});
    std.debug.print("  const v: @Vector(4, i32) = slice[0..4].*;\n", .{});

    std.debug.print("\n【演算】\n", .{});
    std.debug.print("  v1 + v2, v1 - v2, v1 * v2\n", .{});
    std.debug.print("  v1 & v2, v1 | v2, v1 ^ v2, ~v1\n", .{});
    std.debug.print("  v1 < v2, v1 == v2, v1 > v2\n", .{});

    std.debug.print("\n【関数】\n", .{});
    std.debug.print("  @sqrt(v), @abs(v)\n", .{});
    std.debug.print("  @min(v1, v2), @max(v1, v2)\n", .{});
    std.debug.print("  @reduce(.Add/Mul/Max/Min/And/Or, v)\n", .{});
    std.debug.print("  @shuffle(T, v1, v2, mask)\n", .{});
    std.debug.print("  @select(T, bool_mask, true_v, false_v)\n", .{});
    std.debug.print("  @splat(value)\n", .{});

    std.debug.print("\n【変換】\n", .{});
    std.debug.print("  配列 → ベクトル: const v: @Vector(4, T) = arr;\n", .{});
    std.debug.print("  ベクトル → 配列: const arr: [4]T = v;\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. SIMDの利点
// ====================

fn demoBenefits() void {
    std.debug.print("=== 8. SIMDの利点 ===\n\n", .{});

    std.debug.print("【パフォーマンス】\n", .{});
    std.debug.print("  1命令で複数データを並列処理\n", .{});
    std.debug.print("  画像・音声処理で大きな効果\n", .{});

    std.debug.print("\n【可読性】\n", .{});
    std.debug.print("  ループなしでベクトル演算\n", .{});
    std.debug.print("  意図が明確なコード\n", .{});

    std.debug.print("\n【移植性】\n", .{});
    std.debug.print("  ZigがCPUに最適なコードを生成\n", .{});
    std.debug.print("  アセンブリ不要\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoVectorBasics();
    demoOperators();
    demoBuiltins();
    demoShuffleSelect();
    demoPracticalPatterns();
    demoTypesAndNotes();
    demoCheatSheet();
    demoBenefits();

    std.debug.print("===========================================\n", .{});
    std.debug.print("  zig-by-examples-ja 全110ファイル完了！\n", .{});
    std.debug.print("===========================================\n", .{});
}

// ====================
// テスト
// ====================

test "vector creation" {
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2: @Vector(4, i32) = @splat(10);
    const arr = [4]i32{ 5, 6, 7, 8 };
    const v3: @Vector(4, i32) = arr;

    try std.testing.expectEqual(@as(i32, 1), v1[0]);
    try std.testing.expectEqual(@as(i32, 10), v2[0]);
    try std.testing.expectEqual(@as(i32, 5), v3[0]);
}

test "vector operations" {
    const a = @Vector(4, i32){ 1, 2, 3, 4 };
    const b = @Vector(4, i32){ 10, 20, 30, 40 };

    const sum = a + b;
    try std.testing.expectEqual(@as(i32, 11), sum[0]);
    try std.testing.expectEqual(@as(i32, 44), sum[3]);
}

test "@reduce" {
    const v = @Vector(4, i32){ 10, 20, 30, 40 };
    try std.testing.expectEqual(@as(i32, 100), @reduce(.Add, v));
    try std.testing.expectEqual(@as(i32, 40), @reduce(.Max, v));
    try std.testing.expectEqual(@as(i32, 10), @reduce(.Min, v));
}

test "@shuffle reverse" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const reversed = @shuffle(i32, v, undefined, @Vector(4, i32){ 3, 2, 1, 0 });
    try std.testing.expectEqual(@as(i32, 4), reversed[0]);
    try std.testing.expectEqual(@as(i32, 1), reversed[3]);
}

test "@select" {
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };
    const mask = @Vector(4, bool){ true, false, true, false };
    const result = @select(i32, mask, v1, v2);
    try std.testing.expectEqual(@as(i32, 1), result[0]);
    try std.testing.expectEqual(@as(i32, 20), result[1]);
}

test "dot product" {
    const a = @Vector(4, f32){ 1.0, 2.0, 3.0, 4.0 };
    const b = @Vector(4, f32){ 5.0, 6.0, 7.0, 8.0 };
    const dot = @reduce(.Add, a * b);
    // 1*5 + 2*6 + 3*7 + 4*8 = 5 + 12 + 21 + 32 = 70
    try std.testing.expectEqual(@as(f32, 70.0), dot);
}
