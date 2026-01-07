//! # allowzeroポインタ
//!
//! allowzeroはアドレス0を許可する特殊なポインタ修飾子。
//! 通常のポインタはアドレス0を持てないが、allowzeroで許可。
//!
//! ## 用途
//! - メモリマップドI/O（アドレス0が有効な場合）
//! - 組み込みシステム
//! - Cライブラリとの連携
//!
//! ## 構文
//! - *allowzero T: アドレス0を許可

const std = @import("std");

// ====================
// 基本的なallowzeroポインタ
// ====================

fn demoBasicAllowzero() void {
    std.debug.print("--- 基本的なallowzeroポインタ ---\n", .{});

    // 通常のポインタはアドレス0を持てない
    // const normal_ptr: *u32 = @ptrFromInt(0); // 未定義動作

    // allowzeroポインタはアドレス0を持てる
    const allowzero_ptr: *allowzero u32 = @ptrFromInt(0);
    std.debug.print("  allowzero_ptr: 0x{x}\n", .{@intFromPtr(allowzero_ptr)});

    // nullとは異なる概念
    const opt_ptr: ?*u32 = null;
    std.debug.print("  ?*u32 null: 有効な「値なし」状態\n", .{});
    std.debug.print("  *allowzero u32 at 0: アドレス0へのポインタ\n", .{});
    _ = opt_ptr;

    std.debug.print("\n", .{});
}

// ====================
// @typeInfoでallowzero確認
// ====================

fn demoTypeInfoAllowzero() void {
    std.debug.print("--- @typeInfo でallowzero確認 ---\n", .{});

    const NormalPtr = *u32;
    const AllowzeroPtr = *allowzero u32;

    const normal_info = @typeInfo(NormalPtr).pointer;
    const allowzero_info = @typeInfo(AllowzeroPtr).pointer;

    std.debug.print("  *u32:\n", .{});
    std.debug.print("    is_allowzero: {}\n", .{normal_info.is_allowzero});

    std.debug.print("  *allowzero u32:\n", .{});
    std.debug.print("    is_allowzero: {}\n", .{allowzero_info.is_allowzero});

    std.debug.print("\n", .{});
}

// ====================
// Cポインタとallowzero
// ====================

fn demoCPointerAllowzero() void {
    std.debug.print("--- Cポインタとallowzero ---\n", .{});

    // Cポインタ [*c]T は暗黙的にallowzero
    const c_ptr: [*c]const u8 = @ptrFromInt(0);
    std.debug.print("  [*c]const u8 at 0: 0x{x}\n", .{@intFromPtr(c_ptr)});

    // C互換のnullポインタ
    const null_c_ptr: [*c]const u8 = null;
    std.debug.print("  [*c]const u8 null: 0x{x}\n", .{@intFromPtr(null_c_ptr)});

    std.debug.print("  → Cポインタは0アドレスとnullが同等\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// std.mem.zeroInitとallowzero
// ====================

fn demoZeroInit() void {
    std.debug.print("--- std.mem.zeroInit ---\n", .{});

    // 構造体を0初期化
    const Data = struct {
        value: u32,
        name: [8]u8,
        ptr: ?*u32, // Optionalポインタは0初期化可能
    };

    const zeroed = std.mem.zeroes(Data);
    std.debug.print("  zeroed.value: {d}\n", .{zeroed.value});
    std.debug.print("  zeroed.ptr: {?}\n", .{zeroed.ptr});

    // allowzeroフィールドも0初期化可能
    const WithAllowzero = struct {
        ptr: *allowzero u32,
    };

    const zeroed2 = std.mem.zeroes(WithAllowzero);
    std.debug.print("  allowzero ptr zeroed: 0x{x}\n", .{@intFromPtr(zeroed2.ptr)});

    std.debug.print("\n", .{});
}

// ====================
// allowzeroと通常ポインタの変換
// ====================

fn demoConversion() void {
    std.debug.print("--- allowzeroと通常ポインタの変換 ---\n", .{});

    var value: u32 = 42;

    // 通常ポインタ → allowzeroポインタ（暗黙的OK）
    const normal_ptr: *u32 = &value;
    const allowzero_ptr: *allowzero u32 = normal_ptr;
    std.debug.print("  *u32 → *allowzero u32: 暗黙的OK\n", .{});
    std.debug.print("  allowzero_ptr.* = {d}\n", .{allowzero_ptr.*});

    // allowzeroポインタ → 通常ポインタ（0チェックが必要）
    // const restored: *u32 = allowzero_ptr; // 直接は不可

    // 0でないことを確認してから変換
    if (@intFromPtr(allowzero_ptr) != 0) {
        const safe_ptr: *u32 = @ptrCast(allowzero_ptr);
        std.debug.print("  *allowzero u32 → *u32: 0チェック後OK\n", .{});
        std.debug.print("  safe_ptr.* = {d}\n", .{safe_ptr.*});
    }

    std.debug.print("\n", .{});
}

// ====================
// 組み込みシステムでの使用例
// ====================

fn demoEmbeddedExample() void {
    std.debug.print("--- 組み込みシステムでの使用例 ---\n", .{});

    // 多くの組み込みシステムではアドレス0に重要なデータがある
    // - 割り込みベクタテーブル
    // - ブートROM
    // - メモリマップドレジスタ

    std.debug.print("  組み込みでアドレス0が使われる場面:\n", .{});
    std.debug.print("    - 割り込みベクタテーブル\n", .{});
    std.debug.print("    - ブートROM開始アドレス\n", .{});
    std.debug.print("    - 特殊なハードウェアレジスタ\n", .{});

    // 仮想的な割り込みベクタ構造
    const InterruptVector = extern struct {
        reset: *allowzero const fn () callconv(.c) void,
        nmi: *allowzero const fn () callconv(.c) void,
        hard_fault: *allowzero const fn () callconv(.c) void,
    };

    std.debug.print("  InterruptVector size: {d} bytes\n", .{@sizeOf(InterruptVector)});

    std.debug.print("\n", .{});
}

// ====================
// allowzero配列ポインタ
// ====================

fn demoAllowzeroArray() void {
    std.debug.print("--- allowzero配列ポインタ ---\n", .{});

    // 配列へのallowzeroポインタ
    const arr_ptr: [*]allowzero u32 = @ptrFromInt(0);
    std.debug.print("  [*]allowzero u32 at 0: 0x{x}\n", .{@intFromPtr(arr_ptr)});

    // スライスへは変換できない（長さ情報が必要）
    // const slice: []u32 = arr_ptr[0..10]; // 0アドレスでは危険

    std.debug.print("  → 実際のアクセスは危険、型情報としてのみ使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optional vs allowzero
// ====================

fn demoOptionalVsAllowzero() void {
    std.debug.print("--- Optional vs allowzero ---\n", .{});

    std.debug.print("  ?*T (Optional):\n", .{});
    std.debug.print("    - nullは「値なし」を表す\n", .{});
    std.debug.print("    - 型安全なnull表現\n", .{});
    std.debug.print("    - unwrapが必要\n", .{});

    std.debug.print("  *allowzero T:\n", .{});
    std.debug.print("    - アドレス0への有効なポインタ\n", .{});
    std.debug.print("    - 組み込みシステム向け\n", .{});
    std.debug.print("    - 直接参照外し可能（危険）\n", .{});

    // 組み合わせも可能だが、0はnullとして扱われる
    const both: ?*allowzero u32 = @ptrFromInt(0);
    std.debug.print("  ?*allowzero u32 at 0:\n", .{});
    if (both) |ptr| {
        std.debug.print("    ptr: 0x{x}\n", .{@intFromPtr(ptr)});
    } else {
        std.debug.print("    → 0アドレスはnullとして扱われる\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 安全な使用パターン
// ====================

fn demoSafeUsage() void {
    std.debug.print("--- 安全な使用パターン ---\n", .{});

    std.debug.print("  1. 型変換時のチェック:\n", .{});
    std.debug.print("     if (@intFromPtr(ptr) != 0) {{ ... }}\n", .{});

    std.debug.print("  2. Optional併用:\n", .{});
    std.debug.print("     ?*allowzero T で両方の概念を扱う\n", .{});

    std.debug.print("  3. 組み込み専用:\n", .{});
    std.debug.print("     通常のアプリではallowzeroは不要\n", .{});

    std.debug.print("  4. Cライブラリ連携:\n", .{});
    std.debug.print("     [*c]T は暗黙的にallowzero\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== allowzeroポインタ ===\n\n", .{});

    demoBasicAllowzero();
    demoTypeInfoAllowzero();
    demoCPointerAllowzero();
    demoZeroInit();
    demoConversion();
    demoEmbeddedExample();
    demoAllowzeroArray();
    demoOptionalVsAllowzero();
    demoSafeUsage();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・*allowzero T でアドレス0を許可\n", .{});
    std.debug.print("・組み込みシステムで使用\n", .{});
    std.debug.print("・Cポインタは暗黙的にallowzero\n", .{});
    std.debug.print("・Optional(?*T)とは異なる概念\n", .{});
}

// --- テスト ---

test "allowzero pointer creation" {
    const ptr: *allowzero u32 = @ptrFromInt(0);
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(ptr));
}

test "typeinfo is_allowzero" {
    const NormalPtr = *u32;
    const AllowzeroPtr = *allowzero u32;

    const normal_info = @typeInfo(NormalPtr).pointer;
    const allowzero_info = @typeInfo(AllowzeroPtr).pointer;

    try std.testing.expect(!normal_info.is_allowzero);
    try std.testing.expect(allowzero_info.is_allowzero);
}

test "c pointer is allowzero" {
    const c_ptr: [*c]const u8 = @ptrFromInt(0);
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(c_ptr));
}

test "normal to allowzero conversion" {
    var val: u32 = 100;
    const normal_ptr: *u32 = &val;
    const allowzero_ptr: *allowzero u32 = normal_ptr;

    try std.testing.expectEqual(@as(u32, 100), allowzero_ptr.*);
}

test "zeroes with allowzero field" {
    const S = struct {
        ptr: *allowzero u32,
    };

    const zeroed = std.mem.zeroes(S);
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(zeroed.ptr));
}

test "optional allowzero" {
    // ?*allowzero の場合、アドレス0はnullと等しい
    const both: ?*allowzero u32 = @ptrFromInt(0);
    // 0アドレスはOptionalではnullとして扱われる
    try std.testing.expect(both == null);
}

test "allowzero multi pointer" {
    const arr_ptr: [*]allowzero u32 = @ptrFromInt(0);
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(arr_ptr));
}
