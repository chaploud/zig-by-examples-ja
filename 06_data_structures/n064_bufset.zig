//! # BufSet（文字列セット）
//!
//! BufSetは文字列の集合を管理するデータ構造。
//! 文字列をコピーして所有するため、元の文字列のライフタイムを気にしなくて良い。
//!
//! ## 特徴
//! - 文字列をコピーして所有
//! - 重複を自動排除
//! - deinitで自動メモリ解放
//!
//! ## BufMapとの違い
//! - BufSet: 文字列の集合（キーのみ）
//! - BufMap: 文字列のキーバリューマップ

const std = @import("std");

// ====================
// 基本的な使い方
// ====================

fn demoBasicUsage() !void {
    std.debug.print("--- 基本的な使い方 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    // insert: 文字列を追加（コピーされる）
    try set.insert("apple");
    try set.insert("banana");
    try set.insert("cherry");

    std.debug.print("  要素数: {d}\n", .{set.count()});

    // contains: 存在確認
    std.debug.print("  contains(apple): {}\n", .{set.contains("apple")});
    std.debug.print("  contains(grape): {}\n", .{set.contains("grape")});

    std.debug.print("\n", .{});
}

// ====================
// 重複の排除
// ====================

fn demoDuplicateHandling() !void {
    std.debug.print("--- 重複の排除 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("hello");
    std.debug.print("  1回目insert後: {d}個\n", .{set.count()});

    // 同じ文字列を再度追加
    try set.insert("hello");
    std.debug.print("  2回目insert後: {d}個（増えない）\n", .{set.count()});

    try set.insert("world");
    std.debug.print("  別の文字列追加: {d}個\n", .{set.count()});

    std.debug.print("\n", .{});
}

// ====================
// remove（削除）
// ====================

fn demoRemove() !void {
    std.debug.print("--- remove ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("a");
    try set.insert("b");
    try set.insert("c");

    std.debug.print("  削除前: {d}個\n", .{set.count()});

    // remove: 削除（メモリも解放）
    set.remove("b");

    std.debug.print("  削除後: {d}個\n", .{set.count()});
    std.debug.print("  contains(b): {}\n", .{set.contains("b")});

    // 存在しないキーの削除は何もしない
    set.remove("nonexistent");
    std.debug.print("  存在しないキー削除: エラーなし\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// イテレーション
// ====================

fn demoIteration() !void {
    std.debug.print("--- イテレーション ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("red");
    try set.insert("green");
    try set.insert("blue");

    std.debug.print("  全要素:\n", .{});
    var it = set.iterator();
    while (it.next()) |key_ptr| {
        std.debug.print("    - {s}\n", .{key_ptr.*});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践: タグ管理
// ====================

fn demoTagManagement() !void {
    std.debug.print("--- 実践: タグ管理 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tags = std.BufSet.init(allocator);
    defer tags.deinit();

    // 記事にタグを追加
    try tags.insert("programming");
    try tags.insert("zig");
    try tags.insert("tutorial");
    try tags.insert("zig"); // 重複は無視される

    std.debug.print("  タグ数: {d}\n", .{tags.count()});

    // 特定のタグがあるか確認
    if (tags.contains("zig")) {
        std.debug.print("  Zig関連の記事です\n", .{});
    }

    // タグを削除
    tags.remove("tutorial");
    std.debug.print("  'tutorial'タグ削除後: {d}個\n", .{tags.count()});

    std.debug.print("\n", .{});
}

// ====================
// 実践: ユニークなID管理
// ====================

fn demoUniqueIdManagement() !void {
    std.debug.print("--- 実践: ユニークなID管理 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var processed_ids = std.BufSet.init(allocator);
    defer processed_ids.deinit();

    const incoming_ids = [_][]const u8{
        "user-001",
        "user-002",
        "user-001", // 重複
        "user-003",
        "user-002", // 重複
    };

    var new_count: usize = 0;
    var duplicate_count: usize = 0;

    for (incoming_ids) |id| {
        if (processed_ids.contains(id)) {
            duplicate_count += 1;
            std.debug.print("  {s}: 重複（スキップ）\n", .{id});
        } else {
            try processed_ids.insert(id);
            new_count += 1;
            std.debug.print("  {s}: 新規処理\n", .{id});
        }
    }

    std.debug.print("  結果: 新規{d}件, 重複{d}件\n", .{ new_count, duplicate_count });

    std.debug.print("\n", .{});
}

// ====================
// clone（複製）
// ====================

fn demoClone() !void {
    std.debug.print("--- clone ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var original = std.BufSet.init(allocator);
    defer original.deinit();

    try original.insert("x");
    try original.insert("y");

    // clone: 独立したコピーを作成
    var cloned = try original.clone();
    defer cloned.deinit();

    // cloneを変更しても元は影響しない
    cloned.remove("x");
    try cloned.insert("z");

    std.debug.print("  original: {d}個 (x,y)\n", .{original.count()});
    std.debug.print("  cloned: {d}個 (y,z)\n", .{cloned.count()});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  作成:\n", .{});
    std.debug.print("    std.BufSet.init(allocator)\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    insert(str)   - 追加（コピーして所有）\n", .{});
    std.debug.print("    contains(str) - 存在確認\n", .{});
    std.debug.print("    remove(str)   - 削除\n", .{});
    std.debug.print("    count()       - 要素数\n", .{});
    std.debug.print("    iterator()    - 走査\n", .{});
    std.debug.print("    clone()       - 複製\n", .{});

    std.debug.print("  用途:\n", .{});
    std.debug.print("    - タグ管理\n", .{});
    std.debug.print("    - 重複排除\n", .{});
    std.debug.print("    - 許可リスト/拒否リスト\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== BufSet ===\n\n", .{});

    try demoBasicUsage();
    try demoDuplicateHandling();
    try demoRemove();
    try demoIteration();
    try demoTagManagement();
    try demoUniqueIdManagement();
    try demoClone();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・文字列をコピーして所有\n", .{});
    std.debug.print("・重複は自動排除\n", .{});
    std.debug.print("・deinitで自動メモリ解放\n", .{});
    std.debug.print("・タグや許可リストに最適\n", .{});
}

// --- テスト ---

test "bufset insert and contains" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("hello");
    try set.insert("world");

    try std.testing.expect(set.contains("hello"));
    try std.testing.expect(set.contains("world"));
    try std.testing.expect(!set.contains("foo"));
}

test "bufset count" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try std.testing.expectEqual(@as(usize, 0), set.count());

    try set.insert("a");
    try std.testing.expectEqual(@as(usize, 1), set.count());

    try set.insert("b");
    try std.testing.expectEqual(@as(usize, 2), set.count());
}

test "bufset duplicate insertion" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("same");
    try set.insert("same");
    try set.insert("same");

    try std.testing.expectEqual(@as(usize, 1), set.count());
}

test "bufset remove" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("key");
    try std.testing.expect(set.contains("key"));

    set.remove("key");
    try std.testing.expect(!set.contains("key"));
}

test "bufset remove nonexistent" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    // 存在しないキーの削除は何もしない
    set.remove("nonexistent");
    try std.testing.expectEqual(@as(usize, 0), set.count());
}

test "bufset iterator" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("a");
    try set.insert("b");

    var count: usize = 0;
    var it = set.iterator();
    while (it.next()) |_| {
        count += 1;
    }

    try std.testing.expectEqual(@as(usize, 2), count);
}

test "bufset clone" {
    const allocator = std.testing.allocator;

    var original = std.BufSet.init(allocator);
    defer original.deinit();

    try original.insert("x");
    try original.insert("y");

    var cloned = try original.clone();
    defer cloned.deinit();

    // クローンを変更しても元は影響しない
    cloned.remove("x");

    try std.testing.expectEqual(@as(usize, 2), original.count());
    try std.testing.expectEqual(@as(usize, 1), cloned.count());
}

test "bufset multiple operations" {
    const allocator = std.testing.allocator;

    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("a");
    try set.insert("b");
    try set.insert("c");
    try std.testing.expectEqual(@as(usize, 3), set.count());

    set.remove("b");
    try std.testing.expectEqual(@as(usize, 2), set.count());

    try set.insert("d");
    try std.testing.expectEqual(@as(usize, 3), set.count());

    try set.insert("a"); // duplicate
    try std.testing.expectEqual(@as(usize, 3), set.count());
}
