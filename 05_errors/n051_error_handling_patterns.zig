//! # エラーハンドリングパターン
//!
//! Zigでの実践的なエラー処理パターンを紹介。
//! 状況に応じた適切な手法を選択することが重要。
//!
//! ## パターン
//! - try: エラーを呼び出し元に伝播
//! - catch: デフォルト値またはハンドリング
//! - if-else: 条件分岐でのエラー処理
//! - switch: エラー種別による分岐
//!
//! ## 原則
//! - エラーは無視しない
//! - 適切なレベルで処理
//! - リソースはerrdeferで解放

const std = @import("std");

// ====================
// パターン1：tryで伝播
// ====================

const FileError = error{
    FileNotFound,
    PermissionDenied,
    ReadError,
};

fn readConfig(path: []const u8) FileError![]const u8 {
    if (path.len == 0) {
        return error.FileNotFound;
    }
    return "config data";
}

fn loadSettings(path: []const u8) FileError![]const u8 {
    // tryでエラーを伝播
    const data = try readConfig(path);
    return data;
}

fn initializeApp(path: []const u8) FileError!void {
    // さらに伝播
    _ = try loadSettings(path);
    std.debug.print("    アプリ初期化完了\n", .{});
}

fn demoTryPropagation() void {
    std.debug.print("--- パターン1：tryで伝播 ---\n", .{});

    std.debug.print("  tryで伝播（推奨）:\n", .{});
    std.debug.print("    エラーを呼び出し元に自動伝播\n", .{});
    std.debug.print("    エラー処理を上位層に委譲\n", .{});

    // エラーケース
    if (initializeApp("")) |_| {} else |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    }

    // 成功ケース
    if (initializeApp("config.json")) |_| {} else |_| {}

    std.debug.print("\n", .{});
}

// ====================
// パターン2：catchでデフォルト値
// ====================

fn getValue(key: []const u8) error{KeyNotFound}!i32 {
    if (std.mem.eql(u8, key, "count")) {
        return 42;
    }
    return error.KeyNotFound;
}

fn demoCatchDefault() void {
    std.debug.print("--- パターン2：catchでデフォルト値 ---\n", .{});

    // デフォルト値を提供
    const count = getValue("count") catch 0;
    const missing = getValue("missing") catch 100;

    std.debug.print("  getValue(\"count\") catch 0: {d}\n", .{count});
    std.debug.print("  getValue(\"missing\") catch 100: {d}\n", .{missing});

    // catch unreachable（絶対にエラーにならない場合）
    const safe = getValue("count") catch unreachable;
    std.debug.print("  catch unreachable: {d}\n", .{safe});

    std.debug.print("\n", .{});
}

// ====================
// パターン3：catchブロック
// ====================

fn parse(input: []const u8) error{ InvalidFormat, Empty }!i32 {
    if (input.len == 0) return error.Empty;
    if (input[0] < '0' or input[0] > '9') return error.InvalidFormat;
    return 123;
}

fn demoCatchBlock() void {
    std.debug.print("--- パターン3：catchブロック ---\n", .{});

    // catchブロックでエラー処理
    const result = parse("abc") catch |err| blk: {
        std.debug.print("  エラー処理: {s}\n", .{@errorName(err)});
        break :blk -1;
    };
    std.debug.print("  結果: {d}\n", .{result});

    // エラー種別で分岐
    const result2 = parse("") catch |err| blk: {
        switch (err) {
            error.Empty => break :blk @as(i32, 0),
            error.InvalidFormat => break :blk @as(i32, -1),
        }
    };
    std.debug.print("  空文字の結果: {d}\n", .{result2});

    std.debug.print("\n", .{});
}

// ====================
// パターン4：if-elseでのエラー処理
// ====================

fn demoIfElseError() void {
    std.debug.print("--- パターン4：if-elseでのエラー処理 ---\n", .{});

    // 基本形
    if (parse("123")) |value| {
        std.debug.print("  成功: {d}\n", .{value});
    } else |err| {
        std.debug.print("  失敗: {s}\n", .{@errorName(err)});
    }

    // 値を無視
    if (parse("abc")) |_| {
        std.debug.print("  成功\n", .{});
    } else |_| {
        std.debug.print("  失敗（エラー無視）\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン5：エラーに対するswitch
// ====================

const ProcessError = error{
    InvalidInput,
    ResourceExhausted,
    PermissionDenied,
    NetworkError,
};

fn handleError(err: ProcessError) void {
    switch (err) {
        error.InvalidInput => {
            std.debug.print("    入力を確認してください\n", .{});
        },
        error.ResourceExhausted => {
            std.debug.print("    リソースを解放してください\n", .{});
        },
        error.PermissionDenied => {
            std.debug.print("    権限を確認してください\n", .{});
        },
        error.NetworkError => {
            std.debug.print("    ネットワーク接続を確認\n", .{});
        },
    }
}

fn process(fail_type: u8) ProcessError!void {
    return switch (fail_type) {
        1 => error.InvalidInput,
        2 => error.ResourceExhausted,
        3 => error.PermissionDenied,
        4 => error.NetworkError,
        else => {},
    };
}

fn demoSwitchError() void {
    std.debug.print("--- パターン5：エラーに対するswitch ---\n", .{});

    for (1..5) |i| {
        std.debug.print("  fail_type={d}:\n", .{i});
        process(@intCast(i)) catch |err| handleError(err);
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン6：オプショナルとの組み合わせ
// ====================

fn findAndProcess(arr: []const i32, target: i32) error{ProcessingFailed}!?i32 {
    for (arr) |v| {
        if (v == target) {
            if (v < 0) return error.ProcessingFailed;
            return v * 2;
        }
    }
    return null; // 見つからない
}

fn demoOptionalError() void {
    std.debug.print("--- パターン6：オプショナルとの組み合わせ ---\n", .{});

    const arr = [_]i32{ 10, -5, 30 };

    // 成功（見つかった）
    if (findAndProcess(&arr, 10)) |maybe_result| {
        if (maybe_result) |result| {
            std.debug.print("  10: 結果={d}\n", .{result});
        }
    } else |_| {}

    // null（見つからない）
    if (findAndProcess(&arr, 99)) |maybe_result| {
        if (maybe_result) |_| {} else {
            std.debug.print("  99: 見つからない\n", .{});
        }
    } else |_| {}

    // エラー
    if (findAndProcess(&arr, -5)) |_| {} else |err| {
        std.debug.print("  -5: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン7：リトライパターン
// ====================

fn unreliableOperation(attempt: *u32) error{TemporaryError}!void {
    attempt.* += 1;
    if (attempt.* < 3) {
        return error.TemporaryError;
    }
    // 3回目で成功
}

fn demoRetryPattern() void {
    std.debug.print("--- パターン7：リトライパターン ---\n", .{});

    var attempt: u32 = 0;
    const max_retries: u32 = 5;

    var success = false;
    for (0..max_retries) |_| {
        if (unreliableOperation(&attempt)) |_| {
            success = true;
            break;
        } else |_| {
            std.debug.print("  リトライ {d}回目...\n", .{attempt});
        }
    }

    if (success) {
        std.debug.print("  成功（{d}回目）\n", .{attempt});
    } else {
        std.debug.print("  最大リトライ回数超過\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン8：errdeferでクリーンアップ
// ====================

const Resource = struct {
    id: u32,

    pub fn acquire(id: u32) Resource {
        std.debug.print("    リソース{d} 取得\n", .{id});
        return .{ .id = id };
    }

    pub fn release(self: Resource) void {
        std.debug.print("    リソース{d} 解放\n", .{self.id});
    }
};

fn multiResourceOperation(fail_at: u32) !void {
    const r1 = Resource.acquire(1);
    errdefer r1.release();

    if (fail_at == 1) return error.Step1Failed;

    const r2 = Resource.acquire(2);
    errdefer r2.release();

    if (fail_at == 2) return error.Step2Failed;

    const r3 = Resource.acquire(3);
    errdefer r3.release();

    if (fail_at == 3) return error.Step3Failed;

    // 成功時は手動で解放
    std.debug.print("    全て成功\n", .{});
    r3.release();
    r2.release();
    r1.release();
}

fn demoErrdeferCleanup() void {
    std.debug.print("--- パターン8：errdeferでクリーンアップ ---\n", .{});

    std.debug.print("  [ステップ2で失敗]\n", .{});
    multiResourceOperation(2) catch |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    };

    std.debug.print("  [全て成功]\n", .{});
    multiResourceOperation(0) catch {};

    std.debug.print("\n", .{});
}

// ====================
// パターン9：エラー変換
// ====================

const LowLevelError = error{
    IOError,
    OutOfMemory,
};

const HighLevelError = error{
    ConfigLoadFailed,
    InitializationFailed,
};

fn lowLevelOp(fail: bool) LowLevelError!void {
    if (fail) return error.IOError;
}

fn highLevelOp(fail: bool) HighLevelError!void {
    // 低レベルエラーを高レベルに変換
    lowLevelOp(fail) catch {
        return error.ConfigLoadFailed;
    };
}

fn demoErrorConversion() void {
    std.debug.print("--- パターン9：エラー変換 ---\n", .{});

    std.debug.print("  低レベル → 高レベルエラー変換:\n", .{});

    if (highLevelOp(true)) |_| {} else |err| {
        std.debug.print("    {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  try: エラーを呼び出し元に伝播\n", .{});
    std.debug.print("  catch value: デフォルト値を提供\n", .{});
    std.debug.print("  catch |err| blk: エラー処理ブロック\n", .{});
    std.debug.print("  if-else: 成功/失敗で分岐\n", .{});
    std.debug.print("  switch: エラー種別で分岐\n", .{});
    std.debug.print("  errdefer: エラー時のクリーンアップ\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラーハンドリングパターン ===\n\n", .{});

    demoTryPropagation();
    demoCatchDefault();
    demoCatchBlock();
    demoIfElseError();
    demoSwitchError();
    demoOptionalError();
    demoRetryPattern();
    demoErrdeferCleanup();
    demoErrorConversion();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・適切なレベルでエラー処理\n", .{});
    std.debug.print("・errdeferでリソース解放\n", .{});
    std.debug.print("・エラーは無視しない\n", .{});
    std.debug.print("・状況に応じてパターン選択\n", .{});
}

// --- テスト ---

test "try propagation" {
    const result = loadSettings("");
    try std.testing.expectError(error.FileNotFound, result);
}

test "try propagation success" {
    const result = try loadSettings("config.json");
    try std.testing.expectEqualStrings("config data", result);
}

test "catch default value" {
    const result = getValue("missing") catch 100;
    try std.testing.expectEqual(@as(i32, 100), result);
}

test "catch block with error handling" {
    const result = parse("abc") catch |err| blk: {
        try std.testing.expectEqual(error.InvalidFormat, err);
        break :blk -1;
    };
    try std.testing.expectEqual(@as(i32, -1), result);
}

test "if else error handling" {
    if (parse("123")) |value| {
        try std.testing.expectEqual(@as(i32, 123), value);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "switch on error" {
    process(1) catch |err| {
        try std.testing.expectEqual(error.InvalidInput, err);
    };
}

test "optional with error" {
    const arr = [_]i32{ 10, -5, 30 };

    // 成功
    if (findAndProcess(&arr, 10)) |maybe| {
        try std.testing.expectEqual(@as(?i32, 20), maybe);
    } else |_| {
        try std.testing.expect(false);
    }

    // null
    if (findAndProcess(&arr, 99)) |maybe| {
        try std.testing.expect(maybe == null);
    } else |_| {
        try std.testing.expect(false);
    }

    // エラー
    try std.testing.expectError(error.ProcessingFailed, findAndProcess(&arr, -5));
}

test "retry pattern success" {
    var attempt: u32 = 0;
    var success = false;

    for (0..5) |_| {
        if (unreliableOperation(&attempt)) |_| {
            success = true;
            break;
        } else |_| {}
    }

    try std.testing.expect(success);
    try std.testing.expectEqual(@as(u32, 3), attempt);
}

test "error conversion" {
    const result = highLevelOp(true);
    try std.testing.expectError(error.ConfigLoadFailed, result);
}
