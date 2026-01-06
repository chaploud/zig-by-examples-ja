//! # スライス
//!
//! スライスは配列の一部への「ビュー」を提供する。
//! ポインタと長さのペアで構成される。
//!
//! ## 構文
//! - `[]T`: T型のスライス
//! - `[]const T`: 読み取り専用スライス
//! - `arr[start..end]`: 範囲指定でスライス作成
//!
//! ## 配列との違い
//! - 配列: サイズがコンパイル時に決定、値を所有
//! - スライス: サイズが実行時に決定、ビュー（参照）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== スライス ===\n\n", .{});

    // ====================
    // 配列からスライスを作成
    // ====================

    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // 配列全体のスライス
    const all: []const i32 = &arr;
    std.debug.print("全体: {any}, len={d}\n", .{ all, all.len });

    // 範囲を指定してスライス（終端は含まない）
    const part = arr[1..4]; // インデックス1, 2, 3
    std.debug.print("arr[1..4]: {any}\n", .{part});

    // 開始のみ指定（終端まで）
    const from2 = arr[2..];
    std.debug.print("arr[2..]: {any}\n", .{from2});

    // 終端のみ指定（先頭から）
    const to3 = arr[0..3];
    std.debug.print("arr[0..3]: {any}\n", .{to3});

    std.debug.print("\n", .{});

    // ====================
    // スライスのプロパティ
    // ====================

    const slice = arr[1..4];
    std.debug.print("slice.len: {d}\n", .{slice.len});
    std.debug.print("slice.ptr: {*}\n", .{slice.ptr});

    std.debug.print("\n", .{});

    // ====================
    // スライスへのポインタ変換
    // ====================

    var mutable = [_]i32{ 1, 2, 3, 4, 5 };

    // 可変スライス
    var mutable_slice: []i32 = &mutable;
    mutable_slice[0] = 100;
    std.debug.print("変更後: {any}\n", .{mutable_slice});

    // 元の配列も変更される（ビューなので）
    std.debug.print("元の配列: {any}\n", .{mutable});

    std.debug.print("\n", .{});

    // ====================
    // スライスの反復
    // ====================

    const nums: []const i32 = &[_]i32{ 5, 10, 15, 20 };

    std.debug.print("for loop: ", .{});
    for (nums) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n", .{});

    // インデックス付き
    std.debug.print("with index: ", .{});
    for (nums, 0..) |n, i| {
        std.debug.print("[{d}]={d} ", .{ i, n });
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});

    // ====================
    // スライスからスライス
    // ====================

    const original: []const i32 = &[_]i32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    const sub = original[2..7]; // [2, 3, 4, 5, 6]
    const sub_sub = sub[1..3]; // [3, 4]

    std.debug.print("original: {any}\n", .{original});
    std.debug.print("sub (original[2..7]): {any}\n", .{sub});
    std.debug.print("sub_sub (sub[1..3]): {any}\n", .{sub_sub});

    std.debug.print("\n", .{});

    // ====================
    // 関数にスライスを渡す
    // ====================

    const data = [_]i32{ 1, 2, 3, 4, 5 };
    const total = sum(&data);
    std.debug.print("sum(&data): {d}\n", .{total});

    // 部分的なスライスも渡せる
    const partial_sum = sum(data[1..4]);
    std.debug.print("sum(data[1..4]): {d}\n", .{partial_sum});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・スライスは元データへの参照（コピーしない）\n", .{});
    std.debug.print("・境界チェックで安全性を確保\n", .{});
    std.debug.print("・関数の引数には配列よりスライスを使う\n", .{});
}

/// スライスの合計を計算
fn sum(slice: []const i32) i32 {
    var total: i32 = 0;
    for (slice) |n| {
        total += n;
    }
    return total;
}

// ====================
// スライス操作関数
// ====================

/// 指定した値で始まる要素を除去したスライスを返す
fn trimStart(slice: []const i32, value: i32) []const i32 {
    var i: usize = 0;
    while (i < slice.len and slice[i] == value) : (i += 1) {}
    return slice[i..];
}

/// スライス内に値が存在するか
fn contains(slice: []const i32, value: i32) bool {
    for (slice) |item| {
        if (item == value) return true;
    }
    return false;
}

/// 2つのスライスが等しいか
fn equal(a: []const i32, b: []const i32) bool {
    return std.mem.eql(i32, a, b);
}

/// スライスの要素を逆順にコピー
fn reverseCopy(src: []const i32, dest: []i32) void {
    std.debug.assert(src.len == dest.len);
    var i: usize = 0;
    while (i < src.len) : (i += 1) {
        dest[dest.len - 1 - i] = src[i];
    }
}

// --- テスト ---

test "slice from array" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const slice: []const i32 = &arr;

    try std.testing.expectEqual(@as(usize, 5), slice.len);
    try std.testing.expectEqual(@as(i32, 1), slice[0]);
    try std.testing.expectEqual(@as(i32, 5), slice[4]);
}

test "slice range" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // [start..end] は end を含まない
    const slice1 = arr[1..4];
    try std.testing.expectEqual(@as(usize, 3), slice1.len);
    try std.testing.expectEqual(@as(i32, 20), slice1[0]);
    try std.testing.expectEqual(@as(i32, 40), slice1[2]);
}

test "slice start only" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const slice = arr[2..];

    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 3), slice[0]);
}

test "slice end only" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const slice = arr[0..3];

    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 3), slice[2]);
}

test "mutable slice" {
    var arr = [_]i32{ 1, 2, 3 };
    const slice: []i32 = &arr;

    slice[1] = 100;

    try std.testing.expectEqual(@as(i32, 100), arr[1]);
    try std.testing.expectEqual(@as(i32, 100), slice[1]);
}

test "slice of slice" {
    const arr = [_]i32{ 0, 1, 2, 3, 4, 5 };
    const s1 = arr[1..5]; // [1, 2, 3, 4]
    const s2 = s1[1..3]; // [2, 3]

    try std.testing.expectEqual(@as(usize, 2), s2.len);
    try std.testing.expectEqual(@as(i32, 2), s2[0]);
    try std.testing.expectEqual(@as(i32, 3), s2[1]);
}

test "sum function with slice" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), sum(&arr));
    try std.testing.expectEqual(@as(i32, 9), sum(arr[1..4])); // 2 + 3 + 4
}

test "trimStart function" {
    const arr = [_]i32{ 0, 0, 0, 1, 2, 3 };
    const trimmed = trimStart(&arr, 0);

    try std.testing.expectEqual(@as(usize, 3), trimmed.len);
    try std.testing.expectEqual(@as(i32, 1), trimmed[0]);
}

test "contains function" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    try std.testing.expect(contains(&arr, 3));
    try std.testing.expect(!contains(&arr, 10));
}

test "equal function" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 3 };
    const c = [_]i32{ 1, 2, 4 };

    try std.testing.expect(equal(&a, &b));
    try std.testing.expect(!equal(&a, &c));
}

test "reverseCopy function" {
    const src = [_]i32{ 1, 2, 3, 4, 5 };
    var dest: [5]i32 = undefined;

    reverseCopy(&src, &dest);

    try std.testing.expectEqual(@as(i32, 5), dest[0]);
    try std.testing.expectEqual(@as(i32, 1), dest[4]);
}

test "slice len property" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const slice = arr[3..8];

    try std.testing.expectEqual(@as(usize, 5), slice.len);
}

test "empty slice" {
    const arr = [_]i32{ 1, 2, 3 };
    const empty = arr[1..1]; // 空のスライス

    try std.testing.expectEqual(@as(usize, 0), empty.len);
}

test "slice iteration" {
    const arr = [_]i32{ 1, 2, 3 };
    const slice: []const i32 = &arr;

    var sum_val: i32 = 0;
    for (slice) |n| {
        sum_val += n;
    }

    try std.testing.expectEqual(@as(i32, 6), sum_val);
}

test "slice with sentinel" {
    // センチネル付きスライス（null終端文字列など）
    const str: [:0]const u8 = "hello";
    try std.testing.expectEqual(@as(usize, 5), str.len);
    try std.testing.expectEqual(@as(u8, 0), str[str.len]);
}
