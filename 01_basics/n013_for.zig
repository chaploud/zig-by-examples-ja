//! # forループ
//!
//! Zigのforループは配列やスライスの要素を反復処理する。
//! 範囲ベースの反復にも使える。
//!
//! ## 構文
//! - `for (items) |item|`: 要素の反復
//! - `for (items, 0..) |item, i|`: インデックス付き
//! - `for (0..n) |i|`: 範囲の反復
//!
//! ## 特徴
//! - C言語のfor (i=0; i<n; i++) とは異なる
//! - 要素を直接取得（インデックス操作不要）
//! - breakとcontinueが使える

const std = @import("std");

pub fn main() void {
    std.debug.print("=== forループ ===\n\n", .{});

    // ====================
    // 配列の反復
    // ====================

    const numbers = [_]i32{ 10, 20, 30, 40, 50 };

    std.debug.print("配列の反復: ", .{});
    for (numbers) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // インデックス付き反復
    // ====================

    const fruits = [_][]const u8{ "apple", "banana", "cherry" };

    std.debug.print("インデックス付き:\n", .{});
    for (fruits, 0..) |fruit, i| {
        std.debug.print("  [{d}] {s}\n", .{ i, fruit });
    }
    std.debug.print("\n", .{});

    // ====================
    // 範囲の反復
    // ====================

    std.debug.print("0..5: ", .{});
    for (0..5) |i| {
        std.debug.print("{d} ", .{i});
    }
    std.debug.print("\n", .{});

    // 開始位置を指定
    std.debug.print("3..8: ", .{});
    for (3..8) |i| {
        std.debug.print("{d} ", .{i});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // ポインタでの反復（要素の変更）
    // ====================

    var mutable = [_]i32{ 1, 2, 3, 4, 5 };

    std.debug.print("変更前: {any}\n", .{mutable});
    for (&mutable) |*elem| {
        elem.* *= 2;
    }
    std.debug.print("変更後: {any}\n\n", .{mutable});

    // ====================
    // 複数配列の同時反復
    // ====================

    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 10, 20, 30 };

    std.debug.print("複数配列の反復:\n", .{});
    for (a, b) |x, y| {
        std.debug.print("  {d} + {d} = {d}\n", .{ x, y, x + y });
    }
    std.debug.print("\n", .{});

    // ====================
    // breakとcontinue
    // ====================

    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    // break: 早期終了
    std.debug.print("break example: ", .{});
    for (data) |n| {
        if (n > 5) break;
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n", .{});

    // continue: スキップ
    std.debug.print("偶数のみ: ", .{});
    for (data) |n| {
        if (@rem(n, 2) != 0) continue;
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // forのelse節
    // ====================

    const items = [_]i32{ 1, 3, 5, 7 };

    std.debug.print("偶数を探す: ", .{});
    const found = for (items) |item| {
        if (@rem(item, 2) == 0) break item;
    } else blk: {
        std.debug.print("見つからず → ", .{});
        break :blk -1;
    };
    std.debug.print("{d}\n", .{found});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・配列/スライス/範囲を反復\n", .{});
    std.debug.print("・インデックスは 0.. で取得\n", .{});
    std.debug.print("・ポインタで要素を変更可能\n", .{});
}

// ====================
// 実用的な関数例
// ====================

/// 配列の合計を計算
fn sum(arr: []const i32) i32 {
    var total: i32 = 0;
    for (arr) |n| {
        total += n;
    }
    return total;
}

/// 配列の平均を計算
fn average(arr: []const i32) ?f64 {
    if (arr.len == 0) return null;
    const total = sum(arr);
    return @as(f64, @floatFromInt(total)) / @as(f64, @floatFromInt(arr.len));
}

/// 配列内の要素をカウント
fn count(arr: []const i32, target: i32) usize {
    var cnt: usize = 0;
    for (arr) |n| {
        if (n == target) cnt += 1;
    }
    return cnt;
}

/// 最初に見つかったインデックスを返す
fn indexOf(arr: []const i32, target: i32) ?usize {
    for (arr, 0..) |n, i| {
        if (n == target) return i;
    }
    return null;
}

/// 配列をコピー
fn copy(src: []const i32, dest: []i32) void {
    for (src, dest) |s, *d| {
        d.* = s;
    }
}

/// 配列の各要素に関数を適用
fn map(arr: []i32, f: *const fn (i32) i32) void {
    for (arr) |*elem| {
        elem.* = f(elem.*);
    }
}

// --- テスト ---

test "basic for loop" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    var total: i32 = 0;

    for (arr) |n| {
        total += n;
    }

    try std.testing.expectEqual(@as(i32, 15), total);
}

test "for with index" {
    const arr = [_]i32{ 10, 20, 30 };
    var sum_indices: usize = 0;
    var sum_values: i32 = 0;

    for (arr, 0..) |val, i| {
        sum_indices += i;
        sum_values += val;
    }

    try std.testing.expectEqual(@as(usize, 3), sum_indices); // 0 + 1 + 2
    try std.testing.expectEqual(@as(i32, 60), sum_values);
}

test "range for" {
    var total: usize = 0;

    for (0..5) |i| {
        total += i;
    }

    try std.testing.expectEqual(@as(usize, 10), total); // 0 + 1 + 2 + 3 + 4
}

test "range with start" {
    var total: usize = 0;

    for (5..10) |i| {
        total += i;
    }

    try std.testing.expectEqual(@as(usize, 35), total); // 5 + 6 + 7 + 8 + 9
}

test "for with pointer" {
    var arr = [_]i32{ 1, 2, 3 };

    for (&arr) |*elem| {
        elem.* *= 10;
    }

    try std.testing.expectEqual(@as(i32, 10), arr[0]);
    try std.testing.expectEqual(@as(i32, 20), arr[1]);
    try std.testing.expectEqual(@as(i32, 30), arr[2]);
}

test "for with multiple arrays" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 10, 20, 30 };
    var result: [3]i32 = undefined;

    for (a, b, 0..) |x, y, i| {
        result[i] = x + y;
    }

    try std.testing.expectEqual(@as(i32, 11), result[0]);
    try std.testing.expectEqual(@as(i32, 22), result[1]);
    try std.testing.expectEqual(@as(i32, 33), result[2]);
}

test "for with break" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    var last: i32 = 0;

    for (arr) |n| {
        if (n > 3) break;
        last = n;
    }

    try std.testing.expectEqual(@as(i32, 3), last);
}

test "for with continue" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    var sum_even: i32 = 0;

    for (arr) |n| {
        if (@rem(n, 2) != 0) continue;
        sum_even += n;
    }

    try std.testing.expectEqual(@as(i32, 6), sum_even); // 2 + 4
}

test "for else" {
    const arr = [_]i32{ 1, 3, 5, 7 };

    // 偶数を探す（見つからない）
    const found = for (arr) |n| {
        if (@rem(n, 2) == 0) break n;
    } else @as(i32, -1);

    try std.testing.expectEqual(@as(i32, -1), found);

    // 3を探す（見つかる）
    const found2 = for (arr) |n| {
        if (n == 3) break n;
    } else @as(i32, -1);

    try std.testing.expectEqual(@as(i32, 3), found2);
}

test "sum function" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), sum(&arr));
}

test "average function" {
    const arr = [_]i32{ 10, 20, 30 };
    const avg = average(&arr);
    try std.testing.expect(avg != null);
    try std.testing.expect(@abs(avg.? - 20.0) < 0.001);

    const empty: [0]i32 = .{};
    try std.testing.expect(average(&empty) == null);
}

test "count function" {
    const arr = [_]i32{ 1, 2, 2, 3, 2, 4 };
    try std.testing.expectEqual(@as(usize, 3), count(&arr, 2));
    try std.testing.expectEqual(@as(usize, 0), count(&arr, 5));
}

test "indexOf function" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    try std.testing.expectEqual(@as(?usize, 2), indexOf(&arr, 30));
    try std.testing.expect(indexOf(&arr, 99) == null);
}

test "copy function" {
    const src = [_]i32{ 1, 2, 3 };
    var dest: [3]i32 = undefined;

    copy(&src, &dest);

    try std.testing.expectEqual(@as(i32, 1), dest[0]);
    try std.testing.expectEqual(@as(i32, 2), dest[1]);
    try std.testing.expectEqual(@as(i32, 3), dest[2]);
}

test "map function" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };

    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    map(&arr, double);

    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 10), arr[4]);
}
