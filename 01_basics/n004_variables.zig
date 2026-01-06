//! # 変数（var）
//!
//! Zigでは `var` キーワードで変数（可変オブジェクト）を宣言する。
//! constと異なり、宣言後に値を変更できる。
//!
//! ## varの使用条件
//! - **型を明示的に指定する必要がある**
//! - 宣言後に必ず値を変更しなければならない（そうでなければconstを使う）
//!
//! ## なぜconstを優先するのか？
//! Zigは安全性と最適化のため、変更しない値にはconstを使うことを推奨する。
//! varを使用し、一度も変更しないとコンパイルエラーになる。

const std = @import("std");

// ====================
// 基本的なvarの宣言
// ====================

pub fn main() void {
    std.debug.print("=== 変数（var） ===\n\n", .{});

    // varは型を明示的に指定する必要がある
    var counter: i32 = 0;
    std.debug.print("counter初期値: {d}\n", .{counter});

    // 値を変更できる
    counter = 1;
    counter += 10;
    std.debug.print("counter変更後: {d}\n", .{counter});

    // 演算子を使った変更
    var x: i32 = 100;
    x += 50; // x = x + 50
    x -= 30; // x = x - 30
    x *= 2; // x = x * 2
    std.debug.print("演算後のx: {d}\n", .{x});

    std.debug.print("\n", .{});

    // ====================
    // undefined（未初期化）
    // ====================

    // undefinedで宣言すると、後で初期化できる
    // 注意: 初期化前にアクセスすると未定義動作になる
    var later_init: i32 = undefined;
    later_init = 42; // ここで初期化
    std.debug.print("later_init: {d}\n", .{later_init});

    // 配列のundefined初期化
    var buffer: [5]u8 = undefined;
    // メモリを0で埋める
    @memset(&buffer, 0);
    buffer[0] = 'H';
    buffer[1] = 'i';
    std.debug.print("buffer: {s}\n", .{buffer[0..2]});

    std.debug.print("\n", .{});

    // ====================
    // ループでの変数
    // ====================

    // ループカウンタ
    var sum: i32 = 0;
    var i: usize = 1;
    while (i <= 10) : (i += 1) {
        sum += @intCast(i);
    }
    std.debug.print("1から10の合計: {d}\n", .{sum});

    // forループでは範囲変数はconst
    var product: i32 = 1;
    for (1..6) |n| {
        // n自体はconstだが、productを変更できる
        product *= @intCast(n);
    }
    std.debug.print("5の階乗: {d}\n", .{product});

    std.debug.print("\n", .{});

    // ====================
    // varポインタ
    // ====================

    var value: i32 = 10;
    const ptr: *i32 = &value; // varへのポインタ
    ptr.* = 99; // ポインタ経由で値を変更
    std.debug.print("ポインタ経由で変更: {d}\n", .{value});

    std.debug.print("\n", .{});

    // ====================
    // 変数のシャドーイング
    // ====================

    // Zigでは同じスコープ内でのシャドーイングは禁止
    // 以下はコンパイルエラー:
    // var shadow: i32 = 1;
    // var shadow: i32 = 2;  // error: redefinition

    // ただし内部スコープでは可能
    var outer: i32 = 1;
    {
        // 内部スコープで同名の変数を作成
        var outer_copy = outer;
        outer_copy += 100;
        std.debug.print("内部スコープのouter_copy: {d}\n", .{outer_copy});
    }
    // 外部の変数は影響を受けない
    outer += 1; // outerを変更して使用
    std.debug.print("外部スコープのouter: {d}\n", .{outer});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・varは型を明示する必要がある\n", .{});
    std.debug.print("・使用しない/変更しないvarはエラー\n", .{});
    std.debug.print("・変更しない値にはconstを使う\n", .{});
}

// ====================
// 関数内での変数
// ====================

/// 配列の要素を2倍にする
fn doubleElements(arr: []i32) void {
    // スライスの各要素を変更
    for (arr) |*item| {
        item.* *= 2;
    }
}

/// 累積和を計算
fn runningSum(input: []const i32, output: []i32) void {
    var sum: i32 = 0;
    for (input, 0..) |val, idx| {
        sum += val;
        output[idx] = sum;
    }
}

// --- テスト ---

test "var basic mutation" {
    var x: i32 = 10;
    x += 5;
    x *= 2;
    try std.testing.expectEqual(@as(i32, 30), x);
}

test "var requires explicit type" {
    // varは型を明示的に指定する必要がある
    var a: u8 = 255;
    a -= 1;
    try std.testing.expectEqual(@as(u8, 254), a);
}

test "var undefined initialization" {
    var arr: [3]i32 = undefined;
    // undefinedは後で初期化する必要がある
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    try std.testing.expectEqual(@as(i32, 1), arr[0]);
    try std.testing.expectEqual(@as(i32, 6), arr[0] + arr[1] + arr[2]);
}

test "var in loops" {
    var sum: i32 = 0;
    var i: i32 = 1;
    while (i <= 5) : (i += 1) {
        sum += i;
    }
    // 1+2+3+4+5 = 15
    try std.testing.expectEqual(@as(i32, 15), sum);
}

test "var pointer mutation" {
    var value: i32 = 100;
    const ptr = &value;
    ptr.* = 200;
    try std.testing.expectEqual(@as(i32, 200), value);
}

test "double elements function" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    doubleElements(&arr);
    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 10), arr[4]);
}

test "running sum function" {
    const input = [_]i32{ 1, 2, 3, 4 };
    var output: [4]i32 = undefined;
    runningSum(&input, &output);
    // 累積和: [1, 3, 6, 10]
    try std.testing.expectEqual(@as(i32, 1), output[0]);
    try std.testing.expectEqual(@as(i32, 3), output[1]);
    try std.testing.expectEqual(@as(i32, 6), output[2]);
    try std.testing.expectEqual(@as(i32, 10), output[3]);
}

test "var vs const - practical example" {
    // constの配列の中身は変更できない
    const const_arr = [_]i32{ 1, 2, 3 };
    _ = const_arr;
    // const_arr[0] = 10;  // error: cannot assign to constant

    // varの配列は変更可能
    var var_arr = [_]i32{ 1, 2, 3 };
    var_arr[0] = 10;
    try std.testing.expectEqual(@as(i32, 10), var_arr[0]);
}
