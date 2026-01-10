//! # BitSet（ビット集合）
//!
//! BitSetは整数の集合を効率的に表現するデータ構造。
//! 各整数に1ビットを割り当て、存在の有無を管理する。
//!
//! ## 種類
//! - StaticBitSet(N): コンパイル時サイズ確定、最適化される
//! - IntegerBitSet(N): 単一整数で管理（小さいサイズ向け）
//! - ArrayBitSet(T, N): 配列で管理（大きいサイズ向け）
//! - DynamicBitSet: 実行時サイズ確定、アロケータ使用
//!
//! ## 特徴
//! - 存在確認O(1)、和集合・積集合O(n)
//! - メモリ効率が良い（1要素1ビット）

const std = @import("std");

// ====================
// 基本: StaticBitSet
// ====================

fn demoStaticBitSet() void {
    std.debug.print("--- StaticBitSet ---\n", .{});

    // StaticBitSet(サイズ): サイズに応じて最適な実装を選択
    var set = std.StaticBitSet(16).initEmpty();

    // set: ビットをセット
    set.set(3);
    set.set(7);
    set.set(12);

    std.debug.print("  セット後: ", .{});
    for (0..16) |i| {
        if (set.isSet(i)) {
            std.debug.print("{d} ", .{i});
        }
    }
    std.debug.print("\n", .{});

    // isSet: ビットの確認
    std.debug.print("  isSet(3): {}\n", .{set.isSet(3)});
    std.debug.print("  isSet(5): {}\n", .{set.isSet(5)});

    // count: セットされたビット数
    std.debug.print("  count: {d}\n", .{set.count()});

    std.debug.print("\n", .{});
}

// ====================
// unset と toggle
// ====================

fn demoUnsetAndToggle() void {
    std.debug.print("--- unset と toggle ---\n", .{});

    var set = std.StaticBitSet(8).initEmpty();

    set.set(1);
    set.set(2);
    set.set(3);

    std.debug.print("  初期: ", .{});
    printBitSet(&set, 8);

    // unset: ビットをクリア
    set.unset(2);
    std.debug.print("  unset(2): ", .{});
    printBitSet(&set, 8);

    // toggle: ビットを反転
    set.toggle(1); // 1 -> 0
    set.toggle(5); // 0 -> 1
    std.debug.print("  toggle(1,5): ", .{});
    printBitSet(&set, 8);

    std.debug.print("\n", .{});
}

fn printBitSet(set: anytype, size: usize) void {
    for (0..size) |i| {
        if (set.isSet(i)) {
            std.debug.print("{d} ", .{i});
        }
    }
    std.debug.print("\n", .{});
}

// ====================
// initFull（全ビットセット）
// ====================

fn demoInitFull() void {
    std.debug.print("--- initFull ---\n", .{});

    // 全ビットがセットされた状態で初期化
    var set = std.StaticBitSet(8).initFull();

    std.debug.print("  initFull count: {d}\n", .{set.count()});

    // 不要なビットをクリア
    set.unset(0);
    set.unset(7);

    std.debug.print("  unset(0,7): ", .{});
    printBitSet(&set, 8);

    std.debug.print("\n", .{});
}

// ====================
// 集合演算
// ====================

fn demoSetOperations() void {
    std.debug.print("--- 集合演算 ---\n", .{});

    var setA = std.StaticBitSet(8).initEmpty();
    var setB = std.StaticBitSet(8).initEmpty();

    setA.set(1);
    setA.set(2);
    setA.set(3);

    setB.set(2);
    setB.set(3);
    setB.set(4);

    std.debug.print("  setA: ", .{});
    printBitSet(&setA, 8);
    std.debug.print("  setB: ", .{});
    printBitSet(&setB, 8);

    // setUnion: 和集合 (A ∪ B)
    var unionSet = setA;
    unionSet.setUnion(setB);
    std.debug.print("  A ∪ B: ", .{});
    printBitSet(&unionSet, 8);

    // setIntersection: 積集合 (A ∩ B)
    var intersectSet = setA;
    intersectSet.setIntersection(setB);
    std.debug.print("  A ∩ B: ", .{});
    printBitSet(&intersectSet, 8);

    // toggleSet: 排他的論理和 (A ⊕ B)
    var xorSet = setA;
    xorSet.toggleSet(setB);
    std.debug.print("  A ⊕ B: ", .{});
    printBitSet(&xorSet, 8);

    std.debug.print("\n", .{});
}

// ====================
// イテレーション
// ====================

fn demoIteration() void {
    std.debug.print("--- イテレーション ---\n", .{});

    var set = std.StaticBitSet(16).initEmpty();
    set.set(2);
    set.set(5);
    set.set(8);
    set.set(11);
    set.set(14);

    // iterator: セットされたビットを走査
    std.debug.print("  セットされたビット: ", .{});
    var it = set.iterator(.{});
    while (it.next()) |index| {
        std.debug.print("{d} ", .{index});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// DynamicBitSet
// ====================

fn demoDynamicBitSet() !void {
    std.debug.print("--- DynamicBitSet ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 実行時にサイズを決定
    const size: usize = 100;
    var set = try std.DynamicBitSet.initEmpty(allocator, size);
    defer set.deinit();

    set.set(10);
    set.set(50);
    set.set(99);

    std.debug.print("  サイズ: {d}\n", .{set.capacity()});
    std.debug.print("  count: {d}\n", .{set.count()});

    std.debug.print("  セットされたビット: ", .{});
    var it = set.iterator(.{});
    while (it.next()) |index| {
        std.debug.print("{d} ", .{index});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 範囲操作
// ====================

fn demoRangeOperations() void {
    std.debug.print("--- 範囲操作 ---\n", .{});

    var set = std.StaticBitSet(16).initEmpty();

    // setRangeValue: 範囲内のビットを一括設定
    set.setRangeValue(.{ .start = 4, .end = 10 }, true);

    std.debug.print("  range[4..10]セット: ", .{});
    printBitSet(&set, 16);

    // 一部をクリア
    set.setRangeValue(.{ .start = 6, .end = 8 }, false);

    std.debug.print("  range[6..8]クリア: ", .{});
    printBitSet(&set, 16);

    std.debug.print("\n", .{});
}

// ====================
// 実践: フラグ管理
// ====================

fn demoFlags() void {
    std.debug.print("--- 実践: フラグ管理 ---\n", .{});

    // 機能フラグの管理
    const Features = enum(usize) {
        dark_mode = 0,
        notifications = 1,
        analytics = 2,
        beta_features = 3,
        auto_save = 4,
    };

    var enabled_features = std.StaticBitSet(8).initEmpty();

    // フラグを有効化
    enabled_features.set(@intFromEnum(Features.dark_mode));
    enabled_features.set(@intFromEnum(Features.notifications));
    enabled_features.set(@intFromEnum(Features.auto_save));

    std.debug.print("  dark_mode: {}\n", .{enabled_features.isSet(@intFromEnum(Features.dark_mode))});
    std.debug.print("  analytics: {}\n", .{enabled_features.isSet(@intFromEnum(Features.analytics))});
    std.debug.print("  有効機能数: {d}\n", .{enabled_features.count()});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  種類:\n", .{});
    std.debug.print("    StaticBitSet(N)  - コンパイル時サイズ\n", .{});
    std.debug.print("    DynamicBitSet    - 実行時サイズ\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    set(i)           - ビットセット\n", .{});
    std.debug.print("    unset(i)         - ビットクリア\n", .{});
    std.debug.print("    toggle(i)        - ビット反転\n", .{});
    std.debug.print("    isSet(i)         - 存在確認\n", .{});
    std.debug.print("    count()          - セット数\n", .{});

    std.debug.print("  集合演算:\n", .{});
    std.debug.print("    setUnion         - 和集合\n", .{});
    std.debug.print("    setIntersection  - 積集合\n", .{});
    std.debug.print("    toggleSet        - 排他的論理和\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== BitSet ===\n\n", .{});

    demoStaticBitSet();
    demoUnsetAndToggle();
    demoInitFull();
    demoSetOperations();
    demoIteration();
    try demoDynamicBitSet();
    demoRangeOperations();
    demoFlags();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・1要素1ビットで効率的\n", .{});
    std.debug.print("・存在確認がO(1)\n", .{});
    std.debug.print("・集合演算が高速\n", .{});
    std.debug.print("・フラグ管理に最適\n", .{});
}

// --- テスト ---

test "bitset set and isSet" {
    var set = std.StaticBitSet(16).initEmpty();

    try std.testing.expect(!set.isSet(5));

    set.set(5);
    try std.testing.expect(set.isSet(5));
    try std.testing.expect(!set.isSet(4));
}

test "bitset count" {
    var set = std.StaticBitSet(16).initEmpty();

    try std.testing.expectEqual(@as(usize, 0), set.count());

    set.set(1);
    set.set(5);
    set.set(10);

    try std.testing.expectEqual(@as(usize, 3), set.count());
}

test "bitset unset" {
    var set = std.StaticBitSet(16).initEmpty();

    set.set(5);
    try std.testing.expect(set.isSet(5));

    set.unset(5);
    try std.testing.expect(!set.isSet(5));
}

test "bitset toggle" {
    var set = std.StaticBitSet(16).initEmpty();

    set.toggle(5);
    try std.testing.expect(set.isSet(5));

    set.toggle(5);
    try std.testing.expect(!set.isSet(5));
}

test "bitset initFull" {
    var set = std.StaticBitSet(8).initFull();

    try std.testing.expectEqual(@as(usize, 8), set.count());

    for (0..8) |i| {
        try std.testing.expect(set.isSet(i));
    }
}

test "bitset setUnion" {
    var setA = std.StaticBitSet(8).initEmpty();
    var setB = std.StaticBitSet(8).initEmpty();

    setA.set(1);
    setA.set(2);

    setB.set(2);
    setB.set(3);

    setA.setUnion(setB);

    try std.testing.expect(setA.isSet(1));
    try std.testing.expect(setA.isSet(2));
    try std.testing.expect(setA.isSet(3));
    try std.testing.expectEqual(@as(usize, 3), setA.count());
}

test "bitset setIntersection" {
    var setA = std.StaticBitSet(8).initEmpty();
    var setB = std.StaticBitSet(8).initEmpty();

    setA.set(1);
    setA.set(2);
    setA.set(3);

    setB.set(2);
    setB.set(3);
    setB.set(4);

    setA.setIntersection(setB);

    try std.testing.expect(!setA.isSet(1));
    try std.testing.expect(setA.isSet(2));
    try std.testing.expect(setA.isSet(3));
    try std.testing.expect(!setA.isSet(4));
    try std.testing.expectEqual(@as(usize, 2), setA.count());
}

test "bitset toggleSet" {
    var setA = std.StaticBitSet(8).initEmpty();
    var setB = std.StaticBitSet(8).initEmpty();

    setA.set(1);
    setA.set(2);

    setB.set(2);
    setB.set(3);

    setA.toggleSet(setB);

    try std.testing.expect(setA.isSet(1));
    try std.testing.expect(!setA.isSet(2)); // 両方にあるので0に
    try std.testing.expect(setA.isSet(3));
}

test "bitset iterator" {
    var set = std.StaticBitSet(16).initEmpty();

    set.set(2);
    set.set(5);
    set.set(10);

    var result: [3]usize = undefined;
    var i: usize = 0;
    var it = set.iterator(.{});
    while (it.next()) |index| {
        result[i] = index;
        i += 1;
    }

    try std.testing.expectEqual(@as(usize, 2), result[0]);
    try std.testing.expectEqual(@as(usize, 5), result[1]);
    try std.testing.expectEqual(@as(usize, 10), result[2]);
}

test "dynamic bitset" {
    const allocator = std.testing.allocator;

    var set = try std.DynamicBitSet.initEmpty(allocator, 100);
    defer set.deinit();

    set.set(10);
    set.set(50);
    set.set(99);

    try std.testing.expect(set.isSet(10));
    try std.testing.expect(set.isSet(50));
    try std.testing.expect(set.isSet(99));
    try std.testing.expectEqual(@as(usize, 3), set.count());
}

test "bitset setRangeValue" {
    var set = std.StaticBitSet(16).initEmpty();

    set.setRangeValue(.{ .start = 4, .end = 8 }, true);

    try std.testing.expect(!set.isSet(3));
    try std.testing.expect(set.isSet(4));
    try std.testing.expect(set.isSet(5));
    try std.testing.expect(set.isSet(6));
    try std.testing.expect(set.isSet(7));
    try std.testing.expect(!set.isSet(8));
}
