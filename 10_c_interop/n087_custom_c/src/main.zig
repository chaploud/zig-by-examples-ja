//! # 自作Cコードとの連携
//!
//! 自作のCソースファイルをZigからビルド・呼び出す実践例。
//!
//! ## このファイルで学ぶこと
//! - Cソースファイルのビルド設定
//! - Cヘッダーのインポート
//! - C関数の呼び出し
//! - C構造体の使用
//! - Zig関数をCコールバックとして渡す
//!
//! ## ビルド設定のポイント
//! - addCSourceFiles(): Cソースを追加
//! - addIncludePath(): ヘッダー検索パス

const std = @import("std");

// ====================
// Cヘッダーをインポート
// ====================

const c = @cImport({
    @cInclude("mathlib.h");
});

// ====================
// 基本的な関数呼び出し
// ====================

fn demoBasicFunctions() void {
    std.debug.print("=== 基本的なC関数呼び出し ===\n\n", .{});

    // add
    const sum = c.add(10, 20);
    std.debug.print("  add(10, 20) = {d}\n", .{sum});

    // multiply
    const product = c.multiply(7, 8);
    std.debug.print("  multiply(7, 8) = {d}\n", .{product});

    // factorial
    std.debug.print("\n【階乗】\n", .{});
    for (0..8) |i| {
        const n: i32 = @intCast(i);
        std.debug.print("  {d}! = {d}\n", .{ n, c.factorial(n) });
    }

    std.debug.print("\n", .{});
}

// ====================
// 配列操作
// ====================

fn demoArrayFunctions() void {
    std.debug.print("=== C配列操作 ===\n\n", .{});

    // array_sum
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const sum = c.array_sum(&arr, arr.len);
    std.debug.print("  配列: {any}\n", .{arr});
    std.debug.print("  array_sum = {d}\n", .{sum});

    // array_double (配列を変更)
    std.debug.print("\n【array_double】\n", .{});
    std.debug.print("  変更前: {any}\n", .{arr});
    c.array_double(&arr, arr.len);
    std.debug.print("  変更後: {any}\n", .{arr});

    std.debug.print("\n", .{});
}

// ====================
// 文字列操作
// ====================

fn demoStringFunctions() void {
    std.debug.print("=== C文字列操作 ===\n\n", .{});

    // count_chars
    const text: [*:0]const u8 = "hello world";
    const count_l = c.count_chars(text, 'l');
    const count_o = c.count_chars(text, 'o');
    std.debug.print("  \"{s}\" における:\n", .{text});
    std.debug.print("    'l' の数: {d}\n", .{count_l});
    std.debug.print("    'o' の数: {d}\n", .{count_o});

    // reverse_string (文字列を変更)
    std.debug.print("\n【reverse_string】\n", .{});
    var buffer: [20]u8 = undefined;
    const src = "Zig";
    @memcpy(buffer[0..src.len], src);
    buffer[src.len] = 0; // ヌル終端

    std.debug.print("  変更前: {s}\n", .{buffer[0..src.len]});
    c.reverse_string(&buffer);
    std.debug.print("  変更後: {s}\n", .{buffer[0..src.len]});

    std.debug.print("\n", .{});
}

// ====================
// C構造体の使用
// ====================

fn demoStructs() void {
    std.debug.print("=== C構造体の使用 ===\n\n", .{});

    // Point構造体の作成
    const p1 = c.Point{ .x = 3, .y = 4 };
    const p2 = c.Point{ .x = 6, .y = 8 };

    std.debug.print("  p1 = ({d}, {d})\n", .{ p1.x, p1.y });
    std.debug.print("  p2 = ({d}, {d})\n", .{ p2.x, p2.y });

    // point_add
    const sum = c.point_add(p1, p2);
    std.debug.print("\n  point_add(p1, p2) = ({d}, {d})\n", .{ sum.x, sum.y });

    // point_distance_squared
    const origin = c.Point{ .x = 0, .y = 0 };
    const dist_sq = c.point_distance_squared(origin, p1);
    std.debug.print("  原点からp1までの距離の2乗 = {d}\n", .{dist_sq});

    std.debug.print("\n", .{});
}

// ====================
// コールバック関数
// ====================

// Zigで定義したコールバック関数（C呼び出し規約）
fn zigAdd(a: i32, b: i32) callconv(.c) i32 {
    return a + b;
}

fn zigMultiply(a: i32, b: i32) callconv(.c) i32 {
    return a * b;
}

fn zigMax(a: i32, b: i32) callconv(.c) i32 {
    return if (a > b) a else b;
}

fn demoCallback() void {
    std.debug.print("=== コールバック関数 ===\n\n", .{});

    std.debug.print("  ZigからC関数へコールバックを渡す:\n\n", .{});

    // Zigの関数をCに渡す
    const result1 = c.apply_operation(10, 20, zigAdd);
    std.debug.print("  apply_operation(10, 20, zigAdd) = {d}\n", .{result1});

    const result2 = c.apply_operation(10, 20, zigMultiply);
    std.debug.print("  apply_operation(10, 20, zigMultiply) = {d}\n", .{result2});

    const result3 = c.apply_operation(10, 20, zigMax);
    std.debug.print("  apply_operation(10, 20, zigMax) = {d}\n", .{result3});

    std.debug.print("\n【ポイント】\n", .{});
    std.debug.print("  callconv(.c) でC呼び出し規約を指定\n", .{});
    std.debug.print("  Zig関数のポインタをそのまま渡せる\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// build.zig の解説
// ====================

fn demoBuildExplanation() void {
    std.debug.print("=== build.zig の設定 ===\n\n", .{});

    std.debug.print("【Cソースの追加】\n", .{});
    std.debug.print("  exe.root_module.addCSourceFiles(.{{\n", .{});
    std.debug.print("      .root = b.path(\"c_src\"),\n", .{});
    std.debug.print("      .files = &.{{\"mathlib.c\"}},\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【インクルードパス】\n", .{});
    std.debug.print("  exe.root_module.addIncludePath(b.path(\"c_src\"));\n", .{});
    std.debug.print("  → @cInclude(\"mathlib.h\") で見つかる\n", .{});

    std.debug.print("\n【複数ファイルの場合】\n", .{});
    std.debug.print("  .files = &.{{\"file1.c\", \"file2.c\", \"file3.c\"}},\n", .{});

    std.debug.print("\n【コンパイラフラグ】\n", .{});
    std.debug.print("  .flags = &.{{\"-Wall\", \"-O2\"}},\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== 自作Cコード連携 まとめ ===\n\n", .{});

    std.debug.print("【ファイル構成】\n", .{});
    std.debug.print("  project/\n", .{});
    std.debug.print("  ├── build.zig\n", .{});
    std.debug.print("  ├── src/main.zig\n", .{});
    std.debug.print("  └── c_src/\n", .{});
    std.debug.print("      ├── lib.h\n", .{});
    std.debug.print("      └── lib.c\n", .{});

    std.debug.print("\n【build.zig】\n", .{});
    std.debug.print("  addCSourceFiles() - Cソース追加\n", .{});
    std.debug.print("  addIncludePath() - ヘッダーパス\n", .{});

    std.debug.print("\n【main.zig】\n", .{});
    std.debug.print("  @cImport + @cInclude でヘッダー読み込み\n", .{});
    std.debug.print("  c.func() でC関数呼び出し\n", .{});

    std.debug.print("\n【型の対応】\n", .{});
    std.debug.print("  int32_t → i32\n", .{});
    std.debug.print("  size_t  → usize\n", .{});
    std.debug.print("  char*   → [*:0]u8\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoBasicFunctions();
    demoArrayFunctions();
    demoStringFunctions();
    demoStructs();
    demoCallback();
    demoBuildExplanation();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・translate-c の使い方\n", .{});
    std.debug.print("・外部Cライブラリのリンク\n", .{});
    std.debug.print("・ZigからCへのエクスポート\n", .{});
}

// ====================
// テスト
// ====================

test "add" {
    try std.testing.expectEqual(@as(i32, 30), c.add(10, 20));
    try std.testing.expectEqual(@as(i32, 0), c.add(-5, 5));
}

test "multiply" {
    try std.testing.expectEqual(@as(i32, 56), c.multiply(7, 8));
    try std.testing.expectEqual(@as(i32, -15), c.multiply(3, -5));
}

test "factorial" {
    try std.testing.expectEqual(@as(i32, 1), c.factorial(0));
    try std.testing.expectEqual(@as(i32, 1), c.factorial(1));
    try std.testing.expectEqual(@as(i32, 120), c.factorial(5));
    try std.testing.expectEqual(@as(i32, 5040), c.factorial(7));
}

test "array_sum" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), c.array_sum(&arr, arr.len));
}

test "array_double" {
    var arr = [_]i32{ 1, 2, 3 };
    c.array_double(&arr, arr.len);
    try std.testing.expectEqual(@as(i32, 2), arr[0]);
    try std.testing.expectEqual(@as(i32, 4), arr[1]);
    try std.testing.expectEqual(@as(i32, 6), arr[2]);
}

test "count_chars" {
    const text: [*:0]const u8 = "hello";
    try std.testing.expectEqual(@as(usize, 2), c.count_chars(text, 'l'));
    try std.testing.expectEqual(@as(usize, 1), c.count_chars(text, 'h'));
    try std.testing.expectEqual(@as(usize, 0), c.count_chars(text, 'z'));
}

test "reverse_string" {
    var buf: [10]u8 = undefined;
    @memcpy(buf[0..3], "abc");
    buf[3] = 0;
    c.reverse_string(&buf);
    try std.testing.expectEqualStrings("cba", buf[0..3]);
}

test "point_add" {
    const p1 = c.Point{ .x = 1, .y = 2 };
    const p2 = c.Point{ .x = 3, .y = 4 };
    const result = c.point_add(p1, p2);
    try std.testing.expectEqual(@as(i32, 4), result.x);
    try std.testing.expectEqual(@as(i32, 6), result.y);
}

test "point_distance_squared" {
    const origin = c.Point{ .x = 0, .y = 0 };
    const p = c.Point{ .x = 3, .y = 4 };
    try std.testing.expectEqual(@as(i32, 25), c.point_distance_squared(origin, p));
}

test "callback" {
    try std.testing.expectEqual(@as(i32, 30), c.apply_operation(10, 20, zigAdd));
    try std.testing.expectEqual(@as(i32, 200), c.apply_operation(10, 20, zigMultiply));
}
