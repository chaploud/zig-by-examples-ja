//! # PriorityQueue（優先度付きキュー）
//!
//! PriorityQueueは優先度の高い要素を先に取り出すデータ構造。
//! ヒープ（二分ヒープ）を使って効率的に実装されている。
//!
//! ## 特徴
//! - 挿入: O(log n)
//! - 最優先要素の取り出し: O(log n)
//! - 最優先要素の参照: O(1)
//!
//! ## 用途
//! - タスクスケジューリング
//! - ダイクストラ法などのアルゴリズム
//! - イベント処理

const std = @import("std");

// ====================
// 比較関数（モジュールレベル）
// ====================

// 最小値優先（小さい値が先）
fn orderAscI32(context: void, a: i32, b: i32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

// 最大値優先（大きい値が先）
fn orderDescI32(context: void, a: i32, b: i32) std.math.Order {
    _ = context;
    return std.math.order(b, a);
}

fn orderAscU32(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

// タスク構造体用
const Task = struct {
    name: []const u8,
    priority: u8,
};

fn orderTaskByPriority(context: void, a: Task, b: Task) std.math.Order {
    _ = context;
    return std.math.order(a.priority, b.priority);
}

// コンテキスト付き比較用
const Config = struct {
    ascending: bool,
};

fn orderWithConfig(config: Config, a: i32, b: i32) std.math.Order {
    if (config.ascending) {
        return std.math.order(a, b);
    } else {
        return std.math.order(b, a);
    }
}

// ====================
// 基本: 最小値優先キュー
// ====================

fn demoMinQueue() !void {
    std.debug.print("--- 最小値優先キュー ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    // add: 要素を追加
    try queue.add(30);
    try queue.add(10);
    try queue.add(50);
    try queue.add(20);
    try queue.add(40);

    std.debug.print("  追加順: 30, 10, 50, 20, 40\n", .{});
    std.debug.print("  取り出し順（小さい順）: ", .{});

    // remove: 最優先要素を取り出し
    while (queue.removeOrNull()) |value| {
        std.debug.print("{d} ", .{value});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 最大値優先キュー
// ====================

fn demoMaxQueue() !void {
    std.debug.print("--- 最大値優先キュー ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(i32, void, orderDescI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(30);
    try queue.add(10);
    try queue.add(50);
    try queue.add(20);
    try queue.add(40);

    std.debug.print("  追加順: 30, 10, 50, 20, 40\n", .{});
    std.debug.print("  取り出し順（大きい順）: ", .{});

    while (queue.removeOrNull()) |value| {
        std.debug.print("{d} ", .{value});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// peek（先頭を覗く）
// ====================

fn demoPeek() !void {
    std.debug.print("--- peek（先頭を覗く） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(5);
    try queue.add(3);
    try queue.add(8);

    // peek: 取り出さずに最優先要素を見る
    if (queue.peek()) |top| {
        std.debug.print("  peek: {d}（取り出さない）\n", .{top});
    }

    std.debug.print("  キュー長: {d}\n", .{queue.count()});

    // 実際に取り出す
    _ = queue.remove();
    if (queue.peek()) |top| {
        std.debug.print("  remove後のpeek: {d}\n", .{top});
    }

    std.debug.print("\n", .{});
}

// ====================
// addSlice（複数追加）
// ====================

fn demoAddSlice() !void {
    std.debug.print("--- addSlice（複数追加） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(u32, void, orderAscU32).init(allocator, {});
    defer queue.deinit();

    // スライスで一度に追加
    const data = [_]u32{ 100, 20, 75, 50, 30 };
    try queue.addSlice(&data);

    std.debug.print("  追加データ: 100, 20, 75, 50, 30\n", .{});
    std.debug.print("  取り出し順: ", .{});

    while (queue.removeOrNull()) |value| {
        std.debug.print("{d} ", .{value});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体の優先度キュー
// ====================

fn demoStructQueue() !void {
    std.debug.print("--- 構造体の優先度キュー ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(Task, void, orderTaskByPriority).init(allocator, {});
    defer queue.deinit();

    try queue.add(.{ .name = "低優先度タスク", .priority = 10 });
    try queue.add(.{ .name = "高優先度タスク", .priority = 1 });
    try queue.add(.{ .name = "中優先度タスク", .priority = 5 });

    std.debug.print("  タスク実行順:\n", .{});
    while (queue.removeOrNull()) |task| {
        std.debug.print("    優先度{d}: {s}\n", .{ task.priority, task.name });
    }

    std.debug.print("\n", .{});
}

// ====================
// コンテキスト付き比較
// ====================

fn demoContextComparison() !void {
    std.debug.print("--- コンテキスト付き比較 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 昇順キュー
    var ascending_queue = std.PriorityQueue(i32, Config, orderWithConfig).init(
        allocator,
        Config{ .ascending = true },
    );
    defer ascending_queue.deinit();

    try ascending_queue.add(3);
    try ascending_queue.add(1);
    try ascending_queue.add(2);

    std.debug.print("  昇順: ", .{});
    while (ascending_queue.removeOrNull()) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    // 降順キュー
    var descending_queue = std.PriorityQueue(i32, Config, orderWithConfig).init(
        allocator,
        Config{ .ascending = false },
    );
    defer descending_queue.deinit();

    try descending_queue.add(3);
    try descending_queue.add(1);
    try descending_queue.add(2);

    std.debug.print("  降順: ", .{});
    while (descending_queue.removeOrNull()) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// count と update
// ====================

fn demoCountAndUpdate() !void {
    std.debug.print("--- count と update ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(10);
    try queue.add(20);
    try queue.add(30);

    std.debug.print("  要素数: {d}\n", .{queue.count()});

    // update: 特定インデックスの値を更新
    queue.update(5, 1); // インデックス1の値を5に変更
    std.debug.print("  インデックス1を5に更新\n", .{});

    std.debug.print("  取り出し順: ", .{});
    while (queue.removeOrNull()) |value| {
        std.debug.print("{d} ", .{value});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  定義:\n", .{});
    std.debug.print("    std.PriorityQueue(T, Context, compareFn)\n", .{});

    std.debug.print("  比較関数:\n", .{});
    std.debug.print("    fn(ctx, a, b) -> std.math.Order\n", .{});
    std.debug.print("    .lt: aが優先 / .gt: bが優先 / .eq: 同等\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    add(elem)       - 要素追加\n", .{});
    std.debug.print("    addSlice(&arr)  - 複数追加\n", .{});
    std.debug.print("    remove()        - 最優先を取り出し\n", .{});
    std.debug.print("    removeOrNull()  - 空ならnull\n", .{});
    std.debug.print("    peek()          - 最優先を覗く\n", .{});
    std.debug.print("    count()         - 要素数\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== PriorityQueue ===\n\n", .{});

    try demoMinQueue();
    try demoMaxQueue();
    try demoPeek();
    try demoAddSlice();
    try demoStructQueue();
    try demoContextComparison();
    try demoCountAndUpdate();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・ヒープベースの優先度キュー\n", .{});
    std.debug.print("・比較関数で優先度を定義\n", .{});
    std.debug.print("・挿入/取り出しがO(log n)\n", .{});
    std.debug.print("・タスクスケジューリングに最適\n", .{});
}

// --- テスト ---

test "priority queue min heap" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(3);
    try queue.add(1);
    try queue.add(2);

    try std.testing.expectEqual(@as(i32, 1), queue.remove());
    try std.testing.expectEqual(@as(i32, 2), queue.remove());
    try std.testing.expectEqual(@as(i32, 3), queue.remove());
}

test "priority queue max heap" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(i32, void, orderDescI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(3);
    try queue.add(1);
    try queue.add(2);

    try std.testing.expectEqual(@as(i32, 3), queue.remove());
    try std.testing.expectEqual(@as(i32, 2), queue.remove());
    try std.testing.expectEqual(@as(i32, 1), queue.remove());
}

test "priority queue peek" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try queue.add(5);
    try queue.add(3);

    try std.testing.expectEqual(@as(?i32, 3), queue.peek());
    try std.testing.expectEqual(@as(usize, 2), queue.count());
}

test "priority queue addSlice" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(u32, void, orderAscU32).init(allocator, {});
    defer queue.deinit();

    const data = [_]u32{ 30, 10, 20 };
    try queue.addSlice(&data);

    try std.testing.expectEqual(@as(usize, 3), queue.count());
    try std.testing.expectEqual(@as(u32, 10), queue.remove());
}

test "priority queue removeOrNull empty" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try std.testing.expectEqual(@as(?i32, null), queue.removeOrNull());
}

test "priority queue count" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(i32, void, orderAscI32).init(allocator, {});
    defer queue.deinit();

    try std.testing.expectEqual(@as(usize, 0), queue.count());

    try queue.add(1);
    try std.testing.expectEqual(@as(usize, 1), queue.count());

    try queue.add(2);
    try std.testing.expectEqual(@as(usize, 2), queue.count());

    _ = queue.remove();
    try std.testing.expectEqual(@as(usize, 1), queue.count());
}

test "priority queue struct comparison" {
    const allocator = std.testing.allocator;

    var queue = std.PriorityQueue(Task, void, orderTaskByPriority).init(allocator, {});
    defer queue.deinit();

    try queue.add(.{ .name = "c", .priority = 3 });
    try queue.add(.{ .name = "a", .priority = 1 });
    try queue.add(.{ .name = "b", .priority = 2 });

    try std.testing.expectEqual(@as(u8, 1), queue.remove().priority);
    try std.testing.expectEqual(@as(u8, 2), queue.remove().priority);
    try std.testing.expectEqual(@as(u8, 3), queue.remove().priority);
}

test "priority queue with context" {
    const allocator = std.testing.allocator;

    // 降順（負の乗数効果）
    var queue = std.PriorityQueue(i32, Config, orderWithConfig).init(
        allocator,
        Config{ .ascending = false },
    );
    defer queue.deinit();

    try queue.add(1);
    try queue.add(3);
    try queue.add(2);

    try std.testing.expectEqual(@as(i32, 3), queue.remove());
    try std.testing.expectEqual(@as(i32, 2), queue.remove());
    try std.testing.expectEqual(@as(i32, 1), queue.remove());
}
