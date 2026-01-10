//! # BufMap（文字列キーバリューマップ）
//!
//! BufMapはキーと値の両方が文字列のマップ。
//! StringHashMapと違い、キーと値をコピーして所有する。
//!
//! ## 特徴
//! - キーと値は内部でコピーされる（所有権を取る）
//! - 削除時に自動的にメモリ解放
//! - 環境変数などの文字列ペア管理に最適
//!
//! ## StringHashMapとの違い
//! - StringHashMap: キー・値の所有権はユーザー管理
//! - BufMap: キー・値をコピーして自動管理

const std = @import("std");

// ====================
// 基本的な使い方
// ====================

fn demoBasicUsage() !void {
    std.debug.print("--- 基本的な使い方 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    // put: キーと値を追加（コピーされる）
    try map.put("name", "Alice");
    try map.put("age", "25");
    try map.put("city", "Tokyo");

    std.debug.print("  要素数: {d}\n", .{map.count()});

    // get: 値を取得
    if (map.get("name")) |value| {
        std.debug.print("  name: {s}\n", .{value});
    }

    if (map.get("age")) |value| {
        std.debug.print("  age: {s}\n", .{value});
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

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("status", "pending");
    std.debug.print("  初期: status = {s}\n", .{map.get("status").?});

    // 同じキーでputすると値が更新される
    try map.put("status", "completed");
    std.debug.print("  更新後: status = {s}\n", .{map.get("status").?});

    // 要素数は増えない
    std.debug.print("  要素数: {d}\n", .{map.count()});

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

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("a", "1");
    try map.put("b", "2");
    try map.put("c", "3");

    std.debug.print("  削除前: {d}個\n", .{map.count()});

    // remove: キーで削除（メモリも自動解放）
    map.remove("b");

    std.debug.print("  削除後: {d}個\n", .{map.count()});

    // 削除されたキーはnullを返す
    if (map.get("b")) |_| {
        std.debug.print("  b: 存在\n", .{});
    } else {
        std.debug.print("  b: 削除済み\n", .{});
    }

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

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("PATH", "/usr/bin");
    try map.put("HOME", "/home/user");
    try map.put("LANG", "ja_JP.UTF-8");

    std.debug.print("  全エントリ:\n", .{});
    var it = map.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {s} = {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// 存在確認
// ====================

fn demoExistenceCheck() !void {
    std.debug.print("--- 存在確認 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("key1", "value1");

    // getでnullチェック
    const exists1 = map.get("key1") != null;
    const exists2 = map.get("key2") != null;

    std.debug.print("  key1 exists: {}\n", .{exists1});
    std.debug.print("  key2 exists: {}\n", .{exists2});

    std.debug.print("\n", .{});
}

// ====================
// 実践: 設定管理
// ====================

fn demoConfigManagement() !void {
    std.debug.print("--- 実践: 設定管理 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var config = std.BufMap.init(allocator);
    defer config.deinit();

    // デフォルト設定
    try config.put("host", "localhost");
    try config.put("port", "8080");
    try config.put("timeout", "30");
    try config.put("debug", "false");

    std.debug.print("  設定:\n", .{});
    var it = config.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {s}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // 設定の上書き
    try config.put("debug", "true");
    std.debug.print("  debugを変更: {s}\n", .{config.get("debug").?});

    std.debug.print("\n", .{});
}

// ====================
// getPtr（ポインタ取得）
// ====================

fn demoGetPtr() !void {
    std.debug.print("--- getPtr ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("counter", "100");

    // getPtr: 値へのポインタを取得
    if (map.getPtr("counter")) |ptr| {
        std.debug.print("  値のアドレス: {*}\n", .{ptr});
        std.debug.print("  値: {s}\n", .{ptr.*});
    }

    std.debug.print("\n", .{});
}

// ====================
// StringHashMapとの比較
// ====================

fn demoComparison() void {
    std.debug.print("--- StringHashMapとの比較 ---\n", .{});

    std.debug.print("  StringHashMap:\n", .{});
    std.debug.print("    - キー・値の所有権はユーザー\n", .{});
    std.debug.print("    - 文字列リテラルなど静的データ向け\n", .{});
    std.debug.print("    - メモリ管理は自分で行う\n", .{});

    std.debug.print("  BufMap:\n", .{});
    std.debug.print("    - キー・値をコピーして所有\n", .{});
    std.debug.print("    - 動的な文字列データ向け\n", .{});
    std.debug.print("    - deinit()で自動解放\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  作成:\n", .{});
    std.debug.print("    std.BufMap.init(allocator)\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    put(key, value) - 追加/更新\n", .{});
    std.debug.print("    get(key)        - 取得\n", .{});
    std.debug.print("    getPtr(key)     - ポインタ取得\n", .{});
    std.debug.print("    remove(key)     - 削除\n", .{});
    std.debug.print("    count()         - 要素数\n", .{});
    std.debug.print("    iterator()      - 走査\n", .{});

    std.debug.print("  用途:\n", .{});
    std.debug.print("    - 環境変数管理\n", .{});
    std.debug.print("    - 設定ファイルパース\n", .{});
    std.debug.print("    - HTTPヘッダー管理\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== BufMap ===\n\n", .{});

    try demoBasicUsage();
    try demoUpdate();
    try demoRemove();
    try demoIteration();
    try demoExistenceCheck();
    try demoConfigManagement();
    try demoGetPtr();
    demoComparison();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・キー・値をコピーして所有\n", .{});
    std.debug.print("・deinitで自動メモリ解放\n", .{});
    std.debug.print("・文字列ペア管理に最適\n", .{});
    std.debug.print("・環境変数・設定管理向け\n", .{});
}

// --- テスト ---

test "bufmap put and get" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("key1", "value1");
    try map.put("key2", "value2");

    try std.testing.expectEqualStrings("value1", map.get("key1").?);
    try std.testing.expectEqualStrings("value2", map.get("key2").?);
}

test "bufmap count" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try std.testing.expectEqual(@as(u32, 0), map.count());

    try map.put("a", "1");
    try std.testing.expectEqual(@as(u32, 1), map.count());

    try map.put("b", "2");
    try std.testing.expectEqual(@as(u32, 2), map.count());
}

test "bufmap update" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("key", "value1");
    try map.put("key", "value2");

    try std.testing.expectEqualStrings("value2", map.get("key").?);
    try std.testing.expectEqual(@as(u32, 1), map.count());
}

test "bufmap remove" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("key", "value");
    try std.testing.expect(map.get("key") != null);

    map.remove("key");
    try std.testing.expect(map.get("key") == null);
}

test "bufmap nonexistent key" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try std.testing.expect(map.get("nonexistent") == null);
}

test "bufmap iterator" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("a", "1");
    try map.put("b", "2");

    var count: usize = 0;
    var it = map.iterator();
    while (it.next()) |_| {
        count += 1;
    }

    try std.testing.expectEqual(@as(usize, 2), count);
}

test "bufmap getPtr" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("key", "value");

    const ptr = map.getPtr("key");
    try std.testing.expect(ptr != null);
    try std.testing.expectEqualStrings("value", ptr.?.*);
}

test "bufmap remove nonexistent" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    // 存在しないキーの削除は何もしない
    map.remove("nonexistent");
    try std.testing.expectEqual(@as(u32, 0), map.count());
}

test "bufmap multiple operations" {
    const allocator = std.testing.allocator;

    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("a", "1");
    try map.put("b", "2");
    try map.put("c", "3");

    try std.testing.expectEqual(@as(u32, 3), map.count());

    map.remove("b");
    try std.testing.expectEqual(@as(u32, 2), map.count());

    try map.put("d", "4");
    try std.testing.expectEqual(@as(u32, 3), map.count());

    try map.put("a", "10"); // update
    try std.testing.expectEqualStrings("10", map.get("a").?);
    try std.testing.expectEqual(@as(u32, 3), map.count());
}
