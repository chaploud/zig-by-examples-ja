//! # テストパターン
//!
//! 実践的なテストパターンとテクニック。
//! モック、スタブ、依存性注入など。
//!
//! ## 主要パターン
//! - モック/スタブ: 外部依存の置換
//! - 依存性注入: テスト容易性の向上
//! - テーブル駆動: データ駆動テスト
//! - プロパティベース: 不変条件のテスト

const std = @import("std");

// ====================
// モック/スタブパターン
// ====================

// 本番用インターフェース
const Logger = struct {
    logFn: *const fn ([]const u8) void,

    pub fn log(self: Logger, message: []const u8) void {
        self.logFn(message);
    }
};

// 本番実装
fn realLog(message: []const u8) void {
    std.debug.print("[LOG] {s}\n", .{message});
}

// テスト用モック
const MockLogger = struct {
    call_count: usize = 0,
    last_message: []const u8 = "",

    pub fn log(self: *MockLogger, message: []const u8) void {
        self.call_count += 1;
        self.last_message = message;
    }
};

// ロガーを使う関数
fn processData(logger: Logger, data: []const u8) void {
    logger.log("Processing started");
    _ = data;
    logger.log("Processing completed");
}

test "mock: logger call count" {
    // モックをLoggerインターフェースとして使う（コールバック形式）
    // 静的変数でカウントを追跡
    const Counter = struct {
        var call_count: usize = 0;

        fn log(_: []const u8) void {
            call_count += 1;
        }

        fn reset() void {
            call_count = 0;
        }
    };

    Counter.reset();
    const logger = Logger{ .logFn = Counter.log };
    processData(logger, "test data");

    // 2回呼ばれるはず（started, completed）
    try std.testing.expectEqual(@as(usize, 2), Counter.call_count);
}

// ====================
// 依存性注入パターン
// ====================

// 設定可能なリーダー
fn Reader(comptime ReaderType: type) type {
    return struct {
        const Self = @This();
        context: *ReaderType,

        pub fn read(self: Self, buffer: []u8) !usize {
            return self.context.read(buffer);
        }
    };
}

// テスト用リーダー
const TestReader = struct {
    data: []const u8,
    pos: usize = 0,

    pub fn read(self: *TestReader, buffer: []u8) !usize {
        if (self.pos >= self.data.len) return 0;

        const remaining = self.data.len - self.pos;
        const to_read = @min(buffer.len, remaining);

        @memcpy(buffer[0..to_read], self.data[self.pos..][0..to_read]);
        self.pos += to_read;
        return to_read;
    }
};

fn countBytes(reader: anytype) !usize {
    var count: usize = 0;
    var buffer: [1024]u8 = undefined;

    while (true) {
        const n = try reader.read(&buffer);
        if (n == 0) break;
        count += n;
    }

    return count;
}

test "di: test reader injection" {
    var reader = TestReader{ .data = "Hello, World!" };

    const count = try countBytes(&reader);
    try std.testing.expectEqual(@as(usize, 13), count);
}

// ====================
// テーブル駆動テスト
// ====================

fn parseNumber(s: []const u8) !i32 {
    if (s.len == 0) return error.EmptyString;

    var result: i32 = 0;
    var negative = false;
    var start: usize = 0;

    if (s[0] == '-') {
        negative = true;
        start = 1;
    } else if (s[0] == '+') {
        start = 1;
    }

    if (start >= s.len) return error.InvalidFormat;

    for (s[start..]) |c| {
        if (c < '0' or c > '9') return error.InvalidChar;
        result = result * 10 + @as(i32, @intCast(c - '0'));
    }

    return if (negative) -result else result;
}

test "table driven: parseNumber success cases" {
    const TestCase = struct {
        input: []const u8,
        expected: i32,
    };

    const cases = [_]TestCase{
        .{ .input = "0", .expected = 0 },
        .{ .input = "123", .expected = 123 },
        .{ .input = "-456", .expected = -456 },
        .{ .input = "+789", .expected = 789 },
        .{ .input = "999", .expected = 999 },
    };

    for (cases) |case| {
        const result = try parseNumber(case.input);
        try std.testing.expectEqual(case.expected, result);
    }
}

test "table driven: parseNumber error cases" {
    const ErrorCase = struct {
        input: []const u8,
        expected_error: anyerror,
    };

    const cases = [_]ErrorCase{
        .{ .input = "", .expected_error = error.EmptyString },
        .{ .input = "-", .expected_error = error.InvalidFormat },
        .{ .input = "12a3", .expected_error = error.InvalidChar },
        .{ .input = "abc", .expected_error = error.InvalidChar },
    };

    for (cases) |case| {
        try std.testing.expectError(case.expected_error, parseNumber(case.input));
    }
}

// ====================
// プロパティベーステスト
// ====================

fn reverse(slice: []u8) void {
    if (slice.len == 0) return;

    var i: usize = 0;
    var j: usize = slice.len - 1;
    while (i < j) {
        const tmp = slice[i];
        slice[i] = slice[j];
        slice[j] = tmp;
        i += 1;
        j -= 1;
    }
}

test "property: reverse twice equals original" {
    // 任意の入力に対して、2回reverseすると元に戻る
    const test_cases = [_][]const u8{
        "hello",
        "a",
        "",
        "abcdef",
        "12345",
    };

    for (test_cases) |original| {
        var buffer: [100]u8 = undefined;
        @memcpy(buffer[0..original.len], original);
        const slice = buffer[0..original.len];

        reverse(slice);
        reverse(slice);

        try std.testing.expectEqualStrings(original, slice);
    }
}

test "property: reverse length preserved" {
    const test_cases = [_][]const u8{
        "hello",
        "",
        "x",
        "longer string",
    };

    for (test_cases) |original| {
        var buffer: [100]u8 = undefined;
        @memcpy(buffer[0..original.len], original);
        const slice = buffer[0..original.len];

        const len_before = slice.len;
        reverse(slice);
        try std.testing.expectEqual(len_before, slice.len);
    }
}

// ====================
// セットアップ/ティアダウン
// ====================

const TestContext = struct {
    allocator: std.mem.Allocator,
    temp_data: []u8,

    pub fn setup(allocator: std.mem.Allocator) !TestContext {
        const data = try allocator.alloc(u8, 256);
        @memset(data, 0xFF);
        return .{
            .allocator = allocator,
            .temp_data = data,
        };
    }

    pub fn teardown(self: *TestContext) void {
        self.allocator.free(self.temp_data);
    }
};

test "setup/teardown: context management" {
    var ctx = try TestContext.setup(std.testing.allocator);
    defer ctx.teardown();

    // セットアップで0xFFに初期化されている
    try std.testing.expectEqual(@as(u8, 0xFF), ctx.temp_data[0]);

    // テスト中に変更
    ctx.temp_data[0] = 0x00;
    try std.testing.expectEqual(@as(u8, 0x00), ctx.temp_data[0]);
}

// ====================
// エッジケーステスト
// ====================

fn safeDivide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivisionByZero;
    if (a == std.math.minInt(i32) and b == -1) return error.Overflow;
    return @divTrunc(a, b);
}

test "edge: division edge cases" {
    // 通常ケース
    try std.testing.expectEqual(@as(i32, 5), try safeDivide(10, 2));
    try std.testing.expectEqual(@as(i32, -5), try safeDivide(-10, 2));

    // 境界値
    try std.testing.expectEqual(@as(i32, 0), try safeDivide(0, 5));
    try std.testing.expectEqual(@as(i32, 1), try safeDivide(std.math.maxInt(i32), std.math.maxInt(i32)));

    // エラーケース
    try std.testing.expectError(error.DivisionByZero, safeDivide(10, 0));
    try std.testing.expectError(error.Overflow, safeDivide(std.math.minInt(i32), -1));
}

// ====================
// 状態遷移テスト
// ====================

const State = enum {
    idle,
    running,
    paused,
    stopped,
};

const StateMachine = struct {
    state: State = .idle,

    pub fn start(self: *StateMachine) !void {
        if (self.state != .idle and self.state != .paused) {
            return error.InvalidTransition;
        }
        self.state = .running;
    }

    pub fn pause(self: *StateMachine) !void {
        if (self.state != .running) return error.InvalidTransition;
        self.state = .paused;
    }

    pub fn stop(self: *StateMachine) !void {
        if (self.state == .stopped) return error.InvalidTransition;
        self.state = .stopped;
    }

    pub fn reset(self: *StateMachine) void {
        self.state = .idle;
    }
};

test "state: valid transitions" {
    var sm = StateMachine{};

    try std.testing.expectEqual(State.idle, sm.state);

    try sm.start();
    try std.testing.expectEqual(State.running, sm.state);

    try sm.pause();
    try std.testing.expectEqual(State.paused, sm.state);

    try sm.start(); // paused -> running
    try std.testing.expectEqual(State.running, sm.state);

    try sm.stop();
    try std.testing.expectEqual(State.stopped, sm.state);
}

test "state: invalid transitions" {
    var sm = StateMachine{};

    // idle -> pause: 不正
    try std.testing.expectError(error.InvalidTransition, sm.pause());

    sm.state = .stopped;
    // stopped -> start: 不正
    try std.testing.expectError(error.InvalidTransition, sm.start());
    // stopped -> stop: 不正
    try std.testing.expectError(error.InvalidTransition, sm.stop());
}

// ====================
// まとめ
// ====================

// テストパターン一覧:
// 1. モック/スタブ: 外部依存を置換
// 2. 依存性注入: インターフェース経由で注入
// 3. テーブル駆動: データ配列でテストケース管理
// 4. プロパティベース: 不変条件を検証
// 5. セットアップ/ティアダウン: リソース管理
// 6. エッジケース: 境界値とエラー条件
// 7. 状態遷移: 状態マシンのテスト

pub fn main() void {
    std.debug.print("=== テストパターン ===\n\n", .{});
    std.debug.print("テスト実行: zig test 07_testing/n068_test_patterns.zig\n\n", .{});

    std.debug.print("--- パターン一覧 ---\n", .{});
    std.debug.print("  モック/スタブ     - 外部依存を置換\n", .{});
    std.debug.print("  依存性注入       - テスト容易性向上\n", .{});
    std.debug.print("  テーブル駆動     - データ配列でケース管理\n", .{});
    std.debug.print("  プロパティベース - 不変条件の検証\n", .{});
    std.debug.print("  状態遷移         - 状態マシンテスト\n", .{});
}
