//! # SegmentedList
//!
//! SegmentedListは要素へのポインタが無効化されない動的リスト。
//! ArrayListと異なり、追加時にも既存要素のアドレスが保持される。
//!
//! ## 特徴
//! - ポインタ安定性: 追加しても既存要素のアドレスは変わらない
//! - O(1)のappend/pop
//! - 2のべき乗サイズのセグメントで管理
//! - 事前確保（prealloc）でスタック上に配置可能
//!
//! ## ArrayListとの違い
//! - ArrayList: 連続メモリ、リアロケーションでポインタ無効化
//! - SegmentedList: セグメント分割、ポインタ安定

const std = @import("std");

// ====================
// 基本的な使い方
// ====================

fn demoBasicUsage() !void {
    std.debug.print("--- 基本的な使い方 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // SegmentedList(型, 事前確保数)
    // 事前確保数は0か2のべき乗
    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    // append: 要素を追加
    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);
    try list.append(allocator, 40);
    try list.append(allocator, 50);

    std.debug.print("  要素数: {d}\n", .{list.count()});

    // at: インデックスでアクセス（ポインタを返す）
    std.debug.print("  list.at(0).*: {d}\n", .{list.at(0).*});
    std.debug.print("  list.at(2).*: {d}\n", .{list.at(2).*});

    std.debug.print("\n", .{});
}

// ====================
// ポインタ安定性
// ====================

fn demoPointerStability() !void {
    std.debug.print("--- ポインタ安定性 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 100);
    try list.append(allocator, 200);

    // 最初の要素へのポインタを保存
    const ptr_to_first = list.at(0);
    const original_value = ptr_to_first.*;

    std.debug.print("  追加前のポインタ値: {d}\n", .{ptr_to_first.*});

    // 大量の要素を追加
    for (0..100) |i| {
        try list.append(allocator, @intCast(i));
    }

    // ポインタは依然として有効！
    std.debug.print("  追加後のポインタ値: {d}\n", .{ptr_to_first.*});
    std.debug.print("  ポインタ安定: {}\n", .{ptr_to_first.* == original_value});

    std.debug.print("\n", .{});
}

// ====================
// pop（末尾から取り出し）
// ====================

fn demoPop() !void {
    std.debug.print("--- pop ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    std.debug.print("  追加後: {d}個\n", .{list.count()});

    // pop: 末尾から取り出し
    if (list.pop()) |value| {
        std.debug.print("  pop: {d}\n", .{value});
    }

    if (list.pop()) |value| {
        std.debug.print("  pop: {d}\n", .{value});
    }

    std.debug.print("  残り: {d}個\n", .{list.count()});

    std.debug.print("\n", .{});
}

// ====================
// addOneでの直接操作
// ====================

fn demoAddOne() !void {
    std.debug.print("--- addOne ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    // addOne: 新しい要素の場所を確保してポインタを返す
    const ptr1 = try list.addOne(allocator);
    ptr1.* = 100; // 直接書き込み

    const ptr2 = try list.addOne(allocator);
    ptr2.* = 200;

    std.debug.print("  addOneで追加: {d}, {d}\n", .{ list.at(0).*, list.at(1).* });

    std.debug.print("\n", .{});
}

// ====================
// 事前確保（prealloc）
// ====================

fn demoPrealloc() !void {
    std.debug.print("--- 事前確保（prealloc） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // prealloc=8: 最初の8要素はスタック上
    var list: std.SegmentedList(i32, 8) = .{};
    defer list.deinit(allocator);

    std.debug.print("  prealloc_count: {d}\n", .{@TypeOf(list).prealloc_count});

    // 8要素まではヒープ割り当てなし
    for (0..8) |i| {
        try list.append(allocator, @intCast(i * 10));
    }

    std.debug.print("  8要素追加（preallocの範囲内）\n", .{});

    // 9要素目からヒープ使用
    try list.append(allocator, 80);
    std.debug.print("  9要素目からヒープ使用\n", .{});

    std.debug.print("  合計: {d}個\n", .{list.count()});

    std.debug.print("\n", .{});
}

// ====================
// appendSlice
// ====================

fn demoAppendSlice() !void {
    std.debug.print("--- appendSlice ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    // スライスを一度に追加
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    try list.appendSlice(allocator, &data);

    std.debug.print("  追加後: {d}個\n", .{list.count()});
    std.debug.print("  内容: ", .{});
    for (0..list.count()) |i| {
        std.debug.print("{d} ", .{list.at(i).*});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// clearとshrink
// ====================

fn demoClearAndShrink() !void {
    std.debug.print("--- clearとshrink ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    for (0..20) |i| {
        try list.append(allocator, @intCast(i));
    }

    std.debug.print("  追加後: {d}個\n", .{list.count()});

    // clearRetainingCapacity: 要素クリア、容量保持
    list.clearRetainingCapacity();
    std.debug.print("  clearRetainingCapacity: {d}個\n", .{list.count()});

    // 再度追加
    try list.append(allocator, 100);
    try list.append(allocator, 200);

    // shrinkRetainingCapacity: 長さを縮小
    list.shrinkRetainingCapacity(1);
    std.debug.print("  shrinkRetainingCapacity(1): {d}個\n", .{list.count()});

    std.debug.print("\n", .{});
}

// ====================
// ArrayListとの比較
// ====================

fn demoComparison() void {
    std.debug.print("--- ArrayListとの比較 ---\n", .{});

    std.debug.print("  ArrayList:\n", .{});
    std.debug.print("    - 連続メモリ\n", .{});
    std.debug.print("    - リアロケーションでポインタ無効化\n", .{});
    std.debug.print("    - キャッシュ効率が最高\n", .{});
    std.debug.print("    - items[] でスライスアクセス可能\n", .{});

    std.debug.print("  SegmentedList:\n", .{});
    std.debug.print("    - セグメント分割メモリ\n", .{});
    std.debug.print("    - ポインタが常に安定\n", .{});
    std.debug.print("    - preallocでスタック利用可能\n", .{});
    std.debug.print("    - at(i)でアクセス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  定義:\n", .{});
    std.debug.print("    std.SegmentedList(T, prealloc)\n", .{});
    std.debug.print("    prealloc: 0か2のべき乗\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    append(alloc, val) - 追加\n", .{});
    std.debug.print("    at(index)          - ポインタ取得\n", .{});
    std.debug.print("    pop()              - 末尾取り出し\n", .{});
    std.debug.print("    addOne(alloc)      - 場所確保\n", .{});
    std.debug.print("    count()            - 要素数\n", .{});

    std.debug.print("  用途:\n", .{});
    std.debug.print("    - ポインタ安定性が必要な場合\n", .{});
    std.debug.print("    - 自己参照構造体\n", .{});
    std.debug.print("    - コールバック登録\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== SegmentedList ===\n\n", .{});

    try demoBasicUsage();
    try demoPointerStability();
    try demoPop();
    try demoAddOne();
    try demoPrealloc();
    try demoAppendSlice();
    try demoClearAndShrink();
    demoComparison();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・ポインタが追加後も安定\n", .{});
    std.debug.print("・preallocでスタック利用\n", .{});
    std.debug.print("・at(i)でポインタ取得\n", .{});
    std.debug.print("・自己参照構造に最適\n", .{});
}

// --- テスト ---

test "segmentedlist basic append and at" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    try std.testing.expectEqual(@as(usize, 3), list.count());
    try std.testing.expectEqual(@as(i32, 10), list.at(0).*);
    try std.testing.expectEqual(@as(i32, 20), list.at(1).*);
    try std.testing.expectEqual(@as(i32, 30), list.at(2).*);
}

test "segmentedlist pointer stability" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 100);

    const ptr = list.at(0);
    const original = ptr.*;

    // 大量追加
    for (0..100) |i| {
        try list.append(allocator, @intCast(i));
    }

    // ポインタは依然として有効
    try std.testing.expectEqual(original, ptr.*);
}

test "segmentedlist pop" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    try std.testing.expectEqual(@as(?i32, 30), list.pop());
    try std.testing.expectEqual(@as(?i32, 20), list.pop());
    try std.testing.expectEqual(@as(usize, 1), list.count());
}

test "segmentedlist addOne" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    const ptr = try list.addOne(allocator);
    ptr.* = 42;

    try std.testing.expectEqual(@as(i32, 42), list.at(0).*);
}

test "segmentedlist appendSlice" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    const data = [_]i32{ 1, 2, 3 };
    try list.appendSlice(allocator, &data);

    try std.testing.expectEqual(@as(usize, 3), list.count());
    try std.testing.expectEqual(@as(i32, 1), list.at(0).*);
    try std.testing.expectEqual(@as(i32, 3), list.at(2).*);
}

test "segmentedlist clearRetainingCapacity" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);

    list.clearRetainingCapacity();

    try std.testing.expectEqual(@as(usize, 0), list.count());
}

test "segmentedlist shrinkRetainingCapacity" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    list.shrinkRetainingCapacity(1);

    try std.testing.expectEqual(@as(usize, 1), list.count());
    try std.testing.expectEqual(@as(i32, 10), list.at(0).*);
}

test "segmentedlist empty pop" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try std.testing.expectEqual(@as(?i32, null), list.pop());
}

test "segmentedlist modify via at" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 100);

    list.at(0).* = 200;

    try std.testing.expectEqual(@as(i32, 200), list.at(0).*);
}

test "segmentedlist beyond prealloc" {
    const allocator = std.testing.allocator;

    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(allocator);

    // 4 (prealloc) を超えて追加
    for (0..10) |i| {
        try list.append(allocator, @intCast(i));
    }

    try std.testing.expectEqual(@as(usize, 10), list.count());
    try std.testing.expectEqual(@as(i32, 9), list.at(9).*);
}
