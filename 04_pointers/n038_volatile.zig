//! # Volatileポインタ
//!
//! Volatileポインタは最適化の抑制を指示する特殊なポインタ。
//! メモリマップドI/Oやハードウェアレジスタアクセスに使用。
//!
//! ## 用途
//! - メモリマップドI/O
//! - ハードウェアレジスタ
//! - マルチスレッドでの共有メモリ（アトミック推奨）
//!
//! ## 構文
//! - *volatile T: 単一要素
//! - [*]volatile T: 複数要素

const std = @import("std");

// ====================
// 基本的なVolatileポインタ
// ====================

fn demoBasicVolatile() void {
    std.debug.print("--- 基本的なVolatileポインタ ---\n", .{});

    // 通常のポインタ
    var normal: u32 = 100;
    const normal_ptr: *u32 = &normal;
    normal_ptr.* = 200;
    std.debug.print("  通常: {d}\n", .{normal_ptr.*});

    // Volatileポインタ
    var volatile_val: u32 = 100;
    const volatile_ptr: *volatile u32 = &volatile_val;
    volatile_ptr.* = 200;
    std.debug.print("  volatile: {d}\n", .{volatile_ptr.*});

    std.debug.print("  → volatileは最適化を抑制\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 最適化の影響
// ====================

fn demoOptimizationEffect() void {
    std.debug.print("--- 最適化の影響 ---\n", .{});

    std.debug.print("  通常のポインタ:\n", .{});
    std.debug.print("    - コンパイラは読み書きを最適化可能\n", .{});
    std.debug.print("    - 不要な読み込みを省略\n", .{});
    std.debug.print("    - レジスタにキャッシュ\n", .{});

    std.debug.print("  Volatileポインタ:\n", .{});
    std.debug.print("    - 毎回メモリからロード\n", .{});
    std.debug.print("    - 毎回メモリにストア\n", .{});
    std.debug.print("    - 順序を維持\n", .{});

    // 例: ループ内での違い
    var counter: u32 = 0;
    const volatile_counter: *volatile u32 = &counter;

    // volatileでは毎回読み書きが発生
    for (0..5) |_| {
        volatile_counter.* += 1;
    }
    std.debug.print("  volatile counter: {d}\n", .{volatile_counter.*});

    std.debug.print("\n", .{});
}

// ====================
// ハードウェアレジスタの模擬
// ====================

// ハードウェアレジスタをポインタ経由でアクセスする例
const HardwareRegs = packed struct {
    status: u32,
    data: u32,
    control: u32,
};

fn demoHardwareRegister() void {
    std.debug.print("--- ハードウェアレジスタの模擬 ---\n", .{});

    var regs = HardwareRegs{
        .status = 0x01, // ready
        .data = 0,
        .control = 0,
    };

    // volatileポインタ経由でアクセス
    const volatile_regs: *volatile HardwareRegs = &regs;

    std.debug.print("  status: 0x{x}\n", .{volatile_regs.status});

    volatile_regs.data = 0xDEADBEEF;
    std.debug.print("  data written: 0x{x}\n", .{volatile_regs.data});

    volatile_regs.control = 0x80;
    std.debug.print("  control: 0x{x}\n", .{volatile_regs.control});

    std.debug.print("  → volatileポインタで毎回読み書き\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// メモリマップドI/O風の例
// ====================

fn demoMemoryMappedIO() void {
    std.debug.print("--- メモリマップドI/O風の例 ---\n", .{});

    // 仮想的なI/Oアドレス（実際にはハードウェア依存）
    var io_buffer = [_]u8{ 0, 0, 0, 0 };
    const io_ptr: [*]volatile u8 = &io_buffer;

    // I/Oポートへの書き込み
    io_ptr[0] = 0xAA; // コマンド
    io_ptr[1] = 0x55; // データ

    std.debug.print("  I/O write: 0x{x}, 0x{x}\n", .{ io_ptr[0], io_ptr[1] });

    // volatileなので読み込みは省略されない
    const status = io_ptr[0];
    std.debug.print("  I/O read: 0x{x}\n", .{status});

    std.debug.print("  → 組み込みシステムでI/Oアクセスに使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @typeInfo でvolatile確認
// ====================

fn demoTypeInfoVolatile() void {
    std.debug.print("--- @typeInfo でvolatile確認 ---\n", .{});

    const NormalPtr = *u32;
    const VolatilePtr = *volatile u32;

    const normal_info = @typeInfo(NormalPtr).pointer;
    const volatile_info = @typeInfo(VolatilePtr).pointer;

    std.debug.print("  *u32:\n", .{});
    std.debug.print("    is_volatile: {}\n", .{normal_info.is_volatile});

    std.debug.print("  *volatile u32:\n", .{});
    std.debug.print("    is_volatile: {}\n", .{volatile_info.is_volatile});

    std.debug.print("\n", .{});
}

// ====================
// volatile配列ポインタ
// ====================

fn demoVolatileArray() void {
    std.debug.print("--- volatile配列ポインタ ---\n", .{});

    var arr = [_]u32{ 1, 2, 3, 4 };

    // 配列へのvolatileポインタ
    const volatile_arr: *volatile [4]u32 = &arr;

    // 要素アクセスもvolatile
    volatile_arr[0] = 10;
    volatile_arr[1] = 20;

    std.debug.print("  volatile_arr[0] = {d}\n", .{volatile_arr[0]});
    std.debug.print("  volatile_arr[1] = {d}\n", .{volatile_arr[1]});

    // 複数要素ポインタ
    const multi_volatile: [*]volatile u32 = &arr;
    multi_volatile[2] = 30;
    std.debug.print("  multi_volatile[2] = {d}\n", .{multi_volatile[2]});

    std.debug.print("\n", .{});
}

// ====================
// volatileとconstの組み合わせ
// ====================

fn demoVolatileConst() void {
    std.debug.print("--- volatileとconstの組み合わせ ---\n", .{});

    var value: u32 = 42;

    // 読み取り専用だがvolatile（ハードウェアステータスなど）
    const read_only: *const volatile u32 = &value;
    std.debug.print("  *const volatile u32: {d}\n", .{read_only.*});
    // read_only.* = 100; // エラー: constは変更不可

    // 読み書き可能なvolatile
    const read_write: *volatile u32 = &value;
    read_write.* = 100;
    std.debug.print("  *volatile u32 (変更後): {d}\n", .{read_write.*});

    std.debug.print("  → constはZig側の制約、volatileはハードウェア向け\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// アトミック操作との違い
// ====================

fn demoVolatileVsAtomic() void {
    std.debug.print("--- volatileとアトミックの違い ---\n", .{});

    std.debug.print("  volatile:\n", .{});
    std.debug.print("    - 最適化抑制のみ\n", .{});
    std.debug.print("    - 順序保証なし（シングルスレッド向け）\n", .{});
    std.debug.print("    - ハードウェアI/O用\n", .{});

    std.debug.print("  std.atomic:\n", .{});
    std.debug.print("    - メモリ順序を保証\n", .{});
    std.debug.print("    - マルチスレッド用\n", .{});
    std.debug.print("    - CPUバリアを含む\n", .{});

    // アトミック操作の例
    var atomic_val = std.atomic.Value(u32).init(0);
    _ = atomic_val.fetchAdd(1, .seq_cst);
    std.debug.print("  atomic fetchAdd: {d}\n", .{atomic_val.load(.seq_cst)});

    std.debug.print("  → マルチスレッドではatomicを使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 使用場面のまとめ
// ====================

fn demoUseCases() void {
    std.debug.print("--- 使用場面のまとめ ---\n", .{});

    std.debug.print("  volatileを使う場面:\n", .{});
    std.debug.print("    - メモリマップドI/O\n", .{});
    std.debug.print("    - ハードウェアレジスタ\n", .{});
    std.debug.print("    - 割り込みハンドラとの共有変数\n", .{});
    std.debug.print("    - デバイスドライバ\n", .{});

    std.debug.print("  使うべきでない場面:\n", .{});
    std.debug.print("    - 通常のマルチスレッド（atomicを使用）\n", .{});
    std.debug.print("    - 普通のメモリ操作\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== Volatileポインタ ===\n\n", .{});

    demoBasicVolatile();
    demoOptimizationEffect();
    demoHardwareRegister();
    demoMemoryMappedIO();
    demoTypeInfoVolatile();
    demoVolatileArray();
    demoVolatileConst();
    demoVolatileVsAtomic();
    demoUseCases();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・*volatile T で最適化を抑制\n", .{});
    std.debug.print("・毎回メモリから読み書き\n", .{});
    std.debug.print("・ハードウェアアクセスに使用\n", .{});
    std.debug.print("・マルチスレッドにはatomicを使う\n", .{});
}

// --- テスト ---

test "volatile pointer read write" {
    var val: u32 = 100;
    const ptr: *volatile u32 = &val;

    ptr.* = 200;
    try std.testing.expectEqual(@as(u32, 200), ptr.*);
}

test "volatile array access" {
    var arr = [_]u32{ 1, 2, 3 };
    const ptr: [*]volatile u32 = &arr;

    ptr[0] = 10;
    ptr[1] = 20;

    try std.testing.expectEqual(@as(u32, 10), ptr[0]);
    try std.testing.expectEqual(@as(u32, 20), ptr[1]);
}

test "typeinfo volatile" {
    const NormalPtr = *u32;
    const VolatilePtr = *volatile u32;

    const normal_info = @typeInfo(NormalPtr).pointer;
    const volatile_info = @typeInfo(VolatilePtr).pointer;

    try std.testing.expect(!normal_info.is_volatile);
    try std.testing.expect(volatile_info.is_volatile);
}

test "const volatile pointer" {
    var val: u32 = 42;
    const ptr: *const volatile u32 = &val;

    // 読み取りは可能
    try std.testing.expectEqual(@as(u32, 42), ptr.*);
    // 書き込みはコンパイルエラー
}

test "volatile pointer type preservation" {
    var val: u32 = 100;
    const ptr: *volatile u32 = &val;

    // 型が保持されることを確認
    const info = @typeInfo(@TypeOf(ptr)).pointer;
    try std.testing.expect(info.is_volatile);
    try std.testing.expect(!info.is_const);
}
