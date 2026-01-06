//! # whileループ
//!
//! 条件が真である間、繰り返し処理を行う。
//! forループより柔軟だが、使い方を誤ると無限ループになりやすい。
//!
//! ## 構文
//! - `while (条件) { ... }`: 基本形
//! - `while (条件) : (更新) { ... }`: 更新式付き
//! - `while (optional) |value| { ... }`: optionalのアンラップ
//!
//! ## 特徴
//! - 条件が偽になるまで繰り返す
//! - break/continueが使える
//! - else節も使える

const std = @import("std");

pub fn main() void {
    std.debug.print("=== whileループ ===\n\n", .{});

    // ====================
    // 基本的なwhileループ
    // ====================

    var i: u32 = 0;
    std.debug.print("基本形: ", .{});
    while (i < 5) {
        std.debug.print("{d} ", .{i});
        i += 1;
    }
    std.debug.print("\n\n", .{});

    // ====================
    // 更新式付きwhile
    // ====================

    var j: u32 = 0;
    std.debug.print("更新式付き: ", .{});
    while (j < 5) : (j += 1) {
        std.debug.print("{d} ", .{j});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // break
    // ====================

    var k: u32 = 0;
    std.debug.print("break example: ", .{});
    while (k < 100) : (k += 1) {
        if (k >= 5) break;
        std.debug.print("{d} ", .{k});
    }
    std.debug.print("\n", .{});
    std.debug.print("k after break: {d}\n\n", .{k});

    // ====================
    // continue
    // ====================

    var m: u32 = 0;
    std.debug.print("偶数のみ (continue): ", .{});
    while (m < 10) : (m += 1) {
        if (m % 2 != 0) continue;
        std.debug.print("{d} ", .{m});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // breakで値を返す
    // ====================

    var n: u32 = 0;
    const found = while (n < 100) : (n += 1) {
        if (n * n > 50) break n;
    } else @as(u32, 0);

    std.debug.print("n*n > 50 となる最小のn: {d}\n\n", .{found});

    // ====================
    // else節
    // ====================

    var p: u32 = 0;
    const result = while (p < 5) : (p += 1) {
        if (p == 10) break p; // この条件は満たされない
    } else blk: {
        std.debug.print("ループ正常終了 → ", .{});
        break :blk @as(u32, 999);
    };
    std.debug.print("else result: {d}\n\n", .{result});

    // ====================
    // optionalのアンラップ
    // ====================

    var nums = [_]i32{ 1, 2, 3 };
    var iter = Iterator{ .items = &nums, .index = 0 };

    std.debug.print("optional unwrap: ", .{});
    while (iter.next()) |val| {
        std.debug.print("{d} ", .{val});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // ラベル付きwhile
    // ====================

    var outer: u32 = 0;
    std.debug.print("labeled break: ", .{});
    outer_loop: while (outer < 3) : (outer += 1) {
        var inner: u32 = 0;
        while (inner < 3) : (inner += 1) {
            if (outer == 1 and inner == 1) {
                std.debug.print("[break] ", .{});
                break :outer_loop;
            }
            std.debug.print("({d},{d}) ", .{ outer, inner });
        }
    }
    std.debug.print("\n", .{});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・条件が偽になるまで繰り返す\n", .{});
    std.debug.print("・更新式は : (expr) で指定\n", .{});
    std.debug.print("・optional/errorのアンラップも可能\n", .{});
}

// シンプルなイテレータ
const Iterator = struct {
    items: []const i32,
    index: usize,

    fn next(self: *Iterator) ?i32 {
        if (self.index >= self.items.len) return null;
        const item = self.items[self.index];
        self.index += 1;
        return item;
    }
};

// ====================
// 実用的な関数例
// ====================

/// 最大公約数（ユークリッドの互除法）
fn gcd(a: u32, b: u32) u32 {
    var x = a;
    var y = b;
    while (y != 0) {
        const temp = y;
        y = x % y;
        x = temp;
    }
    return x;
}

/// 最小公倍数
fn lcm(a: u32, b: u32) u32 {
    return (a * b) / gcd(a, b);
}

/// 累乗計算（整数）
fn power(base: u32, exp: u32) u32 {
    var result: u32 = 1;
    var e = exp;
    while (e > 0) : (e -= 1) {
        result *= base;
    }
    return result;
}

/// 数字の桁数を数える
fn countDigits(n: u32) u32 {
    if (n == 0) return 1;
    var count: u32 = 0;
    var num = n;
    while (num > 0) : (num /= 10) {
        count += 1;
    }
    return count;
}

/// 文字列内の文字を数える
fn countChar(s: []const u8, c: u8) usize {
    var count: usize = 0;
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == c) count += 1;
    }
    return count;
}

// --- テスト ---

test "basic while" {
    var i: u32 = 0;
    var sum: u32 = 0;
    while (i < 5) {
        sum += i;
        i += 1;
    }
    try std.testing.expectEqual(@as(u32, 10), sum); // 0+1+2+3+4
}

test "while with update" {
    var i: u32 = 0;
    var sum: u32 = 0;
    while (i < 5) : (i += 1) {
        sum += i;
    }
    try std.testing.expectEqual(@as(u32, 10), sum);
    try std.testing.expectEqual(@as(u32, 5), i);
}

test "while with break" {
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        if (i == 5) break;
    }
    try std.testing.expectEqual(@as(u32, 5), i);
}

test "while with continue" {
    var i: u32 = 0;
    var sum: u32 = 0;
    while (i < 10) : (i += 1) {
        if (i % 2 != 0) continue;
        sum += i;
    }
    try std.testing.expectEqual(@as(u32, 20), sum); // 0+2+4+6+8
}

test "while break with value" {
    var i: u32 = 0;
    const found = while (i < 100) : (i += 1) {
        if (i * i > 50) break i;
    } else @as(u32, 0);

    try std.testing.expectEqual(@as(u32, 8), found); // 8*8 = 64 > 50
}

test "while else" {
    var i: u32 = 0;
    const result = while (i < 5) : (i += 1) {
        if (i == 10) break i;
    } else @as(u32, 999);

    try std.testing.expectEqual(@as(u32, 999), result);
}

test "while with optional" {
    var nums = [_]i32{ 1, 2, 3 };
    var iter = Iterator{ .items = &nums, .index = 0 };

    var sum: i32 = 0;
    while (iter.next()) |val| {
        sum += val;
    }

    try std.testing.expectEqual(@as(i32, 6), sum);
}

test "labeled while" {
    var outer: u32 = 0;
    var count: u32 = 0;

    outer_loop: while (outer < 3) : (outer += 1) {
        var inner: u32 = 0;
        while (inner < 3) : (inner += 1) {
            count += 1;
            if (outer == 1 and inner == 1) {
                break :outer_loop;
            }
        }
    }

    try std.testing.expectEqual(@as(u32, 5), count); // (0,0)(0,1)(0,2)(1,0)(1,1)
}

test "gcd function" {
    try std.testing.expectEqual(@as(u32, 6), gcd(12, 18));
    try std.testing.expectEqual(@as(u32, 1), gcd(17, 13));
    try std.testing.expectEqual(@as(u32, 5), gcd(5, 0));
}

test "lcm function" {
    try std.testing.expectEqual(@as(u32, 36), lcm(12, 18));
    try std.testing.expectEqual(@as(u32, 12), lcm(3, 4));
}

test "power function" {
    try std.testing.expectEqual(@as(u32, 1), power(2, 0));
    try std.testing.expectEqual(@as(u32, 8), power(2, 3));
    try std.testing.expectEqual(@as(u32, 1000), power(10, 3));
}

test "countDigits function" {
    try std.testing.expectEqual(@as(u32, 1), countDigits(0));
    try std.testing.expectEqual(@as(u32, 1), countDigits(5));
    try std.testing.expectEqual(@as(u32, 3), countDigits(123));
    try std.testing.expectEqual(@as(u32, 5), countDigits(12345));
}

test "countChar function" {
    try std.testing.expectEqual(@as(usize, 3), countChar("hello world", 'l'));
    try std.testing.expectEqual(@as(usize, 2), countChar("hello world", 'o'));
    try std.testing.expectEqual(@as(usize, 0), countChar("hello world", 'z'));
}

test "infinite loop prevention" {
    // whileループが適切に終了することを確認
    var i: u32 = 0;
    const max_iterations: u32 = 1000;

    while (i < max_iterations) : (i += 1) {
        // 何かの処理
    }

    try std.testing.expectEqual(@as(u32, 1000), i);
}
