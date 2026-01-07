//! # 組み込み関数（builtin）
//!
//! Zigには@で始まる組み込み関数がある。
//! コンパイラによって直接実装され、低レベル操作を提供。
//!
//! ## カテゴリ
//! - 型変換: @intCast, @floatCast, @ptrCast
//! - 型情報: @TypeOf, @typeInfo, @typeName
//! - メモリ: @memset, @memcpy, @alignOf
//! - 算術: @addWithOverflow, @mulWithOverflow

const std = @import("std");

// ====================
// 型変換
// ====================

fn demonstrateTypeCast() void {
    std.debug.print("--- 型変換 ---\n", .{});

    // @as: 明示的な型付け
    const a = @as(i32, 42);
    std.debug.print("@as(i32, 42) = {d}\n", .{a});

    // @intCast: 整数型間の変換
    const big: i64 = 1000;
    const small: i16 = @intCast(big);
    std.debug.print("@intCast: i64({d}) -> i16({d})\n", .{ big, small });

    // @floatCast: 浮動小数点型間の変換
    const f64_val: f64 = 3.14159265358979;
    const f32_val: f32 = @floatCast(f64_val);
    std.debug.print("@floatCast: f64({d:.10}) -> f32({d:.6})\n", .{ f64_val, f32_val });

    // @intFromFloat: 浮動小数点から整数へ
    const pi: f64 = 3.14;
    const pi_int: i32 = @intFromFloat(pi);
    std.debug.print("@intFromFloat: f64({d}) -> i32({d})\n", .{ pi, pi_int });

    // @floatFromInt: 整数から浮動小数点へ
    const n: i32 = 42;
    const n_float: f64 = @floatFromInt(n);
    std.debug.print("@floatFromInt: i32({d}) -> f64({d})\n", .{ n, n_float });

    // @intFromBool: boolから整数へ
    const t: u8 = @intFromBool(true);
    const f: u8 = @intFromBool(false);
    std.debug.print("@intFromBool: true={d}, false={d}\n", .{ t, f });

    std.debug.print("\n", .{});
}

// ====================
// 型情報
// ====================

fn demonstrateTypeInfo() void {
    std.debug.print("--- 型情報 ---\n", .{});

    // @TypeOf: 値から型を取得
    const x: i32 = 42;
    const T = @TypeOf(x);
    std.debug.print("@TypeOf(x): {s}\n", .{@typeName(T)});

    // @typeName: 型の名前を取得
    std.debug.print("@typeName(i32): {s}\n", .{@typeName(i32)});
    std.debug.print("@typeName([]const u8): {s}\n", .{@typeName([]const u8)});

    // @sizeOf: 型のバイトサイズ
    std.debug.print("@sizeOf(i8): {d}\n", .{@sizeOf(i8)});
    std.debug.print("@sizeOf(i32): {d}\n", .{@sizeOf(i32)});
    std.debug.print("@sizeOf(i64): {d}\n", .{@sizeOf(i64)});

    // @alignOf: 型のアライメント
    std.debug.print("@alignOf(i8): {d}\n", .{@alignOf(i8)});
    std.debug.print("@alignOf(i32): {d}\n", .{@alignOf(i32)});
    std.debug.print("@alignOf(i64): {d}\n", .{@alignOf(i64)});

    // @bitSizeOf: ビットサイズ
    std.debug.print("@bitSizeOf(i32): {d}\n", .{@bitSizeOf(i32)});
    std.debug.print("@bitSizeOf(bool): {d}\n", .{@bitSizeOf(bool)});

    std.debug.print("\n", .{});
}

// ====================
// 算術演算
// ====================

fn demonstrateArithmetic() void {
    std.debug.print("--- 算術演算 ---\n", .{});

    // @addWithOverflow: オーバーフロー検出付き加算
    const a: u8 = 200;
    const b: u8 = 100;
    const result = @addWithOverflow(a, b);
    std.debug.print("@addWithOverflow(200, 100): result={d}, overflow={}\n", .{ result[0], result[1] != 0 });

    // オーバーフローしない場合
    const c: u8 = 100;
    const d: u8 = 50;
    const result2 = @addWithOverflow(c, d);
    std.debug.print("@addWithOverflow(100, 50): result={d}, overflow={}\n", .{ result2[0], result2[1] != 0 });

    // @mulWithOverflow: オーバーフロー検出付き乗算
    const e: u8 = 20;
    const f: u8 = 20;
    const result3 = @mulWithOverflow(e, f);
    std.debug.print("@mulWithOverflow(20, 20): result={d}, overflow={}\n", .{ result3[0], result3[1] != 0 });

    // @abs: 絶対値
    const neg: i32 = -42;
    std.debug.print("@abs(-42) = {d}\n", .{@abs(neg)});

    // @min, @max
    std.debug.print("@min(3, 7) = {d}\n", .{@min(@as(i32, 3), @as(i32, 7))});
    std.debug.print("@max(3, 7) = {d}\n", .{@max(@as(i32, 3), @as(i32, 7))});

    // @sqrt: 平方根
    const val: f64 = 16.0;
    std.debug.print("@sqrt(16.0) = {d}\n", .{@sqrt(val)});

    // @mod: 剰余
    std.debug.print("@mod(17, 5) = {d}\n", .{@mod(@as(i32, 17), @as(i32, 5))});
    std.debug.print("@mod(-17, 5) = {d}\n", .{@mod(@as(i32, -17), @as(i32, 5))});

    std.debug.print("\n", .{});
}

// ====================
// ビット操作
// ====================

fn demonstrateBitOps() void {
    std.debug.print("--- ビット操作 ---\n", .{});

    const val: u8 = 0b10110100;
    std.debug.print("元の値: 0b{b:0>8} ({d})\n", .{ val, val });

    // @popCount: 1のビット数
    std.debug.print("@popCount: {d}\n", .{@popCount(val)});

    // @clz: 先頭の0の数
    std.debug.print("@clz: {d}\n", .{@clz(val)});

    // @ctz: 末尾の0の数
    std.debug.print("@ctz: {d}\n", .{@ctz(val)});

    // @byteSwap: バイト順反転
    const word: u32 = 0x12345678;
    std.debug.print("@byteSwap(0x{x:0>8}) = 0x{x:0>8}\n", .{ word, @byteSwap(word) });

    // @bitReverse: ビット順反転
    const byte: u8 = 0b11000001;
    std.debug.print("@bitReverse(0b{b:0>8}) = 0b{b:0>8}\n", .{ byte, @bitReverse(byte) });

    std.debug.print("\n", .{});
}

// ====================
// メモリ操作
// ====================

fn demonstrateMemory() void {
    std.debug.print("--- メモリ操作 ---\n", .{});

    // @memset: メモリを値で埋める
    var buffer: [10]u8 = undefined;
    @memset(&buffer, 'A');
    std.debug.print("@memset結果: {s}\n", .{&buffer});

    // @memcpy: メモリコピー
    const src = "Hello";
    var dst: [5]u8 = undefined;
    @memcpy(&dst, src[0..5]);
    std.debug.print("@memcpy結果: {s}\n", .{&dst});

    std.debug.print("\n", .{});
}

// ====================
// Enum操作
// ====================

const Color = enum(u8) {
    red = 1,
    green = 2,
    blue = 3,
};

fn demonstrateEnum() void {
    std.debug.print("--- Enum操作 ---\n", .{});

    const c = Color.green;

    // @intFromEnum: enumを整数に
    std.debug.print("@intFromEnum(.green) = {d}\n", .{@intFromEnum(c)});

    // @enumFromInt: 整数をenumに
    const c2: Color = @enumFromInt(3);
    std.debug.print("@enumFromInt(3) = {}\n", .{c2});

    // @tagName: enum値の名前
    std.debug.print("@tagName(.green) = {s}\n", .{@tagName(c)});

    std.debug.print("\n", .{});
}

// ====================
// エラーとデバッグ
// ====================

fn demonstrateDebug() void {
    std.debug.print("--- エラーとデバッグ ---\n", .{});

    // @errorName: エラーの名前
    const err = error.FileNotFound;
    std.debug.print("@errorName(error.FileNotFound) = {s}\n", .{@errorName(err)});

    // @src: 現在のソース位置
    const src = @src();
    std.debug.print("@src(): {s}:{d}:{d}\n", .{ src.file, src.line, src.column });

    // @compileLog: コンパイル時ログ（デバッグ用、コメントアウト）
    // @compileLog("Debug message");

    std.debug.print("\n", .{});
}

// ====================
// ポインタ操作
// ====================

fn demonstratePointers() void {
    std.debug.print("--- ポインタ操作 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };

    // @ptrCast: ポインタ型変換
    const ptr: *[5]i32 = &arr;
    const byte_ptr: [*]u8 = @ptrCast(ptr);
    std.debug.print("配列の最初のバイト: {d}\n", .{byte_ptr[0]});

    // @intFromPtr: ポインタをアドレス（整数）に
    const addr = @intFromPtr(ptr);
    std.debug.print("配列のアドレス: 0x{x}\n", .{addr});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== 組み込み関数（builtin） ===\n\n", .{});

    demonstrateTypeCast();
    demonstrateTypeInfo();
    demonstrateArithmetic();
    demonstrateBitOps();
    demonstrateMemory();
    demonstrateEnum();
    demonstrateDebug();
    demonstratePointers();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・組み込み関数は@で始まる\n", .{});
    std.debug.print("・低レベル操作を安全に提供\n", .{});
    std.debug.print("・多くはcomptimeでも使用可能\n", .{});
    std.debug.print("・完全なリストはzig langref参照\n", .{});
}

// --- テスト ---

test "@intCast" {
    const big: i64 = 1000;
    const small: i16 = @intCast(big);
    try std.testing.expectEqual(@as(i16, 1000), small);
}

test "@floatCast" {
    const f64_val: f64 = 3.14159265358979;
    const f32_val: f32 = @floatCast(f64_val);
    try std.testing.expect(@abs(f32_val - 3.14159) < 0.0001);
}

test "@intFromFloat" {
    const pi: f64 = 3.14;
    const pi_int: i32 = @intFromFloat(pi);
    try std.testing.expectEqual(@as(i32, 3), pi_int);
}

test "@floatFromInt" {
    const n: i32 = 42;
    const n_float: f64 = @floatFromInt(n);
    try std.testing.expect(@abs(n_float - 42.0) < 0.001);
}

test "@intFromBool" {
    try std.testing.expectEqual(@as(u8, 1), @intFromBool(true));
    try std.testing.expectEqual(@as(u8, 0), @intFromBool(false));
}

test "@sizeOf" {
    try std.testing.expectEqual(@as(usize, 1), @sizeOf(i8));
    try std.testing.expectEqual(@as(usize, 4), @sizeOf(i32));
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(i64));
}

test "@addWithOverflow" {
    // オーバーフローあり
    const result1 = @addWithOverflow(@as(u8, 200), @as(u8, 100));
    try std.testing.expect(result1[1] != 0);

    // オーバーフローなし
    const result2 = @addWithOverflow(@as(u8, 100), @as(u8, 50));
    try std.testing.expectEqual(@as(u8, 150), result2[0]);
    try std.testing.expect(result2[1] == 0);
}

test "@abs" {
    try std.testing.expectEqual(@as(i32, 42), @abs(@as(i32, -42)));
    try std.testing.expectEqual(@as(i32, 42), @abs(@as(i32, 42)));
    try std.testing.expectEqual(@as(i32, 0), @abs(@as(i32, 0)));
}

test "@min @max" {
    try std.testing.expectEqual(@as(i32, 3), @min(@as(i32, 3), @as(i32, 7)));
    try std.testing.expectEqual(@as(i32, 7), @max(@as(i32, 3), @as(i32, 7)));
}

test "@sqrt" {
    try std.testing.expect(@abs(@sqrt(@as(f64, 16.0)) - 4.0) < 0.001);
    try std.testing.expect(@abs(@sqrt(@as(f64, 2.0)) - 1.414) < 0.001);
}

test "@popCount" {
    try std.testing.expectEqual(@as(u8, 4), @popCount(@as(u8, 0b10110100)));
    try std.testing.expectEqual(@as(u8, 0), @popCount(@as(u8, 0)));
    try std.testing.expectEqual(@as(u8, 8), @popCount(@as(u8, 0xFF)));
}

test "@clz @ctz" {
    try std.testing.expectEqual(@as(u8, 1), @clz(@as(u8, 0b01000000)));
    try std.testing.expectEqual(@as(u8, 2), @ctz(@as(u8, 0b00000100)));
}

test "@byteSwap" {
    try std.testing.expectEqual(@as(u32, 0x78563412), @byteSwap(@as(u32, 0x12345678)));
}

test "@bitReverse" {
    try std.testing.expectEqual(@as(u8, 0b10000011), @bitReverse(@as(u8, 0b11000001)));
}

test "@memset" {
    var buffer: [5]u8 = undefined;
    @memset(&buffer, 'X');
    try std.testing.expect(std.mem.eql(u8, &buffer, "XXXXX"));
}

test "@memcpy" {
    const src = "Hello";
    var dst: [5]u8 = undefined;
    @memcpy(&dst, src[0..5]);
    try std.testing.expect(std.mem.eql(u8, &dst, "Hello"));
}

test "@intFromEnum @enumFromInt" {
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(Color.green));
    const c: Color = @enumFromInt(3);
    try std.testing.expect(c == Color.blue);
}

test "@tagName" {
    try std.testing.expect(std.mem.eql(u8, @tagName(Color.red), "red"));
}

test "@errorName" {
    try std.testing.expect(std.mem.eql(u8, @errorName(error.OutOfMemory), "OutOfMemory"));
}
