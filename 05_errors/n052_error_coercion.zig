//! # エラー型変換
//!
//! Zigのエラーセット間の暗黙的・明示的な型変換を解説。
//! エラーセットの包含関係と変換ルールを理解する。
//!
//! ## 変換ルール
//! - サブセット → スーパーセット: 暗黙変換可能
//! - スーパーセット → サブセット: switchで手動変換
//! - anyerror: 全エラーを受け入れ
//!
//! ## 注意
//! - 縮小変換にはswitchで明示的マッピング
//! - 変換できないエラーはnullで表現

const std = @import("std");

// ====================
// エラーセットの定義
// ====================

const FileError = error{
    FileNotFound,
    PermissionDenied,
};

const NetworkError = error{
    ConnectionRefused,
    Timeout,
};

const IOError = FileError || NetworkError;

const AllError = IOError || error{
    OutOfMemory,
    InvalidInput,
};

fn demoErrorSets() void {
    std.debug.print("--- エラーセットの定義 ---\n", .{});

    std.debug.print("  FileError: FileNotFound, PermissionDenied\n", .{});
    std.debug.print("  NetworkError: ConnectionRefused, Timeout\n", .{});
    std.debug.print("  IOError = FileError || NetworkError\n", .{});
    std.debug.print("  AllError = IOError || {{OutOfMemory, InvalidInput}}\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// サブセット → スーパーセット（暗黙変換）
// ====================

fn fileOperation() FileError!void {
    return error.FileNotFound;
}

fn networkOperation() NetworkError!void {
    return error.Timeout;
}

fn ioOperation(use_file: bool) IOError!void {
    if (use_file) {
        // FileError → IOError: 暗黙変換
        try fileOperation();
    } else {
        // NetworkError → IOError: 暗黙変換
        try networkOperation();
    }
}

fn demoSubsetToSuperset() void {
    std.debug.print("--- サブセット → スーパーセット ---\n", .{});

    std.debug.print("  FileError → IOError: 暗黙変換可能\n", .{});
    std.debug.print("  NetworkError → IOError: 暗黙変換可能\n", .{});

    // FileErrorをIOErrorとして扱う
    if (ioOperation(true)) |_| {} else |err| {
        const io_err: IOError = err;
        std.debug.print("  FileError as IOError: {s}\n", .{@errorName(io_err)});
    }

    // NetworkErrorをIOErrorとして扱う
    if (ioOperation(false)) |_| {} else |err| {
        const io_err: IOError = err;
        std.debug.print("  NetworkError as IOError: {s}\n", .{@errorName(io_err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// anyerrorへの変換
// ====================

fn returnsFileError() FileError!void {
    return error.PermissionDenied;
}

fn returnsNetworkError() NetworkError!void {
    return error.ConnectionRefused;
}

fn acceptsAnyError(err: anyerror) void {
    std.debug.print("    anyerror: {s}\n", .{@errorName(err)});
}

fn demoAnyerrorCoercion() void {
    std.debug.print("--- anyerrorへの変換 ---\n", .{});

    std.debug.print("  任意のエラー → anyerror: 常に可能\n", .{});

    // 任意のエラーをanyerrorとして渡せる
    if (returnsFileError()) |_| {} else |err| {
        acceptsAnyError(err);
    }

    if (returnsNetworkError()) |_| {} else |err| {
        acceptsAnyError(err);
    }

    std.debug.print("\n", .{});
}

// ====================
// @errorCastによる縮小変換
// ====================

fn narrowToFileError(err: IOError) ?FileError {
    // IOError → FileError: switchで分岐
    return switch (err) {
        error.FileNotFound => error.FileNotFound,
        error.PermissionDenied => error.PermissionDenied,
        else => null,
    };
}

fn demoErrorCast() void {
    std.debug.print("--- エラーセットの縮小変換 ---\n", .{});

    std.debug.print("  IOError → FileError: switchで手動変換\n", .{});

    // FileErrorに含まれるエラー
    const file_err: IOError = error.FileNotFound;
    if (narrowToFileError(file_err)) |narrow| {
        std.debug.print("  FileNotFound → FileError: {s}\n", .{@errorName(narrow)});
    }

    // FileErrorに含まれないエラー
    const net_err: IOError = error.Timeout;
    if (narrowToFileError(net_err)) |_| {
        std.debug.print("  変換成功（予期しない）\n", .{});
    } else {
        std.debug.print("  Timeout → FileError: null（変換不可）\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// エラーユニオンの変換
// ====================

fn specificFunction() FileError!i32 {
    return error.FileNotFound;
}

fn widerFunction() IOError!i32 {
    // FileError!i32 → IOError!i32: 暗黙変換
    return try specificFunction();
}

fn demoErrorUnionCoercion() void {
    std.debug.print("--- エラーユニオンの変換 ---\n", .{});

    std.debug.print("  FileError!T → IOError!T: 暗黙変換可能\n", .{});

    if (widerFunction()) |_| {} else |err| {
        std.debug.print("  結果: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 関数ポインタとエラー型
// ====================

fn handleFileError() FileError!void {
    return error.FileNotFound;
}

fn handleNetworkError() NetworkError!void {
    return error.Timeout;
}

fn demoFunctionPointers() void {
    std.debug.print("--- 関数ポインタとエラー型 ---\n", .{});

    std.debug.print("  異なるエラー型の関数は直接互換性なし\n", .{});
    std.debug.print("  共通のエラー型に合わせる必要\n", .{});

    // 型を明示的に指定
    const file_fn: *const fn () FileError!void = handleFileError;
    const net_fn: *const fn () NetworkError!void = handleNetworkError;

    if (file_fn()) |_| {} else |err| {
        std.debug.print("  file_fn: {s}\n", .{@errorName(err)});
    }

    if (net_fn()) |_| {} else |err| {
        std.debug.print("  net_fn: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 推論されるエラー型
// ====================

fn inferredOp(condition: bool) !void {
    // エラー型は関数の戻り値から推論
    if (condition) {
        return error.ConditionFailed;
    }
}

fn callInferred() !void {
    // tryで伝播するとエラー型も伝播
    try inferredOp(true);
}

fn demoInferredErrorType() void {
    std.debug.print("--- 推論されるエラー型 ---\n", .{});

    std.debug.print("  !T: コンパイラがエラー型を推論\n", .{});
    std.debug.print("  tryで自動的にエラーが伝播\n", .{});

    if (callInferred()) |_| {} else |err| {
        std.debug.print("  推論されたエラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践：階層的エラー処理
// ====================

const LowLevelError = error{
    DiskFull,
    BadSector,
};

const MiddleLevelError = LowLevelError || error{
    FileCorrupt,
    InvalidPath,
};

const HighLevelError = MiddleLevelError || error{
    ConfigurationError,
    InitializationFailed,
};

fn lowLevel() LowLevelError!void {
    return error.DiskFull;
}

fn middleLevel() MiddleLevelError!void {
    // LowLevelError → MiddleLevelError: 暗黙変換
    try lowLevel();
}

fn highLevel() HighLevelError!void {
    // MiddleLevelError → HighLevelError: 暗黙変換
    try middleLevel();
}

fn narrowToMiddle(err: HighLevelError) ?MiddleLevelError {
    return switch (err) {
        error.DiskFull => error.DiskFull,
        error.BadSector => error.BadSector,
        error.FileCorrupt => error.FileCorrupt,
        error.InvalidPath => error.InvalidPath,
        else => null,
    };
}

fn narrowToLow(err: HighLevelError) ?LowLevelError {
    return switch (err) {
        error.DiskFull => error.DiskFull,
        error.BadSector => error.BadSector,
        else => null,
    };
}

fn demoHierarchicalErrors() void {
    std.debug.print("--- 階層的エラー処理 ---\n", .{});

    std.debug.print("  LowLevel → Middle → High: 自動伝播\n", .{});

    if (highLevel()) |_| {} else |err| {
        std.debug.print("  最上位で捕捉: {s}\n", .{@errorName(err)});

        // 元の型に戻せるか確認
        if (narrowToMiddle(err)) |middle| {
            std.debug.print("    MiddleLevelErrorに変換可: {s}\n", .{@errorName(middle)});
        }

        if (narrowToLow(err)) |low| {
            std.debug.print("    LowLevelErrorに変換可: {s}\n", .{@errorName(low)});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  サブセット → スーパーセット:\n", .{});
    std.debug.print("    暗黙変換可能\n", .{});

    std.debug.print("  スーパーセット → サブセット:\n", .{});
    std.debug.print("    switchで手動変換必要\n", .{});

    std.debug.print("  anyerror:\n", .{});
    std.debug.print("    全エラーを受け入れ\n", .{});

    std.debug.print("  推論型（!T）:\n", .{});
    std.debug.print("    コンパイラが自動推論\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラー型変換 ===\n\n", .{});

    demoErrorSets();
    demoSubsetToSuperset();
    demoAnyerrorCoercion();
    demoErrorCast();
    demoErrorUnionCoercion();
    demoFunctionPointers();
    demoInferredErrorType();
    demoHierarchicalErrors();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・小さいセット→大きいセットは暗黙変換\n", .{});
    std.debug.print("・大きい→小さいはswitchで手動変換\n", .{});
    std.debug.print("・anyerrorは全てを受け入れ\n", .{});
    std.debug.print("・エラー型の包含関係を意識\n", .{});
}

// --- テスト ---

test "subset to superset coercion" {
    const file_err: FileError = error.FileNotFound;
    const io_err: IOError = file_err; // 暗黙変換
    try std.testing.expectEqual(error.FileNotFound, io_err);
}

test "narrow error success" {
    const io_err: IOError = error.FileNotFound;
    const file_err = narrowToFileError(io_err);
    try std.testing.expect(file_err != null);
    try std.testing.expectEqual(error.FileNotFound, file_err.?);
}

test "narrow error failure returns null" {
    const io_err: IOError = error.Timeout;
    const file_err = narrowToFileError(io_err);
    try std.testing.expect(file_err == null);
}

test "anyerror accepts all errors" {
    const file_err: FileError = error.PermissionDenied;
    const any_err: anyerror = file_err;
    try std.testing.expectEqualStrings("PermissionDenied", @errorName(any_err));
}

test "error union coercion" {
    const result: IOError!i32 = specificFunction();
    try std.testing.expectError(error.FileNotFound, result);
}

test "hierarchical error propagation" {
    const result = highLevel();
    try std.testing.expectError(error.DiskFull, result);
}

test "narrow hierarchical error" {
    const high_err: HighLevelError = error.DiskFull;

    // HighLevel → Middle → Low
    const middle = narrowToMiddle(high_err);
    try std.testing.expect(middle != null);

    const low = narrowToLow(high_err);
    try std.testing.expect(low != null);
    try std.testing.expectEqual(error.DiskFull, low.?);
}

test "inferred error type" {
    const result = callInferred();
    try std.testing.expectError(error.ConditionFailed, result);
}
