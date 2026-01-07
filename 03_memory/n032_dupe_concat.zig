//! # dupe と concat
//!
//! メモリのコピーと結合を行うユーティリティ関数。
//! アロケータを使った安全なメモリ操作。
//!
//! ## 主な関数
//! - dupe: スライスをコピー
//! - dupeZ: ゼロ終端付きでコピー
//! - concat: 複数スライスを結合
//! - join: セパレータで結合
//!
//! ## 所有権
//! 返されたメモリは呼び出し側がfree責任を持つ

const std = @import("std");

// ====================
// dupe（コピー）
// ====================

fn demoDupe() !void {
    std.debug.print("--- dupe（コピー） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 文字列のコピー
    const original = "Hello, Zig!";
    const copy = try allocator.dupe(u8, original);
    defer allocator.free(copy);

    std.debug.print("  元: {s}\n", .{original});
    std.debug.print("  コピー: {s}\n", .{copy});

    // 異なるポインタ
    std.debug.print("  元アドレス: 0x{x}\n", .{@intFromPtr(original.ptr)});
    std.debug.print("  コピーアドレス: 0x{x}\n", .{@intFromPtr(copy.ptr)});

    // 数値配列のコピー
    const nums = [_]i32{ 1, 2, 3, 4, 5 };
    const nums_copy = try allocator.dupe(i32, &nums);
    defer allocator.free(nums_copy);

    std.debug.print("  数値コピー: ", .{});
    for (nums_copy) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// dupeZ（ゼロ終端付き）
// ====================

fn demoDupeZ() !void {
    std.debug.print("--- dupeZ（ゼロ終端付き） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 通常のスライスからゼロ終端付きに
    const slice: []const u8 = "Hello";
    const sentinel = try allocator.dupeZ(u8, slice);
    defer allocator.free(sentinel);

    std.debug.print("  スライス: {s} (len={d})\n", .{ slice, slice.len });
    std.debug.print("  センチネル: {s} (len={d})\n", .{ sentinel, sentinel.len });
    std.debug.print("  終端値: {d}\n", .{sentinel[sentinel.len]});

    // C関数への渡し方
    const c_str: [*:0]const u8 = sentinel.ptr;
    _ = c_str; // C関数に渡せる
    std.debug.print("  → [*:0]const u8 としてCに渡せる\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// concat（結合）
// ====================

fn demoConcat() !void {
    std.debug.print("--- concat（結合） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 文字列の結合
    const parts: []const []const u8 = &.{ "Hello", ", ", "Zig", "!" };
    const combined = try std.mem.concat(allocator, u8, parts);
    defer allocator.free(combined);

    std.debug.print("  パーツ: ", .{});
    for (parts) |p| {
        std.debug.print("\"{s}\" ", .{p});
    }
    std.debug.print("\n", .{});
    std.debug.print("  結合: {s}\n", .{combined});

    // 数値配列の結合
    const nums1 = [_]i32{ 1, 2, 3 };
    const nums2 = [_]i32{ 4, 5, 6 };
    const nums_combined = try std.mem.concat(allocator, i32, &.{ &nums1, &nums2 });
    defer allocator.free(nums_combined);

    std.debug.print("  数値結合: ", .{});
    for (nums_combined) |n| {
        std.debug.print("{d} ", .{n});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// concatWithSentinel（センチネル付き結合）
// ====================

fn demoConcatWithSentinel() !void {
    std.debug.print("--- concatWithSentinel ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parts: []const []const u8 = &.{ "foo", "bar", "baz" };
    const combined = try std.mem.concatWithSentinel(allocator, u8, parts, 0);
    defer allocator.free(combined);

    std.debug.print("  結合: {s} (len={d})\n", .{ combined, combined.len });
    std.debug.print("  センチネル: {d}\n", .{combined[combined.len]});

    std.debug.print("\n", .{});
}

// ====================
// join（セパレータ付き結合）
// ====================

fn demoJoin() !void {
    std.debug.print("--- join（セパレータ付き結合） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // カンマ区切り
    const words: []const []const u8 = &.{ "apple", "banana", "cherry" };
    const csv = try std.mem.join(allocator, ", ", words);
    defer allocator.free(csv);

    std.debug.print("  単語: ", .{});
    for (words) |w| {
        std.debug.print("\"{s}\" ", .{w});
    }
    std.debug.print("\n", .{});
    std.debug.print("  結合（カンマ区切り）: {s}\n", .{csv});

    // パス結合
    const path_parts: []const []const u8 = &.{ "/home", "user", "documents" };
    const path = try std.mem.join(allocator, "/", path_parts);
    defer allocator.free(path);
    std.debug.print("  パス結合: {s}\n", .{path});

    // 空セパレータ
    const no_sep = try std.mem.join(allocator, "", words);
    defer allocator.free(no_sep);
    std.debug.print("  空セパレータ: {s}\n", .{no_sep});

    std.debug.print("\n", .{});
}

// ====================
// joinZ（ゼロ終端付きjoin）
// ====================

fn demoJoinZ() !void {
    std.debug.print("--- joinZ（ゼロ終端付き） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const words: []const []const u8 = &.{ "one", "two", "three" };
    const joined = try std.mem.joinZ(allocator, "-", words);
    defer allocator.free(joined);

    std.debug.print("  結合: {s}\n", .{joined});
    std.debug.print("  センチネル: {d}\n", .{joined[joined.len]});

    std.debug.print("\n", .{});
}

// ====================
// 実用例: 文字列ビルダー
// ====================

fn buildString(allocator: std.mem.Allocator, parts: []const []const u8) ![]u8 {
    return std.mem.concat(allocator, u8, parts);
}

fn demoStringBuilder() !void {
    std.debug.print("--- 文字列ビルダー例 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const name = "World";
    const greeting = try buildString(allocator, &.{ "Hello, ", name, "!" });
    defer allocator.free(greeting);

    std.debug.print("  挨拶: {s}\n", .{greeting});

    // 数値を含む文字列の構築
    const num: i32 = 42;
    var buf: [10]u8 = undefined;
    const num_str = std.fmt.bufPrint(&buf, "{d}", .{num}) catch unreachable;

    const result = try buildString(allocator, &.{ "Answer: ", num_str });
    defer allocator.free(result);

    std.debug.print("  数値含む: {s}\n", .{result});

    std.debug.print("\n", .{});
}

// ====================
// メモリ効率の考慮
// ====================

fn demoMemoryEfficiency() !void {
    std.debug.print("--- メモリ効率の考慮 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 多くの小さな結合より、一度にconcatが効率的
    const parts: []const []const u8 = &.{ "a", "b", "c", "d", "e" };

    // 効率的: 一度の割り当て
    const efficient = try std.mem.concat(allocator, u8, parts);
    defer allocator.free(efficient);

    std.debug.print("  効率的: {s} (1回の割り当て)\n", .{efficient});

    std.debug.print("  → 複数のdupeよりconcatが効率的\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== dupe と concat ===\n\n", .{});

    try demoDupe();
    try demoDupeZ();
    try demoConcat();
    try demoConcatWithSentinel();
    try demoJoin();
    try demoJoinZ();
    try demoStringBuilder();
    try demoMemoryEfficiency();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・dupe: スライスをコピー\n", .{});
    std.debug.print("・dupeZ: ゼロ終端付きコピー\n", .{});
    std.debug.print("・concat: 複数スライスを結合\n", .{});
    std.debug.print("・join: セパレータ付きで結合\n", .{});
    std.debug.print("・返り値は呼び出し側がfree\n", .{});
}

// --- テスト ---

test "dupe string" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const original = "test";
    const copy = try allocator.dupe(u8, original);
    defer allocator.free(copy);

    try std.testing.expect(std.mem.eql(u8, original, copy));
    try std.testing.expect(original.ptr != copy.ptr);
}

test "dupe integers" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const nums = [_]i32{ 1, 2, 3 };
    const copy = try allocator.dupe(i32, &nums);
    defer allocator.free(copy);

    try std.testing.expectEqual(@as(usize, 3), copy.len);
    try std.testing.expectEqual(@as(i32, 1), copy[0]);
    try std.testing.expectEqual(@as(i32, 2), copy[1]);
    try std.testing.expectEqual(@as(i32, 3), copy[2]);
}

test "dupeZ" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sentinel = try allocator.dupeZ(u8, "hello");
    defer allocator.free(sentinel);

    try std.testing.expectEqual(@as(usize, 5), sentinel.len);
    try std.testing.expectEqual(@as(u8, 0), sentinel[5]);
}

test "concat" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parts: []const []const u8 = &.{ "abc", "def" };
    const result = try std.mem.concat(allocator, u8, parts);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, "abcdef", result));
}

test "concat with sentinel" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parts: []const []const u8 = &.{ "abc", "def" };
    const result = try std.mem.concatWithSentinel(allocator, u8, parts, 0);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, "abcdef", result));
    try std.testing.expectEqual(@as(u8, 0), result[result.len]);
}

test "join" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const words: []const []const u8 = &.{ "a", "b", "c" };
    const result = try std.mem.join(allocator, ",", words);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, "a,b,c", result));
}

test "joinZ" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const words: []const []const u8 = &.{ "a", "b" };
    const result = try std.mem.joinZ(allocator, "-", words);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, "a-b", result));
    try std.testing.expectEqual(@as(u8, 0), result[result.len]);
}

test "join empty" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const empty: []const []const u8 = &.{};
    const result = try std.mem.join(allocator, ",", empty);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "join single" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const single: []const []const u8 = &.{"only"};
    const result = try std.mem.join(allocator, ",", single);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, "only", result));
}
