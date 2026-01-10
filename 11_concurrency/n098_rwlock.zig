//! # 読み書きロック (RwLock)
//!
//! 複数リーダー・単一ライターのロック機構。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n098_rwlock.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - RwLock の概念と利点
//! - lockShared() / unlockShared() - 読み取りロック
//! - lock() / unlock() - 書き込みロック
//! - Mutex との使い分け

const std = @import("std");
const Thread = std.Thread;
const RwLock = std.Thread.RwLock;

// ====================
// 1. RwLock の概念
// ====================

fn demoRwLockConcept() void {
    std.debug.print("=== 1. RwLock の概念 ===\n\n", .{});

    std.debug.print("【RwLock (Read-Write Lock) とは】\n", .{});
    std.debug.print("  読み取り: 複数スレッドが同時にアクセス可能\n", .{});
    std.debug.print("  書き込み: 1つのスレッドだけがアクセス\n", .{});

    std.debug.print("\n【Mutex との違い】\n", .{});
    std.debug.print("  Mutex  : 常に1スレッドのみ（読み書き問わず）\n", .{});
    std.debug.print("  RwLock : 読み取り時は複数同時OK\n", .{});

    std.debug.print("\n【使いどころ】\n", .{});
    std.debug.print("  読み取りが多く、書き込みが少ない場合\n", .{});
    std.debug.print("  例: 設定値、キャッシュ、参照テーブル\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 基本的な使い方
// ====================

var shared_value: u32 = 0;
var rw_lock: RwLock = .{};

fn reader(id: u8) void {
    for (0..3) |i| {
        // 読み取りロック（共有ロック）
        rw_lock.lockShared();
        const val = shared_value;
        std.debug.print("  Reader {d}: 値 = {d} (読み取り {d}回目)\n", .{ id, val, i + 1 });
        rw_lock.unlockShared();

        Thread.sleep(20 * std.time.ns_per_ms);
    }
}

fn writer() void {
    for (0..3) |i| {
        Thread.sleep(30 * std.time.ns_per_ms);

        // 書き込みロック（排他ロック）
        rw_lock.lock();
        shared_value += 10;
        std.debug.print("  Writer: 値を更新 → {d} ({d}回目)\n", .{ shared_value, i + 1 });
        rw_lock.unlock();
    }
}

fn demoBasicUsage() void {
    std.debug.print("=== 2. 基本的な使い方 ===\n\n", .{});

    shared_value = 0;

    std.debug.print("【読み取りロック】\n", .{});
    std.debug.print("  rw_lock.lockShared();\n", .{});
    std.debug.print("  defer rw_lock.unlockShared();\n", .{});

    std.debug.print("\n【書き込みロック】\n", .{});
    std.debug.print("  rw_lock.lock();\n", .{});
    std.debug.print("  defer rw_lock.unlock();\n", .{});

    std.debug.print("\n【実行例】\n", .{});

    // 複数のリーダーと1つのライター
    const r1 = Thread.spawn(.{}, reader, .{1}) catch return;
    const r2 = Thread.spawn(.{}, reader, .{2}) catch return;
    const w = Thread.spawn(.{}, writer, .{}) catch return;

    r1.join();
    r2.join();
    w.join();

    std.debug.print("\n最終値: {d}\n\n", .{shared_value});
}

// ====================
// 3. defer パターン
// ====================

fn demoDefer() void {
    std.debug.print("=== 3. defer パターン ===\n\n", .{});

    var lock: RwLock = .{};
    var data: u32 = 100;

    // 読み取り
    {
        lock.lockShared();
        defer lock.unlockShared();

        std.debug.print("読み取り: {d}\n", .{data});
        // 早期リターンしても自動解放
    }

    // 書き込み
    {
        lock.lock();
        defer lock.unlock();

        data = 200;
        std.debug.print("書き込み後: {d}\n", .{data});
    }

    std.debug.print("\n", .{});
}

// ====================
// 4. tryLock
// ====================

fn demoTryLock() void {
    std.debug.print("=== 4. tryLock ===\n\n", .{});

    std.debug.print("【tryLockShared()】\n", .{});
    std.debug.print("  読み取りロックを非ブロッキングで試行\n", .{});

    std.debug.print("\n【tryLock()】\n", .{});
    std.debug.print("  書き込みロックを非ブロッキングで試行\n", .{});

    var lock: RwLock = .{};

    // 読み取りロックを試行
    if (lock.tryLockShared()) {
        std.debug.print("\ntryLockShared: 成功\n", .{});
        lock.unlockShared();
    }

    // 書き込みロックを試行
    if (lock.tryLock()) {
        std.debug.print("tryLock: 成功\n", .{});
        lock.unlock();
    }

    std.debug.print("\n", .{});
}

// ====================
// 5. スレッドセーフなキャッシュ
// ====================

const Cache = struct {
    data: std.StringHashMap(i32),
    lock: RwLock,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) Self {
        return .{
            .data = std.StringHashMap(i32).init(allocator),
            .lock = .{},
        };
    }

    fn deinit(self: *Self) void {
        self.data.deinit();
    }

    // 読み取り（複数同時OK）
    fn get(self: *Self, key: []const u8) ?i32 {
        self.lock.lockShared();
        defer self.lock.unlockShared();
        return self.data.get(key);
    }

    // 書き込み（排他）
    fn put(self: *Self, key: []const u8, value: i32) !void {
        self.lock.lock();
        defer self.lock.unlock();
        try self.data.put(key, value);
    }

    // 削除（排他）
    fn remove(self: *Self, key: []const u8) bool {
        self.lock.lock();
        defer self.lock.unlock();
        return self.data.remove(key);
    }
};

fn demoCachePattern() void {
    std.debug.print("=== 5. スレッドセーフなキャッシュ ===\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var cache = Cache.init(gpa.allocator());
    defer cache.deinit();

    // データを追加
    cache.put("apple", 100) catch {};
    cache.put("banana", 200) catch {};

    std.debug.print("apple = {?d}\n", .{cache.get("apple")});
    std.debug.print("banana = {?d}\n", .{cache.get("banana")});
    std.debug.print("cherry = {?d}\n", .{cache.get("cherry")});

    std.debug.print("\n", .{});
}

// ====================
// 6. 読み取り重視のシナリオ
// ====================

const Config = struct {
    value: u32,
    lock: RwLock,

    const Self = @This();

    fn init(initial: u32) Self {
        return .{
            .value = initial,
            .lock = .{},
        };
    }

    fn read(self: *Self) u32 {
        self.lock.lockShared();
        defer self.lock.unlockShared();
        return self.value;
    }

    fn update(self: *Self, new_value: u32) void {
        self.lock.lock();
        defer self.lock.unlock();
        self.value = new_value;
    }
};

fn configReader(config: *Config, id: u8) void {
    for (0..5) |_| {
        const val = config.read();
        std.debug.print("  Reader {d}: config = {d}\n", .{ id, val });
        Thread.sleep(10 * std.time.ns_per_ms);
    }
}

fn configWriter(config: *Config) void {
    Thread.sleep(25 * std.time.ns_per_ms);
    config.update(999);
    std.debug.print("  Writer: config を 999 に更新\n", .{});
}

fn demoReadHeavy() void {
    std.debug.print("=== 6. 読み取り重視のシナリオ ===\n\n", .{});

    var config = Config.init(42);

    std.debug.print("【利点】読み取りが多い場合に効率的\n\n", .{});

    const r1 = Thread.spawn(.{}, configReader, .{ &config, 1 }) catch return;
    const r2 = Thread.spawn(.{}, configReader, .{ &config, 2 }) catch return;
    const r3 = Thread.spawn(.{}, configReader, .{ &config, 3 }) catch return;
    const w = Thread.spawn(.{}, configWriter, .{&config}) catch return;

    r1.join();
    r2.join();
    r3.join();
    w.join();

    std.debug.print("\n最終: config = {d}\n\n", .{config.read()});
}

// ====================
// 7. Mutex vs RwLock
// ====================

fn demoComparison() void {
    std.debug.print("=== 7. Mutex vs RwLock ===\n\n", .{});

    std.debug.print("【Mutex を使う場合】\n", .{});
    std.debug.print("  - 読み書きの比率が同程度\n", .{});
    std.debug.print("  - ロック時間が短い\n", .{});
    std.debug.print("  - シンプルさ優先\n", .{});

    std.debug.print("\n【RwLock を使う場合】\n", .{});
    std.debug.print("  - 読み取りが書き込みより多い\n", .{});
    std.debug.print("  - 同時読み取りで性能向上が見込める\n", .{});
    std.debug.print("  - 例: 設定、キャッシュ、統計情報\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - RwLock は Mutex より複雑\n", .{});
    std.debug.print("  - オーバーヘッドがやや大きい\n", .{});
    std.debug.print("  - 迷ったらまず Mutex を試す\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== RwLock まとめ ===\n\n", .{});

    std.debug.print("【読み取りロック】\n", .{});
    std.debug.print("  lock.lockShared();\n", .{});
    std.debug.print("  defer lock.unlockShared();\n", .{});
    std.debug.print("  複数スレッドが同時に取得可能\n", .{});

    std.debug.print("\n【書き込みロック】\n", .{});
    std.debug.print("  lock.lock();\n", .{});
    std.debug.print("  defer lock.unlock();\n", .{});
    std.debug.print("  排他的（他のロックを待つ）\n", .{});

    std.debug.print("\n【tryLock】\n", .{});
    std.debug.print("  tryLockShared()  // 非ブロッキング読み取り\n", .{});
    std.debug.print("  tryLock()        // 非ブロッキング書き込み\n", .{});

    std.debug.print("\n【使いどころ】\n", .{});
    std.debug.print("  読み取り >> 書き込み のデータ構造\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoRwLockConcept();
    demoBasicUsage();
    demoDefer();
    demoTryLock();
    demoCachePattern();
    demoReadHeavy();
    demoComparison();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n099_atomic: アトミック操作\n", .{});
}

// ====================
// テスト
// ====================

test "RwLock basic shared lock" {
    var lock: RwLock = .{};
    lock.lockShared();
    lock.unlockShared();
}

test "RwLock basic exclusive lock" {
    var lock: RwLock = .{};
    lock.lock();
    lock.unlock();
}

test "RwLock multiple readers" {
    var lock: RwLock = .{};
    var value: u32 = 42;

    const Reader = struct {
        fn read(l: *RwLock, v: *u32, result: *u32) void {
            l.lockShared();
            defer l.unlockShared();
            result.* = v.*;
        }
    };

    var r1: u32 = 0;
    var r2: u32 = 0;

    const t1 = try Thread.spawn(.{}, Reader.read, .{ &lock, &value, &r1 });
    const t2 = try Thread.spawn(.{}, Reader.read, .{ &lock, &value, &r2 });

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 42), r1);
    try std.testing.expectEqual(@as(u32, 42), r2);
}

test "tryLockShared returns true when available" {
    var lock: RwLock = .{};
    try std.testing.expect(lock.tryLockShared());
    lock.unlockShared();
}

test "tryLock returns true when available" {
    var lock: RwLock = .{};
    try std.testing.expect(lock.tryLock());
    lock.unlock();
}

test "Config struct thread safety" {
    var config = Config.init(100);

    const Worker = struct {
        fn work(c: *Config) void {
            for (0..10) |_| {
                _ = c.read();
            }
        }
    };

    const t1 = try Thread.spawn(.{}, Worker.work, .{&config});
    const t2 = try Thread.spawn(.{}, Worker.work, .{&config});

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 100), config.read());
}
