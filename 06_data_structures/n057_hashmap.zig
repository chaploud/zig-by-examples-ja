//! # HashMap
//!
//! HashMapはキーと値のペアを格納するデータ構造。
//! ハッシュ関数により高速な検索・挿入・削除を実現する。
//!
//! ## 種類
//! - AutoHashMap: 汎用的なハッシュマップ
//! - StringHashMap: 文字列キー専用
//! - AutoArrayHashMap: 挿入順序を保持
//! - StringArrayHashMap: 文字列キー＋挿入順序保持
//!
//! ## 主要API
//! - put: キーと値を追加
//! - get: キーから値を取得
//! - remove: キーで削除
//! - iterator: 全エントリを走査

const std = @import("std");

// ====================
// 基本: AutoHashMap
// ====================

fn demoAutoHashMap() !void {
    std.debug.print("--- AutoHashMap ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // AutoHashMap(キー型, 値型)
    var map = std.AutoHashMap(u32, u16).init(allocator);
    defer map.deinit();

    // put: キーと値を追加
    try map.put(54321, 89);
    try map.put(50050, 55);
    try map.put(57709, 41);

    std.debug.print("  格納数: {d}\n", .{map.count()});

    // get: キーから値を取得（Optional）
    if (map.get(50050)) |value| {
        std.debug.print("  key=50050: {d}\n", .{value});
    }

    // 存在しないキー
    if (map.get(99999)) |_| {
        std.debug.print("  key=99999: 見つかった\n", .{});
    } else {
        std.debug.print("  key=99999: 見つからない\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 値の削除
// ====================

fn demoRemove() !void {
    std.debug.print("--- 値の削除 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u32, []const u8).init(allocator);
    defer map.deinit();

    try map.put(1, "one");
    try map.put(2, "two");
    try map.put(3, "three");

    std.debug.print("  削除前: {d}個\n", .{map.count()});

    // remove: 削除成功でtrue
    const removed = map.remove(2);
    std.debug.print("  remove(2): {}\n", .{removed});

    std.debug.print("  削除後: {d}個\n", .{map.count()});

    // fetchRemove: 削除しつつ値を取得
    if (map.fetchRemove(1)) |kv| {
        std.debug.print("  fetchRemove(1): {s}\n", .{kv.value});
    }

    std.debug.print("  最終: {d}個\n", .{map.count()});

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

    var map = std.AutoHashMap(u32, u16).init(allocator);
    defer map.deinit();

    try map.put(100, 10);
    try map.put(200, 20);
    try map.put(300, 30);

    // iterator: 全エントリを走査
    std.debug.print("  全エントリ:\n", .{});
    var it = map.iterator();
    while (it.next()) |entry| {
        std.debug.print("    key={d}, value={d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // keyIterator: キーのみ
    std.debug.print("  キーのみ: ", .{});
    var kit = map.keyIterator();
    while (kit.next()) |key_ptr| {
        std.debug.print("{d} ", .{key_ptr.*});
    }
    std.debug.print("\n", .{});

    // valueIterator: 値のみ
    std.debug.print("  値のみ: ", .{});
    var vit = map.valueIterator();
    while (vit.next()) |value_ptr| {
        std.debug.print("{d} ", .{value_ptr.*});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// StringHashMap
// ====================

fn demoStringHashMap() !void {
    std.debug.print("--- StringHashMap ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // StringHashMap: 文字列をキーにできる
    var ages = std.StringHashMap(u8).init(allocator);
    defer ages.deinit();

    try ages.put("Alice", 25);
    try ages.put("Bob", 30);
    try ages.put("Charlie", 35);

    // 文字列キーで検索
    if (ages.get("Alice")) |age| {
        std.debug.print("  Aliceの年齢: {d}\n", .{age});
    }

    std.debug.print("  全員:\n", .{});
    var it = ages.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {s}: {d}歳\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// ArrayHashMap（挿入順序保持）
// ====================

fn demoArrayHashMap() !void {
    std.debug.print("--- AutoArrayHashMap（挿入順序保持） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // AutoArrayHashMap: 挿入順序を保持
    var map = std.AutoArrayHashMap(u32, []const u8).init(allocator);
    defer map.deinit();

    try map.put(3, "Third");
    try map.put(1, "First");
    try map.put(2, "Second");

    // イテレーションは挿入順
    std.debug.print("  挿入順に出力:\n", .{});
    var it = map.iterator();
    while (it.next()) |entry| {
        std.debug.print("    key={d}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // keys/values でスライスアクセス可能
    std.debug.print("  キー配列: ", .{});
    for (map.keys()) |key| {
        std.debug.print("{d} ", .{key});
    }
    std.debug.print("\n", .{});

    // swapRemove: 順序を保持しない削除（高速）
    map.swapRemove(3);
    std.debug.print("  swapRemove(3)後: ", .{});
    for (map.keys()) |key| {
        std.debug.print("{d} ", .{key});
    }
    std.debug.print("（順序変更あり）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// StringArrayHashMap
// ====================

fn demoStringArrayHashMap() !void {
    std.debug.print("--- StringArrayHashMap ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // StringArrayHashMap: 文字列キー＋挿入順序保持
    var map = std.StringArrayHashMap(f32).init(allocator);
    defer map.deinit();

    try map.put("height", 175.5);
    try map.put("weight", 70.2);
    try map.put("age", 25.0);

    std.debug.print("  挿入順:\n", .{});
    var it = map.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {s}: {d:.1}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// getOrPut（取得または挿入）
// ====================

fn demoGetOrPut() !void {
    std.debug.print("--- getOrPut ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var counts = std.AutoHashMap(u8, u32).init(allocator);
    defer counts.deinit();

    // カウンター的な使い方
    const data = [_]u8{ 1, 2, 1, 3, 1, 2 };

    for (data) |item| {
        // getOrPut: 存在すれば取得、なければ新規作成
        const result = try counts.getOrPut(item);
        if (result.found_existing) {
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }

    std.debug.print("  カウント結果:\n", .{});
    var it = counts.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {d}: {d}回\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// 値の更新
// ====================

fn demoUpdate() !void {
    std.debug.print("--- 値の更新 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u32, i32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    std.debug.print("  初期値: {d}\n", .{map.get(1).?});

    // putで上書き
    try map.put(1, 200);
    std.debug.print("  上書き後: {d}\n", .{map.get(1).?});

    // getPtrで直接変更
    if (map.getPtr(1)) |ptr| {
        ptr.* += 50;
    }
    std.debug.print("  getPtr変更後: {d}\n", .{map.get(1).?});

    std.debug.print("\n", .{});
}

// ====================
// contains（存在確認）
// ====================

fn demoContains() !void {
    std.debug.print("--- contains ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    try map.put(2, 200);

    // contains: キーの存在確認
    std.debug.print("  contains(1): {}\n", .{map.contains(1)});
    std.debug.print("  contains(3): {}\n", .{map.contains(3)});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  HashMap種類:\n", .{});
    std.debug.print("    AutoHashMap(K, V)     - 汎用\n", .{});
    std.debug.print("    StringHashMap(V)      - 文字列キー\n", .{});
    std.debug.print("    AutoArrayHashMap(K,V) - 挿入順序保持\n", .{});
    std.debug.print("    StringArrayHashMap(V) - 文字列+順序保持\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    put(k, v)  - 追加/更新\n", .{});
    std.debug.print("    get(k)     - 取得（Optional）\n", .{});
    std.debug.print("    getPtr(k)  - ポインタ取得\n", .{});
    std.debug.print("    remove(k)  - 削除\n", .{});
    std.debug.print("    contains(k)- 存在確認\n", .{});
    std.debug.print("    getOrPut(k)- 取得or作成\n", .{});
    std.debug.print("    iterator() - 走査\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== HashMap ===\n\n", .{});

    try demoAutoHashMap();
    try demoRemove();
    try demoIteration();
    try demoStringHashMap();
    try demoArrayHashMap();
    try demoStringArrayHashMap();
    try demoGetOrPut();
    try demoUpdate();
    try demoContains();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・HashMapは順序を保証しない\n", .{});
    std.debug.print("・順序が必要ならArrayHashMap\n", .{});
    std.debug.print("・文字列キーはStringHashMap\n", .{});
    std.debug.print("・deinit()で必ず解放\n", .{});
}

// --- テスト ---

test "hashmap put and get" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    try map.put(2, 200);

    try std.testing.expectEqual(@as(?u32, 100), map.get(1));
    try std.testing.expectEqual(@as(?u32, 200), map.get(2));
    try std.testing.expectEqual(@as(?u32, null), map.get(3));
}

test "hashmap count" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try std.testing.expectEqual(@as(u32, 0), map.count());

    try map.put(1, 100);
    try std.testing.expectEqual(@as(u32, 1), map.count());

    try map.put(2, 200);
    try std.testing.expectEqual(@as(u32, 2), map.count());
}

test "hashmap remove" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    try map.put(2, 200);

    const removed = map.remove(1);
    try std.testing.expect(removed);
    try std.testing.expectEqual(@as(?u32, null), map.get(1));
    try std.testing.expectEqual(@as(u32, 1), map.count());
}

test "hashmap contains" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);

    try std.testing.expect(map.contains(1));
    try std.testing.expect(!map.contains(2));
}

test "hashmap getOrPut" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    // 新規作成
    const result1 = try map.getOrPut(1);
    try std.testing.expect(!result1.found_existing);
    result1.value_ptr.* = 100;

    // 既存取得
    const result2 = try map.getOrPut(1);
    try std.testing.expect(result2.found_existing);
    try std.testing.expectEqual(@as(u32, 100), result2.value_ptr.*);
}

test "hashmap getPtr" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);

    if (map.getPtr(1)) |ptr| {
        ptr.* = 200;
    }

    try std.testing.expectEqual(@as(?u32, 200), map.get(1));
}

test "hashmap fetchRemove" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);

    if (map.fetchRemove(1)) |kv| {
        try std.testing.expectEqual(@as(u32, 1), kv.key);
        try std.testing.expectEqual(@as(u32, 100), kv.value);
    } else {
        try std.testing.expect(false);
    }

    try std.testing.expectEqual(@as(u32, 0), map.count());
}

test "stringhashmap basic" {
    const allocator = std.testing.allocator;

    var map = std.StringHashMap(u32).init(allocator);
    defer map.deinit();

    try map.put("hello", 1);
    try map.put("world", 2);

    try std.testing.expectEqual(@as(?u32, 1), map.get("hello"));
    try std.testing.expectEqual(@as(?u32, 2), map.get("world"));
}

test "arrayhashmap preserves order" {
    const allocator = std.testing.allocator;

    var map = std.AutoArrayHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(3, 300);
    try map.put(1, 100);
    try map.put(2, 200);

    const keys = map.keys();
    try std.testing.expectEqual(@as(u32, 3), keys[0]);
    try std.testing.expectEqual(@as(u32, 1), keys[1]);
    try std.testing.expectEqual(@as(u32, 2), keys[2]);
}

test "hashmap iteration" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    try map.put(2, 200);

    var sum: u32 = 0;
    var it = map.iterator();
    while (it.next()) |entry| {
        sum += entry.value_ptr.*;
    }

    try std.testing.expectEqual(@as(u32, 300), sum);
}

test "hashmap put overwrites" {
    const allocator = std.testing.allocator;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    try map.put(1, 100);
    try map.put(1, 200);

    try std.testing.expectEqual(@as(?u32, 200), map.get(1));
    try std.testing.expectEqual(@as(u32, 1), map.count());
}
