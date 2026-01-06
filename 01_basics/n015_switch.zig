//! # switch文
//!
//! Zigのswitchは強力なパターンマッチング機能を持つ。
//! すべてのケースを網羅する必要がある（網羅性チェック）。
//!
//! ## 特徴
//! - 式として値を返せる
//! - 範囲マッチング可能（0...10など）
//! - 複数値を1つのブランチで処理可能
//! - すべての可能性を網羅する必要がある
//! - elseでデフォルトケースを処理

const std = @import("std");

pub fn main() void {
    std.debug.print("=== switch文 ===\n\n", .{});

    // ====================
    // 基本的なswitch
    // ====================

    const day: u8 = 3;
    const day_name = switch (day) {
        1 => "月曜日",
        2 => "火曜日",
        3 => "水曜日",
        4 => "木曜日",
        5 => "金曜日",
        6 => "土曜日",
        7 => "日曜日",
        else => "不明",
    };
    std.debug.print("day={d} → {s}\n\n", .{ day, day_name });

    // ====================
    // 複数値を1つのブランチで
    // ====================

    const num: u8 = 5;
    const category = switch (num) {
        1, 2, 3 => "小",
        4, 5, 6 => "中",
        7, 8, 9 => "大",
        else => "範囲外",
    };
    std.debug.print("num={d} → {s}\n\n", .{ num, category });

    // ====================
    // 範囲マッチング
    // ====================

    const score: u8 = 85;
    const grade = switch (score) {
        90...100 => "A",
        80...89 => "B",
        70...79 => "C",
        60...69 => "D",
        0...59 => "F",
        else => "無効",
    };
    std.debug.print("score={d} → grade={s}\n\n", .{ score, grade });

    // ====================
    // enumとswitch
    // ====================

    const Color = enum { red, green, blue };
    const color = Color.green;

    const rgb = switch (color) {
        .red => "255,0,0",
        .green => "0,255,0",
        .blue => "0,0,255",
    };
    std.debug.print("color={s} → RGB={s}\n\n", .{ @tagName(color), rgb });

    // ====================
    // switchでブロックを実行
    // ====================

    const op: u8 = '+';
    const a: i32 = 10;
    const b: i32 = 3;

    const result = switch (op) {
        '+' => blk: {
            std.debug.print("加算を実行: ", .{});
            break :blk a + b;
        },
        '-' => blk: {
            std.debug.print("減算を実行: ", .{});
            break :blk a - b;
        },
        '*' => a * b,
        '/' => @divTrunc(a, b),
        else => blk: {
            std.debug.print("未対応の演算子: ", .{});
            break :blk 0;
        },
    };
    std.debug.print("{d} {c} {d} = {d}\n\n", .{ a, op, b, result });

    // ====================
    // 文字の分類
    // ====================

    const chars = "aB3!";
    std.debug.print("文字の分類:\n", .{});
    for (chars) |c| {
        const char_type = switch (c) {
            'a'...'z' => "小文字",
            'A'...'Z' => "大文字",
            '0'...'9' => "数字",
            else => "その他",
        };
        std.debug.print("  '{c}' → {s}\n", .{ c, char_type });
    }

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・すべてのケースを網羅する必要がある\n", .{});
    std.debug.print("・範囲は ... で指定（両端含む）\n", .{});
    std.debug.print("・enumとの組み合わせが強力\n", .{});
}

// ====================
// 実用的な関数例
// ====================

/// HTTPステータスコードの説明を返す
fn httpStatusMessage(code: u16) []const u8 {
    return switch (code) {
        200 => "OK",
        201 => "Created",
        204 => "No Content",
        301 => "Moved Permanently",
        302 => "Found",
        304 => "Not Modified",
        400 => "Bad Request",
        401 => "Unauthorized",
        403 => "Forbidden",
        404 => "Not Found",
        500 => "Internal Server Error",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        else => "Unknown",
    };
}

/// 文字の種類を判定
const CharType = enum { digit, lowercase, uppercase, whitespace, other };

fn classifyChar(c: u8) CharType {
    return switch (c) {
        '0'...'9' => .digit,
        'a'...'z' => .lowercase,
        'A'...'Z' => .uppercase,
        ' ', '\t', '\n', '\r' => .whitespace,
        else => .other,
    };
}

/// 月の日数を返す（閏年対応）
fn daysInMonth(month: u8, is_leap_year: bool) ?u8 {
    return switch (month) {
        1, 3, 5, 7, 8, 10, 12 => 31,
        4, 6, 9, 11 => 30,
        2 => if (is_leap_year) 29 else 28,
        else => null,
    };
}

/// 演算子の優先度を返す
fn operatorPrecedence(op: u8) u8 {
    return switch (op) {
        '+', '-' => 1,
        '*', '/' => 2,
        '^' => 3,
        else => 0,
    };
}

// --- テスト ---

test "basic switch" {
    const x: i32 = 2;
    const result = switch (x) {
        1 => "one",
        2 => "two",
        3 => "three",
        else => "other",
    };
    try std.testing.expect(std.mem.eql(u8, result, "two"));
}

test "switch multiple values" {
    const x: i32 = 5;
    const result = switch (x) {
        1, 2, 3 => "small",
        4, 5, 6 => "medium",
        7, 8, 9 => "large",
        else => "other",
    };
    try std.testing.expect(std.mem.eql(u8, result, "medium"));
}

test "switch range" {
    const score: u8 = 85;
    const grade = switch (score) {
        90...100 => "A",
        80...89 => "B",
        70...79 => "C",
        60...69 => "D",
        0...59 => "F",
        else => "Invalid",
    };
    try std.testing.expect(std.mem.eql(u8, grade, "B"));
}

test "switch with enum" {
    const Direction = enum { north, south, east, west };
    const dir = Direction.east;

    const x_delta: i32 = switch (dir) {
        .north, .south => 0,
        .east => 1,
        .west => -1,
    };

    try std.testing.expectEqual(@as(i32, 1), x_delta);
}

test "switch returns value" {
    const a: i32 = 10;
    const b: i32 = 20;
    const op: u8 = '+';

    const result = switch (op) {
        '+' => a + b,
        '-' => a - b,
        '*' => a * b,
        '/' => @divTrunc(a, b),
        else => 0,
    };

    try std.testing.expectEqual(@as(i32, 30), result);
}

test "switch with block" {
    const x: i32 = 5;

    const result = switch (x) {
        5 => blk: {
            const doubled = x * 2;
            break :blk doubled + 1;
        },
        else => 0,
    };

    try std.testing.expectEqual(@as(i32, 11), result);
}

test "httpStatusMessage function" {
    try std.testing.expect(std.mem.eql(u8, httpStatusMessage(200), "OK"));
    try std.testing.expect(std.mem.eql(u8, httpStatusMessage(404), "Not Found"));
    try std.testing.expect(std.mem.eql(u8, httpStatusMessage(999), "Unknown"));
}

test "classifyChar function" {
    try std.testing.expectEqual(CharType.digit, classifyChar('5'));
    try std.testing.expectEqual(CharType.lowercase, classifyChar('a'));
    try std.testing.expectEqual(CharType.uppercase, classifyChar('Z'));
    try std.testing.expectEqual(CharType.whitespace, classifyChar(' '));
    try std.testing.expectEqual(CharType.other, classifyChar('!'));
}

test "daysInMonth function" {
    try std.testing.expectEqual(@as(?u8, 31), daysInMonth(1, false));
    try std.testing.expectEqual(@as(?u8, 28), daysInMonth(2, false));
    try std.testing.expectEqual(@as(?u8, 29), daysInMonth(2, true));
    try std.testing.expectEqual(@as(?u8, 30), daysInMonth(4, false));
    try std.testing.expect(daysInMonth(13, false) == null);
}

test "operatorPrecedence function" {
    try std.testing.expectEqual(@as(u8, 1), operatorPrecedence('+'));
    try std.testing.expectEqual(@as(u8, 1), operatorPrecedence('-'));
    try std.testing.expectEqual(@as(u8, 2), operatorPrecedence('*'));
    try std.testing.expectEqual(@as(u8, 2), operatorPrecedence('/'));
    try std.testing.expectEqual(@as(u8, 3), operatorPrecedence('^'));
    try std.testing.expectEqual(@as(u8, 0), operatorPrecedence('!'));
}

test "switch exhaustiveness" {
    // enumはすべてのケースを網羅する必要がある
    const Status = enum { pending, active, completed };
    const s = Status.active;

    const description = switch (s) {
        .pending => "待機中",
        .active => "アクティブ",
        .completed => "完了",
    };

    try std.testing.expect(std.mem.eql(u8, description, "アクティブ"));
}

test "switch character ranges" {
    const classify = struct {
        fn f(c: u8) []const u8 {
            return switch (c) {
                'a'...'f', 'A'...'F', '0'...'9' => "hex",
                else => "not hex",
            };
        }
    }.f;

    try std.testing.expect(std.mem.eql(u8, classify('a'), "hex"));
    try std.testing.expect(std.mem.eql(u8, classify('F'), "hex"));
    try std.testing.expect(std.mem.eql(u8, classify('9'), "hex"));
    try std.testing.expect(std.mem.eql(u8, classify('g'), "not hex"));
}
