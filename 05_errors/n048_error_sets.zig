//! # エラーセット
//!
//! エラーセットはZigのエラー型を定義・操作する仕組み。
//! 複数のエラーを組み合わせたり、エラーの種類を制限できる。
//!
//! ## 特徴
//! - error{ E1, E2, ... }: エラーセット定義
//! - ||: エラーセットの結合
//! - anyerror: 全てのエラーを含む
//! - @typeInfo(E).error_set: エラー情報取得
//!
//! ## 用途
//! - APIのエラー型を明示
//! - エラーの伝播制御
//! - 型安全なエラー処理

const std = @import("std");

// ====================
// エラーセットの定義
// ====================

const FileError = error{
    FileNotFound,
    PermissionDenied,
    IsDirectory,
    AccessDenied,
};

const NetworkError = error{
    ConnectionRefused,
    ConnectionReset,
    Timeout,
    HostUnreachable,
};

const ParseError = error{
    InvalidSyntax,
    UnexpectedToken,
    EndOfInput,
};

fn demoErrorSetDefinition() void {
    std.debug.print("--- エラーセットの定義 ---\n", .{});

    std.debug.print("  FileError:\n", .{});
    std.debug.print("    FileNotFound, PermissionDenied, ...\n", .{});

    std.debug.print("  NetworkError:\n", .{});
    std.debug.print("    ConnectionRefused, Timeout, ...\n", .{});

    // エラー値の生成
    const err: FileError = error.FileNotFound;
    std.debug.print("  FileError値: {s}\n", .{@errorName(err)});

    std.debug.print("\n", .{});
}

// ====================
// エラーセットの結合
// ====================

const IOError = FileError || NetworkError;

fn demoErrorSetMerge() void {
    std.debug.print("--- エラーセットの結合 ---\n", .{});

    std.debug.print("  IOError = FileError || NetworkError:\n", .{});

    // 両方のエラーを持てる
    const file_err: IOError = error.FileNotFound;
    const net_err: IOError = error.Timeout;

    std.debug.print("    {s} (元はFileError)\n", .{@errorName(file_err)});
    std.debug.print("    {s} (元はNetworkError)\n", .{@errorName(net_err)});

    // 3つ以上も結合可能
    const AllError = FileError || NetworkError || ParseError;
    const parse_err: AllError = error.InvalidSyntax;
    std.debug.print("    {s} (3つ結合)\n", .{@errorName(parse_err)});

    std.debug.print("\n", .{});
}

// ====================
// 関数のエラー型
// ====================

fn readFile(path: []const u8) FileError![]const u8 {
    if (path.len == 0) {
        return error.FileNotFound;
    }
    return "file contents";
}

fn fetchData(url: []const u8) NetworkError![]const u8 {
    if (url.len == 0) {
        return error.ConnectionRefused;
    }
    return "network data";
}

// エラーセット結合した戻り値
fn loadResource(is_local: bool) IOError![]const u8 {
    if (is_local) {
        return try readFile("test.txt");
    } else {
        return try fetchData("http://example.com");
    }
}

fn demoFunctionErrorType() void {
    std.debug.print("--- 関数のエラー型 ---\n", .{});

    // 個別の関数
    if (readFile("test.txt")) |data| {
        std.debug.print("  readFile: {s}\n", .{data});
    } else |_| {}

    if (fetchData("http://example.com")) |data| {
        std.debug.print("  fetchData: {s}\n", .{data});
    } else |_| {}

    // 結合されたエラー型
    if (loadResource(true)) |data| {
        std.debug.print("  loadResource(local): {s}\n", .{data});
    } else |_| {}

    std.debug.print("\n", .{});
}

// ====================
// anyerror
// ====================

fn genericHandler(result: anyerror!i32) void {
    if (result) |value| {
        std.debug.print("  成功: {d}\n", .{value});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }
}

fn demoAnyerror() void {
    std.debug.print("--- anyerror ---\n", .{});

    std.debug.print("  anyerror: 全てのエラーを受け入れる\n", .{});
    std.debug.print("  !T は anyerror!T の省略形\n", .{});

    // 異なるエラー型でも受け入れ可能
    const file_result: FileError!i32 = error.FileNotFound;
    const net_result: NetworkError!i32 = error.Timeout;

    genericHandler(file_result);
    genericHandler(net_result);

    std.debug.print("\n", .{});
}

// ====================
// エラーセットの縮小
// ====================

fn narrowError() FileError!void {
    // anyerrorから特定のエラーセットに変換
    const result: anyerror!void = error.FileNotFound;

    // キャストが必要な場合
    if (result) |_| {} else |err| {
        const narrowed = @as(?FileError, @errorCast(err));
        if (narrowed) |file_err| {
            return file_err;
        }
    }
}

fn demoErrorNarrowing() void {
    std.debug.print("--- エラーセットの縮小 ---\n", .{});

    std.debug.print("  anyerror → 特定のエラーセット:\n", .{});
    std.debug.print("    @errorCast で変換\n", .{});
    std.debug.print("    変換できない場合はnull\n", .{});

    narrowError() catch |err| {
        std.debug.print("  縮小されたエラー: {s}\n", .{@errorName(err)});
    };

    std.debug.print("\n", .{});
}

// ====================
// @errorName
// ====================

fn demoErrorName() void {
    std.debug.print("--- @errorName ---\n", .{});

    const err1: FileError = error.FileNotFound;
    const err2: NetworkError = error.Timeout;

    std.debug.print("  @errorName(error.FileNotFound): {s}\n", .{@errorName(err1)});
    std.debug.print("  @errorName(error.Timeout): {s}\n", .{@errorName(err2)});

    // ログ出力に便利
    std.debug.print("  → ログ出力やデバッグに便利\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// switchでのエラー処理
// ====================

fn handleFileError(err: FileError) void {
    switch (err) {
        error.FileNotFound => std.debug.print("    ファイルが見つかりません\n", .{}),
        error.PermissionDenied => std.debug.print("    アクセス権限がありません\n", .{}),
        error.IsDirectory => std.debug.print("    ディレクトリです\n", .{}),
        error.AccessDenied => std.debug.print("    アクセスが拒否されました\n", .{}),
    }
}

fn demoSwitchError() void {
    std.debug.print("--- switchでのエラー処理 ---\n", .{});

    std.debug.print("  FileError をswitch:\n", .{});

    handleFileError(error.FileNotFound);
    handleFileError(error.PermissionDenied);

    std.debug.print("\n", .{});
}

// ====================
// 推論されるエラーセット
// ====================

fn inferredError(fail: bool) !i32 {
    // コンパイラがエラーセットを推論
    if (fail) {
        return error.SomethingWrong;
    }
    return 42;
}

fn callingInferred() !void {
    // tryで自動的にエラーが伝播
    const result = try inferredError(false);
    std.debug.print("    結果: {d}\n", .{result});
}

fn demoInferredErrorSet() void {
    std.debug.print("--- 推論されるエラーセット ---\n", .{});

    std.debug.print("  !T: コンパイラがエラーセットを推論\n", .{});
    std.debug.print("  関数の実装からエラーを収集\n", .{});

    callingInferred() catch |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    };

    std.debug.print("\n", .{});
}

// ====================
// エラーセットの比較
// ====================

fn demoErrorComparison() void {
    std.debug.print("--- エラーセットの比較 ---\n", .{});

    const err1: FileError = error.FileNotFound;
    const err2: FileError = error.FileNotFound;
    const err3: FileError = error.PermissionDenied;

    std.debug.print("  err1 == err2: {}\n", .{err1 == err2});
    std.debug.print("  err1 == err3: {}\n", .{err1 == err3});

    // 特定のエラーかチェック
    if (err1 == error.FileNotFound) {
        std.debug.print("  err1はFileNotFound\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践パターン：階層化エラー
// ====================

const LowLevelError = error{
    IOError,
    MemoryError,
};

const HighLevelError = error{
    ParseFailed,
    ValidationFailed,
};

const AppError = LowLevelError || HighLevelError;

fn processData() AppError!void {
    // 低レベル処理
    // return error.IOError;

    // 高レベル処理
    // return error.ParseFailed;

    // 成功
}

fn demoHierarchicalErrors() void {
    std.debug.print("--- 階層化エラー ---\n", .{});

    std.debug.print("  LowLevelError: IOError, MemoryError\n", .{});
    std.debug.print("  HighLevelError: ParseFailed, ValidationFailed\n", .{});
    std.debug.print("  AppError = LowLevelError || HighLevelError\n", .{});

    if (processData()) |_| {
        std.debug.print("  処理成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラーセット ===\n\n", .{});

    demoErrorSetDefinition();
    demoErrorSetMerge();
    demoFunctionErrorType();
    demoAnyerror();
    demoErrorNarrowing();
    demoErrorName();
    demoSwitchError();
    demoInferredErrorSet();
    demoErrorComparison();
    demoHierarchicalErrors();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・error{{E1, E2}}でエラーセット定義\n", .{});
    std.debug.print("・||でエラーセット結合\n", .{});
    std.debug.print("・anyerrorは全エラーを受け入れ\n", .{});
    std.debug.print("・@errorNameでエラー名を取得\n", .{});
}

// --- テスト ---

test "error set definition" {
    const err: FileError = error.FileNotFound;
    try std.testing.expectEqualStrings("FileNotFound", @errorName(err));
}

test "error set merge" {
    const file_err: IOError = error.FileNotFound;
    const net_err: IOError = error.Timeout;

    try std.testing.expectEqualStrings("FileNotFound", @errorName(file_err));
    try std.testing.expectEqualStrings("Timeout", @errorName(net_err));
}

test "function with specific error type" {
    const result = readFile("");
    try std.testing.expectError(error.FileNotFound, result);
}

test "combined error from function" {
    const result = loadResource(true);
    if (result) |data| {
        try std.testing.expectEqualStrings("file contents", data);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "error comparison" {
    const err1: FileError = error.FileNotFound;
    const err2: FileError = error.FileNotFound;
    const err3: FileError = error.PermissionDenied;

    try std.testing.expect(err1 == err2);
    try std.testing.expect(err1 != err3);
}

test "switch on error" {
    const err: FileError = error.FileNotFound;

    const msg = switch (err) {
        error.FileNotFound => "not found",
        error.PermissionDenied => "permission denied",
        error.IsDirectory => "is directory",
        error.AccessDenied => "access denied",
    };

    try std.testing.expectEqualStrings("not found", msg);
}

test "error name" {
    try std.testing.expectEqualStrings("FileNotFound", @errorName(error.FileNotFound));
    try std.testing.expectEqualStrings("Timeout", @errorName(error.Timeout));
}

test "inferred error set" {
    const result = inferredError(false);
    if (result) |value| {
        try std.testing.expectEqual(@as(i32, 42), value);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "inferred error set failure" {
    const result = inferredError(true);
    try std.testing.expectError(error.SomethingWrong, result);
}
