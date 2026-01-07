//! # ArrayList
//!
//! ArrayListは動的配列の実装。要素の追加・削除が可能で、
//! 必要に応じて自動的にメモリを拡張する。
//!
//! ## 特徴
//! - 動的サイズの配列
//! - O(1)のランダムアクセス
//! - アロケータを使用してメモリ管理
//!
//! ## 主要API
//! - append: 末尾に追加
//! - items: スライスとしてアクセス
//! - pop: 末尾から取り出し
//! - deinit: メモリ解放

const std = @import("std");

// ====================
// 基本的な使い方
// ====================

fn demoBasicUsage() !void {
    std.debug.print("--- 基本的な使い方 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // ArrayListの作成（Zig 0.15.2: 空のリテラルで初期化）
    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    // 要素の追加
    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    std.debug.print("  追加後: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("  長さ: {d}\n", .{list.items.len});
    std.debug.print("  容量: {d}\n", .{list.capacity});

    std.debug.print("\n", .{});
}

// ====================
// 初期容量の指定
// ====================

fn demoInitCapacity() !void {
    std.debug.print("--- 初期容量の指定 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 初期容量を指定して作成
    var list = try std.ArrayList(i32).initCapacity(allocator, 100);
    defer list.deinit(allocator);

    std.debug.print("  初期容量: {d}\n", .{list.capacity});
    std.debug.print("  初期長さ: {d}\n", .{list.items.len});

    // 要素追加してもリアロケーションなし
    for (0..50) |i| {
        try list.append(allocator, @intCast(i));
    }

    std.debug.print("  追加後容量: {d}\n", .{list.capacity});

    std.debug.print("\n", .{});
}

// ====================
// 要素のアクセス
// ====================

fn demoAccess() !void {
    std.debug.print("--- 要素のアクセス ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    // インデックスアクセス
    std.debug.print("  items[0]: {d}\n", .{list.items[0]});
    std.debug.print("  items[1]: {d}\n", .{list.items[1]});

    // 変更
    list.items[1] = 25;
    std.debug.print("  変更後 items[1]: {d}\n", .{list.items[1]});

    // 最後の要素
    if (list.items.len > 0) {
        std.debug.print("  最後の要素: {d}\n", .{list.items[list.items.len - 1]});
    }

    std.debug.print("\n", .{});
}

// ====================
// 要素の削除
// ====================

fn demoRemoval() !void {
    std.debug.print("--- 要素の削除 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    for (0..5) |i| {
        try list.append(allocator, @as(i32, @intCast(i)) * 10);
    }

    std.debug.print("  初期: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    // pop: 末尾から取り出し
    if (list.pop()) |value| {
        std.debug.print("  pop: {d}\n", .{value});
    }

    // orderedRemove: 順序を保持して削除
    const removed = list.orderedRemove(1);
    std.debug.print("  orderedRemove(1): {d}\n", .{removed});

    std.debug.print("  削除後: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// swapRemove（高速削除）
// ====================

fn demoSwapRemove() !void {
    std.debug.print("--- swapRemove（高速削除） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    for (0..5) |i| {
        try list.append(allocator, @as(i32, @intCast(i)) * 10);
    }

    std.debug.print("  初期: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    // swapRemove: 最後の要素と交換して削除（O(1)）
    const removed = list.swapRemove(1);
    std.debug.print("  swapRemove(1): {d}\n", .{removed});

    std.debug.print("  削除後（順序変更）: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("（順序が変わる）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スライスの追加
// ====================

fn demoAppendSlice() !void {
    std.debug.print("--- スライスの追加 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    // 単一要素追加
    try list.append(allocator, 1);
    try list.append(allocator, 2);

    // スライスを追加
    const more = [_]i32{ 10, 20, 30 };
    try list.appendSlice(allocator, &more);

    std.debug.print("  結果: ", .{});
    for (list.items) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// クリアと縮小
// ====================

fn demoClearAndShrink() !void {
    std.debug.print("--- クリアと縮小 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list = try std.ArrayList(i32).initCapacity(allocator, 100);
    defer list.deinit(allocator);

    for (0..50) |i| {
        try list.append(allocator, @intCast(i));
    }

    std.debug.print("  追加後: len={d}, capacity={d}\n", .{ list.items.len, list.capacity });

    // clearRetainingCapacity: 要素だけクリア
    list.clearRetainingCapacity();
    std.debug.print("  clearRetainingCapacity: len={d}, capacity={d}\n", .{ list.items.len, list.capacity });

    // 再度追加
    for (0..10) |i| {
        try list.append(allocator, @intCast(i));
    }

    // shrinkAndFree: 余分な容量を解放
    list.shrinkAndFree(allocator, list.items.len);
    std.debug.print("  shrinkAndFree: len={d}, capacity={d}\n", .{ list.items.len, list.capacity });

    std.debug.print("\n", .{});
}

// ====================
// toOwnedSlice
// ====================

fn demoToOwnedSlice() !void {
    std.debug.print("--- toOwnedSlice ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .{};
    // deinitは不要（toOwnedSliceで所有権移譲）

    try list.append(allocator, 1);
    try list.append(allocator, 2);
    try list.append(allocator, 3);

    // 所有権を持つスライスを取得（ArrayListは空になる）
    const slice = try list.toOwnedSlice(allocator);
    defer allocator.free(slice);

    std.debug.print("  toOwnedSlice: ", .{});
    for (slice) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("  リスト長: {d}（空になる）\n", .{list.items.len});

    std.debug.print("\n", .{});
}

// ====================
// 実践：文字列リスト
// ====================

fn demoStringList() !void {
    std.debug.print("--- 実践：文字列リスト ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var names: std.ArrayList([]const u8) = .{};
    defer names.deinit(allocator);

    try names.append(allocator, "Alice");
    try names.append(allocator, "Bob");
    try names.append(allocator, "Charlie");

    std.debug.print("  名前リスト:\n", .{});
    for (names.items, 0..) |name, i| {
        std.debug.print("    [{d}] {s}\n", .{ i, name });
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  作成:\n", .{});
    std.debug.print("    var list: std.ArrayList(T) = .{{}};\n", .{});
    std.debug.print("    var list = try ...initCapacity(alloc, n);\n", .{});

    std.debug.print("  追加:\n", .{});
    std.debug.print("    append, appendSlice\n", .{});

    std.debug.print("  削除:\n", .{});
    std.debug.print("    pop, orderedRemove, swapRemove\n", .{});

    std.debug.print("  アクセス:\n", .{});
    std.debug.print("    items[i], items.len\n", .{});

    std.debug.print("  解放:\n", .{});
    std.debug.print("    deinit(allocator)\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ArrayList ===\n\n", .{});

    try demoBasicUsage();
    try demoInitCapacity();
    try demoAccess();
    try demoRemoval();
    try demoSwapRemove();
    try demoAppendSlice();
    try demoClearAndShrink();
    try demoToOwnedSlice();
    try demoStringList();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・ArrayListは動的配列\n", .{});
    std.debug.print("・アロケータを各操作に渡す\n", .{});
    std.debug.print("・deinitで必ず解放\n", .{});
    std.debug.print("・itemsでスライスアクセス\n", .{});
}

// --- テスト ---

test "arraylist basic operations" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    try std.testing.expectEqual(@as(usize, 3), list.items.len);
    try std.testing.expectEqual(@as(i32, 10), list.items[0]);
    try std.testing.expectEqual(@as(i32, 20), list.items[1]);
    try std.testing.expectEqual(@as(i32, 30), list.items[2]);
}

test "arraylist pop" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);

    const popped = list.pop();
    try std.testing.expect(popped != null);
    try std.testing.expectEqual(@as(i32, 20), popped.?);
    try std.testing.expectEqual(@as(usize, 1), list.items.len);
}

test "arraylist orderedRemove" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    const removed = list.orderedRemove(1);
    try std.testing.expectEqual(@as(i32, 20), removed);
    try std.testing.expectEqual(@as(usize, 2), list.items.len);
    try std.testing.expectEqual(@as(i32, 10), list.items[0]);
    try std.testing.expectEqual(@as(i32, 30), list.items[1]);
}

test "arraylist swapRemove" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    const removed = list.swapRemove(0);
    try std.testing.expectEqual(@as(i32, 10), removed);
    try std.testing.expectEqual(@as(usize, 2), list.items.len);
    // 最後の要素が位置0に来る
    try std.testing.expectEqual(@as(i32, 30), list.items[0]);
}

test "arraylist appendSlice" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    const slice = [_]i32{ 1, 2, 3 };
    try list.appendSlice(allocator, &slice);

    try std.testing.expectEqual(@as(usize, 3), list.items.len);
    try std.testing.expectEqual(@as(i32, 1), list.items[0]);
}

test "arraylist toOwnedSlice" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};

    try list.append(allocator, 1);
    try list.append(allocator, 2);

    const slice = try list.toOwnedSlice(allocator);
    defer allocator.free(slice);

    try std.testing.expectEqual(@as(usize, 2), slice.len);
    try std.testing.expectEqual(@as(i32, 1), slice[0]);
    try std.testing.expectEqual(@as(usize, 0), list.items.len);
}

test "arraylist initCapacity" {
    const allocator = std.testing.allocator;

    var list = try std.ArrayList(i32).initCapacity(allocator, 10);
    defer list.deinit(allocator);

    try std.testing.expect(list.capacity >= 10);
    try std.testing.expectEqual(@as(usize, 0), list.items.len);
}

test "arraylist clearRetainingCapacity" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, 1);
    try list.append(allocator, 2);

    const cap_before = list.capacity;
    list.clearRetainingCapacity();

    try std.testing.expectEqual(@as(usize, 0), list.items.len);
    try std.testing.expectEqual(cap_before, list.capacity);
}
