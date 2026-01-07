//! # ブロックとラベル
//!
//! Zigのブロックはスコープを作成し、値を返せる。
//! ラベル付きブロックでbreakやcontinueの制御が可能。
//!
//! ## 用途
//! - 式としてのブロック（値を返す）
//! - ラベル付きbreak/continue
//! - ネストしたループからの脱出

const std = @import("std");

// ====================
// 基本的なブロック
// ====================

fn basicBlock() void {
    std.debug.print("--- 基本的なブロック ---\n", .{});

    // ブロックは独自のスコープを作る
    {
        const x = 10;
        std.debug.print("ブロック内: x = {d}\n", .{x});
    }
    // x はここでは見えない

    // 同名の変数を別のブロックで使える
    {
        const x = 20;
        std.debug.print("別ブロック: x = {d}\n", .{x});
    }

    std.debug.print("\n", .{});
}

// ====================
// 式としてのブロック
// ====================

fn blockAsExpression() void {
    std.debug.print("--- 式としてのブロック ---\n", .{});

    // ブロックは値を返せる
    const value = blk: {
        const a = 10;
        const b = 20;
        break :blk a + b;
    };
    std.debug.print("ブロックの結果: {d}\n", .{value});

    // 条件によって異なる値を返す
    const is_even = true;
    const result = blk: {
        if (is_even) {
            break :blk @as(i32, 2);
        } else {
            break :blk @as(i32, 1);
        }
    };
    std.debug.print("条件付き結果: {d}\n", .{result});

    // 複雑な初期化
    const computed: i32 = init: {
        var sum: i32 = 0;
        for (0..10) |i| {
            sum += @as(i32, @intCast(i));
        }
        break :init sum;
    };
    std.debug.print("計算結果: {d}\n", .{computed});

    std.debug.print("\n", .{});
}

// ====================
// ラベル付きループ
// ====================

fn labeledLoop() void {
    std.debug.print("--- ラベル付きループ ---\n", .{});

    // 外側ループにラベル
    var found_i: usize = 0;
    var found_j: usize = 0;

    outer: for (0..5) |i| {
        for (0..5) |j| {
            if (i * j > 6) {
                found_i = i;
                found_j = j;
                break :outer;
            }
        }
    }

    std.debug.print("break :outer で脱出: i={d}, j={d}\n", .{ found_i, found_j });

    // continue :outer
    var skipped_count: u32 = 0;
    outer: for (0..3) |_| {
        for (0..3) |j| {
            if (j == 1) {
                skipped_count += 1;
                continue :outer;
            }
            std.debug.print("  j={d}\n", .{j});
        }
    }
    std.debug.print("continue :outer 回数: {d}\n", .{skipped_count});

    std.debug.print("\n", .{});
}

// ====================
// whileでのラベル
// ====================

fn labeledWhile() void {
    std.debug.print("--- ラベル付きwhile ---\n", .{});

    var i: u32 = 0;
    var j: u32 = 0;
    var iterations: u32 = 0;

    outer: while (i < 3) : (i += 1) {
        j = 0;
        while (j < 3) : (j += 1) {
            iterations += 1;
            if (i == 1 and j == 1) {
                std.debug.print("  i={d}, j={d} で外側へcontinue\n", .{ i, j });
                continue :outer;
            }
        }
    }

    std.debug.print("総イテレーション: {d}\n", .{iterations});
    std.debug.print("\n", .{});
}

// ====================
// ブロックとdefer
// ====================

fn blockWithDefer() void {
    std.debug.print("--- ブロックとdefer ---\n", .{});

    {
        defer std.debug.print("  内側ブロックのdefer\n", .{});
        std.debug.print("  内側ブロック処理\n", .{});
    }

    defer std.debug.print("  外側のdefer\n", .{});
    std.debug.print("  外側処理\n", .{});
}

// ====================
// 実用例: 検索
// ====================

fn findValue(matrix: []const []const i32, target: i32) ?struct { row: usize, col: usize } {
    for (matrix, 0..) |row, i| {
        for (row, 0..) |val, j| {
            if (val == target) {
                return .{ .row = i, .col = j };
            }
        }
    }
    return null;
}

// ラベル付きブロックを使った検索
fn findWithLabel(matrix: []const []const i32, target: i32) ?struct { row: usize, col: usize } {
    return search: {
        for (matrix, 0..) |row, i| {
            for (row, 0..) |val, j| {
                if (val == target) {
                    break :search .{ .row = i, .col = j };
                }
            }
        }
        break :search null;
    };
}

fn searchDemo() void {
    std.debug.print("--- 検索の例 ---\n", .{});

    const matrix = [_][]const i32{
        &[_]i32{ 1, 2, 3 },
        &[_]i32{ 4, 5, 6 },
        &[_]i32{ 7, 8, 9 },
    };

    if (findValue(&matrix, 5)) |pos| {
        std.debug.print("5の位置: ({d}, {d})\n", .{ pos.row, pos.col });
    }

    if (findWithLabel(&matrix, 8)) |pos| {
        std.debug.print("8の位置: ({d}, {d})\n", .{ pos.row, pos.col });
    }

    if (findValue(&matrix, 10)) |_| {
        std.debug.print("10が見つかった\n", .{});
    } else {
        std.debug.print("10は見つからない\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// コンパイル時ブロック
// ====================

fn comptimeBlock() void {
    std.debug.print("--- コンパイル時ブロック ---\n", .{});

    const sum = comptime blk: {
        var s: i32 = 0;
        for (0..100) |i| {
            s += @as(i32, @intCast(i));
        }
        break :blk s;
    };

    std.debug.print("コンパイル時計算: 0..99の合計 = {d}\n", .{sum});

    // 型を返すブロック
    const T = comptime blk: {
        const use_64bit = true;
        if (use_64bit) {
            break :blk i64;
        } else {
            break :blk i32;
        }
    };
    const value: T = 12345678901234;
    std.debug.print("コンパイル時選択型: {d}\n", .{value});

    std.debug.print("\n", .{});
}

// ====================
// ネストしたスコープ
// ====================

fn nestedScopes() void {
    std.debug.print("--- ネストしたスコープ ---\n", .{});

    // Zigではシャドウイングは許可されていない
    // 各スコープで異なる名前を使う必要がある

    const outer_x: i32 = 1;
    std.debug.print("outer_x = {d}\n", .{outer_x});

    {
        const inner_x: i32 = 2;
        std.debug.print("  inner_x = {d}\n", .{inner_x});

        {
            const innermost_x: i32 = 3;
            std.debug.print("    innermost_x = {d}\n", .{innermost_x});
        }

        std.debug.print("  inner_x = {d} (戻った)\n", .{inner_x});
    }

    std.debug.print("outer_x = {d} (最外側)\n", .{outer_x});
    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ブロックとラベル ===\n\n", .{});

    basicBlock();
    blockAsExpression();
    labeledLoop();
    labeledWhile();
    blockWithDefer();
    std.debug.print("\n", .{});
    searchDemo();
    comptimeBlock();
    nestedScopes();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・ブロックは独自のスコープを作る\n", .{});
    std.debug.print("・blk: {{ break :blk value; }} で値を返す\n", .{});
    std.debug.print("・ラベル付きbreak/continueで制御\n", .{});
    std.debug.print("・comptimeブロックでコンパイル時計算\n", .{});
}

// --- テスト ---

test "block as expression" {
    const result = blk: {
        const a = 10;
        const b = 20;
        break :blk a + b;
    };
    try std.testing.expectEqual(@as(i32, 30), result);
}

test "labeled break" {
    var found = false;

    outer: for (0..10) |i| {
        for (0..10) |j| {
            if (i * j > 50) {
                found = true;
                break :outer;
            }
        }
    }

    try std.testing.expect(found);
}

test "labeled continue" {
    var count: u32 = 0;

    outer: for (0..3) |_| {
        for (0..5) |j| {
            if (j == 2) {
                continue :outer;
            }
            count += 1;
        }
    }

    // 各外側イテレーションで j=0,1 の2回カウント
    try std.testing.expectEqual(@as(u32, 6), count);
}

test "findValue" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 2, 3 },
        &[_]i32{ 4, 5, 6 },
        &[_]i32{ 7, 8, 9 },
    };

    if (findValue(&matrix, 5)) |pos| {
        try std.testing.expectEqual(@as(usize, 1), pos.row);
        try std.testing.expectEqual(@as(usize, 1), pos.col);
    } else {
        try std.testing.expect(false);
    }

    try std.testing.expect(findValue(&matrix, 10) == null);
}

test "findWithLabel" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 2, 3 },
        &[_]i32{ 4, 5, 6 },
        &[_]i32{ 7, 8, 9 },
    };

    if (findWithLabel(&matrix, 9)) |pos| {
        try std.testing.expectEqual(@as(usize, 2), pos.row);
        try std.testing.expectEqual(@as(usize, 2), pos.col);
    } else {
        try std.testing.expect(false);
    }
}

test "comptime block" {
    const factorial_5 = comptime blk: {
        var result: u64 = 1;
        for (1..6) |i| {
            result *= i;
        }
        break :blk result;
    };

    try std.testing.expectEqual(@as(u64, 120), factorial_5);
}

test "nested block scopes" {
    var outer_value: i32 = 0;

    {
        var inner_value: i32 = 10;
        outer_value = inner_value;
        _ = &inner_value;
    }

    try std.testing.expectEqual(@as(i32, 10), outer_value);
}

test "block with conditional break" {
    const condition = true;
    const result = blk: {
        if (condition) {
            break :blk @as(i32, 100);
        }
        break :blk @as(i32, 0);
    };

    try std.testing.expectEqual(@as(i32, 100), result);
}
