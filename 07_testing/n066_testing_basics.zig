//! # テストの基礎
//!
//! Zigは言語レベルでテストをサポートしている。
//! `test`ブロックでユニットテストを記述し、`zig test`で実行。
//!
//! ## 基本構文
//! ```zig
//! test "テスト名" {
//!     try std.testing.expect(条件);
//! }
//! ```
//!
//! ## 特徴
//! - ソースコードと同じファイルにテストを記述
//! - 本番ビルドではテストコードは含まれない
//! - std.testing.allocatorでメモリリーク検出

const std = @import("std");

// ====================
// 被テスト関数
// ====================

fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn divide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

fn factorial(n: u32) u32 {
    if (n == 0) return 1;
    return n * factorial(n - 1);
}

fn isEven(n: i32) bool {
    return @mod(n, 2) == 0;
}

// ====================
// expect（真偽値テスト）
// ====================

test "expect - 基本的な真偽値テスト" {
    // expectは条件がtrueであることを確認
    try std.testing.expect(true);
    try std.testing.expect(1 + 1 == 2);
    try std.testing.expect(add(2, 3) == 5);
}

test "expect - 否定のテスト" {
    try std.testing.expect(!false);
    try std.testing.expect(!(1 == 2));
    try std.testing.expect(!isEven(3));
}

// ====================
// expectEqual（等価テスト）
// ====================

test "expectEqual - 整数の比較" {
    // expectEqual(expected, actual)
    try std.testing.expectEqual(5, add(2, 3));
    try std.testing.expectEqual(0, add(-5, 5));
}

test "expectEqual - 型変換に注意" {
    const result: i32 = 10;
    // 型を明示的にキャスト
    try std.testing.expectEqual(@as(i32, 10), result);
}

test "expectEqual - Optional型" {
    const value: ?i32 = 42;
    try std.testing.expectEqual(@as(?i32, 42), value);

    const null_value: ?i32 = null;
    try std.testing.expectEqual(@as(?i32, null), null_value);
}

test "expectEqual - 列挙型" {
    const Color = enum { red, green, blue };
    const c: Color = .green;
    try std.testing.expectEqual(Color.green, c);
}

// ====================
// expectEqualStrings（文字列比較）
// ====================

test "expectEqualStrings - 文字列の比較" {
    const s1 = "hello";
    const s2 = "hello";
    try std.testing.expectEqualStrings(s1, s2);
}

test "expectEqualStrings - 動的文字列" {
    const allocator = std.testing.allocator;

    const s = try allocator.dupe(u8, "test");
    defer allocator.free(s);

    try std.testing.expectEqualStrings("test", s);
}

// ====================
// expectEqualSlices（配列・スライス比較）
// ====================

test "expectEqualSlices - 配列の比較" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 3 };
    try std.testing.expectEqualSlices(i32, &a, &b);
}

test "expectEqualSlices - スライスの比較" {
    const arr = [_]u8{ 'a', 'b', 'c', 'd' };
    const slice = arr[1..3];
    try std.testing.expectEqualSlices(u8, &[_]u8{ 'b', 'c' }, slice);
}

// ====================
// expectError（エラーのテスト）
// ====================

test "expectError - エラーが発生することを確認" {
    // 0除算でエラーが発生するはず
    try std.testing.expectError(error.DivisionByZero, divide(10, 0));
}

test "expectError - 特定のエラーを期待" {
    const Result = error{InvalidInput};

    const func = struct {
        fn validate(n: i32) !i32 {
            if (n < 0) return Result.InvalidInput;
            return n;
        }
    }.validate;

    try std.testing.expectError(Result.InvalidInput, func(-1));
}

// ====================
// std.testing.allocator（メモリリーク検出）
// ====================

test "allocator - メモリリーク検出" {
    const allocator = std.testing.allocator;

    // メモリを確保
    const data = try allocator.alloc(u8, 100);
    // 正しく解放しないとテスト失敗
    defer allocator.free(data);

    // データを使用
    @memset(data, 0);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
}

test "allocator - ArrayListのテスト" {
    const allocator = std.testing.allocator;

    var list = std.ArrayList(i32){};
    defer list.deinit(allocator); // これがないとリーク

    try list.append(allocator, 1);
    try list.append(allocator, 2);
    try list.append(allocator, 3);

    try std.testing.expectEqual(@as(usize, 3), list.items.len);
}

// ====================
// 複合的なテスト
// ====================

test "複合テスト - 階乗" {
    try std.testing.expectEqual(@as(u32, 1), factorial(0));
    try std.testing.expectEqual(@as(u32, 1), factorial(1));
    try std.testing.expectEqual(@as(u32, 2), factorial(2));
    try std.testing.expectEqual(@as(u32, 6), factorial(3));
    try std.testing.expectEqual(@as(u32, 120), factorial(5));
}

test "複合テスト - エラーと正常系" {
    // 正常系
    const result = try divide(10, 2);
    try std.testing.expectEqual(@as(i32, 5), result);

    // エラー系
    try std.testing.expectError(error.DivisionByZero, divide(10, 0));
}

// ====================
// テストのスキップ
// ====================

test "skip - 条件付きスキップ" {
    // 特定の条件でテストをスキップ
    if (@import("builtin").os.tag == .windows) {
        return error.SkipZigTest;
    }

    // Linux/macOSでのみ実行されるテスト
    try std.testing.expect(true);
}

// ====================
// テスト用ヘルパー関数
// ====================

fn assertInRange(value: i32, min: i32, max: i32) !void {
    if (value < min or value > max) {
        return error.OutOfRange;
    }
}

test "ヘルパー関数を使ったテスト" {
    try assertInRange(5, 0, 10);
    try assertInRange(0, 0, 10);
    try assertInRange(10, 0, 10);

    try std.testing.expectError(error.OutOfRange, assertInRange(-1, 0, 10));
    try std.testing.expectError(error.OutOfRange, assertInRange(11, 0, 10));
}

// ====================
// expectApproxEqAbs（浮動小数点比較）
// ====================

test "expectApproxEqAbs - 浮動小数点の近似比較" {
    const epsilon = 0.0001;
    const a: f64 = 0.1 + 0.2;
    const b: f64 = 0.3;

    // 浮動小数点は誤差があるため近似比較
    try std.testing.expectApproxEqAbs(b, a, epsilon);
}

// ====================
// expectStringStartsWith / expectStringEndsWith
// ====================

test "expectStringStartsWith - 前方一致" {
    const msg = "Error: invalid input";
    try std.testing.expectStringStartsWith(msg, "Error:");
}

test "expectStringEndsWith - 後方一致" {
    const path = "/home/user/file.txt";
    try std.testing.expectStringEndsWith(path, ".txt");
}

// ====================
// まとめ（実行時は表示されない）
// ====================

// テスト関数一覧:
// - expect(bool)              : 条件がtrueか
// - expectEqual(exp, act)     : 値が等しいか
// - expectEqualStrings(s1,s2) : 文字列が等しいか
// - expectEqualSlices(T,s1,s2): 配列が等しいか
// - expectError(err, expr)    : エラーが発生するか
// - expectApproxEqAbs(a,b,e)  : 浮動小数点近似
// - expectStringStartsWith    : 前方一致
// - expectStringEndsWith      : 後方一致
//
// メモリリーク検出:
// const allocator = std.testing.allocator;
// defer で解放しないとテスト失敗
//
// テスト実行: zig test ファイル名.zig

pub fn main() void {
    std.debug.print("=== テストの基礎 ===\n\n", .{});
    std.debug.print("このファイルはテスト用です。\n", .{});
    std.debug.print("以下のコマンドでテストを実行:\n\n", .{});
    std.debug.print("  zig test 07_testing/n066_testing_basics.zig\n\n", .{});

    std.debug.print("--- 主なテスト関数 ---\n", .{});
    std.debug.print("  expect(bool)              - 条件がtrue\n", .{});
    std.debug.print("  expectEqual(exp, act)     - 値が等しい\n", .{});
    std.debug.print("  expectEqualStrings(a, b)  - 文字列比較\n", .{});
    std.debug.print("  expectEqualSlices(T,a,b)  - 配列比較\n", .{});
    std.debug.print("  expectError(err, expr)    - エラー期待\n", .{});
    std.debug.print("  expectApproxEqAbs(a,b,e)  - 浮動小数点\n", .{});

    std.debug.print("\n--- メモリリーク検出 ---\n", .{});
    std.debug.print("  const allocator = std.testing.allocator;\n", .{});
    std.debug.print("  // deferで解放しないとテスト失敗\n", .{});
}
