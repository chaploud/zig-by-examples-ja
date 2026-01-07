//! # エラー処理総まとめ
//!
//! Zigのエラー処理システム全体を俯瞰する。
//! この章で学んだ概念を実践的なコードで確認。
//!
//! ## 学習内容
//! - エラー型とエラーセット
//! - エラーユニオン (!T)
//! - try/catch/errdefer
//! - エラートレース
//! - Optionalとの使い分け

const std = @import("std");

// ====================
// エラーセット
// ====================

const NetworkError = error{
    ConnectionFailed,
    Timeout,
    HostUnreachable,
};

const FileError = error{
    FileNotFound,
    PermissionDenied,
    ReadError,
};

const ParseError = error{
    InvalidFormat,
    UnexpectedToken,
    Empty,
};

// エラーセットの結合
const IOError = NetworkError || FileError;
const AllError = IOError || ParseError;

fn demoErrorSets() void {
    std.debug.print("--- エラーセット ---\n", .{});

    std.debug.print("  定義: error{{ E1, E2, ... }}\n", .{});
    std.debug.print("  結合: A || B\n", .{});
    std.debug.print("  推論: !T（コンパイラが推論）\n", .{});

    const err1: NetworkError = error.Timeout;
    const err2: IOError = err1; // サブセット→スーパーセット
    std.debug.print("  変換: {s} → IOError\n", .{@errorName(err2)});

    std.debug.print("\n", .{});
}

// ====================
// エラーユニオン (!T)
// ====================

fn divide(a: i32, b: i32) error{DivisionByZero}!i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

fn demoErrorUnion() void {
    std.debug.print("--- エラーユニオン (!T) ---\n", .{});

    std.debug.print("  E!T: エラーまたは値\n", .{});
    std.debug.print("  !T: anyerror!Tの省略形\n", .{});

    // 成功
    if (divide(10, 2)) |v| {
        std.debug.print("  divide(10, 2) = {d}\n", .{v});
    } else |_| {}

    // エラー
    if (divide(10, 0)) |_| {} else |err| {
        std.debug.print("  divide(10, 0): {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// try / catch
// ====================

fn processValue(x: i32) !i32 {
    const result = try divide(x, 2);
    return result * 3;
}

fn demoTryCatch() void {
    std.debug.print("--- try / catch ---\n", .{});

    // try: エラーを伝播
    std.debug.print("  try:\n", .{});
    if (processValue(10)) |v| {
        std.debug.print("    processValue(10) = {d}\n", .{v});
    } else |_| {}

    // catch: デフォルト値
    std.debug.print("  catch:\n", .{});
    const result1 = divide(10, 0) catch 0;
    std.debug.print("    catch 0 = {d}\n", .{result1});

    // catch unreachable
    const result2 = divide(10, 2) catch unreachable;
    std.debug.print("    catch unreachable = {d}\n", .{result2});

    std.debug.print("\n", .{});
}

// ====================
// errdefer
// ====================

const Resource = struct {
    name: []const u8,

    fn acquire(name: []const u8) Resource {
        std.debug.print("    {s} acquired\n", .{name});
        return .{ .name = name };
    }

    fn release(self: Resource) void {
        std.debug.print("    {s} released\n", .{self.name});
    }
};

fn initWithErrdefer(fail: bool) !Resource {
    const r = Resource.acquire("resource");
    errdefer r.release(); // エラー時のみ実行

    if (fail) return error.InitFailed;
    return r;
}

fn demoErrdefer() void {
    std.debug.print("--- errdefer ---\n", .{});

    std.debug.print("  errdefer: エラー時のみ実行\n", .{});
    std.debug.print("  defer: 常に実行\n", .{});

    // 成功時
    std.debug.print("  [成功時]\n", .{});
    if (initWithErrdefer(false)) |r| {
        std.debug.print("    成功（手動解放必要）\n", .{});
        r.release();
    } else |_| {}

    // エラー時
    std.debug.print("  [エラー時]\n", .{});
    if (initWithErrdefer(true)) |_| {} else |err| {
        std.debug.print("    エラー: {s}（自動解放済み）\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// エラーペイロード
// ====================

const ValidationResult = struct {
    success: bool,
    field: ?[]const u8,
    message: ?[]const u8,
};

fn validate(data: []const u8) ValidationResult {
    if (data.len == 0) {
        return .{
            .success = false,
            .field = "data",
            .message = "データが空です",
        };
    }
    return .{ .success = true, .field = null, .message = null };
}

fn demoErrorPayload() void {
    std.debug.print("--- エラーペイロード ---\n", .{});

    std.debug.print("  error型には追加データ不可\n", .{});
    std.debug.print("  代替: Result構造体、outパラメータ\n", .{});

    const result = validate("");
    if (!result.success) {
        std.debug.print("  検証失敗:\n", .{});
        std.debug.print("    field: {s}\n", .{result.field.?});
        std.debug.print("    message: {s}\n", .{result.message.?});
    }

    std.debug.print("\n", .{});
}

// ====================
// エラートレース
// ====================

fn level2() !void {
    return error.DeepError;
}

fn level1() !void {
    try level2();
}

fn demoErrorTrace() void {
    std.debug.print("--- エラートレース ---\n", .{});

    std.debug.print("  @errorReturnTrace(): デバッグ時有効\n", .{});
    std.debug.print("  @returnAddress(): 戻りアドレス取得\n", .{});

    if (level1()) |_| {} else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
        if (@errorReturnTrace()) |trace| {
            std.debug.print("  トレース: {d}アドレス記録\n", .{trace.index});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// Optional vs Error
// ====================

fn findIndex(arr: []const i32, target: i32) ?usize {
    for (arr, 0..) |v, i| {
        if (v == target) return i;
    }
    return null; // 見つからないのは正常
}

fn parseNumber(s: []const u8) error{InvalidFormat}!i32 {
    if (s.len == 0 or s[0] < '0' or s[0] > '9') {
        return error.InvalidFormat; // 失敗は異常
    }
    return 42;
}

fn demoOptionalVsError() void {
    std.debug.print("--- Optional vs Error ---\n", .{});

    std.debug.print("  ?T: 「不在」が正常な場合\n", .{});
    const arr = [_]i32{ 10, 20, 30 };
    const idx = findIndex(&arr, 99);
    std.debug.print("    検索: {s}\n", .{if (idx != null) "found" else "not found"});

    std.debug.print("  E!T: 「失敗」の理由が重要\n", .{});
    if (parseNumber("abc")) |_| {} else |err| {
        std.debug.print("    解析: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践パターン
// ====================

const Config = struct {
    host: []const u8,
    port: u16,
    timeout: u32,

    fn default() Config {
        return .{
            .host = "localhost",
            .port = 8080,
            .timeout = 30,
        };
    }
};

fn loadConfig(path: []const u8) FileError!Config {
    if (path.len == 0) return error.FileNotFound;
    return .{
        .host = "api.example.com",
        .port = 443,
        .timeout = 60,
    };
}

fn connect(config: Config) NetworkError!void {
    if (config.port == 0) return error.ConnectionFailed;
    std.debug.print("    Connected to {s}:{d}\n", .{ config.host, config.port });
}

fn initApp(config_path: []const u8) (FileError || NetworkError)!void {
    // 設定読み込み、失敗時はデフォルト
    const config = loadConfig(config_path) catch Config.default();
    errdefer std.debug.print("    Cleanup on error\n", .{});

    try connect(config);
    std.debug.print("    App initialized\n", .{});
}

fn demoPracticalPattern() void {
    std.debug.print("--- 実践パターン ---\n", .{});

    // 成功
    std.debug.print("  [設定ファイルあり]\n", .{});
    initApp("config.json") catch |err| {
        std.debug.print("    Init failed: {s}\n", .{@errorName(err)});
    };

    // デフォルトにフォールバック
    std.debug.print("  [設定ファイルなし→デフォルト]\n", .{});
    initApp("") catch |err| {
        std.debug.print("    Init failed: {s}\n", .{@errorName(err)});
    };

    std.debug.print("\n", .{});
}

// ====================
// 章まとめ
// ====================

fn demoChapterSummary() void {
    std.debug.print("=== 05_errors 章まとめ ===\n", .{});

    std.debug.print("  エラーセット:\n", .{});
    std.debug.print("    error{{...}}, ||, anyerror\n", .{});

    std.debug.print("  エラーユニオン:\n", .{});
    std.debug.print("    E!T, !T\n", .{});

    std.debug.print("  アンラップ:\n", .{});
    std.debug.print("    try, catch, if-else\n", .{});

    std.debug.print("  クリーンアップ:\n", .{});
    std.debug.print("    defer, errdefer\n", .{});

    std.debug.print("  デバッグ:\n", .{});
    std.debug.print("    @errorReturnTrace, @errorName\n", .{});

    std.debug.print("  使い分け:\n", .{});
    std.debug.print("    ?T（正常な不在）vs E!T（異常な失敗）\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラー処理総まとめ ===\n\n", .{});

    demoErrorSets();
    demoErrorUnion();
    demoTryCatch();
    demoErrdefer();
    demoErrorPayload();
    demoErrorTrace();
    demoOptionalVsError();
    demoPracticalPattern();
    demoChapterSummary();

    std.debug.print("--- 次章予告 ---\n", .{});
    std.debug.print("06_data_structures: ArrayList, HashMap, etc.\n", .{});
}

// --- テスト ---

test "error set merge" {
    const net_err: IOError = error.Timeout;
    const file_err: IOError = error.FileNotFound;
    try std.testing.expectEqualStrings("Timeout", @errorName(net_err));
    try std.testing.expectEqualStrings("FileNotFound", @errorName(file_err));
}

test "error union success" {
    const result = try divide(10, 2);
    try std.testing.expectEqual(@as(i32, 5), result);
}

test "error union failure" {
    const result = divide(10, 0);
    try std.testing.expectError(error.DivisionByZero, result);
}

test "try propagation" {
    const result = try processValue(10);
    try std.testing.expectEqual(@as(i32, 15), result);
}

test "catch default" {
    const result = divide(10, 0) catch 0;
    try std.testing.expectEqual(@as(i32, 0), result);
}

test "validation result" {
    const result = validate("");
    try std.testing.expect(!result.success);
    try std.testing.expectEqualStrings("data", result.field.?);
}

test "optional search not found" {
    const arr = [_]i32{ 10, 20, 30 };
    const result = findIndex(&arr, 99);
    try std.testing.expect(result == null);
}

test "optional search found" {
    const arr = [_]i32{ 10, 20, 30 };
    const result = findIndex(&arr, 20);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(usize, 1), result.?);
}

test "parse error" {
    const result = parseNumber("abc");
    try std.testing.expectError(error.InvalidFormat, result);
}

test "config default fallback" {
    const config = loadConfig("") catch Config.default();
    try std.testing.expectEqualStrings("localhost", config.host);
}
