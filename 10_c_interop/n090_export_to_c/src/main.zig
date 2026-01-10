//! # ZigからCへのエクスポート
//!
//! Zigで書いた関数をCから呼び出せるようにする方法。
//!
//! ## このファイルで学ぶこと
//! - export キーワードの使い方
//! - callconv(.c) の指定
//! - 共有ライブラリ/静的ライブラリの作成
//! - C向けヘッダーの生成
//!
//! ## ビルド
//! - 静的ライブラリ: zig build
//! - 共有ライブラリ: zig build -Ddynamic=true

const std = @import("std");

// ====================
// export - C からアクセス可能にする
// ====================

// export をつけると C から呼び出し可能になる
// C 呼び出し規約が自動的に適用される
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

export fn subtract(a: i32, b: i32) i32 {
    return a - b;
}

// ====================
// ポインタを使った関数
// ====================

// 配列の合計を計算（Cポインタを受け取る）
export fn array_sum(arr: [*]const i32, len: usize) i32 {
    var sum: i32 = 0;
    for (0..len) |i| {
        sum += arr[i];
    }
    return sum;
}

// 配列を2倍に（Cポインタを書き換える）
export fn array_double(arr: [*]i32, len: usize) void {
    for (0..len) |i| {
        arr[i] *= 2;
    }
}

// 文字列の長さを返す
export fn string_len(str: [*:0]const u8) usize {
    var len: usize = 0;
    while (str[len] != 0) : (len += 1) {}
    return len;
}

// ====================
// 構造体のエクスポート
// ====================

// extern struct は C と互換性のあるレイアウト
pub const Point = extern struct {
    x: i32,
    y: i32,
};

// 構造体を値で返す
export fn point_create(x: i32, y: i32) Point {
    return Point{ .x = x, .y = y };
}

// 構造体を値で受け取る
export fn point_add(a: Point, b: Point) Point {
    return Point{
        .x = a.x + b.x,
        .y = a.y + b.y,
    };
}

// 構造体をポインタで受け取る
export fn point_scale(p: *Point, factor: i32) void {
    p.x *= factor;
    p.y *= factor;
}

// 距離の2乗を計算
export fn point_distance_sq(a: Point, b: Point) i32 {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    return dx * dx + dy * dy;
}

// ====================
// 文字列バッファへの書き込み
// ====================

// C スタイルの出力パラメータ
export fn format_number(num: i32, buf: [*]u8, buf_len: usize) usize {
    if (buf_len == 0) return 0;

    const slice = buf[0..buf_len];
    const result = std.fmt.bufPrint(slice, "{d}", .{num}) catch {
        return 0;
    };
    return result.len;
}

// 文字列を大文字に変換
export fn to_uppercase(str: [*]u8, len: usize) void {
    for (0..len) |i| {
        const c = str[i];
        if (c >= 'a' and c <= 'z') {
            str[i] = c - 32;
        }
    }
}

// ====================
// コールバック関数
// ====================

// C の関数ポインタ型
pub const BinaryOp = *const fn (i32, i32) callconv(.c) i32;

// コールバックを受け取る関数
export fn apply_op(a: i32, b: i32, op: BinaryOp) i32 {
    return op(a, b);
}

// 配列の各要素にコールバックを適用
pub const UnaryOp = *const fn (i32) callconv(.c) i32;

export fn array_map(arr: [*]i32, len: usize, op: UnaryOp) void {
    for (0..len) |i| {
        arr[i] = op(arr[i]);
    }
}

// ====================
// エラー処理
// ====================

// C ではエラーを戻り値で返す
pub const Error = enum(c_int) {
    ok = 0,
    invalid_input = -1,
    overflow = -2,
    division_by_zero = -3,
};

// 結果と出力ポインタを使うパターン
export fn safe_divide(a: i32, b: i32, result: *i32) Error {
    if (b == 0) return .division_by_zero;
    result.* = @divTrunc(a, b);
    return .ok;
}

// エラーをエラーコードに変換
export fn checked_add(a: i32, b: i32, result: *i32) Error {
    const val = @addWithOverflow(a, b);
    if (val[1] != 0) return .overflow;
    result.* = val[0];
    return .ok;
}

// ====================
// グローバル変数
// ====================

// export でグローバル変数もエクスポート可能
export var global_counter: i32 = 0;

export fn increment_counter() i32 {
    global_counter += 1;
    return global_counter;
}

export fn reset_counter() void {
    global_counter = 0;
}

// ====================
// デモ用 main（ライブラリ使用時は不要）
// ====================

pub fn main() void {
    std.debug.print("=== Zig から C へのエクスポート ===\n\n", .{});

    // export 関数の動作確認
    std.debug.print("【基本関数】\n", .{});
    std.debug.print("  add(10, 20) = {d}\n", .{add(10, 20)});
    std.debug.print("  multiply(7, 8) = {d}\n", .{multiply(7, 8)});
    std.debug.print("  subtract(100, 30) = {d}\n", .{subtract(100, 30)});

    // 配列操作
    std.debug.print("\n【配列操作】\n", .{});
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    std.debug.print("  元の配列: {any}\n", .{arr});
    std.debug.print("  array_sum = {d}\n", .{array_sum(&arr, arr.len)});
    array_double(&arr, arr.len);
    std.debug.print("  array_double後: {any}\n", .{arr});

    // 構造体
    std.debug.print("\n【構造体】\n", .{});
    const p1 = point_create(10, 20);
    const p2 = point_create(3, 4);
    std.debug.print("  p1 = ({d}, {d})\n", .{ p1.x, p1.y });
    std.debug.print("  p2 = ({d}, {d})\n", .{ p2.x, p2.y });
    const p3 = point_add(p1, p2);
    std.debug.print("  point_add = ({d}, {d})\n", .{ p3.x, p3.y });

    // エラー処理
    std.debug.print("\n【エラー処理】\n", .{});
    var result: i32 = undefined;
    const err1 = safe_divide(10, 3, &result);
    std.debug.print("  safe_divide(10, 3) = {d} (err: {any})\n", .{ result, err1 });
    const err2 = safe_divide(10, 0, &result);
    std.debug.print("  safe_divide(10, 0) = err: {any}\n", .{err2});

    // グローバル変数
    std.debug.print("\n【グローバル変数】\n", .{});
    reset_counter();
    std.debug.print("  reset後: {d}\n", .{global_counter});
    _ = increment_counter();
    _ = increment_counter();
    std.debug.print("  2回increment後: {d}\n", .{global_counter});

    std.debug.print("\n=== build.zig の設定 ===\n\n", .{});
    demoBuildExplanation();

    std.debug.print("=== C コード例 ===\n\n", .{});
    demoCCodeExample();
}

fn demoBuildExplanation() void {
    std.debug.print("【静的ライブラリ】\n", .{});
    std.debug.print("  const lib = b.addStaticLibrary(.{{\n", .{});
    std.debug.print("      .name = \"mylib\",\n", .{});
    std.debug.print("      .root_module = ...,\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【共有ライブラリ】\n", .{});
    std.debug.print("  const lib = b.addSharedLibrary(.{{\n", .{});
    std.debug.print("      .name = \"mylib\",\n", .{});
    std.debug.print("      .root_module = ...,\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【生成ファイル】\n", .{});
    std.debug.print("  静的: libmylib.a (Unix) / mylib.lib (Windows)\n", .{});
    std.debug.print("  共有: libmylib.so (Linux) / libmylib.dylib (macOS)\n", .{});

    std.debug.print("\n", .{});
}

fn demoCCodeExample() void {
    std.debug.print("【使用例 (main.c)】\n", .{});
    std.debug.print("  #include <stdio.h>\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("  // Zig からエクスポートされた関数\n", .{});
    std.debug.print("  extern int add(int a, int b);\n", .{});
    std.debug.print("  extern int multiply(int a, int b);\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("  int main() {{\n", .{});
    std.debug.print("      printf(\"add(10, 20) = %d\\n\", add(10, 20));\n", .{});
    std.debug.print("      return 0;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【コンパイル】\n", .{});
    std.debug.print("  # 静的リンク\n", .{});
    std.debug.print("  gcc main.c -L./zig-out/lib -lmylib -o main\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("  # 動的リンク\n", .{});
    std.debug.print("  gcc main.c -L./zig-out/lib -lmylib -o main\n", .{});
    std.debug.print("  LD_LIBRARY_PATH=./zig-out/lib ./main\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// テスト
// ====================

test "add" {
    try std.testing.expectEqual(@as(i32, 30), add(10, 20));
    try std.testing.expectEqual(@as(i32, 0), add(-5, 5));
}

test "multiply" {
    try std.testing.expectEqual(@as(i32, 56), multiply(7, 8));
}

test "array_sum" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), array_sum(&arr, arr.len));
}

test "array_double" {
    var arr = [_]i32{ 1, 2, 3 };
    array_double(&arr, arr.len);
    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 4), arr[1]);
    try std.testing.expectEqual(@as(i32, 6), arr[2]);
}

test "string_len" {
    const str: [*:0]const u8 = "Hello";
    try std.testing.expectEqual(@as(usize, 5), string_len(str));
}

test "point_create" {
    const p = point_create(10, 20);
    try std.testing.expectEqual(@as(i32, 10), p.x);
    try std.testing.expectEqual(@as(i32, 20), p.y);
}

test "point_add" {
    const p1 = Point{ .x = 1, .y = 2 };
    const p2 = Point{ .x = 3, .y = 4 };
    const result = point_add(p1, p2);
    try std.testing.expectEqual(@as(i32, 4), result.x);
    try std.testing.expectEqual(@as(i32, 6), result.y);
}

test "point_scale" {
    var p = Point{ .x = 2, .y = 3 };
    point_scale(&p, 5);
    try std.testing.expectEqual(@as(i32, 10), p.x);
    try std.testing.expectEqual(@as(i32, 15), p.y);
}

test "safe_divide" {
    var result: i32 = undefined;
    try std.testing.expectEqual(Error.ok, safe_divide(10, 2, &result));
    try std.testing.expectEqual(@as(i32, 5), result);

    try std.testing.expectEqual(Error.division_by_zero, safe_divide(10, 0, &result));
}

test "checked_add" {
    var result: i32 = undefined;
    try std.testing.expectEqual(Error.ok, checked_add(100, 200, &result));
    try std.testing.expectEqual(@as(i32, 300), result);
}

test "global_counter" {
    reset_counter();
    try std.testing.expectEqual(@as(i32, 0), global_counter);
    _ = increment_counter();
    try std.testing.expectEqual(@as(i32, 1), global_counter);
    _ = increment_counter();
    try std.testing.expectEqual(@as(i32, 2), global_counter);
    reset_counter();
    try std.testing.expectEqual(@as(i32, 0), global_counter);
}

test "format_number" {
    var buf: [20]u8 = undefined;
    const len = format_number(12345, &buf, buf.len);
    try std.testing.expectEqualStrings("12345", buf[0..len]);
}

test "to_uppercase" {
    var buf = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    to_uppercase(&buf, buf.len);
    try std.testing.expectEqualStrings("HELLO", &buf);
}
