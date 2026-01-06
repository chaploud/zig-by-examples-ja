//! # 真偽値型（bool）
//!
//! Zigの `bool` 型は `true` または `false` の2値のみを持つ。
//! 条件分岐、論理演算、フラグ管理などに使用する。
//!
//! ## 特徴
//! - サイズ: 1バイト（内部的にはu1として扱える）
//! - 整数への暗黙変換はない（安全性のため）
//! - 論理演算子: `and`, `or`, `!`（not）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== 真偽値型（bool） ===\n\n", .{});

    // ====================
    // 基本的な宣言
    // ====================

    const is_active: bool = true;
    const is_disabled: bool = false;

    std.debug.print("is_active: {}\n", .{is_active});
    std.debug.print("is_disabled: {}\n", .{is_disabled});

    std.debug.print("\n", .{});

    // ====================
    // 論理演算子
    // ====================

    const a: bool = true;
    const b: bool = false;

    std.debug.print("a = {}, b = {}\n", .{ a, b });
    std.debug.print("a and b = {}\n", .{a and b}); // AND
    std.debug.print("a or b  = {}\n", .{a or b}); // OR
    std.debug.print("!a      = {}\n", .{!a}); // NOT
    std.debug.print("!b      = {}\n", .{!b}); // NOT

    std.debug.print("\n", .{});

    // ====================
    // 比較演算の結果
    // ====================

    const x: i32 = 10;
    const y: i32 = 20;

    std.debug.print("x = {d}, y = {d}\n", .{ x, y });
    std.debug.print("x == y: {}\n", .{x == y});
    std.debug.print("x != y: {}\n", .{x != y});
    std.debug.print("x < y:  {}\n", .{x < y});
    std.debug.print("x > y:  {}\n", .{x > y});
    std.debug.print("x <= y: {}\n", .{x <= y});
    std.debug.print("x >= y: {}\n", .{x >= y});

    std.debug.print("\n", .{});

    // ====================
    // 条件式での使用
    // ====================

    const score: i32 = 85;
    const passed = score >= 60;

    if (passed) {
        std.debug.print("テスト合格（スコア: {d}）\n", .{score});
    } else {
        std.debug.print("テスト不合格（スコア: {d}）\n", .{score});
    }

    // 複合条件
    const is_valid = score >= 0 and score <= 100;
    std.debug.print("スコアは有効範囲内: {}\n", .{is_valid});

    std.debug.print("\n", .{});

    // ====================
    // 短絡評価
    // ====================

    // `and` と `or` は短絡評価を行う
    // 左辺で結果が確定すれば右辺は評価されない

    const result = false and dangerousFunction(); // 右辺は呼ばれない
    std.debug.print("短絡評価の結果: {}\n", .{result});

    const result2 = true or dangerousFunction(); // 右辺は呼ばれない
    std.debug.print("短絡評価の結果2: {}\n", .{result2});

    std.debug.print("\n", .{});

    // ====================
    // 整数との変換
    // ====================

    // boolから整数へ（明示的キャスト必要）
    const flag: bool = true;
    const as_int: u1 = @intFromBool(flag);
    std.debug.print("true → u1: {d}\n", .{as_int});

    const flag2: bool = false;
    const as_int2: u8 = @intFromBool(flag2);
    std.debug.print("false → u8: {d}\n", .{as_int2});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・boolは暗黙の整数変換なし（安全性）\n", .{});
    std.debug.print("・and/orは短絡評価を行う\n", .{});
    std.debug.print("・比較演算子の結果はbool\n", .{});
}

fn dangerousFunction() bool {
    // この関数が呼ばれたら標準出力にメッセージを出す
    std.debug.print("危険な関数が呼ばれた!\n", .{});
    return true;
}

// ====================
// 実用例
// ====================

/// 範囲内かどうかをチェック
fn isInRange(value: i32, min: i32, max: i32) bool {
    return value >= min and value <= max;
}

/// どれか1つでも真かチェック
fn anyTrue(values: []const bool) bool {
    for (values) |v| {
        if (v) return true;
    }
    return false;
}

/// すべて真かチェック
fn allTrue(values: []const bool) bool {
    for (values) |v| {
        if (!v) return false;
    }
    return true;
}

// --- テスト ---

test "bool values" {
    const t: bool = true;
    const f: bool = false;
    try std.testing.expect(t);
    try std.testing.expect(!f);
}

test "logical operators" {
    // AND
    try std.testing.expect(true and true);
    try std.testing.expect(!(true and false));
    try std.testing.expect(!(false and true));
    try std.testing.expect(!(false and false));

    // OR
    try std.testing.expect(true or true);
    try std.testing.expect(true or false);
    try std.testing.expect(false or true);
    try std.testing.expect(!(false or false));

    // NOT
    try std.testing.expect(!false);
    try std.testing.expect(!!true);
}

test "comparison operators" {
    try std.testing.expect(5 == 5);
    try std.testing.expect(5 != 6);
    try std.testing.expect(5 < 6);
    try std.testing.expect(6 > 5);
    try std.testing.expect(5 <= 5);
    try std.testing.expect(5 >= 5);
}

test "combined conditions" {
    const x: i32 = 15;

    // 複合条件
    try std.testing.expect(x > 10 and x < 20);
    try std.testing.expect(x == 15 or x == 20);
    try std.testing.expect(!(x < 10 or x > 20));
}

test "short circuit evaluation" {
    // 短絡評価: 左辺で結果が確定すれば右辺は評価されない
    var side_effect = false;

    // false and ... → 右辺は評価されない
    _ = false and blk: {
        side_effect = true;
        break :blk true;
    };
    try std.testing.expect(!side_effect);

    // true or ... → 右辺は評価されない
    _ = true or blk: {
        side_effect = true;
        break :blk false;
    };
    try std.testing.expect(!side_effect);
}

test "bool to int conversion" {
    try std.testing.expectEqual(@as(u1, 1), @intFromBool(true));
    try std.testing.expectEqual(@as(u1, 0), @intFromBool(false));
    try std.testing.expectEqual(@as(u8, 1), @intFromBool(true));
    try std.testing.expectEqual(@as(i32, 0), @intFromBool(false));
}

test "isInRange function" {
    try std.testing.expect(isInRange(5, 0, 10));
    try std.testing.expect(isInRange(0, 0, 10)); // 境界値
    try std.testing.expect(isInRange(10, 0, 10)); // 境界値
    try std.testing.expect(!isInRange(-1, 0, 10));
    try std.testing.expect(!isInRange(11, 0, 10));
}

test "anyTrue function" {
    try std.testing.expect(anyTrue(&[_]bool{ false, false, true }));
    try std.testing.expect(anyTrue(&[_]bool{ true, false, false }));
    try std.testing.expect(!anyTrue(&[_]bool{ false, false, false }));
    try std.testing.expect(anyTrue(&[_]bool{ true, true, true }));
}

test "allTrue function" {
    try std.testing.expect(allTrue(&[_]bool{ true, true, true }));
    try std.testing.expect(!allTrue(&[_]bool{ true, false, true }));
    try std.testing.expect(!allTrue(&[_]bool{ false, false, false }));
}

test "bool array operations" {
    const flags = [_]bool{ true, false, true, true };

    // trueの数をカウント
    var count: usize = 0;
    for (flags) |f| {
        if (f) count += 1;
    }
    try std.testing.expectEqual(@as(usize, 3), count);
}

test "conditional expression result" {
    const x: i32 = 10;
    const y: i32 = 20;

    // 条件式の結果をbool変数に格納
    const is_x_larger = x > y;
    try std.testing.expect(!is_x_larger);

    const is_y_larger = y > x;
    try std.testing.expect(is_y_larger);
}
