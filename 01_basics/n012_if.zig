//! # if文
//!
//! Zigのif文は条件に基づいて処理を分岐する。
//! 式としても使え、値を返すことができる。
//!
//! ## 特徴
//! - 条件はbool型のみ（整数の暗黙変換なし）
//! - 式として値を返せる
//! - optionalのアンラップに使える
//! - エラーのアンラップにも使える

const std = @import("std");

pub fn main() void {
    std.debug.print("=== if文 ===\n\n", .{});

    // ====================
    // 基本的なif文
    // ====================

    const x: i32 = 5;

    if (x > 10) {
        std.debug.print("x > 10\n", .{});
    } else {
        std.debug.print("x <= 10\n", .{});
    }

    std.debug.print("\n", .{});

    // ====================
    // else if チェーン
    // ====================

    const score: i32 = 85;

    if (score >= 90) {
        std.debug.print("評価: A\n", .{});
    } else if (score >= 80) {
        std.debug.print("評価: B\n", .{});
    } else if (score >= 70) {
        std.debug.print("評価: C\n", .{});
    } else if (score >= 60) {
        std.debug.print("評価: D\n", .{});
    } else {
        std.debug.print("評価: F\n", .{});
    }

    std.debug.print("\n", .{});

    // ====================
    // if式（値を返す）
    // ====================

    const value: i32 = 42;
    const result = if (value > 0) "正" else "非正";
    std.debug.print("value={d} → {s}\n", .{ value, result });

    // 計算結果を返す
    const abs_value = if (value >= 0) value else -value;
    std.debug.print("abs({d}) = {d}\n", .{ value, abs_value });

    std.debug.print("\n", .{});

    // ====================
    // optionalのアンラップ
    // ====================

    const maybe_num: ?i32 = 42;
    const no_num: ?i32 = null;

    if (maybe_num) |num| {
        std.debug.print("maybe_num has value: {d}\n", .{num});
    } else {
        std.debug.print("maybe_num is null\n", .{});
    }

    if (no_num) |num| {
        std.debug.print("no_num has value: {d}\n", .{num});
    } else {
        std.debug.print("no_num is null\n", .{});
    }

    std.debug.print("\n", .{});

    // ====================
    // optionalポインタのアンラップ
    // ====================

    var data: i32 = 100;
    const opt_ptr: ?*i32 = &data;

    if (opt_ptr) |ptr| {
        std.debug.print("ポインタの値: {d}\n", .{ptr.*});
        ptr.* = 200;
        std.debug.print("変更後: {d}\n", .{data});
    }

    std.debug.print("\n", .{});

    // ====================
    // 複合条件
    // ====================

    const age: u8 = 25;
    const has_license = true;

    if (age >= 18 and has_license) {
        std.debug.print("運転可能\n", .{});
    } else {
        std.debug.print("運転不可\n", .{});
    }

    // 複数条件のOR
    const is_weekend = false;
    const is_holiday = true;

    if (is_weekend or is_holiday) {
        std.debug.print("休日\n", .{});
    } else {
        std.debug.print("平日\n", .{});
    }

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・条件はbool型のみ（0やnullは使えない）\n", .{});
    std.debug.print("・if式で値を返せる\n", .{});
    std.debug.print("・optional/errorのアンラップに便利\n", .{});
}

// ====================
// 実用的な関数例
// ====================

/// 二つの数の大きい方を返す
fn max(a: i32, b: i32) i32 {
    return if (a > b) a else b;
}

/// 二つの数の小さい方を返す
fn min(a: i32, b: i32) i32 {
    return if (a < b) a else b;
}

/// 値を範囲内にクランプする
fn clamp(value: i32, lower: i32, upper: i32) i32 {
    if (value < lower) return lower;
    if (value > upper) return upper;
    return value;
}

/// 符号を返す（-1, 0, 1）
fn sign(n: i32) i32 {
    if (n > 0) return 1;
    if (n < 0) return -1;
    return 0;
}

/// 文字が数字かどうか
fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

/// 文字がアルファベットかどうか
fn isAlpha(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

// --- テスト ---

test "basic if" {
    const x: i32 = 10;
    var result: i32 = 0;

    if (x > 5) {
        result = 1;
    } else {
        result = 0;
    }

    try std.testing.expectEqual(@as(i32, 1), result);
}

test "if as expression" {
    const a: i32 = 5;
    const b: i32 = 10;

    const larger = if (a > b) a else b;
    try std.testing.expectEqual(@as(i32, 10), larger);

    const smaller = if (a < b) a else b;
    try std.testing.expectEqual(@as(i32, 5), smaller);
}

test "else if chain" {
    const score: i32 = 75;

    const grade = if (score >= 90)
        "A"
    else if (score >= 80)
        "B"
    else if (score >= 70)
        "C"
    else
        "F";

    try std.testing.expect(std.mem.eql(u8, grade, "C"));
}

test "if with optional" {
    const some: ?i32 = 42;
    const none: ?i32 = null;

    var some_result: i32 = 0;
    if (some) |val| {
        some_result = val;
    }
    try std.testing.expectEqual(@as(i32, 42), some_result);

    var none_result: i32 = -1;
    if (none) |val| {
        none_result = val;
    } else {
        none_result = 0;
    }
    try std.testing.expectEqual(@as(i32, 0), none_result);
}

test "if with optional pointer" {
    var value: i32 = 100;
    const ptr: ?*i32 = &value;

    if (ptr) |p| {
        p.* = 200;
    }

    try std.testing.expectEqual(@as(i32, 200), value);
}

test "compound conditions" {
    const a = true;
    const b = false;

    try std.testing.expect(a and !b);
    try std.testing.expect(a or b);
    try std.testing.expect(!(a and b));
}

test "max function" {
    try std.testing.expectEqual(@as(i32, 10), max(5, 10));
    try std.testing.expectEqual(@as(i32, 10), max(10, 5));
    try std.testing.expectEqual(@as(i32, 5), max(5, 5));
}

test "min function" {
    try std.testing.expectEqual(@as(i32, 5), min(5, 10));
    try std.testing.expectEqual(@as(i32, 5), min(10, 5));
    try std.testing.expectEqual(@as(i32, 5), min(5, 5));
}

test "clamp function" {
    try std.testing.expectEqual(@as(i32, 5), clamp(5, 0, 10));
    try std.testing.expectEqual(@as(i32, 0), clamp(-5, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), clamp(15, 0, 10));
}

test "sign function" {
    try std.testing.expectEqual(@as(i32, 1), sign(42));
    try std.testing.expectEqual(@as(i32, -1), sign(-42));
    try std.testing.expectEqual(@as(i32, 0), sign(0));
}

test "isDigit function" {
    try std.testing.expect(isDigit('0'));
    try std.testing.expect(isDigit('5'));
    try std.testing.expect(isDigit('9'));
    try std.testing.expect(!isDigit('a'));
    try std.testing.expect(!isDigit(' '));
}

test "isAlpha function" {
    try std.testing.expect(isAlpha('a'));
    try std.testing.expect(isAlpha('Z'));
    try std.testing.expect(!isAlpha('0'));
    try std.testing.expect(!isAlpha(' '));
}

test "if with multiple returns" {
    const classify = struct {
        fn classify(n: i32) []const u8 {
            if (n < 0) return "negative";
            if (n == 0) return "zero";
            return "positive";
        }
    }.classify;

    try std.testing.expect(std.mem.eql(u8, classify(-5), "negative"));
    try std.testing.expect(std.mem.eql(u8, classify(0), "zero"));
    try std.testing.expect(std.mem.eql(u8, classify(5), "positive"));
}
