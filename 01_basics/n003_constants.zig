//! # 定数（const）
//!
//! Zigでは `const` キーワードで定数（不変オブジェクト）を宣言する。
//! 一度値を設定すると、以降は変更できない。
//!
//! ## なぜconstを使うのか？
//! - 意図しない値の変更を防ぐ
//! - コンパイラによる最適化が可能
//! - コードの意図が明確になる
//!
//! Zigでは「変更しないならconst」が基本方針。

const std = @import("std");

// ====================
// 基本的なconstの宣言
// ====================

// 型推論: コンパイラが値から型を推論
const answer = 42; // comptime_int型（コンパイル時整数）

// 明示的な型指定
const max_size: u32 = 1024;
const pi: f64 = 3.14159265358979;

// 文字列リテラル（[]const u8 として扱われる）
const greeting = "Hello, Zig!";

// ブール値
const is_debug = true;

// ====================
// constの不変性
// ====================

// constで宣言した値は変更できない
// 以下はコンパイルエラーになる:
// const x = 10;
// x = 20;  // error: cannot assign to constant

// ====================
// コンパイル時定数（comptime）
// ====================

// トップレベルのconstはコンパイル時に評価される
const computed_value = blk: {
    var sum: i32 = 0;
    for (1..11) |i| {
        sum += @intCast(i);
    }
    break :blk sum; // 1+2+...+10 = 55
};

// コンパイル時に計算される配列サイズ
const array_size = 5;
const fixed_array: [array_size]i32 = .{ 1, 2, 3, 4, 5 };

// ====================
// 構造体フィールドとしてのconst
// ====================

const Config = struct {
    /// 最大接続数（変更不可）
    max_connections: u32,
    /// タイムアウト秒数
    timeout_seconds: u32,

    /// デフォルト設定を返す
    pub fn default() Config {
        return .{
            .max_connections = 100,
            .timeout_seconds = 30,
        };
    }
};

// 定数として構造体を定義
const DEFAULT_CONFIG = Config.default();

// ====================
// constポインタ
// ====================

/// constポインタは参照先を変更できない
fn printValue(ptr: *const i32) void {
    // *ptr = 100;  // error: cannot assign to constant
    std.debug.print("Value: {d}\n", .{ptr.*});
}

pub fn main() void {
    std.debug.print("=== 定数（const） ===\n\n", .{});

    // 基本的なconst
    std.debug.print("answer = {d}\n", .{answer});
    std.debug.print("max_size = {d}\n", .{max_size});
    std.debug.print("pi = {d:.6}\n", .{pi});
    std.debug.print("greeting = {s}\n", .{greeting});
    std.debug.print("is_debug = {}\n", .{is_debug});

    std.debug.print("\n", .{});

    // コンパイル時計算の結果
    std.debug.print("computed_value (1+2+...+10) = {d}\n", .{computed_value});

    // 固定サイズ配列
    std.debug.print("fixed_array = ", .{});
    for (fixed_array) |val| {
        std.debug.print("{d} ", .{val});
    }
    std.debug.print("\n\n", .{});

    // 構造体定数
    std.debug.print("DEFAULT_CONFIG:\n", .{});
    std.debug.print("  max_connections = {d}\n", .{DEFAULT_CONFIG.max_connections});
    std.debug.print("  timeout_seconds = {d}\n", .{DEFAULT_CONFIG.timeout_seconds});

    std.debug.print("\n", .{});

    // 関数内でのconst
    const local_const: i32 = 999;
    std.debug.print("local_const = {d}\n", .{local_const});

    // constポインタの例
    printValue(&local_const);

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("Zigでは未使用のconstはコンパイルエラー\n", .{});
    std.debug.print("変更しない値は常にconstで宣言すべき\n", .{});
}

// --- テスト ---

test "const basic types" {
    // 定数は宣言時に初期化される
    const a: i32 = 10;
    const b: i32 = 20;
    const sum = a + b;

    try std.testing.expectEqual(@as(i32, 30), sum);
}

test "const type inference" {
    // 型推論でcomptime_intになる
    const x = 100;
    // comptime_intは任意の整数型に変換可能
    const y: u8 = x;
    const z: i64 = x;

    try std.testing.expectEqual(@as(u8, 100), y);
    try std.testing.expectEqual(@as(i64, 100), z);
}

test "const comptime evaluation" {
    // コンパイル時に計算される
    try std.testing.expectEqual(@as(i32, 55), computed_value);
}

test "const struct" {
    // 構造体定数の値を確認
    try std.testing.expectEqual(@as(u32, 100), DEFAULT_CONFIG.max_connections);
    try std.testing.expectEqual(@as(u32, 30), DEFAULT_CONFIG.timeout_seconds);
}

test "const array" {
    // 配列サイズがconstで決まる
    try std.testing.expectEqual(@as(usize, 5), fixed_array.len);
    try std.testing.expectEqual(@as(i32, 1), fixed_array[0]);
    try std.testing.expectEqual(@as(i32, 5), fixed_array[4]);
}

test "const string" {
    // 文字列はnull終端のバイト配列へのポインタ
    try std.testing.expectEqual(@as(usize, 11), greeting.len);
    try std.testing.expectEqual(@as(u8, 'H'), greeting[0]);
}
