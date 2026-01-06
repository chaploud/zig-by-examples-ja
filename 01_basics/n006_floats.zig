//! # 浮動小数点型
//!
//! Zigの浮動小数点型はIEEE 754規格に準拠。
//! ビット幅で精度と範囲が決まる。
//!
//! ## 利用可能な型
//! - `f16`: 半精度（16ビット）
//! - `f32`: 単精度（32ビット）- 一般的な用途に最適
//! - `f64`: 倍精度（64ビット）- 高精度が必要な場合
//! - `f128`: 四倍精度（128ビット）
//! - `comptime_float`: コンパイル時浮動小数点（任意精度）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== 浮動小数点型 ===\n\n", .{});

    // ====================
    // 基本的な宣言
    // ====================

    const pi: f32 = 3.14159;
    const e: f64 = 2.71828182845904523;
    const small: f16 = 0.5;

    std.debug.print("f32 pi = {d:.5}\n", .{pi});
    std.debug.print("f64 e  = {d:.15}\n", .{e});
    std.debug.print("f16 small = {d}\n", .{small});

    std.debug.print("\n", .{});

    // ====================
    // 数値リテラル表現
    // ====================

    const decimal: f64 = 123.456;
    const scientific: f64 = 1.23e4; // 1.23 × 10^4 = 12300
    const negative_exp: f64 = 5.67e-3; // 5.67 × 10^-3 = 0.00567
    const with_underscore: f64 = 1_000_000.123_456;

    std.debug.print("通常表記: {d}\n", .{decimal});
    std.debug.print("指数表記 1.23e4: {d}\n", .{scientific});
    std.debug.print("指数表記 5.67e-3: {d}\n", .{negative_exp});
    std.debug.print("区切り付き: {d}\n", .{with_underscore});

    std.debug.print("\n", .{});

    // ====================
    // 特殊な値
    // ====================

    const inf: f32 = std.math.inf(f32); // 正の無限大
    const neg_inf: f32 = -std.math.inf(f32); // 負の無限大
    const nan_value: f32 = std.math.nan(f32); // Not a Number

    std.debug.print("正の無限大: {d}\n", .{inf});
    std.debug.print("負の無限大: {d}\n", .{neg_inf});
    std.debug.print("NaN: {d}\n", .{nan_value});

    // NaNの判定
    std.debug.print("isNan(nan): {}\n", .{std.math.isNan(nan_value)});
    std.debug.print("isInf(inf): {}\n", .{std.math.isInf(inf)});

    std.debug.print("\n", .{});

    // ====================
    // 算術演算
    // ====================

    const a: f64 = 10.5;
    const b: f64 = 3.2;

    std.debug.print("a = {d}, b = {d}\n", .{ a, b });
    std.debug.print("a + b = {d}\n", .{a + b});
    std.debug.print("a - b = {d}\n", .{a - b});
    std.debug.print("a * b = {d}\n", .{a * b});
    std.debug.print("a / b = {d:.6}\n", .{a / b});
    std.debug.print("@mod(a, b) = {d:.6}\n", .{@mod(a, b)});

    // 負の数での剰余
    const c: f64 = -10.5;
    std.debug.print("@mod(-10.5, 3.2) = {d:.6}\n", .{@mod(c, b)});
    std.debug.print("@rem(-10.5, 3.2) = {d:.6}\n", .{@rem(c, b)});

    std.debug.print("\n", .{});

    // ====================
    // 数学関数
    // ====================

    const x: f64 = 2.0;

    std.debug.print("sqrt(2) = {d:.10}\n", .{@sqrt(x)});
    std.debug.print("pow(2, 10) = {d}\n", .{std.math.pow(f64, x, 10.0)});
    std.debug.print("log(e) = {d:.10}\n", .{@log(std.math.e)});
    std.debug.print("sin(pi/2) = {d}\n", .{@sin(std.math.pi / 2.0)});
    std.debug.print("cos(0) = {d}\n", .{@cos(@as(f64, 0.0))});
    std.debug.print("abs(-5.5) = {d}\n", .{@abs(@as(f64, -5.5))});
    std.debug.print("floor(3.7) = {d}\n", .{@floor(@as(f64, 3.7))});
    std.debug.print("ceil(3.2) = {d}\n", .{@ceil(@as(f64, 3.2))});

    std.debug.print("\n", .{});

    // ====================
    // 型変換
    // ====================

    // 整数から浮動小数点へ
    const int_val: i32 = 42;
    const float_val: f64 = @floatFromInt(int_val);
    std.debug.print("整数 {d} → 浮動小数点 {d}\n", .{ int_val, float_val });

    // 浮動小数点から整数へ（切り捨て）
    const float_num: f64 = 3.9;
    const int_num: i32 = @intFromFloat(float_num);
    std.debug.print("浮動小数点 {d} → 整数 {d}\n", .{ float_num, int_num });

    // 浮動小数点型間の変換
    const f64_val: f64 = 1.234567890123456;
    const f32_val: f32 = @floatCast(f64_val);
    std.debug.print("f64 {d:.15} → f32 {d:.7}\n", .{ f64_val, f32_val });

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・浮動小数点演算は結合法則を満たさない場合がある\n", .{});
    std.debug.print("・比較には epsilon を使用することを推奨\n", .{});
    std.debug.print("・0除算は inf を返す（整数と異なりエラーにならない）\n", .{});
}

// ====================
// 浮動小数点比較
// ====================

/// 近似的な等価比較（epsilon使用）
fn approxEqual(a: f64, b: f64) bool {
    const epsilon = 1e-10;
    return @abs(a - b) < epsilon;
}

// --- テスト ---

test "float types precision" {
    // f32は約7桁の精度
    const f32_val: f32 = 1.2345678;
    try std.testing.expect(@abs(f32_val - 1.2345678) < 1e-6);

    // f64は約15桁の精度
    const f64_val: f64 = 1.234567890123456;
    try std.testing.expect(@abs(f64_val - 1.234567890123456) < 1e-14);
}

test "scientific notation" {
    const a: f64 = 1.5e3;
    try std.testing.expectEqual(@as(f64, 1500.0), a);

    const b: f64 = 2.5e-2;
    try std.testing.expect(@abs(b - 0.025) < 1e-10);
}

test "special values" {
    const inf = std.math.inf(f64);
    const nan = std.math.nan(f64);

    try std.testing.expect(std.math.isInf(inf));
    try std.testing.expect(std.math.isNan(nan));
    try std.testing.expect(!std.math.isFinite(inf));
    try std.testing.expect(std.math.isFinite(@as(f64, 1.0)));
}

test "arithmetic operations" {
    const a: f64 = 10.0;
    const b: f64 = 3.0;

    try std.testing.expectEqual(@as(f64, 13.0), a + b);
    try std.testing.expectEqual(@as(f64, 7.0), a - b);
    try std.testing.expectEqual(@as(f64, 30.0), a * b);
    try std.testing.expect(@abs(a / b - 3.333333333333333) < 1e-10);
}

test "mod vs rem" {
    // @mod: 常に正の結果（被除数と同じ符号）
    // @rem: 被除数の符号を維持
    try std.testing.expect(@abs(@mod(@as(f64, -10.0), @as(f64, 3.0)) - 2.0) < 1e-10);
    try std.testing.expect(@abs(@rem(@as(f64, -10.0), @as(f64, 3.0)) - -1.0) < 1e-10);
}

test "math functions" {
    try std.testing.expect(@abs(@sqrt(@as(f64, 4.0)) - 2.0) < 1e-10);
    try std.testing.expect(@abs(@sin(@as(f64, 0.0))) < 1e-10);
    try std.testing.expect(@abs(@cos(@as(f64, 0.0)) - 1.0) < 1e-10);
    try std.testing.expectEqual(@as(f64, 5.0), @abs(@as(f64, -5.0)));
}

test "floor and ceil" {
    try std.testing.expectEqual(@as(f64, 3.0), @floor(@as(f64, 3.7)));
    try std.testing.expectEqual(@as(f64, 4.0), @ceil(@as(f64, 3.2)));
    try std.testing.expectEqual(@as(f64, -4.0), @floor(@as(f64, -3.2)));
    try std.testing.expectEqual(@as(f64, -3.0), @ceil(@as(f64, -3.2)));
}

test "type conversion from int" {
    const int_val: i32 = 42;
    const float_val: f64 = @floatFromInt(int_val);
    try std.testing.expectEqual(@as(f64, 42.0), float_val);
}

test "type conversion to int" {
    // 切り捨て（0方向）
    const pos: f64 = 3.9;
    const neg: f64 = -3.9;
    try std.testing.expectEqual(@as(i32, 3), @as(i32, @intFromFloat(pos)));
    try std.testing.expectEqual(@as(i32, -3), @as(i32, @intFromFloat(neg)));
}

test "float cast between types" {
    const f64_val: f64 = 1.5;
    const f32_val: f32 = @floatCast(f64_val);
    try std.testing.expectEqual(@as(f32, 1.5), f32_val);
}

test "approximate equality" {
    // 浮動小数点の丸め誤差のため、直接比較は避ける
    const a: f64 = 0.1 + 0.2;
    const b: f64 = 0.3;
    // a == b は false になる可能性がある
    try std.testing.expect(@abs(a - b) < 1e-10);
}

test "division by zero produces infinity" {
    const x: f64 = 1.0;
    const y: f64 = 0.0;
    const result = x / y;
    try std.testing.expect(std.math.isInf(result));
}

test "float array" {
    const values = [_]f64{ 1.1, 2.2, 3.3, 4.4, 5.5 };
    var sum: f64 = 0.0;
    for (values) |v| {
        sum += v;
    }
    try std.testing.expect(@abs(sum - 16.5) < 1e-10);
}
