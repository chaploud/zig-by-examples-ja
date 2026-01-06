//! # Optional型
//!
//! Zigではデフォルトですべての値が非null。
//! `?T` を使うと「値があるか、またはnull」を表現できる。
//!
//! ## なぜOptionalが必要か
//! - 値が存在しない可能性を型で明示
//! - nullチェックを強制（安全性）
//! - C言語のnullポインタ問題を防ぐ
//!
//! ## Optionalの使い方
//! - `?T`: 型Tのoptional
//! - `null`: 値がないことを示す
//! - `orelse`: デフォルト値を指定
//! - `if (opt) |value|`: アンラップして使用
//! - `.?`: 強制アンラップ（nullならパニック）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== Optional型 ===\n\n", .{});

    // ====================
    // 基本的な宣言
    // ====================

    // ?i32 は「i32の値またはnull」
    const maybe_num: ?i32 = 42;
    const no_num: ?i32 = null;

    std.debug.print("maybe_num: {?d}\n", .{maybe_num});
    std.debug.print("no_num: {?d}\n", .{no_num});

    std.debug.print("\n", .{});

    // ====================
    // orelse（デフォルト値）
    // ====================

    // nullの場合にデフォルト値を使用
    const value1: i32 = maybe_num orelse 0;
    const value2: i32 = no_num orelse -1;

    std.debug.print("maybe_num orelse 0: {d}\n", .{value1});
    std.debug.print("no_num orelse -1: {d}\n", .{value2});

    std.debug.print("\n", .{});

    // ====================
    // if文でのアンラップ
    // ====================

    // optionalをifでチェックしてアンラップ
    if (maybe_num) |num| {
        std.debug.print("値がある: {d}\n", .{num});
    } else {
        std.debug.print("値がない\n", .{});
    }

    if (no_num) |num| {
        std.debug.print("値がある: {d}\n", .{num});
    } else {
        std.debug.print("値がない（no_num）\n", .{});
    }

    std.debug.print("\n", .{});

    // ====================
    // while文でのOptional
    // ====================

    // イテレータパターンでよく使われる
    var numbers = [_]i32{ 1, 2, 3 };
    var iter = Iterator{ .items = &numbers, .index = 0 };

    std.debug.print("イテレータ: ", .{});
    while (iter.next()) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n\n", .{});

    // ====================
    // 強制アンラップ (.?)
    // ====================

    // 値があることが確実な場合のみ使用
    // nullだとパニック
    const guaranteed: ?i32 = 100;
    const unwrapped = guaranteed.?;
    std.debug.print("強制アンラップ: {d}\n", .{unwrapped});

    std.debug.print("\n", .{});

    // ====================
    // Optionalポインタ
    // ====================

    var data: i32 = 42;
    const opt_ptr: ?*i32 = &data;
    const null_ptr: ?*i32 = null;

    if (opt_ptr) |ptr| {
        std.debug.print("ポインタの値: {d}\n", .{ptr.*});
    }

    if (null_ptr) |_| {
        std.debug.print("これは表示されない\n", .{});
    } else {
        std.debug.print("nullポインタ\n", .{});
    }

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・?T は T または null\n", .{});
    std.debug.print("・orelse でデフォルト値を指定\n", .{});
    std.debug.print("・if文でnullチェックとアンラップを同時に\n", .{});
    std.debug.print("・.? は強制アンラップ（危険）\n", .{});
}

// シンプルなイテレータ構造体
const Iterator = struct {
    items: []const i32,
    index: usize,

    fn next(self: *Iterator) ?i32 {
        if (self.index >= self.items.len) {
            return null;
        }
        const item = self.items[self.index];
        self.index += 1;
        return item;
    }
};

// ====================
// 実用的な関数例
// ====================

/// 配列から値を検索（見つからなければnull）
fn find(haystack: []const i32, needle: i32) ?usize {
    for (haystack, 0..) |item, index| {
        if (item == needle) {
            return index;
        }
    }
    return null;
}

/// 文字列を整数に変換（失敗したらnull）
fn parseDigit(c: u8) ?u8 {
    if (c >= '0' and c <= '9') {
        return c - '0';
    }
    return null;
}

/// 最初の非null値を返す
fn firstNonNull(values: []const ?i32) ?i32 {
    for (values) |v| {
        if (v) |val| {
            return val;
        }
    }
    return null;
}

// --- テスト ---

test "optional basic" {
    const some: ?i32 = 42;
    const none: ?i32 = null;

    try std.testing.expect(some != null);
    try std.testing.expect(none == null);
}

test "orelse operator" {
    const some: ?i32 = 42;
    const none: ?i32 = null;

    try std.testing.expectEqual(@as(i32, 42), some orelse 0);
    try std.testing.expectEqual(@as(i32, 0), none orelse 0);
    try std.testing.expectEqual(@as(i32, -1), none orelse -1);
}

test "if unwrap" {
    const some: ?i32 = 42;
    const none: ?i32 = null;

    if (some) |val| {
        try std.testing.expectEqual(@as(i32, 42), val);
    } else {
        try std.testing.expect(false); // この行には到達しない
    }

    var reached_else = false;
    if (none) |_| {
        try std.testing.expect(false); // この行には到達しない
    } else {
        reached_else = true;
    }
    try std.testing.expect(reached_else);
}

test "forced unwrap .?" {
    const some: ?i32 = 42;
    try std.testing.expectEqual(@as(i32, 42), some.?);
}

test "optional pointer" {
    var value: i32 = 100;
    const ptr: ?*i32 = &value;
    const null_ptr: ?*i32 = null;

    try std.testing.expect(ptr != null);
    try std.testing.expect(null_ptr == null);

    if (ptr) |p| {
        try std.testing.expectEqual(@as(i32, 100), p.*);
    }
}

test "find function" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // 見つかる場合
    const found = find(&arr, 30);
    try std.testing.expectEqual(@as(?usize, 2), found);

    // 見つからない場合
    const not_found = find(&arr, 99);
    try std.testing.expect(not_found == null);
}

test "parseDigit function" {
    try std.testing.expectEqual(@as(?u8, 0), parseDigit('0'));
    try std.testing.expectEqual(@as(?u8, 5), parseDigit('5'));
    try std.testing.expectEqual(@as(?u8, 9), parseDigit('9'));
    try std.testing.expect(parseDigit('a') == null);
    try std.testing.expect(parseDigit(' ') == null);
}

test "firstNonNull function" {
    const vals1 = [_]?i32{ null, null, 42, 100 };
    try std.testing.expectEqual(@as(?i32, 42), firstNonNull(&vals1));

    const vals2 = [_]?i32{ null, null, null };
    try std.testing.expect(firstNonNull(&vals2) == null);

    const vals3 = [_]?i32{ 1, 2, 3 };
    try std.testing.expectEqual(@as(?i32, 1), firstNonNull(&vals3));
}

test "optional in struct" {
    const Person = struct {
        name: []const u8,
        age: ?u8, // 年齢は任意
    };

    const alice = Person{ .name = "Alice", .age = 30 };
    const bob = Person{ .name = "Bob", .age = null };

    try std.testing.expectEqual(@as(?u8, 30), alice.age);
    try std.testing.expect(bob.age == null);
}

test "iterator pattern" {
    var numbers = [_]i32{ 1, 2, 3 };
    var iter = Iterator{ .items = &numbers, .index = 0 };

    try std.testing.expectEqual(@as(?i32, 1), iter.next());
    try std.testing.expectEqual(@as(?i32, 2), iter.next());
    try std.testing.expectEqual(@as(?i32, 3), iter.next());
    try std.testing.expect(iter.next() == null);
}

test "optional chaining with orelse" {
    const maybe_a: ?i32 = null;
    const maybe_b: ?i32 = 10;

    // チェーンで最初の非null値を取得
    const result = maybe_a orelse maybe_b orelse 0;
    try std.testing.expectEqual(@as(i32, 10), result);
}

test "optional comparison" {
    const a: ?i32 = 5;
    const b: ?i32 = 5;
    const c: ?i32 = 10;
    const d: ?i32 = null;

    try std.testing.expect(a == b);
    try std.testing.expect(a != c);
    try std.testing.expect(a != d);
    try std.testing.expect(d == null);
}
