//! # zig translate-c の使い方
//!
//! CヘッダーファイルをZigコードに変換するツールの解説。
//!
//! ## このファイルで学ぶこと
//! - zig translate-c コマンドの使い方
//! - @cImport との違いと使い分け
//! - 変換結果の読み方
//! - 実際の使用パターン
//!
//! ## translate-c vs @cImport
//! - translate-c: 事前にZigコードを生成してプロジェクトに含める
//! - @cImport: ビルド時に動的に変換（キャッシュされる）

const std = @import("std");

// ====================
// 方法1: @cImport（動的変換）
// ====================
// ビルド時にCヘッダーを自動変換
// 簡単だが、変換結果が見えにくい

const c = @cImport({
    @cInclude("sample.h");
});

// ====================
// 方法2: translate-c（事前変換）
// ====================
// コマンド例:
//   zig translate-c c_src/sample.h > src/sample_translated.zig
//
// 利点:
// - 変換結果を確認・修正できる
// - バージョン管理できる
// - コンパイル時間短縮

// ====================
// translate-c の基本使い方
// ====================

fn demoTranslateCBasics() void {
    std.debug.print("=== zig translate-c 基本 ===\n\n", .{});

    std.debug.print("【コマンド形式】\n", .{});
    std.debug.print("  zig translate-c <header.h> [options]\n", .{});

    std.debug.print("\n【基本例】\n", .{});
    std.debug.print("  # Zigコードをファイルに出力\n", .{});
    std.debug.print("  zig translate-c sample.h > sample.zig\n", .{});

    std.debug.print("\n【よく使うオプション】\n", .{});
    std.debug.print("  -I<path>    : インクルードパス追加\n", .{});
    std.debug.print("  -lc         : libcをリンク\n", .{});
    std.debug.print("  -D<macro>   : マクロ定義\n", .{});
    std.debug.print("  --target=   : ターゲット指定\n", .{});

    std.debug.print("\n【実行例】\n", .{});
    std.debug.print("  zig translate-c /usr/include/stdio.h -lc > stdio.zig\n", .{});
    std.debug.print("  zig translate-c mylib.h -Iinclude -DDEBUG > mylib.zig\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 変換結果の例
// ====================

fn demoTranslatedOutput() void {
    std.debug.print("=== 変換結果の例 ===\n\n", .{});

    std.debug.print("【定数マクロ】\n", .{});
    std.debug.print("  C:   #define MAX_SIZE 256\n", .{});
    std.debug.print("  Zig: pub const MAX_SIZE = @as(c_int, 256);\n", .{});
    std.debug.print("\n  実際の値: MAX_SIZE = {d}\n", .{c.MAX_SIZE});

    std.debug.print("\n【文字列マクロ】\n", .{});
    std.debug.print("  C:   #define VERSION \"1.0.0\"\n", .{});
    std.debug.print("  Zig: pub const VERSION = \"1.0.0\";\n", .{});
    std.debug.print("\n  実際の値: VERSION = \"{s}\"\n", .{c.VERSION});

    std.debug.print("\n【関数マクロ】\n", .{});
    std.debug.print("  C:   #define SQUARE(x) ((x) * (x))\n", .{});
    std.debug.print("  Zig: pub inline fn SQUARE(x) ...\n", .{});
    std.debug.print("\n  実際の計算: SQUARE(5) = {d}\n", .{c.SQUARE(@as(c_int, 5))});

    std.debug.print("\n【条件マクロ】\n", .{});
    std.debug.print("  C:   #define MIN(a, b) ((a) < (b) ? (a) : (b))\n", .{});
    std.debug.print("  Zig: pub inline fn MIN(a, b) ...\n", .{});
    std.debug.print("\n  実際の計算: MIN(10, 3) = {d}\n", .{c.MIN(@as(c_int, 10), @as(c_int, 3))});

    std.debug.print("\n", .{});
}

// ====================
// 列挙型の変換
// ====================

fn demoEnumTranslation() void {
    std.debug.print("=== 列挙型の変換 ===\n\n", .{});

    std.debug.print("【Cのenum】\n", .{});
    std.debug.print("  typedef enum {{ COLOR_RED, COLOR_GREEN, COLOR_BLUE }} Color;\n", .{});

    std.debug.print("\n【変換後のZig】\n", .{});
    std.debug.print("  pub const Color = c_uint;  // 型はc_uintに\n", .{});
    std.debug.print("  pub const COLOR_RED: c_uint = 0;\n", .{});
    std.debug.print("  pub const COLOR_GREEN: c_uint = 1;\n", .{});
    std.debug.print("  pub const COLOR_BLUE: c_uint = 2;\n", .{});

    std.debug.print("\n【使用例】\n", .{});
    const red: c.Color = c.COLOR_RED;
    const green: c.Color = c.COLOR_GREEN;
    const blue: c.Color = c.COLOR_BLUE;
    std.debug.print("  COLOR_RED   = {d}\n", .{red});
    std.debug.print("  COLOR_GREEN = {d}\n", .{green});
    std.debug.print("  COLOR_BLUE  = {d}\n", .{blue});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  Cのenumは整数型に変換される\n", .{});
    std.debug.print("  Zigのenum型の安全性は得られない\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体の変換
// ====================

fn demoStructTranslation() void {
    std.debug.print("=== 構造体の変換 ===\n\n", .{});

    std.debug.print("【Cの構造体】\n", .{});
    std.debug.print("  typedef struct {{ int32_t x; int32_t y; }} Vec2;\n", .{});

    std.debug.print("\n【変換後のZig】\n", .{});
    std.debug.print("  pub const Vec2 = extern struct {{\n", .{});
    std.debug.print("      x: i32 = @import(\"std\").mem.zeroes(i32),\n", .{});
    std.debug.print("      y: i32 = @import(\"std\").mem.zeroes(i32),\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【使用例】\n", .{});
    const v1 = c.Vec2{ .x = 10, .y = 20 };
    const v2 = c.Vec2{ .x = 3, .y = 4 };
    std.debug.print("  v1 = ({d}, {d})\n", .{ v1.x, v1.y });
    std.debug.print("  v2 = ({d}, {d})\n", .{ v2.x, v2.y });

    // C関数を呼び出し
    const sum = c.vec2_add(v1, v2);
    std.debug.print("  vec2_add(v1, v2) = ({d}, {d})\n", .{ sum.x, sum.y });

    const scaled = c.vec2_scale(v2, 3);
    std.debug.print("  vec2_scale(v2, 3) = ({d}, {d})\n", .{ scaled.x, scaled.y });

    const dot = c.vec2_dot(v1, v2);
    std.debug.print("  vec2_dot(v1, v2) = {d}\n", .{dot});

    std.debug.print("\n", .{});
}

// ====================
// 関数ポインタの変換
// ====================

// Zigで定義したコールバック
fn zigMax(a: i32, b: i32) callconv(.c) i32 {
    return if (a > b) a else b;
}

fn zigDiff(a: i32, b: i32) callconv(.c) i32 {
    return if (a > b) a - b else b - a;
}

fn demoFunctionPointers() void {
    std.debug.print("=== 関数ポインタの変換 ===\n\n", .{});

    std.debug.print("【Cのtypedef】\n", .{});
    std.debug.print("  typedef int32_t (*BinaryOp)(int32_t, int32_t);\n", .{});

    std.debug.print("\n【変換後のZig】\n", .{});
    std.debug.print("  pub const BinaryOp = \n", .{});
    std.debug.print("      ?*const fn (i32, i32) callconv(.c) i32;\n", .{});

    std.debug.print("\n【使用例】\n", .{});
    const result1 = c.apply_op(15, 8, zigMax);
    std.debug.print("  apply_op(15, 8, zigMax) = {d}\n", .{result1});

    const result2 = c.apply_op(15, 8, zigDiff);
    std.debug.print("  apply_op(15, 8, zigDiff) = {d}\n", .{result2});

    std.debug.print("\n【ポイント】\n", .{});
    std.debug.print("  callconv(.c) でC呼び出し規約を指定\n", .{});
    std.debug.print("  Cの関数ポインタはOptionalになる(?*const fn)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @cImport vs translate-c
// ====================

fn demoComparison() void {
    std.debug.print("=== @cImport vs translate-c ===\n\n", .{});

    std.debug.print("【@cImport】\n", .{});
    std.debug.print("  利点:\n", .{});
    std.debug.print("    - 追加ファイル不要\n", .{});
    std.debug.print("    - 常に最新のヘッダーを使用\n", .{});
    std.debug.print("    - 設定が簡単\n", .{});
    std.debug.print("  欠点:\n", .{});
    std.debug.print("    - 変換エラーがビルド時に発生\n", .{});
    std.debug.print("    - 変換結果が見えない\n", .{});
    std.debug.print("    - 変換結果を修正できない\n", .{});

    std.debug.print("\n【translate-c】\n", .{});
    std.debug.print("  利点:\n", .{});
    std.debug.print("    - 変換結果を確認・修正できる\n", .{});
    std.debug.print("    - バージョン管理に含められる\n", .{});
    std.debug.print("    - ビルド時間短縮\n", .{});
    std.debug.print("    - 複雑なヘッダーのデバッグが容易\n", .{});
    std.debug.print("  欠点:\n", .{});
    std.debug.print("    - 手動でファイル生成が必要\n", .{});
    std.debug.print("    - ヘッダー変更時に再生成が必要\n", .{});

    std.debug.print("\n【推奨】\n", .{});
    std.debug.print("  - 小規模・簡単なヘッダー: @cImport\n", .{});
    std.debug.print("  - 大規模・複雑なヘッダー: translate-c\n", .{});
    std.debug.print("  - 変換問題のデバッグ: translate-c\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 変換できないもの
// ====================

fn demoLimitations() void {
    std.debug.print("=== translate-c の制限 ===\n\n", .{});

    std.debug.print("【変換できないもの】\n", .{});
    std.debug.print("  - 複雑なマクロ（副作用あり等）\n", .{});
    std.debug.print("  - インラインアセンブリ\n", .{});
    std.debug.print("  - 一部のGCC拡張\n", .{});
    std.debug.print("  - 可変長配列（VLA）\n", .{});

    std.debug.print("\n【エラーメッセージ例】\n", .{});
    std.debug.print("  @compileError(\"unable to translate...\")\n", .{});

    std.debug.print("\n【対処法】\n", .{});
    std.debug.print("  1. 変換結果を手動で修正\n", .{});
    std.debug.print("  2. Zigでラッパー関数を書く\n", .{});
    std.debug.print("  3. 問題のあるマクロを避ける\n", .{});

    std.debug.print("\n【実用的なワークフロー】\n", .{});
    std.debug.print("  1. translate-cで変換\n", .{});
    std.debug.print("  2. エラー箇所を確認\n", .{});
    std.debug.print("  3. 必要な部分だけ手動で書く\n", .{});
    std.debug.print("  4. プロジェクトに組み込む\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実践: 基本関数の使用
// ====================

fn demoPracticalUsage() void {
    std.debug.print("=== 実践: C関数の呼び出し ===\n\n", .{});

    // add_numbers
    std.debug.print("【基本計算】\n", .{});
    const sum = c.add_numbers(100, 200);
    std.debug.print("  add_numbers(100, 200) = {d}\n", .{sum});

    const product = c.multiply_numbers(12, 8);
    std.debug.print("  multiply_numbers(12, 8) = {d}\n", .{product});

    // sum_array
    std.debug.print("\n【配列操作】\n", .{});
    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    const arr_sum = c.sum_array(&arr, arr.len);
    std.debug.print("  配列: {any}\n", .{arr});
    std.debug.print("  sum_array = {d}\n", .{arr_sum});

    // double_array
    c.double_array(&arr, arr.len);
    std.debug.print("  double_array後: {any}\n", .{arr});

    // string_length
    std.debug.print("\n【文字列操作】\n", .{});
    const text: [*:0]const u8 = "Hello, Zig!";
    const len = c.string_length(text);
    std.debug.print("  string_length(\"{s}\") = {d}\n", .{ text, len });

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== translate-c まとめ ===\n\n", .{});

    std.debug.print("【コマンド】\n", .{});
    std.debug.print("  zig translate-c header.h > output.zig\n", .{});

    std.debug.print("\n【変換結果】\n", .{});
    std.debug.print("  #define → pub const / pub inline fn\n", .{});
    std.debug.print("  enum    → c_uint/c_int + 定数\n", .{});
    std.debug.print("  struct  → extern struct\n", .{});
    std.debug.print("  関数   → pub extern fn\n", .{});
    std.debug.print("  typedef → pub const\n", .{});

    std.debug.print("\n【使い分け】\n", .{});
    std.debug.print("  @cImport : 簡単なヘッダー向け\n", .{});
    std.debug.print("  translate-c: 複雑なヘッダー、デバッグ向け\n", .{});

    std.debug.print("\n【ベストプラクティス】\n", .{});
    std.debug.print("  1. まず@cImportで試す\n", .{});
    std.debug.print("  2. 問題があればtranslate-cで確認\n", .{});
    std.debug.print("  3. 必要に応じて手動で調整\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoTranslateCBasics();
    demoTranslatedOutput();
    demoEnumTranslation();
    demoStructTranslation();
    demoFunctionPointers();
    demoComparison();
    demoLimitations();
    demoPracticalUsage();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・外部Cライブラリのリンク\n", .{});
    std.debug.print("・ZigからCへのエクスポート\n", .{});
    std.debug.print("・実践的なC連携パターン\n", .{});
}

// ====================
// テスト
// ====================

test "MAX_SIZE" {
    try std.testing.expectEqual(@as(c_int, 256), c.MAX_SIZE);
}

test "VERSION" {
    try std.testing.expectEqualStrings("1.0.0", c.VERSION);
}

test "SQUARE" {
    try std.testing.expectEqual(@as(c_int, 25), c.SQUARE(@as(c_int, 5)));
    try std.testing.expectEqual(@as(c_int, 100), c.SQUARE(@as(c_int, 10)));
}

test "MIN" {
    try std.testing.expectEqual(@as(c_int, 3), c.MIN(@as(c_int, 10), @as(c_int, 3)));
    try std.testing.expectEqual(@as(c_int, -5), c.MIN(@as(c_int, -5), @as(c_int, 0)));
}

test "Color enum values" {
    try std.testing.expectEqual(@as(c_uint, 0), c.COLOR_RED);
    try std.testing.expectEqual(@as(c_uint, 1), c.COLOR_GREEN);
    try std.testing.expectEqual(@as(c_uint, 2), c.COLOR_BLUE);
}

test "Status enum values" {
    try std.testing.expectEqual(@as(c_int, 0), c.STATUS_OK);
    try std.testing.expectEqual(@as(c_int, -1), c.STATUS_ERROR);
    try std.testing.expectEqual(@as(c_int, -2), c.STATUS_NOT_FOUND);
}

test "add_numbers" {
    try std.testing.expectEqual(@as(i32, 30), c.add_numbers(10, 20));
    try std.testing.expectEqual(@as(i32, 0), c.add_numbers(-5, 5));
}

test "multiply_numbers" {
    try std.testing.expectEqual(@as(i32, 56), c.multiply_numbers(7, 8));
}

test "sum_array" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), c.sum_array(&arr, arr.len));
}

test "double_array" {
    var arr = [_]i32{ 1, 2, 3 };
    c.double_array(&arr, arr.len);
    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 4), arr[1]);
    try std.testing.expectEqual(@as(i32, 6), arr[2]);
}

test "vec2_add" {
    const v1 = c.Vec2{ .x = 1, .y = 2 };
    const v2 = c.Vec2{ .x = 3, .y = 4 };
    const result = c.vec2_add(v1, v2);
    try std.testing.expectEqual(@as(i32, 4), result.x);
    try std.testing.expectEqual(@as(i32, 6), result.y);
}

test "vec2_scale" {
    const v = c.Vec2{ .x = 2, .y = 3 };
    const result = c.vec2_scale(v, 5);
    try std.testing.expectEqual(@as(i32, 10), result.x);
    try std.testing.expectEqual(@as(i32, 15), result.y);
}

test "vec2_dot" {
    const v1 = c.Vec2{ .x = 3, .y = 4 };
    const v2 = c.Vec2{ .x = 2, .y = 5 };
    try std.testing.expectEqual(@as(i32, 26), c.vec2_dot(v1, v2));
}

test "string_length" {
    const str: [*:0]const u8 = "Hello";
    try std.testing.expectEqual(@as(usize, 5), c.string_length(str));
}

test "apply_op callback" {
    const max_result = c.apply_op(10, 20, zigMax);
    try std.testing.expectEqual(@as(i32, 20), max_result);

    const diff_result = c.apply_op(15, 8, zigDiff);
    try std.testing.expectEqual(@as(i32, 7), diff_result);
}
