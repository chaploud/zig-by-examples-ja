//! # メモリレイアウト
//!
//! 構造体のメモリレイアウトを制御する方法。
//! struct、packed struct、extern structの違い。
//!
//! ## レイアウトの種類
//! - struct: 最適化されたレイアウト（順序変更あり）
//! - packed struct: ビット単位で詰め込む
//! - extern struct: C互換レイアウト
//!
//! ## 用途
//! - packed: ビットフィールド、プロトコル
//! - extern: C言語との連携

const std = @import("std");

// ====================
// 通常の struct
// ====================

const NormalStruct = struct {
    a: u8,
    b: u32,
    c: u8,
    d: u16,
};

fn demoNormalStruct() void {
    std.debug.print("--- 通常の struct ---\n", .{});

    std.debug.print("  NormalStruct:\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(NormalStruct)});
    std.debug.print("    align: {d}\n", .{@alignOf(NormalStruct)});

    // フィールドオフセット（最適化により順序変更される可能性）
    std.debug.print("    offsets:\n", .{});
    std.debug.print("      a: {d}, b: {d}, c: {d}, d: {d}\n", .{
        @offsetOf(NormalStruct, "a"),
        @offsetOf(NormalStruct, "b"),
        @offsetOf(NormalStruct, "c"),
        @offsetOf(NormalStruct, "d"),
    });

    // 理論上の最小サイズ: 1+4+1+2 = 8 bytes
    // 実際: パディングと並べ替えで変わる可能性
    std.debug.print("    → Zigがフィールド順序を最適化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// packed struct
// ====================

const PackedStruct = packed struct {
    a: u8,
    b: u4,
    c: u4,
    d: u16,
};

const BitFlags = packed struct {
    read: bool,
    write: bool,
    execute: bool,
    _reserved: u5 = 0,
};

fn demoPackedStruct() void {
    std.debug.print("--- packed struct ---\n", .{});

    std.debug.print("  PackedStruct:\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(PackedStruct)});

    // packed structはビット単位
    const ps = PackedStruct{ .a = 0xFF, .b = 0x5, .c = 0xA, .d = 0x1234 };

    // バッキング整数として解釈
    const backing: u32 = @bitCast(ps);
    std.debug.print("    as u32: 0x{x}\n", .{backing});

    // ビットフラグの例
    std.debug.print("  BitFlags:\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(BitFlags)});

    const flags = BitFlags{ .read = true, .write = false, .execute = true };
    const flag_byte: u8 = @bitCast(flags);
    std.debug.print("    flags: read={}, write={}, execute={}\n", .{ flags.read, flags.write, flags.execute });
    std.debug.print("    as u8: 0b{b:0>8}\n", .{flag_byte});

    std.debug.print("\n", .{});
}

// ====================
// extern struct
// ====================

const ExternStruct = extern struct {
    a: u8,
    b: u32,
    c: u8,
    d: u16,
};

fn demoExternStruct() void {
    std.debug.print("--- extern struct ---\n", .{});

    std.debug.print("  ExternStruct (C互換):\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(ExternStruct)});
    std.debug.print("    align: {d}\n", .{@alignOf(ExternStruct)});

    // extern structは宣言順にフィールドを配置
    std.debug.print("    offsets:\n", .{});
    std.debug.print("      a: {d}, b: {d}, c: {d}, d: {d}\n", .{
        @offsetOf(ExternStruct, "a"),
        @offsetOf(ExternStruct, "b"),
        @offsetOf(ExternStruct, "c"),
        @offsetOf(ExternStruct, "d"),
    });

    // C言語と同じレイアウト
    // a(1) + pad(3) + b(4) + c(1) + pad(1) + d(2) = 12
    std.debug.print("    → C言語と同じレイアウトを保証\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// レイアウト比較
// ====================

const CompareNormal = struct { a: u8, b: u32, c: u8 };
const ComparePacked = packed struct { a: u8, b: u32, c: u8 };
const CompareExtern = extern struct { a: u8, b: u32, c: u8 };

fn demoComparison() void {
    std.debug.print("--- レイアウト比較 ---\n", .{});

    std.debug.print("  同じフィールド (u8, u32, u8):\n", .{});
    std.debug.print("    struct:       size={d}, align={d}\n", .{ @sizeOf(CompareNormal), @alignOf(CompareNormal) });
    std.debug.print("    packed:       size={d}, align={d}\n", .{ @sizeOf(ComparePacked), @alignOf(ComparePacked) });
    std.debug.print("    extern:       size={d}, align={d}\n", .{ @sizeOf(CompareExtern), @alignOf(CompareExtern) });

    std.debug.print("\n", .{});
}

// ====================
// packed structのビット操作
// ====================

const IPHeader = packed struct {
    version: u4,
    ihl: u4,
    dscp: u6,
    ecn: u2,
    total_length: u16,
};

fn demoIPHeader() void {
    std.debug.print("--- packed structのビット操作 ---\n", .{});

    std.debug.print("  IPHeader (簡略版):\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(IPHeader)});

    const header = IPHeader{
        .version = 4, // IPv4
        .ihl = 5, // 5 * 4 = 20 bytes
        .dscp = 0,
        .ecn = 0,
        .total_length = 60,
    };

    std.debug.print("    version: {d}\n", .{header.version});
    std.debug.print("    ihl: {d}\n", .{header.ihl});
    std.debug.print("    total_length: {d}\n", .{header.total_length});

    // バイト列として解釈
    const bytes: [4]u8 = @bitCast(header);
    std.debug.print("    bytes: ", .{});
    for (bytes) |b| {
        std.debug.print("{x:0>2} ", .{b});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @bitCastの活用
// ====================

fn demoBitCast() void {
    std.debug.print("--- @bitCast ---\n", .{});

    // 浮動小数点のビットパターン
    const float_val: f32 = 1.0;
    const as_int: u32 = @bitCast(float_val);
    std.debug.print("  f32 1.0 as u32: 0x{x}\n", .{as_int});

    // packed structとの相互変換
    const Packed = packed struct { low: u8, high: u8 };
    const p = Packed{ .low = 0x34, .high = 0x12 };
    const as_u16: u16 = @bitCast(p);
    std.debug.print("  packed {{0x34, 0x12}} as u16: 0x{x}\n", .{as_u16});

    // 逆変換
    const back: Packed = @bitCast(@as(u16, 0xABCD));
    std.debug.print("  u16 0xABCD as packed: low=0x{x}, high=0x{x}\n", .{ back.low, back.high });

    std.debug.print("\n", .{});
}

// ====================
// extern structとC連携
// ====================

const CPoint = extern struct {
    x: c_int,
    y: c_int,
};

const CRect = extern struct {
    origin: CPoint,
    size: extern struct {
        width: c_int,
        height: c_int,
    },
};

fn demoCStruct() void {
    std.debug.print("--- extern structとC連携 ---\n", .{});

    std.debug.print("  CPoint:\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(CPoint)});

    const pt = CPoint{ .x = 10, .y = 20 };
    std.debug.print("    pt.x={d}, pt.y={d}\n", .{ pt.x, pt.y });

    std.debug.print("  CRect:\n", .{});
    std.debug.print("    size: {d} bytes\n", .{@sizeOf(CRect)});

    // C関数に渡す場合はポインタを使用
    // _ = c_function(&pt);

    std.debug.print("    → Cのstruct定義と互換\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @sizeOfと@alignOf
// ====================

fn demoSizeAndAlign() void {
    std.debug.print("--- @sizeOf と @alignOf ---\n", .{});

    const types = .{ u8, u16, u32, u64, f32, f64, *u8, [10]u8 };
    inline for (types) |T| {
        std.debug.print("  {s}: size={d}, align={d}\n", .{
            @typeName(T),
            @sizeOf(T),
            @alignOf(T),
        });
    }

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== メモリレイアウト ===\n\n", .{});

    demoNormalStruct();
    demoPackedStruct();
    demoExternStruct();
    demoComparison();
    demoIPHeader();
    demoBitCast();
    demoCStruct();
    demoSizeAndAlign();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・struct: 最適化（順序変更あり）\n", .{});
    std.debug.print("・packed: ビット詰め、@bitCast可能\n", .{});
    std.debug.print("・extern: C互換、順序保持\n", .{});
    std.debug.print("・@sizeOf: 型のサイズ\n", .{});
    std.debug.print("・@offsetOf: フィールドのオフセット\n", .{});
}

// --- テスト ---

test "normal struct size" {
    // 最適化されるので最小サイズは保証されない
    try std.testing.expect(@sizeOf(NormalStruct) >= 8);
}

test "packed struct size" {
    // packed structは厳密なサイズ
    try std.testing.expectEqual(@as(usize, 4), @sizeOf(PackedStruct));
}

test "extern struct layout" {
    // extern structは宣言順
    try std.testing.expect(@offsetOf(ExternStruct, "a") < @offsetOf(ExternStruct, "b"));
    try std.testing.expect(@offsetOf(ExternStruct, "b") < @offsetOf(ExternStruct, "c"));
    try std.testing.expect(@offsetOf(ExternStruct, "c") < @offsetOf(ExternStruct, "d"));
}

test "packed struct bitcast" {
    const Flags = packed struct {
        a: bool,
        b: bool,
        c: bool,
        _pad: u5 = 0,
    };

    const flags = Flags{ .a = true, .b = false, .c = true };
    const byte: u8 = @bitCast(flags);

    // a=1, b=0, c=1 -> 0b00000101 = 5
    try std.testing.expectEqual(@as(u8, 5), byte);
}

test "bitcast float to int" {
    const f: f32 = 1.0;
    const i: u32 = @bitCast(f);

    // IEEE 754: 1.0 = 0x3F800000
    try std.testing.expectEqual(@as(u32, 0x3F800000), i);
}

test "IPHeader size" {
    try std.testing.expectEqual(@as(usize, 4), @sizeOf(IPHeader));
}

test "CPoint size" {
    // c_int is typically 4 bytes
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(CPoint));
}

test "compare struct sizes" {
    // packed is smallest
    try std.testing.expect(@sizeOf(ComparePacked) <= @sizeOf(CompareNormal));
    try std.testing.expect(@sizeOf(ComparePacked) <= @sizeOf(CompareExtern));
}

test "BitFlags as byte" {
    const flags = BitFlags{ .read = true, .write = true, .execute = false };
    const byte: u8 = @bitCast(flags);

    // read=1, write=1, execute=0 -> 0b00000011 = 3
    try std.testing.expectEqual(@as(u8, 3), byte);
}
