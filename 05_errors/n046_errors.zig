//! # エラー処理の基礎
//!
//! Zigは専用のエラー型とエラーユニオンでエラーを処理する。
//! 例外は存在せず、戻り値でエラーを返す。
//!
//! ## 特徴
//! - error型: 列挙型のようなエラー定義
//! - !T (error union): エラーまたは成功値
//! - try/catch でエラー処理
//! - errdefer でクリーンアップ
//!
//! ## 構文
//! - const MyError = error{ A, B, C };
//! - fn foo() !T または fn foo() MyError!T

const std = @import("std");

// ====================
// エラー型の定義
// ====================

const FileError = error{
    FileNotFound,
    PermissionDenied,
    ReadError,
    WriteError,
};

const NetworkError = error{
    ConnectionRefused,
    Timeout,
    HostUnreachable,
};

fn demoErrorTypes() void {
    std.debug.print("--- エラー型の定義 ---\n", .{});

    std.debug.print("  const FileError = error{{\n", .{});
    std.debug.print("      FileNotFound,\n", .{});
    std.debug.print("      PermissionDenied,\n", .{});
    std.debug.print("      ...\n", .{});
    std.debug.print("  }};\n", .{});

    // エラー値の表示
    const err: FileError = FileError.FileNotFound;
    std.debug.print("  FileError.FileNotFound: {s}\n", .{@errorName(err)});

    std.debug.print("\n", .{});
}

// ====================
// エラーユニオン（!T）
// ====================

fn divide(a: i32, b: i32) error{DivisionByZero}!i32 {
    if (b == 0) {
        return error.DivisionByZero;
    }
    return @divTrunc(a, b);
}

fn demoErrorUnion() void {
    std.debug.print("--- エラーユニオン（!T） ---\n", .{});

    // 成功ケース
    const result1 = divide(10, 2);
    if (result1) |value| {
        std.debug.print("  divide(10, 2) = {d}\n", .{value});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    // エラーケース
    const result2 = divide(10, 0);
    if (result2) |value| {
        std.debug.print("  divide(10, 0) = {d}\n", .{value});
    } else |err| {
        std.debug.print("  divide(10, 0) エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// try キーワード
// ====================

fn processValue(x: i32) !i32 {
    const doubled = try divide(x, 1);
    return doubled * 2;
}

fn callDivide(a: i32, b: i32) !void {
    const result = try divide(a, b);
    std.debug.print("  try結果: {d}\n", .{result});
}

fn demoTryKeyword() void {
    std.debug.print("--- try キーワード ---\n", .{});

    // tryは成功なら値を取り出し、失敗なら即座にエラーを返す
    if (callDivide(20, 4)) {
        std.debug.print("  成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    if (callDivide(10, 0)) {
        std.debug.print("  成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// catch キーワード
// ====================

fn demoCatchKeyword() void {
    std.debug.print("--- catch キーワード ---\n", .{});

    // catchでデフォルト値を提供
    const result1 = divide(10, 0) catch 0;
    std.debug.print("  divide(10, 0) catch 0 = {d}\n", .{result1});

    const result2 = divide(10, 2) catch 0;
    std.debug.print("  divide(10, 2) catch 0 = {d}\n", .{result2});

    // catchでエラーハンドリング
    const result3 = divide(10, 0) catch |err| blk: {
        std.debug.print("  catchブロック: {s}\n", .{@errorName(err)});
        break :blk -1;
    };
    std.debug.print("  結果: {d}\n", .{result3});

    // catch unreachable（エラーが絶対に起きない場合）
    const result4 = divide(10, 2) catch unreachable;
    std.debug.print("  catch unreachable: {d}\n", .{result4});

    std.debug.print("\n", .{});
}

// ====================
// if-else でのエラー処理
// ====================

fn demoIfElseError() void {
    std.debug.print("--- if-else でのエラー処理 ---\n", .{});

    const result = divide(10, 0);

    if (result) |value| {
        std.debug.print("  成功: {d}\n", .{value});
    } else |err| {
        std.debug.print("  失敗: {s}\n", .{@errorName(err)});
    }

    // 値を無視してエラーのみ処理
    if (divide(10, 2)) |_| {
        std.debug.print("  計算成功\n", .{});
    } else |_| {
        std.debug.print("  計算失敗\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// anyerror 型
// ====================

fn mayFail(should_fail: bool) anyerror!i32 {
    if (should_fail) {
        return error.SomeError;
    }
    return 42;
}

fn demoAnyerror() void {
    std.debug.print("--- anyerror 型 ---\n", .{});

    std.debug.print("  anyerror: 任意のエラーを許容\n", .{});
    std.debug.print("  !T は anyerror!T の省略形\n", .{});

    // anyerror型の関数
    if (mayFail(false)) |value| {
        std.debug.print("  mayFail(false) = {d}\n", .{value});
    } else |_| {}

    if (mayFail(true)) |value| {
        std.debug.print("  mayFail(true) = {d}\n", .{value});
    } else |err| {
        std.debug.print("  mayFail(true): {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// エラーの合成
// ====================

const CombinedError = FileError || NetworkError;

fn demoErrorMerge() void {
    std.debug.print("--- エラーの合成 ---\n", .{});

    std.debug.print("  FileError || NetworkError:\n", .{});
    std.debug.print("    FileNotFound, PermissionDenied, ...\n", .{});
    std.debug.print("    ConnectionRefused, Timeout, ...\n", .{});

    // 両方のエラーを持てる
    const err1: CombinedError = error.FileNotFound;
    const err2: CombinedError = error.Timeout;
    std.debug.print("  err1: {s}\n", .{@errorName(err1)});
    std.debug.print("  err2: {s}\n", .{@errorName(err2)});

    std.debug.print("\n", .{});
}

// ====================
// @errorReturnTrace
// ====================

fn demoErrorTrace() void {
    std.debug.print("--- エラートレース ---\n", .{});

    std.debug.print("  @errorReturnTrace():\n", .{});
    std.debug.print("    デバッグビルドでスタックトレース取得\n", .{});
    std.debug.print("    リリースビルドではnull\n", .{});

    // エラートレースの取得（デバッグモードのみ）
    // const trace = @errorReturnTrace();

    std.debug.print("\n", .{});
}

// ====================
// エラーと optional の違い
// ====================

fn findValue(arr: []const i32, target: i32) ?usize {
    for (arr, 0..) |v, i| {
        if (v == target) return i;
    }
    return null;
}

fn getValue(arr: []const i32, idx: usize) error{IndexOutOfBounds}!i32 {
    if (idx >= arr.len) return error.IndexOutOfBounds;
    return arr[idx];
}

fn demoErrorVsOptional() void {
    std.debug.print("--- エラー vs Optional ---\n", .{});

    const arr = [_]i32{ 10, 20, 30 };

    // Optional: 値がない状態
    std.debug.print("  Optional (?T):\n", .{});
    std.debug.print("    値があるかないかの2状態\n", .{});
    if (findValue(&arr, 20)) |idx| {
        std.debug.print("    発見: index={d}\n", .{idx});
    } else {
        std.debug.print("    見つからない\n", .{});
    }

    // エラー: 何が問題かを示す
    std.debug.print("  Error (!T):\n", .{});
    std.debug.print("    何が問題かを表現\n", .{});
    if (getValue(&arr, 5)) |val| {
        std.debug.print("    値: {d}\n", .{val});
    } else |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラー処理の基礎 ===\n\n", .{});

    demoErrorTypes();
    demoErrorUnion();
    demoTryKeyword();
    demoCatchKeyword();
    demoIfElseError();
    demoAnyerror();
    demoErrorMerge();
    demoErrorTrace();
    demoErrorVsOptional();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・error型でエラーを定義\n", .{});
    std.debug.print("・!T (error union)で成功/失敗を表現\n", .{});
    std.debug.print("・tryでエラー伝播、catchでハンドリング\n", .{});
    std.debug.print("・Optionalは値の有無、Errorは問題の種類\n", .{});
}

// --- テスト ---

test "divide success" {
    const result = try divide(10, 2);
    try std.testing.expectEqual(@as(i32, 5), result);
}

test "divide by zero" {
    const result = divide(10, 0);
    try std.testing.expectError(error.DivisionByZero, result);
}

test "catch provides default" {
    const result = divide(10, 0) catch 0;
    try std.testing.expectEqual(@as(i32, 0), result);
}

test "catch with block" {
    const result = divide(10, 0) catch -1;
    try std.testing.expectEqual(@as(i32, -1), result);
}

test "if-else error handling" {
    const result = divide(10, 2);
    if (result) |value| {
        try std.testing.expectEqual(@as(i32, 5), value);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "if-else error case" {
    const result = divide(10, 0);
    if (result) |_| {
        try std.testing.expect(false);
    } else |err| {
        try std.testing.expectEqual(error.DivisionByZero, err);
    }
}

test "error name" {
    const err: FileError = error.FileNotFound;
    try std.testing.expectEqualStrings("FileNotFound", @errorName(err));
}

test "combined error" {
    const err1: CombinedError = error.FileNotFound;
    const err2: CombinedError = error.Timeout;

    try std.testing.expectEqualStrings("FileNotFound", @errorName(err1));
    try std.testing.expectEqualStrings("Timeout", @errorName(err2));
}

test "anyerror success" {
    const result = try mayFail(false);
    try std.testing.expectEqual(@as(i32, 42), result);
}

test "anyerror failure" {
    const result = mayFail(true);
    try std.testing.expectError(error.SomeError, result);
}
