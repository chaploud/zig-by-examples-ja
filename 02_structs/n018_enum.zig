//! # 列挙型（enum）
//!
//! enumは有限個の名前付き値を持つ型。
//! switch文との組み合わせで安全な分岐処理が可能。
//!
//! ## 特徴
//! - コンパイル時に全ての値が既知
//! - switchで網羅性チェック
//! - 整数型へのマッピングが可能
//! - メソッドを持てる

const std = @import("std");

// ====================
// 基本的なenum
// ====================

const Direction = enum {
    north,
    east,
    south,
    west,
};

// ====================
// 明示的な値を持つenum
// ====================

const HttpStatus = enum(u16) {
    ok = 200,
    created = 201,
    bad_request = 400,
    not_found = 404,
    internal_server_error = 500,
};

// ====================
// 連続した値（自動採番）
// ====================

const Color = enum(u8) {
    red = 1,
    green, // 2
    blue, // 3
    alpha, // 4
};

// ====================
// メソッドを持つenum
// ====================

const LogLevel = enum {
    debug,
    info,
    warning,
    err,
    fatal,

    const Self = @This();

    /// 文字列表現を取得
    pub fn toString(self: Self) []const u8 {
        return switch (self) {
            .debug => "DEBUG",
            .info => "INFO",
            .warning => "WARNING",
            .err => "ERROR",
            .fatal => "FATAL",
        };
    }

    /// 指定レベル以上かどうか
    pub fn isAtLeast(self: Self, min_level: Self) bool {
        return @intFromEnum(self) >= @intFromEnum(min_level);
    }

    /// ログ出力（実装例）
    pub fn log(self: Self, message: []const u8) void {
        std.debug.print("[{s}] {s}\n", .{ self.toString(), message });
    }
};

// ====================
// ビットフラグ風の使用
// ====================

const FileMode = enum(u8) {
    read = 1,
    write = 2,
    execute = 4,
};

// ====================
// 曜日の例
// ====================

const DayOfWeek = enum(u8) {
    monday = 1,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,

    const Self = @This();

    pub fn isWeekend(self: Self) bool {
        return self == .saturday or self == .sunday;
    }

    pub fn next(self: Self) Self {
        return if (self == .sunday) .monday else @enumFromInt(@intFromEnum(self) + 1);
    }

    pub fn toJapanese(self: Self) []const u8 {
        return switch (self) {
            .monday => "月曜日",
            .tuesday => "火曜日",
            .wednesday => "水曜日",
            .thursday => "木曜日",
            .friday => "金曜日",
            .saturday => "土曜日",
            .sunday => "日曜日",
        };
    }
};

// ====================
// 状態マシン
// ====================

const ConnectionState = enum {
    disconnected,
    connecting,
    connected,
    error_state,

    const Self = @This();

    pub fn canConnect(self: Self) bool {
        return self == .disconnected or self == .error_state;
    }

    pub fn canDisconnect(self: Self) bool {
        return self == .connected or self == .connecting;
    }
};

pub fn main() void {
    std.debug.print("=== 列挙型（enum） ===\n\n", .{});

    // ====================
    // 基本的な使用
    // ====================

    std.debug.print("--- 基本的なenum ---\n", .{});

    const dir = Direction.north;
    std.debug.print("Direction: {}\n", .{dir});

    // switchとの組み合わせ
    const dir_name = switch (dir) {
        .north => "北",
        .east => "東",
        .south => "南",
        .west => "西",
    };
    std.debug.print("方角: {s}\n", .{dir_name});

    std.debug.print("\n", .{});

    // ====================
    // 整数値との変換
    // ====================

    std.debug.print("--- 整数値との変換 ---\n", .{});

    const status = HttpStatus.ok;
    const status_code: u16 = @intFromEnum(status);
    std.debug.print("HTTP Status: {} (code: {d})\n", .{ status, status_code });

    // 整数からenumへ
    const status2: HttpStatus = @enumFromInt(404);
    std.debug.print("Code 404 = {}\n", .{status2});

    std.debug.print("\n", .{});

    // ====================
    // @tagName でenum名を文字列で取得
    // ====================

    std.debug.print("--- @tagName ---\n", .{});

    const color = Color.green;
    std.debug.print("Color: {s} (value: {d})\n", .{ @tagName(color), @intFromEnum(color) });

    std.debug.print("\n", .{});

    // ====================
    // メソッドを持つenum
    // ====================

    std.debug.print("--- enumのメソッド ---\n", .{});

    const level = LogLevel.warning;
    level.log("何か問題が発生しました");

    std.debug.print("level >= info: {}\n", .{level.isAtLeast(.info)});
    std.debug.print("level >= err: {}\n", .{level.isAtLeast(.err)});

    std.debug.print("\n", .{});

    // ====================
    // 曜日の例
    // ====================

    std.debug.print("--- 曜日の例 ---\n", .{});

    const today = DayOfWeek.friday;
    std.debug.print("今日: {s}\n", .{today.toJapanese()});
    std.debug.print("週末: {}\n", .{today.isWeekend()});

    const tomorrow = today.next();
    std.debug.print("明日: {s}\n", .{tomorrow.toJapanese()});
    std.debug.print("明日は週末: {}\n", .{tomorrow.isWeekend()});

    std.debug.print("\n", .{});

    // ====================
    // 状態マシン
    // ====================

    std.debug.print("--- 状態マシン ---\n", .{});

    var conn_state = ConnectionState.disconnected;
    std.debug.print("状態: {}, 接続可能: {}\n", .{ conn_state, conn_state.canConnect() });

    conn_state = .connected;
    std.debug.print("状態: {}, 切断可能: {}\n", .{ conn_state, conn_state.canDisconnect() });

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・@intFromEnum: enumを整数に変換\n", .{});
    std.debug.print("・@enumFromInt: 整数をenumに変換\n", .{});
    std.debug.print("・@tagName: enum値の名前を文字列で取得\n", .{});
    std.debug.print("・switchは全ての値を網羅する必要がある\n", .{});
}

// --- テスト ---

test "basic enum" {
    const d = Direction.east;
    try std.testing.expect(d == .east);
    try std.testing.expect(d != .west);
}

test "enum with explicit values" {
    try std.testing.expectEqual(@as(u16, 200), @intFromEnum(HttpStatus.ok));
    try std.testing.expectEqual(@as(u16, 404), @intFromEnum(HttpStatus.not_found));
    try std.testing.expectEqual(@as(u16, 500), @intFromEnum(HttpStatus.internal_server_error));
}

test "enum from int" {
    const status: HttpStatus = @enumFromInt(201);
    try std.testing.expect(status == .created);
}

test "sequential enum values" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(Color.red));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(Color.green));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(Color.blue));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(Color.alpha));
}

test "enum @tagName" {
    try std.testing.expect(std.mem.eql(u8, @tagName(Direction.north), "north"));
    try std.testing.expect(std.mem.eql(u8, @tagName(HttpStatus.ok), "ok"));
}

test "LogLevel methods" {
    const debug = LogLevel.debug;
    const err = LogLevel.err;

    try std.testing.expect(std.mem.eql(u8, debug.toString(), "DEBUG"));
    try std.testing.expect(std.mem.eql(u8, err.toString(), "ERROR"));

    try std.testing.expect(!debug.isAtLeast(.info));
    try std.testing.expect(err.isAtLeast(.info));
    try std.testing.expect(err.isAtLeast(.err));
}

test "DayOfWeek" {
    const friday = DayOfWeek.friday;
    const saturday = DayOfWeek.saturday;
    const sunday = DayOfWeek.sunday;

    try std.testing.expect(!friday.isWeekend());
    try std.testing.expect(saturday.isWeekend());
    try std.testing.expect(sunday.isWeekend());

    try std.testing.expect(friday.next() == .saturday);
    try std.testing.expect(sunday.next() == .monday);
}

test "ConnectionState" {
    const disconnected = ConnectionState.disconnected;
    const connected = ConnectionState.connected;
    const connecting = ConnectionState.connecting;

    try std.testing.expect(disconnected.canConnect());
    try std.testing.expect(!connected.canConnect());

    try std.testing.expect(!disconnected.canDisconnect());
    try std.testing.expect(connected.canDisconnect());
    try std.testing.expect(connecting.canDisconnect());
}

test "switch exhaustiveness" {
    // switchは全ての値を網羅する必要がある
    const d = Direction.south;
    const result = switch (d) {
        .north => 0,
        .east => 1,
        .south => 2,
        .west => 3,
    };
    try std.testing.expectEqual(@as(u8, 2), result);
}

test "enum comparison" {
    const a = LogLevel.info;
    const b = LogLevel.info;
    const c = LogLevel.err;

    try std.testing.expect(a == b);
    try std.testing.expect(a != c);

    // 整数値での比較
    try std.testing.expect(@intFromEnum(a) < @intFromEnum(c));
}
