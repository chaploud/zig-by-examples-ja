//! # 配列
//!
//! Zigの配列は固定長のコンパイル時サイズ。
//! すべての要素は同じ型を持つ。
//!
//! ## 構文
//! - `[N]T`: N個のT型要素の配列
//! - `[_]T{...}`: 要素数を推論
//!
//! ## 特徴
//! - サイズは固定（動的配列はArrayListを使用）
//! - 0インデックスベース
//! - 境界チェックが自動的に行われる（安全性）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== 配列 ===\n\n", .{});

    // ====================
    // 基本的な宣言
    // ====================

    // 明示的にサイズを指定
    const explicit: [4]i32 = .{ 10, 20, 30, 40 };
    std.debug.print("explicit: {any}\n", .{explicit});

    // サイズを推論（[_]を使用）
    const inferred = [_]i32{ 1, 2, 3, 4, 5 };
    std.debug.print("inferred: {any}\n", .{inferred});
    std.debug.print("inferred.len: {d}\n", .{inferred.len});

    std.debug.print("\n", .{});

    // ====================
    // 要素へのアクセス
    // ====================

    const arr = [_]i32{ 100, 200, 300, 400, 500 };

    // インデックスでアクセス（0ベース）
    std.debug.print("arr[0] = {d}\n", .{arr[0]});
    std.debug.print("arr[2] = {d}\n", .{arr[2]});
    std.debug.print("arr[arr.len - 1] = {d}\n", .{arr[arr.len - 1]});

    std.debug.print("\n", .{});

    // ====================
    // 変更可能な配列
    // ====================

    var mutable = [_]i32{ 1, 2, 3 };
    std.debug.print("変更前: {any}\n", .{mutable});
    mutable[0] = 100;
    mutable[2] = 300;
    std.debug.print("変更後: {any}\n", .{mutable});

    std.debug.print("\n", .{});

    // ====================
    // 初期値で埋める
    // ====================

    // 全要素を0で初期化
    const zeros: [5]i32 = .{ 0, 0, 0, 0, 0 };
    std.debug.print("zeros: {any}\n", .{zeros});

    // 同じ値で初期化（**演算子）
    const filled = [_]u8{42} ** 5;
    std.debug.print("filled (42 x 5): {any}\n", .{filled});

    // 連番で初期化（comptime使用）
    const sequential = blk: {
        var arr_init: [5]i32 = undefined;
        for (&arr_init, 0..) |*elem, i| {
            elem.* = @intCast(i * 10);
        }
        break :blk arr_init;
    };
    std.debug.print("sequential: {any}\n", .{sequential});

    std.debug.print("\n", .{});

    // ====================
    // 配列連結（++ 演算子）
    // ====================

    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 4, 5 };
    const combined = a ++ b;
    std.debug.print("a ++ b: {any}\n", .{combined});
    std.debug.print("combined.len: {d}\n", .{combined.len});

    std.debug.print("\n", .{});

    // ====================
    // 配列の繰り返し
    // ====================

    const nums = [_]i32{ 10, 20, 30 };

    // for文でイテレート
    std.debug.print("for loop: ", .{});
    for (nums) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n", .{});

    // インデックス付きでイテレート
    std.debug.print("with index: ", .{});
    for (nums, 0..) |n, i| {
        std.debug.print("[{d}]={d} ", .{ i, n });
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});

    // ====================
    // 多次元配列
    // ====================

    const matrix = [3][3]i32{
        .{ 1, 2, 3 },
        .{ 4, 5, 6 },
        .{ 7, 8, 9 },
    };

    std.debug.print("matrix[1][2] = {d}\n", .{matrix[1][2]});
    std.debug.print("matrix:\n", .{});
    for (matrix) |row| {
        std.debug.print("  {any}\n", .{row});
    }

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・配列サイズは固定（コンパイル時に決定）\n", .{});
    std.debug.print("・境界外アクセスはパニック（安全）\n", .{});
    std.debug.print("・動的配列が必要ならArrayListを使用\n", .{});
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

/// 配列の最大値を取得
fn max(arr: []const i32) ?i32 {
    if (arr.len == 0) return null;
    var result = arr[0];
    for (arr[1..]) |n| {
        if (n > result) result = n;
    }
    return result;
}

/// 配列の要素を2倍にする（in-place）
fn doubleInPlace(arr: []i32) void {
    for (arr) |*elem| {
        elem.* *= 2;
    }
}

/// 配列の要素を逆順にする（in-place）
fn reverse(arr: []i32) void {
    if (arr.len < 2) return;
    var left: usize = 0;
    var right: usize = arr.len - 1;
    while (left < right) {
        const tmp = arr[left];
        arr[left] = arr[right];
        arr[right] = tmp;
        left += 1;
        right -= 1;
    }
}

// --- テスト ---

test "array declaration" {
    const arr1: [3]i32 = .{ 1, 2, 3 };
    const arr2 = [_]i32{ 4, 5, 6 };

    try std.testing.expectEqual(@as(usize, 3), arr1.len);
    try std.testing.expectEqual(@as(usize, 3), arr2.len);
}

test "array access" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    try std.testing.expectEqual(@as(i32, 10), arr[0]);
    try std.testing.expectEqual(@as(i32, 30), arr[2]);
    try std.testing.expectEqual(@as(i32, 50), arr[4]);
    try std.testing.expectEqual(@as(i32, 50), arr[arr.len - 1]);
}

test "mutable array" {
    var arr = [_]i32{ 1, 2, 3 };
    arr[0] = 100;
    arr[2] = 300;

    try std.testing.expectEqual(@as(i32, 100), arr[0]);
    try std.testing.expectEqual(@as(i32, 2), arr[1]);
    try std.testing.expectEqual(@as(i32, 300), arr[2]);
}

test "array concatenation ++" {
    const a = [_]i32{ 1, 2 };
    const b = [_]i32{ 3, 4, 5 };
    const c = a ++ b;

    try std.testing.expectEqual(@as(usize, 5), c.len);
    try std.testing.expectEqual(@as(i32, 1), c[0]);
    try std.testing.expectEqual(@as(i32, 5), c[4]);
}

test "array repetition **" {
    const single = [_]u8{42};
    const repeated = single ** 4;

    try std.testing.expectEqual(@as(usize, 4), repeated.len);
    for (repeated) |elem| {
        try std.testing.expectEqual(@as(u8, 42), elem);
    }
}

test "array iteration" {
    const arr = [_]i32{ 1, 2, 3 };
    var sum_val: i32 = 0;

    for (arr) |n| {
        sum_val += n;
    }

    try std.testing.expectEqual(@as(i32, 6), sum_val);
}

test "array iteration with index" {
    const arr = [_]i32{ 10, 20, 30 };
    var index_sum: usize = 0;

    for (arr, 0..) |_, i| {
        index_sum += i;
    }

    try std.testing.expectEqual(@as(usize, 3), index_sum); // 0 + 1 + 2
}

test "multidimensional array" {
    const matrix = [2][3]i32{
        .{ 1, 2, 3 },
        .{ 4, 5, 6 },
    };

    try std.testing.expectEqual(@as(i32, 1), matrix[0][0]);
    try std.testing.expectEqual(@as(i32, 6), matrix[1][2]);
    try std.testing.expectEqual(@as(usize, 2), matrix.len);
    try std.testing.expectEqual(@as(usize, 3), matrix[0].len);
}

test "sum function" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), sum(&arr));
}

test "max function" {
    const arr = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };
    try std.testing.expectEqual(@as(?i32, 9), max(&arr));

    const empty: [0]i32 = .{};
    try std.testing.expect(max(&empty) == null);
}

test "doubleInPlace function" {
    var arr = [_]i32{ 1, 2, 3 };
    doubleInPlace(&arr);

    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 4), arr[1]);
    try std.testing.expectEqual(@as(i32, 6), arr[2]);
}

test "reverse function" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    reverse(&arr);

    try std.testing.expectEqual(@as(i32, 5), arr[0]);
    try std.testing.expectEqual(@as(i32, 4), arr[1]);
    try std.testing.expectEqual(@as(i32, 3), arr[2]);
    try std.testing.expectEqual(@as(i32, 2), arr[3]);
    try std.testing.expectEqual(@as(i32, 1), arr[4]);
}

test "array to slice" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const slice: []const i32 = &arr;

    try std.testing.expectEqual(@as(usize, 5), slice.len);
    try std.testing.expectEqual(@as(i32, 1), slice[0]);
}

test "array equality" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 3 };
    const c = [_]i32{ 1, 2, 4 };

    try std.testing.expect(std.mem.eql(i32, &a, &b));
    try std.testing.expect(!std.mem.eql(i32, &a, &c));
}
