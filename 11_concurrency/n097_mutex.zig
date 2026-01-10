//! # ミューテックス
//!
//! Mutex を使った排他制御とデータ競合の防止。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n097_mutex.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - データ競合（Race Condition）の問題
//! - std.Thread.Mutex の基本
//! - lock() と unlock()
//! - defer を使ったアンロック
//! - デッドロックの回避

const std = @import("std");
const Thread = std.Thread;
const Mutex = std.Thread.Mutex;

// ====================
// 1. データ競合の問題
// ====================

fn demoDataRace() void {
    std.debug.print("=== 1. データ競合の問題 ===\n\n", .{});

    std.debug.print("【データ競合とは】\n", .{});
    std.debug.print("  複数スレッドが同時に同じメモリにアクセスし、\n", .{});
    std.debug.print("  少なくとも1つが書き込みを行う状況\n", .{});

    std.debug.print("\n【問題のあるコード例】\n", .{});
    std.debug.print("  var counter: u32 = 0;\n", .{});
    std.debug.print("  // スレッド1: counter += 1;  // 読み→加算→書き\n", .{});
    std.debug.print("  // スレッド2: counter += 1;  // 同時に実行\n", .{});
    std.debug.print("  // 結果: 2ではなく1になる可能性！\n", .{});

    std.debug.print("\n【解決策】\n", .{});
    std.debug.print("  Mutex で排他制御を行う\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. Mutex の基本
// ====================

var shared_counter: u32 = 0;
var counter_mutex: Mutex = .{};

fn incrementWithMutex() void {
    for (0..1000) |_| {
        // ロックを取得
        counter_mutex.lock();
        // クリティカルセクション（排他区間）
        shared_counter += 1;
        // ロックを解放
        counter_mutex.unlock();
    }
}

fn demoMutexBasics() void {
    std.debug.print("=== 2. Mutex の基本 ===\n\n", .{});

    shared_counter = 0;

    std.debug.print("[Main] 初期値: {d}\n", .{shared_counter});

    // 2つのスレッドを起動
    const t1 = Thread.spawn(.{}, incrementWithMutex, .{}) catch return;
    const t2 = Thread.spawn(.{}, incrementWithMutex, .{}) catch return;

    t1.join();
    t2.join();

    std.debug.print("[Main] 最終値: {d}\n", .{shared_counter});
    std.debug.print("[Main] 期待値: 2000\n", .{});

    if (shared_counter == 2000) {
        std.debug.print("[Main] 正しい結果！\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 3. defer でアンロック
// ====================

fn incrementWithDefer(mutex: *Mutex, counter: *u32) void {
    for (0..1000) |_| {
        mutex.lock();
        defer mutex.unlock(); // 確実にアンロック

        // 複雑な処理でも安全
        counter.* += 1;
        if (counter.* % 500 == 0) {
            // 早期リターンしても defer で解放される
        }
    }
}

fn demoDeferUnlock() void {
    std.debug.print("=== 3. defer でアンロック ===\n\n", .{});

    std.debug.print("【推奨パターン】\n", .{});
    std.debug.print("  mutex.lock();\n", .{});
    std.debug.print("  defer mutex.unlock();  // 確実に解放\n", .{});
    std.debug.print("  // ... クリティカルセクション ...\n", .{});

    var mutex: Mutex = .{};
    var counter: u32 = 0;

    const t1 = Thread.spawn(.{}, incrementWithDefer, .{ &mutex, &counter }) catch return;
    const t2 = Thread.spawn(.{}, incrementWithDefer, .{ &mutex, &counter }) catch return;

    t1.join();
    t2.join();

    std.debug.print("カウンタ: {d} (期待値: 2000)\n\n", .{counter});
}

// ====================
// 4. tryLock
// ====================

fn demoTryLock() void {
    std.debug.print("=== 4. tryLock ===\n\n", .{});

    std.debug.print("【tryLock()】\n", .{});
    std.debug.print("  ブロックせずにロック取得を試みる\n", .{});
    std.debug.print("  true: ロック取得成功\n", .{});
    std.debug.print("  false: 他がロック中\n", .{});

    var mutex: Mutex = .{};

    // 最初の tryLock は成功するはず
    if (mutex.tryLock()) {
        std.debug.print("\n最初の tryLock: 成功\n", .{});

        // 2回目は失敗するはず（自己デッドロック防止）
        // ただし同一スレッドでの二重ロックは未定義動作
        // ここでは別の例を示す

        mutex.unlock();
        std.debug.print("アンロック完了\n", .{});
    }

    // 再度 tryLock（成功）
    if (mutex.tryLock()) {
        std.debug.print("再度 tryLock: 成功\n", .{});
        mutex.unlock();
    }

    std.debug.print("\n", .{});
}

// ====================
// 5. 保護されたデータ構造
// ====================

const ThreadSafeCounter = struct {
    value: u32,
    mutex: Mutex,

    const Self = @This();

    fn init() Self {
        return .{
            .value = 0,
            .mutex = .{},
        };
    }

    fn increment(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.value += 1;
    }

    fn decrement(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.value > 0) {
            self.value -= 1;
        }
    }

    fn get(self: *Self) u32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.value;
    }
};

fn workerIncrement(counter: *ThreadSafeCounter) void {
    for (0..500) |_| {
        counter.increment();
    }
}

fn demoThreadSafeStruct() void {
    std.debug.print("=== 5. 保護されたデータ構造 ===\n\n", .{});

    std.debug.print("【設計パターン】\n", .{});
    std.debug.print("  構造体にMutexを含める\n", .{});
    std.debug.print("  メソッド内でロック/アンロック\n", .{});

    var counter = ThreadSafeCounter.init();

    const t1 = Thread.spawn(.{}, workerIncrement, .{&counter}) catch return;
    const t2 = Thread.spawn(.{}, workerIncrement, .{&counter}) catch return;
    const t3 = Thread.spawn(.{}, workerIncrement, .{&counter}) catch return;

    t1.join();
    t2.join();
    t3.join();

    std.debug.print("\n最終値: {d} (期待値: 1500)\n\n", .{counter.get()});
}

// ====================
// 6. デッドロック
// ====================

fn demoDeadlock() void {
    std.debug.print("=== 6. デッドロック ===\n\n", .{});

    std.debug.print("【デッドロックとは】\n", .{});
    std.debug.print("  2つ以上のスレッドが互いのロック解放を待つ状態\n", .{});

    std.debug.print("\n【危険なパターン】\n", .{});
    std.debug.print("  // スレッド1:\n", .{});
    std.debug.print("  mutex_a.lock();\n", .{});
    std.debug.print("  mutex_b.lock();  // Bを待つ\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("  // スレッド2:\n", .{});
    std.debug.print("  mutex_b.lock();\n", .{});
    std.debug.print("  mutex_a.lock();  // Aを待つ → デッドロック！\n", .{});

    std.debug.print("\n【回避策】\n", .{});
    std.debug.print("  1. ロック順序を統一する\n", .{});
    std.debug.print("     常に A → B の順でロック\n", .{});
    std.debug.print("  2. tryLock + リトライ\n", .{});
    std.debug.print("  3. ロックのスコープを最小化\n", .{});
    std.debug.print("  4. 1つのMutexで複数リソースを保護\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. ロック順序の統一
// ====================

var mutex_a: Mutex = .{};
var mutex_b: Mutex = .{};
var resource_a: u32 = 0;
var resource_b: u32 = 0;

fn safeWorker1() void {
    // 常に A → B の順でロック
    mutex_a.lock();
    defer mutex_a.unlock();

    mutex_b.lock();
    defer mutex_b.unlock();

    resource_a += 1;
    resource_b += 1;
}

fn safeWorker2() void {
    // 同じく A → B の順でロック（重要！）
    mutex_a.lock();
    defer mutex_a.unlock();

    mutex_b.lock();
    defer mutex_b.unlock();

    resource_a += 2;
    resource_b += 2;
}

fn demoLockOrdering() void {
    std.debug.print("=== 7. ロック順序の統一 ===\n\n", .{});

    resource_a = 0;
    resource_b = 0;

    const t1 = Thread.spawn(.{}, safeWorker1, .{}) catch return;
    const t2 = Thread.spawn(.{}, safeWorker2, .{}) catch return;

    t1.join();
    t2.join();

    std.debug.print("resource_a: {d}\n", .{resource_a});
    std.debug.print("resource_b: {d}\n", .{resource_b});
    std.debug.print("デッドロックなし！\n\n", .{});
}

// ====================
// 8. 粒度の最適化
// ====================

fn demoGranularity() void {
    std.debug.print("=== 8. 粒度の最適化 ===\n\n", .{});

    std.debug.print("【粗粒度ロック】\n", .{});
    std.debug.print("  1つのMutexで全体を保護\n", .{});
    std.debug.print("  長所: シンプル、デッドロックしにくい\n", .{});
    std.debug.print("  短所: 並列性が低下\n", .{});

    std.debug.print("\n【細粒度ロック】\n", .{});
    std.debug.print("  要素ごとにMutexを持つ\n", .{});
    std.debug.print("  長所: 並列性が向上\n", .{});
    std.debug.print("  短所: 複雑、デッドロックのリスク\n", .{});

    std.debug.print("\n【指針】\n", .{});
    std.debug.print("  まず粗粒度で正しく動かす\n", .{});
    std.debug.print("  必要なら測定して細粒度化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== Mutex まとめ ===\n\n", .{});

    std.debug.print("【基本操作】\n", .{});
    std.debug.print("  var mutex: Mutex = .{{}};\n", .{});
    std.debug.print("  mutex.lock();      // ロック取得\n", .{});
    std.debug.print("  defer mutex.unlock();  // 確実に解放\n", .{});

    std.debug.print("\n【ノンブロッキング】\n", .{});
    std.debug.print("  if (mutex.tryLock()) {{ ... }}\n", .{});

    std.debug.print("\n【設計パターン】\n", .{});
    std.debug.print("  構造体 + Mutex = スレッドセーフ型\n", .{});

    std.debug.print("\n【デッドロック回避】\n", .{});
    std.debug.print("  - ロック順序を統一\n", .{});
    std.debug.print("  - スコープを最小化\n", .{});
    std.debug.print("  - defer でアンロック\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoDataRace();
    demoMutexBasics();
    demoDeferUnlock();
    demoTryLock();
    demoThreadSafeStruct();
    demoDeadlock();
    demoLockOrdering();
    demoGranularity();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n098_rwlock: 読み書きロック\n", .{});
}

// ====================
// テスト
// ====================

test "Mutex basic lock/unlock" {
    var mutex: Mutex = .{};
    mutex.lock();
    mutex.unlock();
    // エラーなく完了すればOK
}

test "Mutex protects shared data" {
    var mutex: Mutex = .{};
    var counter: u32 = 0;

    const Worker = struct {
        fn work(m: *Mutex, c: *u32) void {
            for (0..100) |_| {
                m.lock();
                defer m.unlock();
                c.* += 1;
            }
        }
    };

    const t1 = try Thread.spawn(.{}, Worker.work, .{ &mutex, &counter });
    const t2 = try Thread.spawn(.{}, Worker.work, .{ &mutex, &counter });

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 200), counter);
}

test "tryLock returns true when available" {
    var mutex: Mutex = .{};
    try std.testing.expect(mutex.tryLock());
    mutex.unlock();
}

test "ThreadSafeCounter" {
    var counter = ThreadSafeCounter.init();

    const Worker = struct {
        fn work(c: *ThreadSafeCounter) void {
            for (0..50) |_| {
                c.increment();
            }
        }
    };

    const t1 = try Thread.spawn(.{}, Worker.work, .{&counter});
    const t2 = try Thread.spawn(.{}, Worker.work, .{&counter});

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 100), counter.get());
}
