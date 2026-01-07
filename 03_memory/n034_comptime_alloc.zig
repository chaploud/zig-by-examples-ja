//! # コンパイル時メモリ
//!
//! Zigはコンパイル時にもメモリ操作が可能。
//! comptimeでデータ構造を構築し、バイナリに埋め込む。
//!
//! ## 特徴
//! - コンパイル時計算で定数を生成
//! - ランタイムコストゼロ
//! - バイナリサイズへの影響あり
//!
//! ## 用途
//! - ルックアップテーブル
//! - 文字列処理
//! - 最適化されたデータ構造

const std = @import("std");

// ====================
// コンパイル時配列生成
// ====================

fn generateSquares(comptime n: usize) [n]u32 {
    var result: [n]u32 = undefined;
    for (0..n) |i| {
        result[i] = @as(u32, @intCast(i * i));
    }
    return result;
}

fn demoComptimeArray() void {
    std.debug.print("--- コンパイル時配列生成 ---\n", .{});

    // コンパイル時に生成された配列
    const squares = comptime generateSquares(10);

    std.debug.print("  平方数テーブル: ", .{});
    for (squares) |sq| {
        std.debug.print("{d} ", .{sq});
    }
    std.debug.print("\n", .{});

    // ランタイムでは読み取りのみ
    std.debug.print("  squares[5] = {d}\n", .{squares[5]});

    std.debug.print("  → コンパイル時に計算、ランタイムコストゼロ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// コンパイル時文字列操作
// ====================

fn comptime_upper(comptime str: []const u8) *const [str.len]u8 {
    return comptime blk: {
        var result: [str.len]u8 = undefined;
        for (str, 0..) |c, i| {
            result[i] = if (c >= 'a' and c <= 'z') c - 32 else c;
        }
        const final = result;
        break :blk &final;
    };
}

fn demoComptimeString() void {
    std.debug.print("--- コンパイル時文字列操作 ---\n", .{});

    const lower = "hello world";
    const upper = comptime_upper(lower);

    std.debug.print("  元: {s}\n", .{lower});
    std.debug.print("  大文字: {s}\n", .{upper});

    std.debug.print("  → 変換はコンパイル時に完了\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ルックアップテーブル
// ====================

fn generateFibTable(comptime n: usize) [n]u64 {
    var result: [n]u64 = undefined;
    result[0] = 0;
    if (n > 1) result[1] = 1;
    for (2..n) |i| {
        result[i] = result[i - 1] + result[i - 2];
    }
    return result;
}

fn demoLookupTable() void {
    std.debug.print("--- ルックアップテーブル ---\n", .{});

    const fib_table = comptime generateFibTable(20);

    std.debug.print("  フィボナッチ数列:\n", .{});
    std.debug.print("    fib(10) = {d}\n", .{fib_table[10]});
    std.debug.print("    fib(15) = {d}\n", .{fib_table[15]});
    std.debug.print("    fib(19) = {d}\n", .{fib_table[19]});

    std.debug.print("  → 計算済みテーブルをO(1)で参照\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// StaticStringMap
// ====================

fn demoStaticStringMap() void {
    std.debug.print("--- StaticStringMap ---\n", .{});

    // コンパイル時にハッシュマップを構築
    const map = std.StaticStringMap(i32).initComptime(.{
        .{ "one", 1 },
        .{ "two", 2 },
        .{ "three", 3 },
        .{ "four", 4 },
        .{ "five", 5 },
    });

    std.debug.print("  map.get(\"three\") = {?d}\n", .{map.get("three")});
    std.debug.print("  map.get(\"six\") = {?d}\n", .{map.get("six")});

    std.debug.print("  → コンパイル時にハッシュ計算済み\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @embedFile
// ====================

fn demoEmbedFile() void {
    std.debug.print("--- @embedFile ---\n", .{});

    // ファイルをバイナリに埋め込み（実際に使う場合）
    // const data = @embedFile("data.txt");

    std.debug.print("  @embedFile(\"path\"):\n", .{});
    std.debug.print("    - コンパイル時にファイルを読み込み\n", .{});
    std.debug.print("    - バイナリに埋め込む\n", .{});
    std.debug.print("    - 結果は []const u8\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// comptimeブロック
// ====================

fn demoComptimeBlock() void {
    std.debug.print("--- comptimeブロック ---\n", .{});

    const result = comptime blk: {
        var sum: u32 = 0;
        for (1..101) |i| {
            sum += @as(u32, @intCast(i));
        }
        break :blk sum;
    };

    std.debug.print("  1..100の合計 = {d}\n", .{result});
    std.debug.print("  → ランタイムでは定数として埋め込み\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 型レベルのコンパイル時計算
// ====================

fn Matrix(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    return struct {
        data: [rows][cols]T,

        const Self = @This();

        pub fn init(value: T) Self {
            var result: Self = undefined;
            for (&result.data) |*row| {
                for (row) |*cell| {
                    cell.* = value;
                }
            }
            return result;
        }

        pub fn get(self: *const Self, row: usize, col: usize) T {
            return self.data[row][col];
        }
    };
}

fn demoComptimeType() void {
    std.debug.print("--- 型レベルのコンパイル時計算 ---\n", .{});

    const Mat3x3 = Matrix(f32, 3, 3);
    const mat = Mat3x3.init(1.0);

    std.debug.print("  Matrix(f32, 3, 3):\n", .{});
    std.debug.print("    size = {d} bytes\n", .{@sizeOf(Mat3x3)});
    std.debug.print("    mat.get(1, 1) = {d}\n", .{mat.get(1, 1)});

    std.debug.print("  → 型もコンパイル時に生成\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 最適化の比較
// ====================

fn demoOptimization() void {
    std.debug.print("--- 最適化の比較 ---\n", .{});

    std.debug.print("  ランタイム計算:\n", .{});
    std.debug.print("    - 毎回計算が必要\n", .{});
    std.debug.print("    - CPU時間を消費\n", .{});

    std.debug.print("  コンパイル時計算:\n", .{});
    std.debug.print("    - 結果がバイナリに埋め込み\n", .{});
    std.debug.print("    - ランタイムコストゼロ\n", .{});
    std.debug.print("    - バイナリサイズは増加\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// コンパイル時の制限
// ====================

fn demoLimitations() void {
    std.debug.print("--- コンパイル時の制限 ---\n", .{});

    std.debug.print("  できないこと:\n", .{});
    std.debug.print("    - ファイルI/O\n", .{});
    std.debug.print("    - ネットワーク\n", .{});
    std.debug.print("    - 実行時の値に依存する計算\n", .{});
    std.debug.print("    - 副作用のある操作\n", .{});

    std.debug.print("  できること:\n", .{});
    std.debug.print("    - 純粋な計算\n", .{});
    std.debug.print("    - @embedFile\n", .{});
    std.debug.print("    - 型生成\n", .{});
    std.debug.print("    - 文字列操作\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== コンパイル時メモリ ===\n\n", .{});

    demoComptimeArray();
    demoComptimeString();
    demoLookupTable();
    demoStaticStringMap();
    demoEmbedFile();
    demoComptimeBlock();
    demoComptimeType();
    demoOptimization();
    demoLimitations();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・comptimeで計算をコンパイル時に実行\n", .{});
    std.debug.print("・結果はバイナリに埋め込み\n", .{});
    std.debug.print("・ランタイムコストゼロ\n", .{});
    std.debug.print("・StaticStringMapでハッシュ最適化\n", .{});
    std.debug.print("・@embedFileでファイル埋め込み\n", .{});
}

// --- テスト ---

test "comptime squares" {
    const squares = comptime generateSquares(5);
    try std.testing.expectEqual(@as(u32, 0), squares[0]);
    try std.testing.expectEqual(@as(u32, 1), squares[1]);
    try std.testing.expectEqual(@as(u32, 4), squares[2]);
    try std.testing.expectEqual(@as(u32, 9), squares[3]);
    try std.testing.expectEqual(@as(u32, 16), squares[4]);
}

test "comptime fibonacci" {
    const fib = comptime generateFibTable(11);
    try std.testing.expectEqual(@as(u64, 0), fib[0]);
    try std.testing.expectEqual(@as(u64, 1), fib[1]);
    try std.testing.expectEqual(@as(u64, 1), fib[2]);
    try std.testing.expectEqual(@as(u64, 2), fib[3]);
    try std.testing.expectEqual(@as(u64, 55), fib[10]); // fib(10) = 55
}

test "comptime upper" {
    const upper = comptime_upper("hello");
    try std.testing.expect(std.mem.eql(u8, upper, "HELLO"));
}

test "StaticStringMap" {
    const map = std.StaticStringMap(i32).initComptime(.{
        .{ "a", 1 },
        .{ "b", 2 },
        .{ "c", 3 },
    });

    try std.testing.expectEqual(@as(?i32, 1), map.get("a"));
    try std.testing.expectEqual(@as(?i32, 2), map.get("b"));
    try std.testing.expectEqual(@as(?i32, 3), map.get("c"));
    try std.testing.expectEqual(@as(?i32, null), map.get("d"));
}

test "comptime block sum" {
    const sum = comptime blk: {
        var s: u32 = 0;
        for (1..11) |i| {
            s += @as(u32, @intCast(i));
        }
        break :blk s;
    };

    try std.testing.expectEqual(@as(u32, 55), sum);
}

test "Matrix type" {
    const Mat2x2 = Matrix(i32, 2, 2);
    const mat = Mat2x2.init(42);

    try std.testing.expectEqual(@as(usize, 16), @sizeOf(Mat2x2));
    try std.testing.expectEqual(@as(i32, 42), mat.get(0, 0));
    try std.testing.expectEqual(@as(i32, 42), mat.get(1, 1));
}
