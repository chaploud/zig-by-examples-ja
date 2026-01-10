//! # テストの構成
//!
//! 複数ファイルにまたがるテストの整理方法と、
//! モジュール内のテストを網羅的に実行する方法。
//!
//! ## 主要テクニック
//! - refAllDecls: インポートしたモジュールのテストを実行
//! - 名前付きテスト: テストの分類と識別
//! - ファイル分割: コードとテストの分離

const std = @import("std");

// ====================
// 被テストモジュール（埋め込み）
// ====================

// 通常は別ファイルだが、説明のため同一ファイル内に定義
const math_utils = struct {
    pub fn add(a: i32, b: i32) i32 {
        return a + b;
    }

    pub fn multiply(a: i32, b: i32) i32 {
        return a * b;
    }

    pub fn isPositive(n: i32) bool {
        return n > 0;
    }

    // モジュール内テスト
    test "add works" {
        try std.testing.expectEqual(@as(i32, 5), add(2, 3));
    }

    test "multiply works" {
        try std.testing.expectEqual(@as(i32, 6), multiply(2, 3));
    }
};

const string_utils = struct {
    pub fn isEmpty(s: []const u8) bool {
        return s.len == 0;
    }

    pub fn startsWith(s: []const u8, prefix: []const u8) bool {
        if (s.len < prefix.len) return false;
        return std.mem.eql(u8, s[0..prefix.len], prefix);
    }

    // モジュール内テスト
    test "isEmpty" {
        try std.testing.expect(isEmpty(""));
        try std.testing.expect(!isEmpty("hello"));
    }

    test "startsWith" {
        try std.testing.expect(startsWith("hello world", "hello"));
        try std.testing.expect(!startsWith("hello", "world"));
    }
};

// ====================
// refAllDecls（モジュールテスト実行）
// ====================

// refAllDeclsを使うと、インポートしたモジュール内の
// 全てのテストが実行対象になる
test {
    // math_utils内の全テストを参照
    std.testing.refAllDecls(math_utils);

    // string_utils内の全テストを参照
    std.testing.refAllDecls(string_utils);
}

// ====================
// 名前付きテスト（分類）
// ====================

// テスト名で機能を分類
test "math: addition" {
    try std.testing.expectEqual(@as(i32, 0), math_utils.add(0, 0));
    try std.testing.expectEqual(@as(i32, -1), math_utils.add(-2, 1));
}

test "math: multiplication" {
    try std.testing.expectEqual(@as(i32, 0), math_utils.multiply(0, 5));
    try std.testing.expectEqual(@as(i32, -6), math_utils.multiply(-2, 3));
}

test "string: empty check" {
    try std.testing.expect(string_utils.isEmpty(""));
}

test "string: prefix check" {
    try std.testing.expect(string_utils.startsWith("zigzag", "zig"));
}

// ====================
// 境界値テスト
// ====================

test "boundary: integer limits" {
    const max_i32: i32 = std.math.maxInt(i32);
    const min_i32: i32 = std.math.minInt(i32);

    try std.testing.expect(math_utils.isPositive(max_i32));
    try std.testing.expect(!math_utils.isPositive(min_i32));
    try std.testing.expect(!math_utils.isPositive(0));
}

test "boundary: empty and single char" {
    try std.testing.expect(string_utils.isEmpty(""));
    try std.testing.expect(!string_utils.isEmpty("x"));
    try std.testing.expect(string_utils.startsWith("a", "a"));
    try std.testing.expect(!string_utils.startsWith("", "a"));
}

// ====================
// テスト用フィクスチャ
// ====================

const TestFixture = struct {
    allocator: std.mem.Allocator,
    data: []u8,

    pub fn init(allocator: std.mem.Allocator) !TestFixture {
        const data = try allocator.alloc(u8, 100);
        @memset(data, 0);
        return .{
            .allocator = allocator,
            .data = data,
        };
    }

    pub fn deinit(self: *TestFixture) void {
        self.allocator.free(self.data);
    }
};

test "fixture: setup and teardown" {
    var fixture = try TestFixture.init(std.testing.allocator);
    defer fixture.deinit();

    // フィクスチャを使ったテスト
    fixture.data[0] = 42;
    try std.testing.expectEqual(@as(u8, 42), fixture.data[0]);
}

// ====================
// パラメータ化テスト（手動）
// ====================

fn testAddition(a: i32, b: i32, expected: i32) !void {
    try std.testing.expectEqual(expected, math_utils.add(a, b));
}

test "parameterized: addition cases" {
    // 複数のテストケースを配列で管理
    const cases = [_]struct { a: i32, b: i32, expected: i32 }{
        .{ .a = 0, .b = 0, .expected = 0 },
        .{ .a = 1, .b = 2, .expected = 3 },
        .{ .a = -1, .b = 1, .expected = 0 },
        .{ .a = -5, .b = -3, .expected = -8 },
        .{ .a = 100, .b = -100, .expected = 0 },
    };

    for (cases) |case| {
        try testAddition(case.a, case.b, case.expected);
    }
}

test "parameterized: startsWith cases" {
    const cases = [_]struct { s: []const u8, prefix: []const u8, expected: bool }{
        .{ .s = "hello", .prefix = "hel", .expected = true },
        .{ .s = "hello", .prefix = "hello", .expected = true },
        .{ .s = "hello", .prefix = "world", .expected = false },
        .{ .s = "", .prefix = "", .expected = true },
        .{ .s = "a", .prefix = "ab", .expected = false },
    };

    for (cases) |case| {
        try std.testing.expectEqual(case.expected, string_utils.startsWith(case.s, case.prefix));
    }
}

// ====================
// 条件付きテスト
// ====================

test "conditional: os specific" {
    // OSに応じたテスト
    if (@import("builtin").os.tag == .linux) {
        // Linux固有のテスト
        try std.testing.expect(true);
    } else if (@import("builtin").os.tag == .macos) {
        // macOS固有のテスト
        try std.testing.expect(true);
    } else if (@import("builtin").os.tag == .windows) {
        // Windows固有のテスト
        try std.testing.expect(true);
    }
}

test "conditional: debug mode" {
    // デバッグモードでのみ実行
    if (@import("builtin").mode == .Debug) {
        try std.testing.expect(true);
    }
}

// ====================
// テストの出力確認
// ====================

fn formatResult(allocator: std.mem.Allocator, value: i32) ![]u8 {
    return try std.fmt.allocPrint(allocator, "Result: {d}", .{value});
}

test "output: formatted string" {
    const allocator = std.testing.allocator;

    const output = try formatResult(allocator, 42);
    defer allocator.free(output);

    try std.testing.expectEqualStrings("Result: 42", output);
}

// ====================
// エラーケースの網羅
// ====================

const ValidationError = error{
    TooShort,
    TooLong,
    InvalidChar,
};

fn validateUsername(name: []const u8) ValidationError!void {
    if (name.len < 3) return error.TooShort;
    if (name.len > 20) return error.TooLong;
    for (name) |c| {
        if (!std.ascii.isAlphanumeric(c) and c != '_') {
            return error.InvalidChar;
        }
    }
}

test "validation: all error cases" {
    // TooShort
    try std.testing.expectError(error.TooShort, validateUsername("ab"));
    try std.testing.expectError(error.TooShort, validateUsername(""));

    // TooLong
    try std.testing.expectError(error.TooLong, validateUsername("a" ** 21));

    // InvalidChar
    try std.testing.expectError(error.InvalidChar, validateUsername("hello world"));
    try std.testing.expectError(error.InvalidChar, validateUsername("user@name"));

    // 正常系
    try validateUsername("valid_user123");
    try validateUsername("abc");
}

// ====================
// まとめ
// ====================

// テスト構成のベストプラクティス:
// 1. 機能ごとに名前でグループ化
// 2. refAllDeclsでモジュールテストを含める
// 3. フィクスチャでセットアップ/ティアダウン
// 4. パラメータ化で重複削減
// 5. 境界値とエラーケースを網羅

pub fn main() void {
    std.debug.print("=== テストの構成 ===\n\n", .{});
    std.debug.print("テスト実行: zig test 07_testing/n067_test_organization.zig\n\n", .{});

    std.debug.print("--- テスト構成テクニック ---\n", .{});
    std.debug.print("  refAllDecls      - モジュール内テストを実行\n", .{});
    std.debug.print("  名前付きテスト   - 機能ごとに分類\n", .{});
    std.debug.print("  フィクスチャ     - セットアップ/ティアダウン\n", .{});
    std.debug.print("  パラメータ化     - テストケース配列\n", .{});
    std.debug.print("  条件付きテスト   - OS/モード別\n", .{});

    std.debug.print("\n--- テスト実行例 ---\n", .{});
    std.debug.print("  zig test file.zig          # 全テスト\n", .{});
    std.debug.print("  zig test --test-filter     # フィルタ\n", .{});
}
