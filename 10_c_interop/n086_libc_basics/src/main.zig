//! # libc連携の基礎
//!
//! ZigからCの標準ライブラリ(libc)を呼び出す実践例。
//!
//! ## このファイルで学ぶこと
//! - @cImport でCヘッダーをインポート
//! - C関数の呼び出し方
//! - C ABI互換の型
//! - ヌル終端文字列の扱い
//!
//! ## ビルド方法
//! build.zig で `exe.linkLibC()` を指定

const std = @import("std");

// ====================
// @cImport でCヘッダーをインポート
// ====================

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("string.h");
    @cInclude("math.h");
    @cInclude("time.h");
});

// ====================
// 基本的なC関数の呼び出し
// ====================

fn demoBasicCalls() void {
    std.debug.print("=== 基本的なC関数の呼び出し ===\n\n", .{});

    // --- printf ---
    std.debug.print("【printf】\n", .{});
    // C言語の printf を直接呼び出し
    _ = c.printf("  Hello from C printf!\n");
    _ = c.printf("  Number: %d, Float: %.2f\n", @as(c_int, 42), @as(f64, 3.14));

    std.debug.print("\n", .{});
}

// ====================
// 文字列操作
// ====================

fn demoStringFunctions() void {
    std.debug.print("=== C文字列操作 ===\n\n", .{});

    // Zigの文字列リテラルはヌル終端
    const hello: [*:0]const u8 = "Hello, World!";

    // --- strlen ---
    std.debug.print("【strlen】\n", .{});
    const len = c.strlen(hello);
    std.debug.print("  strlen(\"{s}\") = {d}\n", .{ hello, len });

    // --- strcmp ---
    std.debug.print("\n【strcmp】\n", .{});
    const str1: [*:0]const u8 = "apple";
    const str2: [*:0]const u8 = "banana";
    const cmp = c.strcmp(str1, str2);
    std.debug.print("  strcmp(\"{s}\", \"{s}\") = {d}\n", .{ str1, str2, cmp });
    if (cmp < 0) {
        std.debug.print("  → \"{s}\" < \"{s}\"\n", .{ str1, str2 });
    }

    // --- strchr ---
    std.debug.print("\n【strchr】\n", .{});
    const text: [*:0]const u8 = "Hello, Zig!";
    const found = c.strchr(text, 'Z');
    if (found != null) {
        std.debug.print("  strchr(\"{s}\", 'Z') = \"{s}\"\n", .{ text, found });
    }

    std.debug.print("\n", .{});
}

// ====================
// 数学関数
// ====================

fn demoMathFunctions() void {
    std.debug.print("=== C数学関数 (math.h) ===\n\n", .{});

    // --- sqrt ---
    const x: f64 = 16.0;
    const sqrt_x = c.sqrt(x);
    std.debug.print("  sqrt({d}) = {d}\n", .{ x, sqrt_x });

    // --- pow ---
    const base: f64 = 2.0;
    const exp: f64 = 10.0;
    const pow_result = c.pow(base, exp);
    std.debug.print("  pow({d}, {d}) = {d}\n", .{ base, exp, pow_result });

    // --- sin, cos ---
    const pi: f64 = 3.14159265358979;
    std.debug.print("  sin(pi) = {d:.6}\n", .{c.sin(pi)});
    std.debug.print("  cos(pi) = {d:.6}\n", .{c.cos(pi)});

    // --- floor, ceil ---
    const val: f64 = 3.7;
    std.debug.print("  floor({d}) = {d}\n", .{ val, c.floor(val) });
    std.debug.print("  ceil({d}) = {d}\n", .{ val, c.ceil(val) });

    std.debug.print("\n", .{});
}

// ====================
// メモリ操作
// ====================

fn demoMemoryFunctions() void {
    std.debug.print("=== Cメモリ操作 ===\n\n", .{});

    // --- malloc/free ---
    std.debug.print("【malloc/free】\n", .{});

    const size: usize = 10;
    const ptr: ?*anyopaque = c.malloc(size * @sizeOf(c_int));

    if (ptr) |p| {
        std.debug.print("  malloc({d} bytes) 成功\n", .{size * @sizeOf(c_int)});

        // ポインタをキャストして使用
        const int_ptr: [*]c_int = @ptrCast(@alignCast(p));
        for (0..size) |i| {
            int_ptr[i] = @intCast(i * 10);
        }

        std.debug.print("  データ: ", .{});
        for (0..size) |i| {
            std.debug.print("{d} ", .{int_ptr[i]});
        }
        std.debug.print("\n", .{});

        c.free(p);
        std.debug.print("  free() 完了\n", .{});
    }

    // --- memset ---
    std.debug.print("\n【memset】\n", .{});
    var buffer: [10]u8 = undefined;
    _ = c.memset(&buffer, 'X', buffer.len);
    std.debug.print("  memset後: {s}\n", .{&buffer});

    // --- memcpy ---
    std.debug.print("\n【memcpy】\n", .{});
    const src = "Hello";
    var dest: [10]u8 = undefined;
    _ = c.memcpy(&dest, src.ptr, 5);
    dest[5] = 0;
    std.debug.print("  memcpy後: {s}\n", .{dest[0..5]});

    std.debug.print("\n", .{});
}

// ====================
// 時刻関数
// ====================

fn demoTimeFunctions() void {
    std.debug.print("=== C時刻関数 (time.h) ===\n\n", .{});

    // --- time ---
    const current_time = c.time(null);
    std.debug.print("  time(null) = {d} (Unix timestamp)\n", .{current_time});

    // --- localtime ---
    const tm_ptr = c.localtime(&current_time);
    if (tm_ptr) |tm| {
        std.debug.print("  現在時刻: {d}/{d:0>2}/{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}\n", .{
            tm.*.tm_year + 1900,
            tm.*.tm_mon + 1,
            tm.*.tm_mday,
            tm.*.tm_hour,
            tm.*.tm_min,
            tm.*.tm_sec,
        });
    }

    std.debug.print("\n", .{});
}

// ====================
// C ABI 型の解説
// ====================

fn demoCAbiTypes() void {
    std.debug.print("=== C ABI 互換型 ===\n\n", .{});

    std.debug.print("【型の対応】\n", .{});
    std.debug.print("  Zig           → C\n", .{});
    std.debug.print("  c_int         → int         ({d} bytes)\n", .{@sizeOf(c_int)});
    std.debug.print("  c_uint        → unsigned int\n", .{});
    std.debug.print("  c_long        → long        ({d} bytes)\n", .{@sizeOf(c_long)});
    std.debug.print("  c_longlong    → long long   ({d} bytes)\n", .{@sizeOf(c_longlong)});
    std.debug.print("  c_char        → char\n", .{});
    std.debug.print("  f32           → float\n", .{});
    std.debug.print("  f64           → double\n", .{});

    std.debug.print("\n【ポインタ】\n", .{});
    std.debug.print("  [*c]T         → T*  (Cポインタ, NULL許容)\n", .{});
    std.debug.print("  ?*T           → T*  (オプショナルポインタ)\n", .{});
    std.debug.print("  [*:0]const u8 → const char* (ヌル終端文字列)\n", .{});

    std.debug.print("\n【void】\n", .{});
    std.debug.print("  *anyopaque    → void*\n", .{});
    std.debug.print("  ?*anyopaque   → void* (NULL許容)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== libc連携 まとめ ===\n\n", .{});

    std.debug.print("【ビルド設定】\n", .{});
    std.debug.print("  build.zig: exe.linkLibC();\n", .{});

    std.debug.print("\n【Cヘッダーのインポート】\n", .{});
    std.debug.print("  const c = @cImport({{\n", .{});
    std.debug.print("      @cInclude(\"stdio.h\");\n", .{});
    std.debug.print("      @cInclude(\"stdlib.h\");\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【関数呼び出し】\n", .{});
    std.debug.print("  c.printf(...)   // stdio.h\n", .{});
    std.debug.print("  c.strlen(...)   // string.h\n", .{});
    std.debug.print("  c.sqrt(...)     // math.h\n", .{});
    std.debug.print("  c.malloc(...)   // stdlib.h\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - Zig文字列 → Cに渡す時はヌル終端確認\n", .{});
    std.debug.print("  - c.mallocの戻り値 → ?*anyopaque\n", .{});
    std.debug.print("  - Zigのアロケータの方が安全\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoBasicCalls();
    demoStringFunctions();
    demoMathFunctions();
    demoMemoryFunctions();
    demoTimeFunctions();
    demoCAbiTypes();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・自作Cコードとの連携\n", .{});
    std.debug.print("・translate-c の使い方\n", .{});
    std.debug.print("・外部Cライブラリのリンク\n", .{});
}

// ====================
// テスト
// ====================

test "strlen" {
    const str: [*:0]const u8 = "Hello";
    const len = c.strlen(str);
    try std.testing.expectEqual(@as(usize, 5), len);
}

test "strcmp" {
    const a: [*:0]const u8 = "aaa";
    const b: [*:0]const u8 = "bbb";
    try std.testing.expect(c.strcmp(a, b) < 0);
    try std.testing.expect(c.strcmp(b, a) > 0);
    try std.testing.expectEqual(@as(c_int, 0), c.strcmp(a, a));
}

test "sqrt" {
    const result = c.sqrt(25.0);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), result, 0.0001);
}

test "pow" {
    const result = c.pow(2.0, 3.0);
    try std.testing.expectApproxEqAbs(@as(f64, 8.0), result, 0.0001);
}

test "memset" {
    var buf: [5]u8 = undefined;
    _ = c.memset(&buf, 'A', buf.len);
    try std.testing.expectEqualStrings("AAAAA", &buf);
}

test "malloc and free" {
    const ptr = c.malloc(100);
    try std.testing.expect(ptr != null);
    c.free(ptr);
}
