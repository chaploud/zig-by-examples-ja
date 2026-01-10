//! # Futex（低レベル同期）
//!
//! OSカーネルを使った効率的なスレッド待機。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n103_futex.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - Futex の概念と用途
//! - wait() と wake()
//! - タイムアウト付き待機
//! - 高レベルプリミティブの実装
//!
//! 注意: Futexは低レベルAPI。通常はMutex/WaitGroupを使用

const std = @import("std");
const Thread = std.Thread;
const Futex = std.Thread.Futex;
const Atomic = std.atomic;

// ====================
// 1. Futex の概念
// ====================

fn demoFutexConcept() void {
    std.debug.print("=== 1. Futex の概念 ===\n\n", .{});

    std.debug.print("【Futex とは】\n", .{});
    std.debug.print("  Fast Userspace Mutex の略\n", .{});
    std.debug.print("  Linuxで生まれた低レベル同期機構\n", .{});

    std.debug.print("\n【基本動作】\n", .{});
    std.debug.print("  wait(): 値が期待値と一致したらスリープ\n", .{});
    std.debug.print("  wake(): スリープ中のスレッドを起こす\n", .{});

    std.debug.print("\n【特徴】\n", .{});
    std.debug.print("  - 32bitアドレスをキーに使用\n", .{});
    std.debug.print("  - ユーザー空間でまず検査\n", .{});
    std.debug.print("  - 必要な時だけカーネル呼び出し\n", .{});

    std.debug.print("\n【用途】\n", .{});
    std.debug.print("  Mutex, Semaphore, Condition Variable等の実装\n", .{});
    std.debug.print("  通常は直接使わない（高レベルAPIを使用）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. wait と wake の基本
// ====================

var signal = Atomic.Value(u32).init(0);

fn waiter(id: u8) void {
    std.debug.print("  Waiter {d}: 待機開始\n", .{id});

    // signal が 0 の間待機
    while (signal.load(.acquire) == 0) {
        Futex.wait(&signal, 0);
    }

    std.debug.print("  Waiter {d}: 起床！signal = {d}\n", .{ id, signal.load(.acquire) });
}

fn demoBasicWaitWake() void {
    std.debug.print("=== 2. wait と wake の基本 ===\n\n", .{});

    signal.store(0, .seq_cst);

    std.debug.print("【API】\n", .{});
    std.debug.print("  Futex.wait(&var, expected)  // varがexpectedなら待機\n", .{});
    std.debug.print("  Futex.wake(&var, count)     // count個のスレッドを起こす\n", .{});

    std.debug.print("\n【実行】\n", .{});

    const w1 = Thread.spawn(.{}, waiter, .{1}) catch return;
    const w2 = Thread.spawn(.{}, waiter, .{2}) catch return;

    Thread.sleep(50 * std.time.ns_per_ms);

    std.debug.print("[Main] signal を 1 に設定\n", .{});
    signal.store(1, .release);

    // すべての待機スレッドを起こす
    Futex.wake(&signal, std.math.maxInt(u32));

    w1.join();
    w2.join();

    std.debug.print("\n", .{});
}

// ====================
// 3. タイムアウト付き待機
// ====================

fn demoTimedWait() void {
    std.debug.print("=== 3. タイムアウト付き待機 ===\n\n", .{});

    var value = Atomic.Value(u32).init(42);

    std.debug.print("【timedWait】\n", .{});
    std.debug.print("  タイムアウト付きで待機\n", .{});
    std.debug.print("  error.Timeout を返す可能性\n", .{});

    const start = std.time.milliTimestamp();

    // 100ms タイムアウトで待機（値は変わらないのでタイムアウトする）
    const result = Futex.timedWait(&value, 42, 100 * std.time.ns_per_ms);

    const elapsed = std.time.milliTimestamp() - start;

    if (result) |_| {
        std.debug.print("起床（値が変わった）\n", .{});
    } else |err| {
        switch (err) {
            error.Timeout => std.debug.print("タイムアウト！経過: {d}ms\n", .{elapsed}),
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// 4. セマフォの実装
// ====================

const Semaphore = struct {
    count: Atomic.Value(u32),

    const Self = @This();

    fn init(initial: u32) Self {
        return .{
            .count = Atomic.Value(u32).init(initial),
        };
    }

    fn acquire(self: *Self) void {
        while (true) {
            const c = self.count.load(.acquire);
            if (c > 0) {
                // カウントをデクリメント
                if (self.count.cmpxchgWeak(c, c - 1, .acquire, .monotonic) == null) {
                    return; // 成功
                }
            } else {
                // カウントが0なら待機
                Futex.wait(&self.count, 0);
            }
        }
    }

    fn release(self: *Self) void {
        _ = self.count.fetchAdd(1, .release);
        Futex.wake(&self.count, 1);
    }
};

fn semaphoreWorker(sem: *Semaphore, id: u8) void {
    sem.acquire();
    std.debug.print("  Worker {d}: セマフォ取得\n", .{id});
    Thread.sleep(30 * std.time.ns_per_ms);
    std.debug.print("  Worker {d}: セマフォ解放\n", .{id});
    sem.release();
}

fn demoSemaphore() void {
    std.debug.print("=== 4. セマフォの実装 ===\n\n", .{});

    std.debug.print("【セマフォ】\n", .{});
    std.debug.print("  同時アクセス数を制限\n", .{});
    std.debug.print("  カウント + Futex で実装\n", .{});

    // 2つまで同時アクセス可能
    var sem = Semaphore.init(2);

    std.debug.print("\n【実行】 (最大同時2)\n", .{});

    var threads: [4]Thread = undefined;
    for (0..4) |i| {
        threads[i] = Thread.spawn(.{}, semaphoreWorker, .{ &sem, @as(u8, @intCast(i + 1)) }) catch continue;
    }

    for (&threads) |*t| {
        t.join();
    }

    std.debug.print("\n", .{});
}

// ====================
// 5. イベントフラグ
// ====================

const Event = struct {
    state: Atomic.Value(u32),

    const UNSET: u32 = 0;
    const SET: u32 = 1;

    const Self = @This();

    fn init() Self {
        return .{
            .state = Atomic.Value(u32).init(UNSET),
        };
    }

    fn wait_event(self: *Self) void {
        while (self.state.load(.acquire) == UNSET) {
            Futex.wait(&self.state, UNSET);
        }
    }

    fn set(self: *Self) void {
        self.state.store(SET, .release);
        Futex.wake(&self.state, std.math.maxInt(u32)); // 全員起こす
    }

    fn reset(self: *Self) void {
        self.state.store(UNSET, .release);
    }

    fn isSet(self: *Self) bool {
        return self.state.load(.acquire) == SET;
    }
};

fn eventWaiter(event: *Event, id: u8) void {
    std.debug.print("  Waiter {d}: イベント待機\n", .{id});
    event.wait_event();
    std.debug.print("  Waiter {d}: イベント受信！\n", .{id});
}

fn demoEvent() void {
    std.debug.print("=== 5. イベントフラグ ===\n\n", .{});

    std.debug.print("【イベントフラグ】\n", .{});
    std.debug.print("  一度セットすると全待機者が起きる\n", .{});

    var event = Event.init();

    const w1 = Thread.spawn(.{}, eventWaiter, .{ &event, 1 }) catch return;
    const w2 = Thread.spawn(.{}, eventWaiter, .{ &event, 2 }) catch return;

    Thread.sleep(50 * std.time.ns_per_ms);

    std.debug.print("[Main] イベントをセット\n", .{});
    event.set();

    w1.join();
    w2.join();

    std.debug.print("\n", .{});
}

// ====================
// 6. スプリアス起床
// ====================

fn demoSpuriousWakeup() void {
    std.debug.print("=== 6. スプリアス起床 ===\n\n", .{});

    std.debug.print("【スプリアス起床とは】\n", .{});
    std.debug.print("  wake()なしに勝手に起きること\n", .{});
    std.debug.print("  OSの実装上発生する可能性がある\n", .{});

    std.debug.print("\n【対策】\n", .{});
    std.debug.print("  必ずループで条件を再チェック\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("  while (condition_not_met) {{\n", .{});
    std.debug.print("      Futex.wait(&var, expected);\n", .{});
    std.debug.print("      // ここで条件を再チェック\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 使い分け
// ====================

fn demoUseCases() void {
    std.debug.print("=== 7. 使い分け ===\n\n", .{});

    std.debug.print("【直接使うケース】\n", .{});
    std.debug.print("  - カスタム同期プリミティブの実装\n", .{});
    std.debug.print("  - 最大限のパフォーマンスが必要\n", .{});
    std.debug.print("  - 標準ライブラリの実装を理解したい\n", .{});

    std.debug.print("\n【高レベルAPIを使うケース】\n", .{});
    std.debug.print("  - 通常のアプリケーション開発\n", .{});
    std.debug.print("  - Mutex, RwLock, WaitGroup で十分\n", .{});
    std.debug.print("  - コードの可読性・保守性重視\n", .{});

    std.debug.print("\n【Zigでの実装状況】\n", .{});
    std.debug.print("  std.Thread.Mutex    → Futexベース\n", .{});
    std.debug.print("  std.Thread.RwLock   → Futexベース\n", .{});
    std.debug.print("  std.Thread.WaitGroup → Futexベース\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== Futex まとめ ===\n\n", .{});

    std.debug.print("【基本API】\n", .{});
    std.debug.print("  Futex.wait(&var, expected)  // 待機\n", .{});
    std.debug.print("  Futex.wake(&var, count)     // 起床\n", .{});
    std.debug.print("  Futex.timedWait(...)        // タイムアウト付き\n", .{});

    std.debug.print("\n【実装例】\n", .{});
    std.debug.print("  セマフォ: カウント + Futex\n", .{});
    std.debug.print("  イベント: フラグ + Futex\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - スプリアス起床に対応（ループで再チェック）\n", .{});
    std.debug.print("  - 低レベルAPI（通常は高レベルAPIを使用）\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoFutexConcept();
    demoBasicWaitWake();
    demoTimedWait();
    demoSemaphore();
    demoEvent();
    demoSpuriousWakeup();
    demoUseCases();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n104_once: 一度だけ初期化\n", .{});
}

// ====================
// テスト
// ====================

test "Futex basic wake" {
    var flag = Atomic.Value(u32).init(0);

    // 値を変えてwakeを呼ぶ（待機者がいなくてもOK）
    flag.store(1, .release);
    Futex.wake(&flag, 1);
}

test "Futex timedWait timeout" {
    var value = Atomic.Value(u32).init(42);

    const result = Futex.timedWait(&value, 42, 10 * std.time.ns_per_ms);
    try std.testing.expectError(error.Timeout, result);
}

test "Semaphore acquire release" {
    var sem = Semaphore.init(2);

    sem.acquire();
    sem.acquire();
    // 2つ取得できる

    sem.release();
    sem.release();
    // 解放

    try std.testing.expectEqual(@as(u32, 2), sem.count.load(.seq_cst));
}

test "Event set and check" {
    var event = Event.init();

    try std.testing.expect(!event.isSet());

    event.set();
    try std.testing.expect(event.isSet());

    event.reset();
    try std.testing.expect(!event.isSet());
}
