//! # アドレス空間（Address Space）
//!
//! アドレス空間はポインタがどの種類のメモリを指すかを示す。
//! 主にGPUプログラミングや組み込みシステムで使用。
//!
//! ## 主なアドレス空間
//! - generic: 通常のメモリ（デフォルト）
//! - global: GPUグローバルメモリ
//! - shared: GPUスレッド間共有メモリ
//! - constant: 定数メモリ
//!
//! ## 構文
//! - addrspace(.generic) *T

const std = @import("std");

// ====================
// アドレス空間の種類
// ====================

fn demoAddressSpaceTypes() void {
    std.debug.print("--- アドレス空間の種類 ---\n", .{});

    std.debug.print("  CPU アドレス空間:\n", .{});
    std.debug.print("    generic: 通常メモリ（デフォルト）\n", .{});
    std.debug.print("    gs: x86 GSセグメント\n", .{});
    std.debug.print("    fs: x86 FSセグメント\n", .{});
    std.debug.print("    ss: x86 スタックセグメント\n", .{});

    std.debug.print("  GPU アドレス空間:\n", .{});
    std.debug.print("    global: グローバルメモリ\n", .{});
    std.debug.print("    shared: 共有メモリ\n", .{});
    std.debug.print("    local: ローカルメモリ\n", .{});
    std.debug.print("    constant: 定数メモリ\n", .{});

    std.debug.print("  AVR アドレス空間:\n", .{});
    std.debug.print("    flash: フラッシュメモリ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ポインタのアドレス空間
// ====================

fn demoPointerAddressSpace() void {
    std.debug.print("--- ポインタのアドレス空間 ---\n", .{});

    var value: u32 = 42;

    // デフォルトはgeneric
    const generic_ptr: *u32 = &value;
    std.debug.print("  *u32: generic（デフォルト）\n", .{});
    std.debug.print("  value: {d}\n", .{generic_ptr.*});

    // 明示的にgenericを指定
    const explicit_generic: *addrspace(.generic) u32 = &value;
    std.debug.print("  *addrspace(.generic) u32: {d}\n", .{explicit_generic.*});

    // 型情報から確認
    const ptr_info = @typeInfo(@TypeOf(generic_ptr)).pointer;
    std.debug.print("  address_space: {s}\n", .{@tagName(ptr_info.address_space)});

    std.debug.print("\n", .{});
}

// ====================
// @typeInfo でアドレス空間確認
// ====================

fn demoTypeInfoAddressSpace() void {
    std.debug.print("--- @typeInfo でアドレス空間確認 ---\n", .{});

    const GenericPtr = *u32;
    const ExplicitGenericPtr = *addrspace(.generic) u32;

    const generic_info = @typeInfo(GenericPtr).pointer;
    const explicit_info = @typeInfo(ExplicitGenericPtr).pointer;

    std.debug.print("  *u32:\n", .{});
    std.debug.print("    address_space: {s}\n", .{@tagName(generic_info.address_space)});

    std.debug.print("  *addrspace(.generic) u32:\n", .{});
    std.debug.print("    address_space: {s}\n", .{@tagName(explicit_info.address_space)});

    std.debug.print("  （fs/gs等はx86固有、global/shared等はGPU固有）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// GPUスタイルのアドレス空間例
// ====================

fn demoGPUStyleAddressSpace() void {
    std.debug.print("--- GPUスタイルのアドレス空間 ---\n", .{});

    // GPUプログラミングでの典型的な使い方
    // 注意: 実際のGPUコードではこれらは異なるメモリ領域を指す

    std.debug.print("  GPU kernel風の型定義例:\n", .{});
    std.debug.print("    *addrspace(.global) f32 - グローバルバッファ\n", .{});
    std.debug.print("    *addrspace(.shared) f32 - ワークグループ共有\n", .{});
    std.debug.print("    *addrspace(.local) f32 - スレッドローカル\n", .{});

    // 注意: これらの型はGPUターゲットでのみ有効
    // 通常のCPUターゲットでは使用できない
    // const GlobalPtr = *addrspace(.global) f32;  // GPUのみ
    // const SharedPtr = *addrspace(.shared) f32;  // GPUのみ
    // const LocalPtr = *addrspace(.local) f32;    // GPUのみ

    std.debug.print("  → GPUターゲットでのみ使用可能\n", .{});
    std.debug.print("  → ZigはNVPTX/AMDGPUをサポート\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// AVRフラッシュアドレス空間
// ====================

fn demoAVRFlashAddressSpace() void {
    std.debug.print("--- AVRフラッシュアドレス空間 ---\n", .{});

    // AVRマイコンではRAMとフラッシュは別のアドレス空間
    std.debug.print("  AVRの特徴:\n", .{});
    std.debug.print("    - RAMとフラッシュは別アドレス空間\n", .{});
    std.debug.print("    - 定数はフラッシュに配置で省RAM\n", .{});
    std.debug.print("    - LPM命令でフラッシュから読み込み\n", .{});

    // 型として定義（AVRターゲットのみ）
    // const FlashPtr = *addrspace(.flash) const u8;  // AVRのみ
    std.debug.print("  *addrspace(.flash) const u8 (AVRのみ)\n", .{});

    std.debug.print("  → AVRターゲットでのみ使用可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// セグメントレジスタ (x86)
// ====================

fn demoSegmentRegisters() void {
    std.debug.print("--- セグメントレジスタ (x86) ---\n", .{});

    std.debug.print("  x86セグメント:\n", .{});
    std.debug.print("    fs: スレッドローカルストレージ (Linux)\n", .{});
    std.debug.print("    gs: カーネルデータ / TLS (Windows)\n", .{});
    std.debug.print("    ss: スタックセグメント\n", .{});

    // x86でのみ有効な型
    // const FSPtr = *addrspace(.fs) u32;  // x86のみ
    // const GSPtr = *addrspace(.gs) u32;  // x86のみ

    std.debug.print("  FSPtr: *addrspace(.fs) u32 (x86のみ)\n", .{});
    std.debug.print("  GSPtr: *addrspace(.gs) u32 (x86のみ)\n", .{});

    std.debug.print("  → OSカーネルや特殊なシステムコードで使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// アドレス空間の変換
// ====================

fn demoAddressSpaceConversion() void {
    std.debug.print("--- アドレス空間の変換 ---\n", .{});

    std.debug.print("  アドレス空間の変換ルール:\n", .{});
    std.debug.print("    - 同じアドレス空間: 暗黙的に変換可能\n", .{});
    std.debug.print("    - 異なるアドレス空間: @addrSpaceCast必要\n", .{});

    var val: u32 = 100;
    const ptr: *u32 = &val;

    // 明示的なキャスト例（通常は同じアドレス空間なので不要）
    const explicit: *addrspace(.generic) u32 = @addrSpaceCast(ptr);
    std.debug.print("  @addrSpaceCast: {d}\n", .{explicit.*});

    std.debug.print("  → 異なるアドレス空間間の変換は慎重に\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 使用場面のまとめ
// ====================

fn demoUseCases() void {
    std.debug.print("--- 使用場面のまとめ ---\n", .{});

    std.debug.print("  通常のアプリケーション:\n", .{});
    std.debug.print("    → generic（デフォルト）で十分\n", .{});
    std.debug.print("    → アドレス空間を意識する必要なし\n", .{});

    std.debug.print("  GPUプログラミング:\n", .{});
    std.debug.print("    → global/shared/local を使い分け\n", .{});
    std.debug.print("    → メモリ階層の最適化\n", .{});

    std.debug.print("  組み込みシステム:\n", .{});
    std.debug.print("    → flash で定数をROM配置\n", .{});
    std.debug.print("    → RAM使用量の削減\n", .{});

    std.debug.print("  OSカーネル/ドライバ:\n", .{});
    std.debug.print("    → fs/gs でTLSアクセス\n", .{});
    std.debug.print("    → セグメント固有の操作\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== アドレス空間（Address Space） ===\n\n", .{});

    demoAddressSpaceTypes();
    demoPointerAddressSpace();
    demoTypeInfoAddressSpace();
    demoGPUStyleAddressSpace();
    demoAVRFlashAddressSpace();
    demoSegmentRegisters();
    demoAddressSpaceConversion();
    demoUseCases();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・generic がデフォルトのアドレス空間\n", .{});
    std.debug.print("・GPUでglobal/shared/localを使用\n", .{});
    std.debug.print("・組み込みでflashメモリ指定\n", .{});
    std.debug.print("・通常のアプリでは意識不要\n", .{});
}

// --- テスト ---

test "default address space is generic" {
    var val: u32 = 42;
    const ptr = &val;
    const info = @typeInfo(@TypeOf(ptr)).pointer;

    try std.testing.expectEqual(std.builtin.AddressSpace.generic, info.address_space);
}

test "explicit generic address space" {
    var val: u32 = 100;
    const ptr: *addrspace(.generic) u32 = &val;

    try std.testing.expectEqual(@as(u32, 100), ptr.*);

    const info = @typeInfo(@TypeOf(ptr)).pointer;
    try std.testing.expectEqual(std.builtin.AddressSpace.generic, info.address_space);
}

test "address space type info" {
    // x86以外では.fs/.gsは使えないのでgenericでテスト
    const GenericPtr = *addrspace(.generic) u32;
    const info = @typeInfo(GenericPtr).pointer;

    try std.testing.expectEqual(std.builtin.AddressSpace.generic, info.address_space);
}

test "addrSpaceCast within same space" {
    var val: u32 = 123;
    const ptr: *u32 = &val;
    const casted: *addrspace(.generic) u32 = @addrSpaceCast(ptr);

    try std.testing.expectEqual(@as(u32, 123), casted.*);
}

// GPU/AVR アドレス空間テストはターゲット固有のためスキップ
// test "gpu address space types" { ... }
// test "avr flash address space type" { ... }
