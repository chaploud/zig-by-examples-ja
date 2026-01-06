//! # 整数型
//!
//! Zigは多様な整数型を提供する。ビット幅と符号の有無で型が決まる。
//!
//! ## 符号なし整数（unsigned）
//! - `u8`, `u16`, `u32`, `u64`, `u128`
//! - 0以上の値のみ格納可能
//!
//! ## 符号付き整数（signed）
//! - `i8`, `i16`, `i32`, `i64`, `i128`
//! - 負の値も格納可能（2の補数表現）
//!
//! ## 特殊な整数型
//! - `usize`: ポインタサイズの符号なし整数（64bitシステムでは64bit）
//! - `isize`: ポインタサイズの符号付き整数
//! - `comptime_int`: コンパイル時整数（任意精度）

const std = @import("std");

pub fn main() void {
    std.debug.print("=== 整数型 ===\n\n", .{});

    // ====================
    // 符号なし整数
    // ====================

    const byte: u8 = 255; // 0 ~ 255
    const word: u16 = 65535; // 0 ~ 65535
    const dword: u32 = 4_294_967_295; // 数値リテラルに _ を使える
    const qword: u64 = 18_446_744_073_709_551_615;

    std.debug.print("u8  最大値: {d}\n", .{byte});
    std.debug.print("u16 最大値: {d}\n", .{word});
    std.debug.print("u32 最大値: {d}\n", .{dword});
    std.debug.print("u64 最大値: {d}\n", .{qword});

    std.debug.print("\n", .{});

    // ====================
    // 符号付き整数
    // ====================

    const signed8: i8 = -128; // -128 ~ 127
    const signed16: i16 = -32768; // -32768 ~ 32767
    const signed32: i32 = -2_147_483_648;
    const positive: i32 = 2_147_483_647;

    std.debug.print("i8  最小値: {d}\n", .{signed8});
    std.debug.print("i16 最小値: {d}\n", .{signed16});
    std.debug.print("i32 最小値: {d}\n", .{signed32});
    std.debug.print("i32 最大値: {d}\n", .{positive});

    std.debug.print("\n", .{});

    // ====================
    // usizeとisize
    // ====================

    // usizeはインデックスやサイズに使用する
    const arr = [_]i32{ 10, 20, 30, 40, 50 };
    const index: usize = 2;
    std.debug.print("arr[{d}] = {d}\n", .{ index, arr[index] });

    // スライスの長さはusize
    const slice = arr[1..4];
    std.debug.print("スライスの長さ: {d}\n", .{slice.len});

    std.debug.print("\n", .{});

    // ====================
    // 数値リテラル表現
    // ====================

    const decimal = 1234; // 10進数
    const hex = 0xFF; // 16進数（255）
    const octal = 0o755; // 8進数（493）
    const binary = 0b1010; // 2進数（10）

    std.debug.print("10進数: {d}\n", .{decimal});
    std.debug.print("16進数 0xFF = {d}\n", .{hex});
    std.debug.print("8進数 0o755 = {d}\n", .{octal});
    std.debug.print("2進数 0b1010 = {d}\n", .{binary});

    std.debug.print("\n", .{});

    // ====================
    // 型の範囲取得
    // ====================

    // std.math.maxInt / minInt で型の最大・最小値を取得
    std.debug.print("u8の範囲: {d} ~ {d}\n", .{ std.math.minInt(u8), std.math.maxInt(u8) });
    std.debug.print("i8の範囲: {d} ~ {d}\n", .{ std.math.minInt(i8), std.math.maxInt(i8) });

    std.debug.print("\n", .{});

    // ====================
    // ビット演算
    // ====================

    const a: u8 = 0b1100; // 12
    const b: u8 = 0b1010; // 10

    std.debug.print("a = 0b{b:0>4}, b = 0b{b:0>4}\n", .{ a, b });
    std.debug.print("a & b (AND)  = 0b{b:0>4} ({d})\n", .{ a & b, a & b });
    std.debug.print("a | b (OR)   = 0b{b:0>4} ({d})\n", .{ a | b, a | b });
    std.debug.print("a ^ b (XOR)  = 0b{b:0>4} ({d})\n", .{ a ^ b, a ^ b });
    std.debug.print("~a    (NOT)  = {b:0>8} ({d})\n", .{ ~a, ~a });
    std.debug.print("a << 2       = 0b{b:0>6} ({d})\n", .{ @as(u8, a) << 2, @as(u8, a) << 2 });
    std.debug.print("a >> 2       = 0b{b:0>4} ({d})\n", .{ a >> 2, a >> 2 });

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・オーバーフローはデフォルトで検出される（安全）\n", .{});
    std.debug.print("・明示的なオーバーフロー演算子: +%, -%, *%\n", .{});
    std.debug.print("・saturating演算子: +|, -|, *|\n", .{});
}

// ====================
// カスタムビット幅整数
// ====================

/// Zigは任意のビット幅の整数型を作成できる
fn customBitWidthDemo() void {
    // u3 は 0~7 の値を格納できる（3ビット）
    const small: u3 = 7;
    // i5 は -16~15 の値を格納できる（5ビット）
    const medium: i5 = -16;
    _ = small;
    _ = medium;
}

// ====================
// オーバーフロー演算
// ====================

/// ラッピング（wrapping）演算: オーバーフロー時に循環
fn wrappingOps() u8 {
    var x: u8 = 255;
    x +%= 1; // 結果: 0 (255 + 1 がラップ)
    return x;
}

/// サチュレーティング（saturating）演算: 限界値で停止
fn saturatingOps() u8 {
    var x: u8 = 250;
    x +|= 10; // 結果: 255 (250 + 10 は265だが255で停止)
    return x;
}

// --- テスト ---

test "unsigned integers range" {
    try std.testing.expectEqual(@as(u8, 0), std.math.minInt(u8));
    try std.testing.expectEqual(@as(u8, 255), std.math.maxInt(u8));
    try std.testing.expectEqual(@as(u16, 0), std.math.minInt(u16));
    try std.testing.expectEqual(@as(u16, 65535), std.math.maxInt(u16));
}

test "signed integers range" {
    try std.testing.expectEqual(@as(i8, -128), std.math.minInt(i8));
    try std.testing.expectEqual(@as(i8, 127), std.math.maxInt(i8));
    try std.testing.expectEqual(@as(i16, -32768), std.math.minInt(i16));
    try std.testing.expectEqual(@as(i16, 32767), std.math.maxInt(i16));
}

test "number literals" {
    try std.testing.expectEqual(@as(i32, 255), 0xFF);
    try std.testing.expectEqual(@as(i32, 493), 0o755);
    try std.testing.expectEqual(@as(i32, 10), 0b1010);
    try std.testing.expectEqual(@as(i32, 1_000_000), 1000000);
}

test "bit operations" {
    const a: u8 = 0b1100;
    const b: u8 = 0b1010;

    try std.testing.expectEqual(@as(u8, 0b1000), a & b); // AND
    try std.testing.expectEqual(@as(u8, 0b1110), a | b); // OR
    try std.testing.expectEqual(@as(u8, 0b0110), a ^ b); // XOR
    try std.testing.expectEqual(@as(u8, 0b11110011), ~a); // NOT
}

test "shift operations" {
    const x: u8 = 0b0001;
    try std.testing.expectEqual(@as(u8, 0b0100), x << 2); // 左シフト
    try std.testing.expectEqual(@as(u8, 0b0000), x >> 2); // 右シフト

    const y: u8 = 0b1000;
    try std.testing.expectEqual(@as(u8, 0b0010), y >> 2);
}

test "wrapping operations" {
    var x: u8 = 255;
    x +%= 1;
    try std.testing.expectEqual(@as(u8, 0), x);

    var y: u8 = 0;
    y -%= 1;
    try std.testing.expectEqual(@as(u8, 255), y);
}

test "saturating operations" {
    var x: u8 = 250;
    x +|= 10;
    try std.testing.expectEqual(@as(u8, 255), x);

    var y: u8 = 5;
    y -|= 10;
    try std.testing.expectEqual(@as(u8, 0), y);
}

test "custom bit width integers" {
    const small: u3 = 7; // max value for u3
    try std.testing.expectEqual(@as(u3, 7), small);

    const medium: i5 = -16; // min value for i5
    try std.testing.expectEqual(@as(i5, -16), medium);

    // u12 can store 0 ~ 4095
    const custom: u12 = 4095;
    try std.testing.expectEqual(@as(u12, 4095), custom);
}

test "usize for indexing" {
    const arr = [_]i32{ 10, 20, 30 };
    const idx: usize = 1;
    try std.testing.expectEqual(@as(i32, 20), arr[idx]);
    try std.testing.expectEqual(@as(usize, 3), arr.len);
}

test "integer type casting" {
    const small: u8 = 100;
    const larger: u32 = small; // 小さい型から大きい型は暗黙変換
    try std.testing.expectEqual(@as(u32, 100), larger);

    const big: u32 = 200;
    const truncated: u8 = @intCast(big); // 明示的キャストが必要
    try std.testing.expectEqual(@as(u8, 200), truncated);
}
