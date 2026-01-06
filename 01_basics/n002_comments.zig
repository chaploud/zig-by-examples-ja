//! # コメント（Comments）
//!
//! Zigには3種類のコメントがある：
//! - `//` : 通常のコメント（行末まで）
//! - `///` : ドキュメントコメント（関数・型・変数の説明用）
//! - `//!` : トップレベルドキュメントコメント（ファイル・モジュールの説明用）
//!
//! ドキュメントコメントは `zig doc` コマンドでHTMLドキュメントを生成するときに使われる。
//! また、IDE（zls等）がホバー時に表示する説明にも使われる。

const std = @import("std");

// ====================
// 通常のコメント (//)
// ====================

// 通常のコメントは `//` で始まる
// コードの補足説明やメモに使う
// 複数行にわたる場合は各行に `//` を付ける

// コードの右側にも書ける（インラインコメント）
const magic_number = 42; // 生命、宇宙、そして万物についての究極の疑問の答え

// ====================
// ドキュメントコメント (///)
// ====================

/// 2つの数値を加算する
///
/// ## 引数
/// - `a`: 最初の数値
/// - `b`: 2番目の数値
///
/// ## 戻り値
/// `a`と`b`の合計
///
/// ## 使用例
/// ```zig
/// const result = add(2, 3);
/// // result == 5
/// ```
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// ユーザー情報を表す構造体
///
/// 名前と年齢を保持するシンプルな構造体。
/// ドキュメントコメントは構造体にも付けられる。
const User = struct {
    /// ユーザーの名前
    name: []const u8,
    /// ユーザーの年齢（0〜150を想定）
    age: u8,

    /// ユーザー情報を文字列として出力する
    pub fn print(self: User) void {
        std.debug.print("User: {s}, Age: {d}\n", .{ self.name, self.age });
    }
};

/// 定数にもドキュメントコメントを付けられる
///
/// 円周率の近似値
pub const PI = 3.14159;

// ====================
// コメントアウトの例
// ====================

// 一時的にコードを無効化するのにコメントを使える
// const unused_value = 100;

pub fn main() void {
    // 通常のコメントでコードを説明
    std.debug.print("=== Zigのコメント ===\n", .{});

    // ドキュメントコメント付きの関数を呼び出し
    const sum = add(10, 20);
    std.debug.print("add(10, 20) = {d}\n", .{sum});

    // 構造体を使う
    const user = User{ .name = "Taro", .age = 25 };
    user.print();

    // 定数を使う
    std.debug.print("PI = {d:.5}\n", .{PI}); // 小数点以下5桁で表示

    std.debug.print("\n", .{});
    std.debug.print("ドキュメントコメント (///) は `zig doc` でHTML生成に使われる\n", .{});
    std.debug.print("トップレベルコメント (//!) はファイルの説明に使われる\n", .{});
}

// --- テスト ---

test "add function" {
    // 基本的な加算テスト
    try std.testing.expectEqual(@as(i32, 5), add(2, 3));
    try std.testing.expectEqual(@as(i32, 0), add(-1, 1));
    try std.testing.expectEqual(@as(i32, -10), add(-5, -5));
}

test "User struct" {
    // 構造体のフィールドアクセスをテスト
    const user = User{ .name = "Test", .age = 30 };
    try std.testing.expectEqualStrings("Test", user.name);
    try std.testing.expectEqual(@as(u8, 30), user.age);
}

test "PI constant" {
    // 定数が正しい値か確認
    try std.testing.expect(PI > 3.14);
    try std.testing.expect(PI < 3.15);
}

// ====================
// 注意: Zigにはブロックコメント /* */ がない
// ====================
// Cスタイルの /* */ ブロックコメントは使えない
// 複数行コメントは各行に // を付ける必要がある
//
// この設計により：
// - コメントのネスト問題を回避
// - パース処理がシンプルに
// - コードの可読性が向上（コメント範囲が明確）
