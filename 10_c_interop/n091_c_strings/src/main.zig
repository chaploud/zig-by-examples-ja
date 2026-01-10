//! # C文字列とZig文字列の変換
//!
//! CとZig間での文字列の相互変換テクニック。
//!
//! ## このファイルで学ぶこと
//! - Zig文字列とC文字列の違い
//! - std.mem.span() でC文字列をZigスライスに
//! - std.mem.sliceTo() でセンチネルまでスライス
//! - ヌル終端の追加方法
//! - アロケータを使った変換

const std = @import("std");

const c = @cImport({
    @cInclude("string.h");
    @cInclude("stdlib.h");
});

// ====================
// Zig文字列 vs C文字列
// ====================

fn demoStringDifferences() void {
    std.debug.print("=== Zig文字列 vs C文字列 ===\n\n", .{});

    std.debug.print("【Zig文字列 (スライス)】\n", .{});
    std.debug.print("  型: []const u8\n", .{});
    std.debug.print("  構成: ポインタ + 長さ\n", .{});
    std.debug.print("  ヌル終端: 不要\n", .{});

    std.debug.print("\n【C文字列】\n", .{});
    std.debug.print("  型: char*, const char*\n", .{});
    std.debug.print("  構成: ポインタのみ（長さは'\\0'で判定）\n", .{});
    std.debug.print("  ヌル終端: 必須\n", .{});

    std.debug.print("\n【Zigの文字列リテラル】\n", .{});
    const literal = "Hello";
    std.debug.print("  型: *const [5:0]u8  (長さ5、ヌル終端付き)\n", .{});
    std.debug.print("  値: \"{s}\"\n", .{literal});
    std.debug.print("  長さ: {d}\n", .{literal.len});
    std.debug.print("  literal[5] = {d} (ヌル文字)\n", .{literal[5]});

    std.debug.print("\n【重要】Zigリテラルはヌル終端付きなので\n", .{});
    std.debug.print("  Cに直接渡せる場合が多い\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Zig → C への変換
// ====================

fn demoZigToC() void {
    std.debug.print("=== Zig → C 変換 ===\n\n", .{});

    // 方法1: 文字列リテラルはそのまま使える
    std.debug.print("【方法1: リテラルをそのまま渡す】\n", .{});
    const literal: [*:0]const u8 = "Hello, World!";
    const len1 = c.strlen(literal);
    std.debug.print("  strlen(\"Hello, World!\") = {d}\n", .{len1});

    // 方法2: スライスの .ptr を使う
    std.debug.print("\n【方法2: スライスの .ptr】\n", .{});
    // 注意: リテラルなので実際にはヌル終端あり
    // 一般のスライスではヌル終端が保証されない
    std.debug.print("  slice.ptr を使用\n", .{});
    std.debug.print("  注意: スライスはヌル終端を保証しない\n", .{});

    // 方法3: センチネル終端スライス
    std.debug.print("\n【方法3: センチネル終端スライス】\n", .{});
    const sentinel_slice: [:0]const u8 = "Hello";
    const len3 = c.strlen(sentinel_slice.ptr);
    std.debug.print("  [:0]const u8 型はヌル終端を保証\n", .{});
    std.debug.print("  strlen(sentinel_slice.ptr) = {d}\n", .{len3});

    // 方法4: 配列をヌル終端付きにキャスト
    std.debug.print("\n【方法4: 配列 → センチネルポインタ】\n", .{});
    var buf: [10]u8 = undefined;
    @memcpy(buf[0..5], "Hello");
    buf[5] = 0;
    const c_str: [*:0]u8 = buf[0..5 :0];
    const len4 = c.strlen(c_str);
    std.debug.print("  手動でヌル終端を付けてキャスト\n", .{});
    std.debug.print("  strlen = {d}\n", .{len4});

    std.debug.print("\n", .{});
}

// ====================
// C → Zig への変換
// ====================

fn demoCToZig() void {
    std.debug.print("=== C → Zig 変換 ===\n\n", .{});

    // C文字列（ヌル終端）
    const c_str: [*:0]const u8 = "Hello from C!";

    // 方法1: std.mem.span() - センチネルまでスライス
    std.debug.print("【方法1: std.mem.span()】\n", .{});
    const span_result = std.mem.span(c_str);
    std.debug.print("  型: [:0]const u8\n", .{});
    std.debug.print("  値: \"{s}\"\n", .{span_result});
    std.debug.print("  長さ: {d}\n", .{span_result.len});

    // 方法2: センチネルポインタからスライス
    std.debug.print("\n【方法2: センチネルポインタ】\n", .{});
    const sentinel_ptr: [*:0]const u8 = c_str;
    const slice_to = std.mem.span(sentinel_ptr);
    std.debug.print("  [*:0]const u8 は std.mem.span() で変換\n", .{});
    std.debug.print("  値: \"{s}\"\n", .{slice_to});

    // 方法3: 長さを指定してスライス
    std.debug.print("\n【方法3: 長さ指定スライス】\n", .{});
    const len = c.strlen(c_str);
    const fixed_slice = c_str[0..len];
    std.debug.print("  strlen()で長さを取得してスライス\n", .{});
    std.debug.print("  値: \"{s}\"\n", .{fixed_slice});
    std.debug.print("  長さ: {d}\n", .{fixed_slice.len});

    std.debug.print("\n", .{});
}

// ====================
// アロケータを使った変換
// ====================

fn demoAllocatorConversion(allocator: std.mem.Allocator) !void {
    std.debug.print("=== アロケータを使った変換 ===\n\n", .{});

    // Zigスライス → ヌル終端付きコピー
    std.debug.print("【allocator.dupeZ() - ヌル終端付き複製】\n", .{});
    const original: []const u8 = "Hello, Zig!";
    const c_copy = try allocator.dupeZ(u8, original);
    defer allocator.free(c_copy);

    std.debug.print("  元: \"{s}\" (長さ{d})\n", .{ original, original.len });
    std.debug.print("  複製: \"{s}\" (長さ{d})\n", .{ c_copy, c_copy.len });
    std.debug.print("  c_copy[{d}] = {d} (ヌル終端)\n", .{ c_copy.len, c_copy[c_copy.len] });

    // フォーマット付きで生成
    std.debug.print("\n【allocPrintSentinel() - フォーマット生成】\n", .{});
    const name = "World";
    const formatted = try std.fmt.allocPrintSentinel(allocator, "Hello, {s}!", .{name}, 0);
    defer allocator.free(formatted);
    std.debug.print("  結果: \"{s}\"\n", .{formatted});

    // C文字列 → Zigスライス（コピー）
    std.debug.print("\n【allocator.dupe() - コピー】\n", .{});
    const c_str: [*:0]const u8 = "C String";
    const span = std.mem.span(c_str);
    const zig_copy = try allocator.dupe(u8, span);
    defer allocator.free(zig_copy);
    std.debug.print("  C文字列をZigスライスにコピー\n", .{});
    std.debug.print("  結果: \"{s}\"\n", .{zig_copy});

    std.debug.print("\n", .{});
}

// ====================
// よくあるパターン
// ====================

fn demoCommonPatterns() void {
    std.debug.print("=== よくあるパターン ===\n\n", .{});

    // パターン1: Cの関数にリテラルを渡す
    std.debug.print("【パターン1: リテラル直接渡し】\n", .{});
    std.debug.print("  c.strlen(\"Hello\")  // OK\n", .{});
    std.debug.print("  c.printf(\"%%s\", \"World\")  // OK\n", .{});

    // パターン2: バッファを渡して結果を受け取る
    std.debug.print("\n【パターン2: 出力バッファ】\n", .{});
    var buf: [256]u8 = undefined;
    const src: [*:0]const u8 = "Source";
    _ = c.strcpy(&buf, src);
    const result = std.mem.span(@as([*:0]u8, @ptrCast(&buf)));
    std.debug.print("  strcpy後: \"{s}\"\n", .{result});

    // パターン3: 条件付きヌル終端チェック
    std.debug.print("\n【パターン3: Optionalポインタ】\n", .{});
    const maybe_str: ?[*:0]const u8 = "Hello";
    if (maybe_str) |str| {
        const span = std.mem.span(str);
        std.debug.print("  値あり: \"{s}\"\n", .{span});
    } else {
        std.debug.print("  NULL\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 型の対応表
// ====================

fn demoTypeMapping() void {
    std.debug.print("=== 文字列型の対応表 ===\n\n", .{});

    std.debug.print("【Zig型 → C型】\n", .{});
    std.debug.print("  []const u8       →  (長さ必要)\n", .{});
    std.debug.print("  [:0]const u8     →  const char*\n", .{});
    std.debug.print("  [*:0]const u8    →  const char*\n", .{});
    std.debug.print("  [*]const u8      →  const char* (長さ必要)\n", .{});

    std.debug.print("\n【C型 → Zig型】\n", .{});
    std.debug.print("  const char*      →  [*:0]const u8 / ?[*:0]const u8\n", .{});
    std.debug.print("  char*            →  [*:0]u8 / ?[*:0]u8\n", .{});
    std.debug.print("  char[N]          →  [N]u8\n", .{});

    std.debug.print("\n【変換関数】\n", .{});
    std.debug.print("  std.mem.span()        C文字列 → [:0]スライス\n", .{});
    std.debug.print("  std.mem.sliceTo()     [*] → センチネル付きスライス\n", .{});
    std.debug.print("  allocator.dupeZ()     スライス → ヌル終端付きコピー\n", .{});
    std.debug.print("  std.fmt.allocPrintSentinel() フォーマット → センチネル文字列\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 注意点 ===\n\n", .{});

    std.debug.print("【ヌル終端の保証】\n", .{});
    std.debug.print("  []const u8 : ヌル終端なし\n", .{});
    std.debug.print("  [:0]const u8 : ヌル終端あり（Zig保証）\n", .{});
    std.debug.print("  [*:0]const u8 : ヌル終端あり\n", .{});

    std.debug.print("\n【バッファサイズ】\n", .{});
    std.debug.print("  C文字列をコピーする時は +1 (ヌル文字分)\n", .{});
    std.debug.print("  バッファ[N] に入れる時は最大N-1文字\n", .{});

    std.debug.print("\n【メモリ管理】\n", .{});
    std.debug.print("  Cからの戻り値は要確認:\n", .{});
    std.debug.print("    - 静的バッファ: free不要\n", .{});
    std.debug.print("    - malloc確保: c.free()必要\n", .{});
    std.debug.print("    - Zigでdupe: allocator.free()必要\n", .{});

    std.debug.print("\n【エンコーディング】\n", .{});
    std.debug.print("  Zig: UTF-8前提\n", .{});
    std.debug.print("  C: ロケール依存（通常ASCII/UTF-8）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== C文字列変換 まとめ ===\n\n", .{});

    std.debug.print("【Zig → C】\n", .{});
    std.debug.print("  リテラル: そのまま渡せる\n", .{});
    std.debug.print("  スライス: .ptrを使う（ヌル終端注意）\n", .{});
    std.debug.print("  安全に: allocator.dupeZ()\n", .{});

    std.debug.print("\n【C → Zig】\n", .{});
    std.debug.print("  std.mem.span() が最も簡単\n", .{});
    std.debug.print("  コピー必要なら allocator.dupe()\n", .{});

    std.debug.print("\n【推奨プラクティス】\n", .{});
    std.debug.print("  1. 可能なら [:0]const u8 を使う\n", .{});
    std.debug.print("  2. バッファは余裕を持って確保\n", .{});
    std.debug.print("  3. メモリ管理を明確に\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    demoStringDifferences();
    demoZigToC();
    demoCToZig();
    try demoAllocatorConversion(allocator);
    demoCommonPatterns();
    demoTypeMapping();
    demoCaveats();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・メモリレイアウトとアライメント\n", .{});
    std.debug.print("・構造体のパッキング\n", .{});
    std.debug.print("・C連携総まとめ\n", .{});
}

// ====================
// テスト
// ====================

test "string literal to C" {
    const literal: [*:0]const u8 = "Hello";
    const len = c.strlen(literal);
    try std.testing.expectEqual(@as(usize, 5), len);
}

test "std.mem.span" {
    const c_str: [*:0]const u8 = "Hello, World!";
    const span = std.mem.span(c_str);
    try std.testing.expectEqualStrings("Hello, World!", span);
    try std.testing.expectEqual(@as(usize, 13), span.len);
}

test "sentinel pointer" {
    const c_str: [*:0]const u8 = "Hello";
    const span = std.mem.span(c_str);
    try std.testing.expectEqualStrings("Hello", span);
}

test "allocator.dupeZ" {
    const allocator = std.testing.allocator;
    const original: []const u8 = "Hello";
    const c_copy = try allocator.dupeZ(u8, original);
    defer allocator.free(c_copy);

    try std.testing.expectEqual(@as(usize, 5), c_copy.len);
    try std.testing.expectEqual(@as(u8, 0), c_copy[c_copy.len]);
    try std.testing.expectEqualStrings("Hello", c_copy);
}

test "manual null termination" {
    var buf: [10]u8 = undefined;
    @memcpy(buf[0..5], "Hello");
    buf[5] = 0;
    const c_str: [*:0]u8 = buf[0..5 :0];
    const span = std.mem.span(c_str);
    try std.testing.expectEqualStrings("Hello", span);
}

test "strcpy and span" {
    var buf: [256]u8 = undefined;
    const src: [*:0]const u8 = "Test";
    _ = c.strcpy(&buf, src);
    const result = std.mem.span(@as([*:0]u8, @ptrCast(&buf)));
    try std.testing.expectEqualStrings("Test", result);
}

test "allocPrintSentinel" {
    const allocator = std.testing.allocator;
    const result = try std.fmt.allocPrintSentinel(allocator, "Hello, {s}!", .{"World"}, 0);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello, World!", result);
}

test "sentinel slice" {
    const sentinel: [:0]const u8 = "Hello";
    try std.testing.expectEqual(@as(usize, 5), sentinel.len);
    try std.testing.expectEqual(@as(u8, 0), sentinel[sentinel.len]);

    const len = c.strlen(sentinel.ptr);
    try std.testing.expectEqual(@as(usize, 5), len);
}
