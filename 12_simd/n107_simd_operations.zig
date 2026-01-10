//! # SIMD 操作関数
//!
//! @reduce とベクトル操作関数の使い方。
//!
//! ## 実行方法
//! ```
//! zig run 12_simd/n107_simd_operations.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - @reduce によるベクトルの集約
//! - ベクトル対応の組み込み関数
//! - ビット演算

const std = @import("std");

// ====================
// 1. @reduce の基本
// ====================

fn demoReduceBasics() void {
    std.debug.print("=== 1. @reduce の基本 ===\n\n", .{});

    std.debug.print("【@reduce とは】\n", .{});
    std.debug.print("  ベクトルの全要素を1つの値に集約\n", .{});
    std.debug.print("  @reduce(演算, ベクトル) の形式\n", .{});

    const v = @Vector(4, i32){ 10, 20, 30, 40 };
    std.debug.print("\n  v = {any}\n", .{v});

    // 合計
    const sum = @reduce(.Add, v);
    std.debug.print("\n【.Add（合計）】\n", .{});
    std.debug.print("  @reduce(.Add, v) = {d}\n", .{sum});

    // 積
    const product = @reduce(.Mul, v);
    std.debug.print("\n【.Mul（積）】\n", .{});
    std.debug.print("  @reduce(.Mul, v) = {d}\n", .{product});

    // 最大値
    const max_val = @reduce(.Max, v);
    std.debug.print("\n【.Max（最大値）】\n", .{});
    std.debug.print("  @reduce(.Max, v) = {d}\n", .{max_val});

    // 最小値
    const min_val = @reduce(.Min, v);
    std.debug.print("\n【.Min（最小値）】\n", .{});
    std.debug.print("  @reduce(.Min, v) = {d}\n", .{min_val});

    std.debug.print("\n", .{});
}

// ====================
// 2. 浮動小数点の @reduce
// ====================

fn demoReduceFloat() void {
    std.debug.print("=== 2. 浮動小数点の @reduce ===\n\n", .{});

    const v = @Vector(4, f32){ 1.5, 2.5, 3.5, 4.5 };
    std.debug.print("v = {any}\n\n", .{v});

    const sum = @reduce(.Add, v);
    const max_val = @reduce(.Max, v);
    const min_val = @reduce(.Min, v);

    std.debug.print("@reduce(.Add, v) = {d:.2}\n", .{sum});
    std.debug.print("@reduce(.Max, v) = {d:.2}\n", .{max_val});
    std.debug.print("@reduce(.Min, v) = {d:.2}\n", .{min_val});

    std.debug.print("\n", .{});
}

// ====================
// 3. ブールベクトルの @reduce
// ====================

fn demoReduceBool() void {
    std.debug.print("=== 3. ブールベクトルの @reduce ===\n\n", .{});

    const all_true = @Vector(4, bool){ true, true, true, true };
    const some_true = @Vector(4, bool){ true, false, true, false };
    const all_false = @Vector(4, bool){ false, false, false, false };

    std.debug.print("all_true  = {any}\n", .{all_true});
    std.debug.print("some_true = {any}\n", .{some_true});
    std.debug.print("all_false = {any}\n", .{all_false});

    std.debug.print("\n【.And（すべてtrue？）】\n", .{});
    std.debug.print("  all_true:  {}\n", .{@reduce(.And, all_true)});
    std.debug.print("  some_true: {}\n", .{@reduce(.And, some_true)});
    std.debug.print("  all_false: {}\n", .{@reduce(.And, all_false)});

    std.debug.print("\n【.Or（いずれかtrue？）】\n", .{});
    std.debug.print("  all_true:  {}\n", .{@reduce(.Or, all_true)});
    std.debug.print("  some_true: {}\n", .{@reduce(.Or, some_true)});
    std.debug.print("  all_false: {}\n", .{@reduce(.Or, all_false)});

    // 実用例: 条件チェック
    const values = @Vector(4, i32){ 10, 20, 30, 40 };
    const threshold: @Vector(4, i32) = @splat(15);
    const above = values > threshold;

    std.debug.print("\n【実用例】\n", .{});
    std.debug.print("  values = {any}\n", .{values});
    std.debug.print("  threshold = 15\n", .{});
    std.debug.print("  above = {any}\n", .{above});
    std.debug.print("  すべて15超？ {}\n", .{@reduce(.And, above)});
    std.debug.print("  いずれか15超？ {}\n", .{@reduce(.Or, above)});

    std.debug.print("\n", .{});
}

// ====================
// 4. ビット演算
// ====================

fn demoBitOperations() void {
    std.debug.print("=== 4. ビット演算 ===\n\n", .{});

    const v1 = @Vector(4, u8){ 0b1100, 0b1010, 0b1111, 0b0000 };
    const v2 = @Vector(4, u8){ 0b1010, 0b1010, 0b0000, 0b1111 };

    std.debug.print("v1 = {any} (2進: 1100, 1010, 1111, 0000)\n", .{v1});
    std.debug.print("v2 = {any} (2進: 1010, 1010, 0000, 1111)\n", .{v2});

    // AND
    const and_result = v1 & v2;
    std.debug.print("\n【AND】 v1 & v2 = {any}\n", .{and_result});

    // OR
    const or_result = v1 | v2;
    std.debug.print("【OR】  v1 | v2 = {any}\n", .{or_result});

    // XOR
    const xor_result = v1 ^ v2;
    std.debug.print("【XOR】 v1 ^ v2 = {any}\n", .{xor_result});

    // NOT
    const not_result = ~v1;
    std.debug.print("【NOT】 ~v1 = {any}\n", .{not_result});

    // @reduce でのビット演算
    std.debug.print("\n【@reduce でのビット演算】\n", .{});
    const bits = @Vector(4, u8){ 0b0001, 0b0010, 0b0100, 0b1000 };
    std.debug.print("  bits = {any}\n", .{bits});
    std.debug.print("  @reduce(.Or, bits) = {d} (0b1111)\n", .{@reduce(.Or, bits)});
    std.debug.print("  @reduce(.And, bits) = {d}\n", .{@reduce(.And, bits)});
    std.debug.print("  @reduce(.Xor, bits) = {d}\n", .{@reduce(.Xor, bits)});

    std.debug.print("\n", .{});
}

// ====================
// 5. 数学関数
// ====================

fn demoMathFunctions() void {
    std.debug.print("=== 5. 数学関数 ===\n\n", .{});

    const v = @Vector(4, f32){ 1.0, 4.0, 9.0, 16.0 };
    std.debug.print("v = {any}\n\n", .{v});

    // @sqrt
    const sqrt_v = @sqrt(v);
    std.debug.print("【@sqrt】 {any}\n", .{sqrt_v});

    // @abs（負の値で）
    const neg = @Vector(4, f32){ -1.0, 2.0, -3.0, 4.0 };
    const abs_neg = @abs(neg);
    std.debug.print("\nneg = {any}\n", .{neg});
    std.debug.print("【@abs】 {any}\n", .{abs_neg});

    // @min, @max（2つのベクトル間）
    const a = @Vector(4, f32){ 1.0, 5.0, 3.0, 8.0 };
    const b = @Vector(4, f32){ 2.0, 3.0, 7.0, 4.0 };
    const min_ab = @min(a, b);
    const max_ab = @max(a, b);

    std.debug.print("\na = {any}\n", .{a});
    std.debug.print("b = {any}\n", .{b});
    std.debug.print("【@min】 {any}\n", .{min_ab});
    std.debug.print("【@max】 {any}\n", .{max_ab});

    std.debug.print("\n", .{});
}

// ====================
// 6. シフト演算
// ====================

fn demoShiftOperations() void {
    std.debug.print("=== 6. シフト演算 ===\n\n", .{});

    const v = @Vector(4, u8){ 1, 2, 4, 8 };
    std.debug.print("v = {any}\n\n", .{v});

    // 左シフト
    const shift_amount: @Vector(4, u3) = @splat(2);
    const left = v << shift_amount;
    std.debug.print("【左シフト 2】 v << 2 = {any}\n", .{left});

    // 右シフト
    const right = v >> @as(@Vector(4, u3), @splat(1));
    std.debug.print("【右シフト 1】 v >> 1 = {any}\n", .{right});

    // 要素ごとに異なるシフト量
    const var_shift = @Vector(4, u3){ 0, 1, 2, 3 };
    const base: @Vector(4, u8) = @splat(16);
    const var_result = base >> var_shift;
    std.debug.print("\n【可変シフト】\n", .{});
    std.debug.print("  base = {any}\n", .{base});
    std.debug.print("  shift = {any}\n", .{var_shift});
    std.debug.print("  result = {any}\n", .{var_result});

    std.debug.print("\n", .{});
}

// ====================
// 7. 実用例: ドット積
// ====================

fn demoDotProduct() void {
    std.debug.print("=== 7. 実用例: ドット積 ===\n\n", .{});

    const a = @Vector(4, f32){ 1.0, 2.0, 3.0, 4.0 };
    const b = @Vector(4, f32){ 5.0, 6.0, 7.0, 8.0 };

    std.debug.print("a = {any}\n", .{a});
    std.debug.print("b = {any}\n", .{b});

    // ドット積 = 各要素の積の総和
    const product = a * b;
    const dot = @reduce(.Add, product);

    std.debug.print("\n【計算】\n", .{});
    std.debug.print("  a * b = {any}\n", .{product});
    std.debug.print("  dot(a, b) = {d:.1}\n", .{dot});
    std.debug.print("  (1*5 + 2*6 + 3*7 + 4*8 = 70)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. @reduce の演算一覧
// ====================

fn demoReduceOperations() void {
    std.debug.print("=== 8. @reduce の演算一覧 ===\n\n", .{});

    std.debug.print("【算術演算】\n", .{});
    std.debug.print("  .Add  - 加算 (合計)\n", .{});
    std.debug.print("  .Mul  - 乗算 (積)\n", .{});
    std.debug.print("  .Max  - 最大値\n", .{});
    std.debug.print("  .Min  - 最小値\n", .{});

    std.debug.print("\n【ビット演算】\n", .{});
    std.debug.print("  .And  - ビットAND\n", .{});
    std.debug.print("  .Or   - ビットOR\n", .{});
    std.debug.print("  .Xor  - ビットXOR\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - ブールベクトルでは .And/.Or が論理演算\n", .{});
    std.debug.print("  - 結果型はベクトルの要素型と同じ\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoReduceBasics();
    demoReduceFloat();
    demoReduceBool();
    demoBitOperations();
    demoMathFunctions();
    demoShiftOperations();
    demoDotProduct();
    demoReduceOperations();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n108_simd_shuffle: @shuffleによる要素並べ替え\n", .{});
}

// ====================
// テスト
// ====================

test "@reduce Add" {
    const v = @Vector(4, i32){ 10, 20, 30, 40 };
    const sum = @reduce(.Add, v);
    try std.testing.expectEqual(@as(i32, 100), sum);
}

test "@reduce Max/Min" {
    const v = @Vector(4, i32){ 10, 40, 20, 30 };
    try std.testing.expectEqual(@as(i32, 40), @reduce(.Max, v));
    try std.testing.expectEqual(@as(i32, 10), @reduce(.Min, v));
}

test "@reduce Mul" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(i32, 24), @reduce(.Mul, v));
}

test "@reduce And/Or" {
    const all_true = @Vector(4, bool){ true, true, true, true };
    const some_true = @Vector(4, bool){ true, false, true, false };

    try std.testing.expect(@reduce(.And, all_true));
    try std.testing.expect(!@reduce(.And, some_true));
    try std.testing.expect(@reduce(.Or, some_true));
}

test "bit operations" {
    const v1 = @Vector(4, u8){ 0b1100, 0b1010, 0b1111, 0b0000 };
    const v2 = @Vector(4, u8){ 0b1010, 0b1010, 0b0000, 0b1111 };

    const and_result = v1 & v2;
    try std.testing.expectEqual(@as(u8, 0b1000), and_result[0]);

    const or_result = v1 | v2;
    try std.testing.expectEqual(@as(u8, 0b1110), or_result[0]);
}

test "dot product" {
    const a = @Vector(4, f32){ 1.0, 2.0, 3.0, 4.0 };
    const b = @Vector(4, f32){ 5.0, 6.0, 7.0, 8.0 };
    const dot = @reduce(.Add, a * b);
    try std.testing.expectEqual(@as(f32, 70.0), dot);
}
