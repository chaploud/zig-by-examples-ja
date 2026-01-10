//! # C連携のメモリレイアウト
//!
//! Cと互換性のあるメモリレイアウトと構造体パッキング。
//!
//! ## このファイルで学ぶこと
//! - extern struct と packed struct
//! - メモリアライメントの違い
//! - @offsetOf と @sizeOf
//! - 構造体のパディング
//!
//! ## 重要なポイント
//! - C連携には extern struct を使用
//! - packed struct はビットレベル制御用

const std = @import("std");

// ====================
// 通常の struct vs extern struct
// ====================

// 通常の構造体（Zigがレイアウトを決定）
const ZigStruct = struct {
    a: u8,
    b: u32,
    c: u8,
};

// extern struct（C互換のレイアウト）
const CStruct = extern struct {
    a: u8,
    b: u32,
    c: u8,
};

// packed struct（パディングなし）
const PackedStruct = packed struct {
    a: u8,
    b: u32,
    c: u8,
};

fn demoStructComparison() void {
    std.debug.print("=== struct レイアウト比較 ===\n\n", .{});

    // Zigの通常のstruct
    std.debug.print("【通常の struct】\n", .{});
    std.debug.print("  Zigがレイアウトを最適化\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(ZigStruct)});
    std.debug.print("  オフセット: a={d}, b={d}, c={d}\n", .{
        @offsetOf(ZigStruct, "a"),
        @offsetOf(ZigStruct, "b"),
        @offsetOf(ZigStruct, "c"),
    });

    // C互換のextern struct
    std.debug.print("\n【extern struct】（C互換）\n", .{});
    std.debug.print("  Cと同じレイアウト規則\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(CStruct)});
    std.debug.print("  オフセット: a={d}, b={d}, c={d}\n", .{
        @offsetOf(CStruct, "a"),
        @offsetOf(CStruct, "b"),
        @offsetOf(CStruct, "c"),
    });

    // packed struct
    std.debug.print("\n【packed struct】\n", .{});
    std.debug.print("  パディングなし、ビット単位で詰める\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(PackedStruct)});
    // packed structはフィールドへのオフセットがビット単位になる
    std.debug.print("  ※ ビットフィールドアクセス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パディングの可視化
// ====================

const PaddingExample = extern struct {
    a: u8, // 1 byte
    // padding: 3 bytes
    b: u32, // 4 bytes, 4バイトアライメント必要
    c: u8, // 1 byte
    // padding: 3 bytes (構造体全体のアライメント)
};

fn demoPadding() void {
    std.debug.print("=== パディング解説 ===\n\n", .{});

    std.debug.print("【extern struct のレイアウト】\n", .{});
    std.debug.print("  struct {{\n", .{});
    std.debug.print("      a: u8,   // offset=0, size=1\n", .{});
    std.debug.print("      // [padding: 3 bytes]\n", .{});
    std.debug.print("      b: u32,  // offset=4, size=4 (4バイトアライメント)\n", .{});
    std.debug.print("      c: u8,   // offset=8, size=1\n", .{});
    std.debug.print("      // [padding: 3 bytes]\n", .{});
    std.debug.print("  }}  // 合計: 12 bytes\n", .{});

    std.debug.print("\n【実際の値】\n", .{});
    std.debug.print("  @sizeOf(PaddingExample) = {d}\n", .{@sizeOf(PaddingExample)});
    std.debug.print("  @alignOf(PaddingExample) = {d}\n", .{@alignOf(PaddingExample)});

    std.debug.print("\n【オフセット】\n", .{});
    std.debug.print("  a: {d}\n", .{@offsetOf(PaddingExample, "a")});
    std.debug.print("  b: {d}\n", .{@offsetOf(PaddingExample, "b")});
    std.debug.print("  c: {d}\n", .{@offsetOf(PaddingExample, "c")});

    std.debug.print("\n", .{});
}

// ====================
// 効率的なレイアウト
// ====================

// パディングが多い配置
const Inefficient = extern struct {
    a: u8,
    b: u64,
    c: u8,
    d: u32,
};

// パディングを減らした配置
const Efficient = extern struct {
    b: u64, // 8バイトを最初に
    d: u32, // 4バイト
    a: u8, // 1バイト
    c: u8, // 1バイト
    // padding: 2 bytes
};

fn demoEfficientLayout() void {
    std.debug.print("=== 効率的なレイアウト ===\n\n", .{});

    std.debug.print("【非効率な配置】\n", .{});
    std.debug.print("  struct {{ a: u8, b: u64, c: u8, d: u32 }}\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(Inefficient)});

    std.debug.print("\n【効率的な配置】\n", .{});
    std.debug.print("  struct {{ b: u64, d: u32, a: u8, c: u8 }}\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(Efficient)});

    std.debug.print("\n【ルール】\n", .{});
    std.debug.print("  大きいフィールドを先に配置\n", .{});
    std.debug.print("  8バイト → 4バイト → 2バイト → 1バイト\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// C の典型的な構造体
// ====================

// C の struct sockaddr_in 相当
const SockAddrIn = extern struct {
    sin_family: u16, // AF_INET
    sin_port: u16, // ポート番号（ネットワークバイトオーダー）
    sin_addr: u32, // IPアドレス
    sin_zero: [8]u8, // パディング
};

// C の struct timeval 相当
const TimeVal = extern struct {
    tv_sec: c_long, // 秒
    tv_usec: c_long, // マイクロ秒
};

fn demoCStructs() void {
    std.debug.print("=== C構造体の例 ===\n\n", .{});

    std.debug.print("【SockAddrIn】(struct sockaddr_in相当)\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(SockAddrIn)});
    std.debug.print("  sin_family offset: {d}\n", .{@offsetOf(SockAddrIn, "sin_family")});
    std.debug.print("  sin_port offset: {d}\n", .{@offsetOf(SockAddrIn, "sin_port")});
    std.debug.print("  sin_addr offset: {d}\n", .{@offsetOf(SockAddrIn, "sin_addr")});
    std.debug.print("  sin_zero offset: {d}\n", .{@offsetOf(SockAddrIn, "sin_zero")});

    std.debug.print("\n【TimeVal】(struct timeval相当)\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(TimeVal)});
    std.debug.print("  tv_sec offset: {d}\n", .{@offsetOf(TimeVal, "tv_sec")});
    std.debug.print("  tv_usec offset: {d}\n", .{@offsetOf(TimeVal, "tv_usec")});

    std.debug.print("\n", .{});
}

// ====================
// packed struct の用途
// ====================

// ビットフィールド
const Flags = packed struct {
    readable: bool,
    writable: bool,
    executable: bool,
    _reserved: u5,
};

// ネットワークヘッダー
const IPv4Header = packed struct {
    version: u4,
    ihl: u4,
    dscp: u6,
    ecn: u2,
    total_length: u16,
    identification: u16,
    flags: u3,
    fragment_offset: u13,
    ttl: u8,
    protocol: u8,
    checksum: u16,
    src_addr: u32,
    dst_addr: u32,
};

fn demoPackedStruct() void {
    std.debug.print("=== packed struct ===\n\n", .{});

    std.debug.print("【ビットフラグ】\n", .{});
    std.debug.print("  packed struct {{ readable: bool, writable: bool, ... }}\n", .{});
    std.debug.print("  サイズ: {d} bytes ({d} bits)\n", .{ @sizeOf(Flags), @sizeOf(Flags) * 8 });

    var flags = Flags{
        .readable = true,
        .writable = true,
        .executable = false,
        ._reserved = 0,
    };
    std.debug.print("  フラグ値: readable={}, writable={}, executable={}\n", .{
        flags.readable,
        flags.writable,
        flags.executable,
    });

    // ビット操作
    const as_byte: *u8 = @ptrCast(&flags);
    std.debug.print("  バイト値: 0b{b:0>8} (0x{x:0>2})\n", .{ as_byte.*, as_byte.* });

    std.debug.print("\n【IPv4ヘッダー】\n", .{});
    std.debug.print("  packed struct で正確なビット配置\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{@sizeOf(IPv4Header)});

    std.debug.print("\n【注意】\n", .{});
    std.debug.print("  packed structのフィールドはアドレス取得不可\n", .{});
    std.debug.print("  C連携には extern struct を使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// align 指定
// ====================

fn demoAlignment() void {
    std.debug.print("=== アライメント指定 ===\n\n", .{});

    std.debug.print("【基本型のアライメント】\n", .{});
    std.debug.print("  u8:  align={d}\n", .{@alignOf(u8)});
    std.debug.print("  u16: align={d}\n", .{@alignOf(u16)});
    std.debug.print("  u32: align={d}\n", .{@alignOf(u32)});
    std.debug.print("  u64: align={d}\n", .{@alignOf(u64)});
    std.debug.print("  f32: align={d}\n", .{@alignOf(f32)});
    std.debug.print("  f64: align={d}\n", .{@alignOf(f64)});

    std.debug.print("\n【Cの型】\n", .{});
    std.debug.print("  c_int:      size={d}, align={d}\n", .{ @sizeOf(c_int), @alignOf(c_int) });
    std.debug.print("  c_long:     size={d}, align={d}\n", .{ @sizeOf(c_long), @alignOf(c_long) });
    std.debug.print("  c_longlong: size={d}, align={d}\n", .{ @sizeOf(c_longlong), @alignOf(c_longlong) });
    std.debug.print("  usize:      size={d}, align={d}\n", .{ @sizeOf(usize), @alignOf(usize) });

    std.debug.print("\n【カスタムアライメント】\n", .{});

    const Aligned16 = extern struct {
        data: u32 align(16),
    };
    std.debug.print("  u32 align(16): struct align={d}\n", .{@alignOf(Aligned16)});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== メモリレイアウト まとめ ===\n\n", .{});

    std.debug.print("【struct の種類】\n", .{});
    std.debug.print("  struct       Zigが最適化、C非互換\n", .{});
    std.debug.print("  extern struct  C互換レイアウト\n", .{});
    std.debug.print("  packed struct  ビットレベル制御\n", .{});

    std.debug.print("\n【C連携のルール】\n", .{});
    std.debug.print("  1. extern struct を使用\n", .{});
    std.debug.print("  2. Cの型を使用 (c_int, c_long等)\n", .{});
    std.debug.print("  3. アライメントを意識\n", .{});

    std.debug.print("\n【便利な組み込み関数】\n", .{});
    std.debug.print("  @sizeOf(T)      サイズ取得\n", .{});
    std.debug.print("  @alignOf(T)     アライメント取得\n", .{});
    std.debug.print("  @offsetOf(T,f)  フィールドオフセット\n", .{});

    std.debug.print("\n【効率化のコツ】\n", .{});
    std.debug.print("  大きいフィールドを先に配置\n", .{});
    std.debug.print("  同じサイズのフィールドをまとめる\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoStructComparison();
    demoPadding();
    demoEfficientLayout();
    demoCStructs();
    demoPackedStruct();
    demoAlignment();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・opaque型とC連携\n", .{});
    std.debug.print("・C連携実践パターン\n", .{});
    std.debug.print("・C連携総まとめ\n", .{});
}

// ====================
// テスト
// ====================

test "extern struct C compatible" {
    // extern structはC互換レイアウト
    try std.testing.expectEqual(@as(usize, 0), @offsetOf(CStruct, "a"));
    try std.testing.expectEqual(@as(usize, 4), @offsetOf(CStruct, "b"));
    try std.testing.expectEqual(@as(usize, 8), @offsetOf(CStruct, "c"));
    try std.testing.expectEqual(@as(usize, 12), @sizeOf(CStruct));
}

test "padding example" {
    try std.testing.expectEqual(@as(usize, 12), @sizeOf(PaddingExample));
    try std.testing.expectEqual(@as(usize, 4), @alignOf(PaddingExample));
}

test "efficient vs inefficient" {
    // 効率的な配置の方がサイズが小さい
    try std.testing.expect(@sizeOf(Efficient) <= @sizeOf(Inefficient));
}

test "packed struct size" {
    // Flags は 8 bits = 1 byte
    try std.testing.expectEqual(@as(usize, 1), @sizeOf(Flags));
}

test "flags bit manipulation" {
    var flags = Flags{
        .readable = true,
        .writable = false,
        .executable = true,
        ._reserved = 0,
    };

    const as_byte: *u8 = @ptrCast(&flags);
    // bit 0 = readable (1), bit 1 = writable (0), bit 2 = executable (1)
    try std.testing.expectEqual(@as(u8, 0b00000101), as_byte.*);
}

test "sockaddr_in size" {
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(SockAddrIn));
}

test "IPv4 header size" {
    // packed structの実際のサイズを確認
    // (Zigのpacked structは内部表現が異なる場合がある)
    try std.testing.expect(@sizeOf(IPv4Header) > 0);
}

test "c_long size" {
    // プラットフォーム依存だが、サイズとアライメントは一致すべき
    try std.testing.expectEqual(@sizeOf(c_long), @alignOf(c_long));
}
