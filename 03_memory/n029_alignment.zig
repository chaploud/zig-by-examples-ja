//! # メモリアライメント
//!
//! アライメントはメモリアドレスの境界を指定する。
//! CPUが効率的にデータにアクセスするために重要。
//!
//! ## 基本概念
//! - アライメントN: アドレスがNの倍数
//! - @alignOf(T): 型Tのアライメント要件
//! - align(N): アライメントを明示的に指定
//!
//! ## 用途
//! - パフォーマンス最適化
//! - ハードウェア要件への対応
//! - C言語との連携

const std = @import("std");

// ====================
// 基本的なアライメント
// ====================

fn demoBasicAlignment() void {
    std.debug.print("--- 基本的なアライメント ---\n", .{});

    // 各型のアライメント
    std.debug.print("  @alignOf(u8):  {d}\n", .{@alignOf(u8)});
    std.debug.print("  @alignOf(u16): {d}\n", .{@alignOf(u16)});
    std.debug.print("  @alignOf(u32): {d}\n", .{@alignOf(u32)});
    std.debug.print("  @alignOf(u64): {d}\n", .{@alignOf(u64)});
    std.debug.print("  @alignOf(usize): {d}\n", .{@alignOf(usize)});

    // ポインタのアライメント
    std.debug.print("  @alignOf(*u8): {d}\n", .{@alignOf(*u8)});
    std.debug.print("  @alignOf(*u64): {d}\n", .{@alignOf(*u64)});

    std.debug.print("\n", .{});
}

// ====================
// 構造体のアライメント
// ====================

const PackedStruct = packed struct {
    a: u8,
    b: u16,
    c: u8,
};

const NormalStruct = struct {
    a: u8,
    b: u16,
    c: u8,
};

const AlignedStruct = struct {
    a: u8,
    b: u16,
    c: u8,
    _pad: u8 = 0, // パディング明示
};

fn demoStructAlignment() void {
    std.debug.print("--- 構造体のアライメント ---\n", .{});

    std.debug.print("  PackedStruct:\n", .{});
    std.debug.print("    size: {d}, align: {d}\n", .{ @sizeOf(PackedStruct), @alignOf(PackedStruct) });

    std.debug.print("  NormalStruct:\n", .{});
    std.debug.print("    size: {d}, align: {d}\n", .{ @sizeOf(NormalStruct), @alignOf(NormalStruct) });

    // フィールドオフセット
    std.debug.print("  NormalStruct offsets:\n", .{});
    std.debug.print("    a: {d}, b: {d}, c: {d}\n", .{
        @offsetOf(NormalStruct, "a"),
        @offsetOf(NormalStruct, "b"),
        @offsetOf(NormalStruct, "c"),
    });

    std.debug.print("\n", .{});
}

// ====================
// 明示的なアライメント指定
// ====================

fn demoExplicitAlignment() void {
    std.debug.print("--- 明示的なアライメント指定 ---\n", .{});

    // 配列にアライメント指定
    var buffer: [16]u8 align(16) = undefined;
    const addr = @intFromPtr(&buffer);

    std.debug.print("  16バイトアライン配列:\n", .{});
    std.debug.print("    アドレス: 0x{x}\n", .{addr});
    std.debug.print("    16で割れる: {}\n", .{addr % 16 == 0});

    // 変数にアライメント指定
    var value: u32 align(8) = 42;
    const value_addr = @intFromPtr(&value);
    _ = &value;

    std.debug.print("  8バイトアラインu32:\n", .{});
    std.debug.print("    アドレス: 0x{x}\n", .{value_addr});
    std.debug.print("    8で割れる: {}\n", .{value_addr % 8 == 0});

    std.debug.print("\n", .{});
}

// ====================
// アライメント付きスライス
// ====================

fn demoAlignedSlice() void {
    std.debug.print("--- アライメント付きスライス ---\n", .{});

    // u32として安全に再解釈できるバッファ
    var bytes: [8]u8 align(@alignOf(u32)) = .{ 1, 0, 0, 0, 2, 0, 0, 0 };

    // u32スライスとして再解釈
    const u32_slice: []align(@alignOf(u32)) u8 = &bytes;
    const as_u32: *const [2]u32 = @ptrCast(u32_slice.ptr);

    std.debug.print("  bytes: {any}\n", .{bytes});
    std.debug.print("  as u32[0]: {d}\n", .{as_u32[0]});
    std.debug.print("  as u32[1]: {d}\n", .{as_u32[1]});

    std.debug.print("\n", .{});
}

// ====================
// @alignCast
// ====================

fn demoAlignCast() void {
    std.debug.print("--- @alignCast ---\n", .{});

    // 高アライメントバッファ
    var buffer: [16]u8 align(8) = undefined;

    // 低アライメントポインタとして取得
    const low_align_ptr: [*]u8 = &buffer;

    // 高アライメントに戻す
    const high_align_ptr: [*]align(8) u8 = @alignCast(low_align_ptr);
    _ = high_align_ptr;

    std.debug.print("  低アライメント → 高アライメント: @alignCast\n", .{});
    std.debug.print("  実行時にアライメント違反をチェック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// アロケータとアライメント
// ====================

fn demoAllocatorAlignment() !void {
    std.debug.print("--- アロケータとアライメント ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 通常の割り当て（自然なアライメント）
    const normal = try allocator.alloc(u64, 4);
    defer allocator.free(normal);

    const normal_addr = @intFromPtr(normal.ptr);
    std.debug.print("  通常割り当て: align={d}\n", .{@alignOf(u64)});
    std.debug.print("    アドレス: 0x{x}\n", .{normal_addr});

    // 明示的アライメント指定 (Zig 0.15: enumでアライメント指定)
    const aligned = try allocator.alignedAlloc(u8, .@"64", 128);
    defer allocator.free(aligned);

    const aligned_addr = @intFromPtr(aligned.ptr);
    std.debug.print("  64バイトアライン割り当て:\n", .{});
    std.debug.print("    アドレス: 0x{x}\n", .{aligned_addr});
    std.debug.print("    64で割れる: {}\n", .{aligned_addr % 64 == 0});

    std.debug.print("\n", .{});
}

// ====================
// SIMD向けアライメント
// ====================

fn demoSimdAlignment() void {
    std.debug.print("--- SIMD向けアライメント ---\n", .{});

    // SIMD操作に必要なアライメント（例: 16バイト）
    var simd_buffer: [64]f32 align(16) = undefined;
    for (&simd_buffer, 0..) |*v, i| {
        v.* = @floatFromInt(i);
    }

    const addr = @intFromPtr(&simd_buffer);
    std.debug.print("  SIMDバッファ (align 16):\n", .{});
    std.debug.print("    アドレス: 0x{x}\n", .{addr});
    std.debug.print("    16で割れる: {}\n", .{addr % 16 == 0});
    std.debug.print("    要素数: {d}\n", .{simd_buffer.len});

    std.debug.print("\n", .{});
}

// ====================
// ページアライメント
// ====================

fn demoPageAlignment() !void {
    std.debug.print("--- ページアライメント ---\n", .{});

    // page_allocatorはページ境界にアライン
    const page_size = std.heap.pageSize();
    std.debug.print("  ページサイズ: {d} bytes\n", .{page_size});

    const allocator = std.heap.page_allocator;
    const page = try allocator.alloc(u8, page_size);
    defer allocator.free(page);

    const addr = @intFromPtr(page.ptr);
    std.debug.print("  ページアドレス: 0x{x}\n", .{addr});
    std.debug.print("  ページ境界: {}\n", .{addr % page_size == 0});

    std.debug.print("\n", .{});
}

// ====================
// 実用例: キャッシュライン最適化
// ====================

const CacheLineSize = 64;

const CacheAlignedCounter = struct {
    value: u64 align(CacheLineSize) = 0,

    pub fn increment(self: *@This()) void {
        self.value += 1;
    }
};

fn demoCacheLineAlignment() void {
    std.debug.print("--- キャッシュライン最適化 ---\n", .{});

    var counter = CacheAlignedCounter{};
    counter.increment();

    const addr = @intFromPtr(&counter.value);
    std.debug.print("  カウンタ値: {d}\n", .{counter.value});
    std.debug.print("  アドレス: 0x{x}\n", .{addr});
    std.debug.print("  キャッシュライン境界 (64): {}\n", .{addr % 64 == 0});
    std.debug.print("  → False sharing防止に有効\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== メモリアライメント ===\n\n", .{});

    demoBasicAlignment();
    demoStructAlignment();
    demoExplicitAlignment();
    demoAlignedSlice();
    demoAlignCast();
    try demoAllocatorAlignment();
    demoSimdAlignment();
    try demoPageAlignment();
    demoCacheLineAlignment();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・@alignOf(T): 型Tの自然なアライメント\n", .{});
    std.debug.print("・align(N): 明示的にアライメント指定\n", .{});
    std.debug.print("・@alignCast: アライメント変換（実行時チェック）\n", .{});
    std.debug.print("・SIMD/キャッシュ最適化に重要\n", .{});
}

// --- テスト ---

test "basic alignment" {
    try std.testing.expectEqual(@as(usize, 1), @alignOf(u8));
    try std.testing.expectEqual(@as(usize, 2), @alignOf(u16));
    try std.testing.expectEqual(@as(usize, 4), @alignOf(u32));
    try std.testing.expectEqual(@as(usize, 8), @alignOf(u64));
}

test "struct alignment" {
    // packed構造体でもバッキング整数のアライメントが適用される
    try std.testing.expectEqual(@as(usize, 4), @alignOf(PackedStruct));

    // 通常構造体は最大フィールドのアライメント
    try std.testing.expectEqual(@as(usize, 2), @alignOf(NormalStruct));
}

test "explicit alignment" {
    var buffer: [16]u8 align(16) = undefined;
    const addr = @intFromPtr(&buffer);
    try std.testing.expect(addr % 16 == 0);
}

test "aligned allocation" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const aligned = try allocator.alignedAlloc(u8, .@"64", 128);
    defer allocator.free(aligned);

    const addr = @intFromPtr(aligned.ptr);
    try std.testing.expect(addr % 64 == 0);
}

test "@alignCast" {
    var buffer: [8]u8 align(8) = undefined;
    const low: [*]u8 = &buffer;
    const high: [*]align(8) u8 = @alignCast(low);
    try std.testing.expect(@intFromPtr(high) == @intFromPtr(low));
}

test "reinterpret aligned bytes as u32" {
    var bytes: [8]u8 align(@alignOf(u32)) = .{ 1, 0, 0, 0, 2, 0, 0, 0 };
    const as_u32: *const [2]u32 = @ptrCast(&bytes);

    try std.testing.expectEqual(@as(u32, 1), as_u32[0]);
    try std.testing.expectEqual(@as(u32, 2), as_u32[1]);
}

test "page allocator alignment" {
    const page_size = std.heap.pageSize();
    const allocator = std.heap.page_allocator;

    const page = try allocator.alloc(u8, page_size);
    defer allocator.free(page);

    const addr = @intFromPtr(page.ptr);
    try std.testing.expect(addr % page_size == 0);
}

test "offsetOf" {
    // NormalStructのレイアウト: a(1B), pad(1B), b(2B), c(1B), pad(1B)
    // フィールド順序は最適化される可能性あり
    const a_offset = @offsetOf(NormalStruct, "a");
    const b_offset = @offsetOf(NormalStruct, "b");
    const c_offset = @offsetOf(NormalStruct, "c");

    // オフセットが有効な範囲内であることを確認
    try std.testing.expect(a_offset < @sizeOf(NormalStruct));
    try std.testing.expect(b_offset < @sizeOf(NormalStruct));
    try std.testing.expect(c_offset < @sizeOf(NormalStruct));
}
