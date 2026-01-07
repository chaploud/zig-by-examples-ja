//! # OptionalとErrorの使い分け
//!
//! ?TとE!Tの違いと適切な使い分けを解説。
//! 両者は異なる意味を持ち、状況に応じて選択する。
//!
//! ## ?T (Optional)
//! - 値がある/ない（2状態）
//! - 正常な「不在」を表現
//! - 検索結果、設定値など
//!
//! ## E!T (Error Union)
//! - 成功/失敗（何が失敗か明示）
//! - 異常状態を表現
//! - IO操作、解析処理など

const std = @import("std");

// ====================
// 基本的な違い
// ====================

fn demoBasicDifference() void {
    std.debug.print("--- 基本的な違い ---\n", .{});

    std.debug.print("  ?T (Optional):\n", .{});
    std.debug.print("    - 値がある (T) または ない (null)\n", .{});
    std.debug.print("    - 「不在」は正常な状態\n", .{});

    std.debug.print("  E!T (Error Union):\n", .{});
    std.debug.print("    - 成功 (T) または 失敗 (error)\n", .{});
    std.debug.print("    - 「失敗」は何かが問題だった\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optional: 検索結果
// ====================

fn findInArray(arr: []const i32, target: i32) ?usize {
    for (arr, 0..) |v, i| {
        if (v == target) return i;
    }
    return null; // 見つからないのは正常
}

fn demoOptionalSearch() void {
    std.debug.print("--- Optional: 検索結果 ---\n", .{});

    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // 見つかった
    if (findInArray(&arr, 30)) |idx| {
        std.debug.print("  30: index={d}\n", .{idx});
    }

    // 見つからない（正常）
    if (findInArray(&arr, 99)) |_| {
        std.debug.print("  99: found\n", .{});
    } else {
        std.debug.print("  99: not found（正常）\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// Error: ファイル操作
// ====================

const FileError = error{
    FileNotFound,
    PermissionDenied,
    IOError,
};

fn readFile(path: []const u8) FileError![]const u8 {
    if (path.len == 0) return error.FileNotFound;
    if (std.mem.eql(u8, path, "/root/secret")) return error.PermissionDenied;
    return "file contents";
}

fn demoErrorFileOp() void {
    std.debug.print("--- Error: ファイル操作 ---\n", .{});

    // 成功
    if (readFile("config.txt")) |contents| {
        std.debug.print("  config.txt: {s}\n", .{contents});
    } else |_| {}

    // エラー（何が問題かわかる）
    if (readFile("")) |_| {} else |err| {
        std.debug.print("  空パス: {s}\n", .{@errorName(err)});
    }

    if (readFile("/root/secret")) |_| {} else |err| {
        std.debug.print("  権限なし: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 選択基準
// ====================

fn demoSelectionCriteria() void {
    std.debug.print("--- 選択基準 ---\n", .{});

    std.debug.print("  Optionalを使う場合:\n", .{});
    std.debug.print("    - 「ない」が正常な状態\n", .{});
    std.debug.print("    - 理由の説明が不要\n", .{});
    std.debug.print("    - 例: 検索、設定値、キャッシュ\n", .{});

    std.debug.print("  Errorを使う場合:\n", .{});
    std.debug.print("    - 「失敗」の理由が重要\n", .{});
    std.debug.print("    - 呼び出し元が対処を変える\n", .{});
    std.debug.print("    - 例: IO, 解析, 検証\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Map/Dict操作
// ====================

const ValueMap = struct {
    keys: []const []const u8,
    values: []const i32,

    // Optional: キーがなくても正常
    fn get(self: ValueMap, key: []const u8) ?i32 {
        for (self.keys, self.values) |k, v| {
            if (std.mem.eql(u8, k, key)) return v;
        }
        return null;
    }
};

fn demoMapLookup() void {
    std.debug.print("--- Map/Dict操作 ---\n", .{});

    const keys = [_][]const u8{ "a", "b", "c" };
    const values = [_]i32{ 1, 2, 3 };
    const map = ValueMap{
        .keys = &keys,
        .values = &values,
    };

    // キーがある
    if (map.get("b")) |v| {
        std.debug.print("  map[\"b\"] = {d}\n", .{v});
    }

    // キーがない（正常）
    const value = map.get("z") orelse 0;
    std.debug.print("  map[\"z\"] orelse 0 = {d}\n", .{value});

    std.debug.print("\n", .{});
}

// ====================
// 解析処理
// ====================

const ParseError = error{
    InvalidFormat,
    OutOfRange,
    Empty,
};

// Error: 解析失敗は問題
fn parseNumber(s: []const u8) ParseError!i32 {
    if (s.len == 0) return error.Empty;
    if (s[0] < '0' or s[0] > '9') return error.InvalidFormat;
    return 42; // 簡易実装
}

fn demoParseOperation() void {
    std.debug.print("--- 解析処理 ---\n", .{});

    // 成功
    if (parseNumber("123")) |n| {
        std.debug.print("  \"123\": {d}\n", .{n});
    } else |_| {}

    // エラー（理由がわかる）
    if (parseNumber("")) |_| {} else |err| {
        std.debug.print("  \"\": {s}\n", .{@errorName(err)});
    }

    if (parseNumber("abc")) |_| {} else |err| {
        std.debug.print("  \"abc\": {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 両方が必要な場合
// ====================

const QueryError = error{
    ConnectionFailed,
    Timeout,
};

// エラーまたは結果（見つかるかどうかはOptional）
fn queryDatabase(id: u32) QueryError!?[]const u8 {
    if (id == 0) return error.ConnectionFailed;
    if (id == 999) return null; // 見つからない
    return "user data";
}

fn demoBothNeeded() void {
    std.debug.print("--- 両方が必要な場合 ---\n", .{});

    std.debug.print("  E!?T: エラーまたはOptional\n", .{});

    // 成功（見つかった）
    if (queryDatabase(1)) |maybe_data| {
        if (maybe_data) |data| {
            std.debug.print("  id=1: {s}\n", .{data});
        }
    } else |_| {}

    // 成功（見つからない）
    if (queryDatabase(999)) |maybe_data| {
        if (maybe_data) |_| {} else {
            std.debug.print("  id=999: not found（正常）\n", .{});
        }
    } else |_| {}

    // エラー
    if (queryDatabase(0)) |_| {} else |err| {
        std.debug.print("  id=0: {s}（異常）\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 変換パターン
// ====================

fn optToErr(opt: ?i32) error{NotFound}!i32 {
    return opt orelse error.NotFound;
}

fn demoConversions() void {
    std.debug.print("--- 変換パターン ---\n", .{});

    // Optional → Error
    std.debug.print("  ?T → E!T: orelse error.X\n", .{});
    const opt: ?i32 = null;
    const err_result = optToErr(opt);
    if (err_result) |_| {} else |e| {
        std.debug.print("    結果: {s}\n", .{@errorName(e)});
    }

    // Error → Optional
    std.debug.print("  E!T → ?T: catch null\n", .{});
    const err_val: ParseError!i32 = error.InvalidFormat;
    const opt_result: ?i32 = err_val catch null;
    if (opt_result) |_| {} else {
        std.debug.print("    結果: null\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践例：設定読み込み
// ====================

const Config = struct {
    host: ?[]const u8,
    port: ?u16,
    timeout: u32,
};

const ConfigError = error{
    FileNotFound,
    ParseError,
};

fn loadConfig(path: []const u8) ConfigError!Config {
    if (path.len == 0) return error.FileNotFound;

    // 設定値がないのは正常（デフォルト使用）
    return Config{
        .host = "localhost",
        .port = null, // ポート指定なし
        .timeout = 30,
    };
}

fn demoConfigExample() void {
    std.debug.print("--- 実践例：設定読み込み ---\n", .{});

    if (loadConfig("config.json")) |config| {
        std.debug.print("  host: {s}\n", .{config.host orelse "(default)"});
        if (config.port) |p| {
            std.debug.print("  port: {d}\n", .{p});
        } else {
            std.debug.print("  port: (not specified)\n", .{});
        }
        std.debug.print("  timeout: {d}\n", .{config.timeout});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  ?T (Optional):\n", .{});
    std.debug.print("    「不在」が正常な場合に使用\n", .{});

    std.debug.print("  E!T (Error):\n", .{});
    std.debug.print("    「失敗」の理由が重要な場合に使用\n", .{});

    std.debug.print("  E!?T (両方):\n", .{});
    std.debug.print("    エラーも不在もありうる場合\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== OptionalとErrorの使い分け ===\n\n", .{});

    demoBasicDifference();
    demoOptionalSearch();
    demoErrorFileOp();
    demoSelectionCriteria();
    demoMapLookup();
    demoParseOperation();
    demoBothNeeded();
    demoConversions();
    demoConfigExample();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・Optionalは「正常な不在」\n", .{});
    std.debug.print("・Errorは「異常な失敗」\n", .{});
    std.debug.print("・両方必要なら E!?T\n", .{});
    std.debug.print("・意図に合った型を選択\n", .{});
}

// --- テスト ---

test "optional search found" {
    const arr = [_]i32{ 10, 20, 30 };
    const result = findInArray(&arr, 20);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(usize, 1), result.?);
}

test "optional search not found" {
    const arr = [_]i32{ 10, 20, 30 };
    const result = findInArray(&arr, 99);
    try std.testing.expect(result == null);
}

test "error file operation success" {
    const result = try readFile("config.txt");
    try std.testing.expectEqualStrings("file contents", result);
}

test "error file operation error" {
    const result = readFile("");
    try std.testing.expectError(error.FileNotFound, result);
}

test "map lookup found" {
    const keys = [_][]const u8{ "a", "b", "c" };
    const values = [_]i32{ 1, 2, 3 };
    const map = ValueMap{
        .keys = &keys,
        .values = &values,
    };

    const result = map.get("b");
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i32, 2), result.?);
}

test "map lookup not found uses default" {
    const keys = [_][]const u8{ "a", "b", "c" };
    const values = [_]i32{ 1, 2, 3 };
    const map = ValueMap{
        .keys = &keys,
        .values = &values,
    };

    const result = map.get("z") orelse 0;
    try std.testing.expectEqual(@as(i32, 0), result);
}

test "parse success" {
    const result = try parseNumber("123");
    try std.testing.expectEqual(@as(i32, 42), result);
}

test "parse error" {
    const result = parseNumber("");
    try std.testing.expectError(error.Empty, result);
}

test "query database success found" {
    if (queryDatabase(1)) |maybe_data| {
        try std.testing.expect(maybe_data != null);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "query database success not found" {
    if (queryDatabase(999)) |maybe_data| {
        try std.testing.expect(maybe_data == null);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "query database error" {
    try std.testing.expectError(error.ConnectionFailed, queryDatabase(0));
}

test "optional to error" {
    const opt: ?i32 = null;

    // orelse でエラーを返すパターン
    const helper = struct {
        fn convert(o: ?i32) error{NotFound}!i32 {
            return o orelse error.NotFound;
        }
    };

    const result = helper.convert(opt);
    try std.testing.expectError(error.NotFound, result);
}

test "error to optional" {
    const err_val: ParseError!i32 = error.InvalidFormat;
    const result: ?i32 = err_val catch null;
    try std.testing.expect(result == null);
}
