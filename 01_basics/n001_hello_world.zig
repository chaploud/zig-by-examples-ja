//! # Hello World
//!
//! Zigプログラムの最も基本的な形式。
//! std.debug.printを使ってコンソールに出力する。

const std = @import("std");

/// メイン関数 - プログラムのエントリーポイント
/// pub: 他のモジュールから呼び出し可能にする
/// fn main(): main関数は特別で、プログラム実行時に最初に呼ばれる
pub fn main() void {
    // std.debug.print は stderr に出力する
    // フォーマット文字列内の {s} はスライス（文字列）用のプレースホルダー
    // .{} は無名構造体リテラルで、フォーマット引数を渡す
    std.debug.print("Hello, {s}!\n", .{"World"});

    // 複数の引数を渡す例
    std.debug.print("{s} is learning {s}\n", .{ "You", "Zig" });

    // 数値のフォーマット: {d} は整数用
    const answer: i32 = 42;
    std.debug.print("The answer is {d}\n", .{answer});
}

// --- テスト ---

test "hello world compiles" {
    // このテストはコンパイルが通ることを確認するだけ
    try std.testing.expect(true);
}

test "string formatting" {
    // bufPrintを使って文字列をフォーマットし、結果を検証
    var buffer: [100]u8 = undefined;
    const result = std.fmt.bufPrint(&buffer, "Hello, {s}!", .{"Zig"}) catch unreachable;
    try std.testing.expectEqualStrings("Hello, Zig!", result);
}
