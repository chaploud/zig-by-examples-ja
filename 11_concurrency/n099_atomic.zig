//! # アトミック操作
//!
//! ロックなしでスレッドセーフな操作を行う方法。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n099_atomic.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - std.atomic.Value の基本
//! - load() と store()
//! - fetchAdd(), fetchSub() などの操作
//! - メモリオーダリング
//! - compareAndSwap (CAS)

const std = @import("std");
const Thread = std.Thread;
const Atomic = std.atomic;

// ====================
// 1. アトミック操作とは
// ====================

fn demoAtomicConcept() void {
    std.debug.print("=== 1. アトミック操作とは ===\n\n", .{});

    std.debug.print("【アトミック = 不可分】\n", .{});
    std.debug.print("  操作が中断されることなく完了する\n", .{});
    std.debug.print("  他スレッドから途中状態が見えない\n", .{});

    std.debug.print("\n【Mutex との違い】\n", .{});
    std.debug.print("  Mutex  : ロックによる排他制御\n", .{});
    std.debug.print("  Atomic : ハードウェア命令による保証\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  - ロックのオーバーヘッドなし\n", .{});
    std.debug.print("  - デッドロックの心配なし\n", .{});
    std.debug.print("  - 単純な操作に最適\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. atomic.Value の基本
// ====================

fn demoAtomicValue() void {
    std.debug.print("=== 2. atomic.Value の基本 ===\n\n", .{});

    // アトミック変数の作成
    var counter = Atomic.Value(u32).init(0);

    std.debug.print("【初期化】\n", .{});
    std.debug.print("  var v = Atomic.Value(u32).init(0);\n", .{});

    // 値の読み取り
    const val = counter.load(.seq_cst);
    std.debug.print("\n【load()】値の読み取り: {d}\n", .{val});

    // 値の書き込み
    counter.store(42, .seq_cst);
    std.debug.print("【store()】値を42に設定\n", .{});

    std.debug.print("現在の値: {d}\n\n", .{counter.load(.seq_cst)});
}

// ====================
// 3. fetchAdd / fetchSub
// ====================

var atomic_counter = Atomic.Value(u32).init(0);

fn incrementAtomic() void {
    for (0..1000) |_| {
        // 加算してから前の値を返す
        _ = atomic_counter.fetchAdd(1, .seq_cst);
    }
}

fn demoFetchAddSub() void {
    std.debug.print("=== 3. fetchAdd / fetchSub ===\n\n", .{});

    atomic_counter.store(0, .seq_cst);

    std.debug.print("【fetchAdd】\n", .{});
    std.debug.print("  const old = v.fetchAdd(1, .seq_cst);\n", .{});
    std.debug.print("  // アトミックに加算、前の値を返す\n", .{});

    // 複数スレッドで加算
    const t1 = Thread.spawn(.{}, incrementAtomic, .{}) catch return;
    const t2 = Thread.spawn(.{}, incrementAtomic, .{}) catch return;

    t1.join();
    t2.join();

    std.debug.print("\n2スレッド × 1000回 = {d} (期待値: 2000)\n", .{
        atomic_counter.load(.seq_cst),
    });

    // fetchSub の例
    var val = Atomic.Value(i32).init(100);
    const old = val.fetchSub(30, .seq_cst);
    std.debug.print("\n【fetchSub】100 - 30 = {d} (前の値: {d})\n\n", .{
        val.load(.seq_cst),
        old,
    });
}

// ====================
// 4. その他のアトミック操作
// ====================

fn demoOtherOperations() void {
    std.debug.print("=== 4. その他のアトミック操作 ===\n\n", .{});

    var val = Atomic.Value(u32).init(0b1111_0000);

    std.debug.print("初期値: 0b{b:0>8}\n\n", .{val.load(.seq_cst)});

    // fetchOr - ビットOR
    _ = val.fetchOr(0b0000_1111, .seq_cst);
    std.debug.print("【fetchOr】  0b0000_1111 → 0b{b:0>8}\n", .{val.load(.seq_cst)});

    // fetchAnd - ビットAND
    _ = val.fetchAnd(0b1111_0000, .seq_cst);
    std.debug.print("【fetchAnd】 0b1111_0000 → 0b{b:0>8}\n", .{val.load(.seq_cst)});

    // fetchXor - ビットXOR
    _ = val.fetchXor(0b0101_0101, .seq_cst);
    std.debug.print("【fetchXor】 0b0101_0101 → 0b{b:0>8}\n", .{val.load(.seq_cst)});

    std.debug.print("\n", .{});
}

// ====================
// 5. メモリオーダリング
// ====================

fn demoMemoryOrdering() void {
    std.debug.print("=== 5. メモリオーダリング ===\n\n", .{});

    std.debug.print("【メモリオーダーとは】\n", .{});
    std.debug.print("  コンパイラ/CPUの最適化による並べ替えを制御\n", .{});

    std.debug.print("\n【主なオーダー】\n", .{});
    std.debug.print("  .seq_cst   最も厳密。迷ったらこれ\n", .{});
    std.debug.print("  .acq_rel   acquire + release\n", .{});
    std.debug.print("  .acquire   この後の操作が先に実行されない\n", .{});
    std.debug.print("  .release   この前の操作が後に実行されない\n", .{});
    std.debug.print("  .monotonic 最も緩い。順序保証なし\n", .{});

    std.debug.print("\n【推奨】\n", .{});
    std.debug.print("  まず .seq_cst を使う\n", .{});
    std.debug.print("  性能が問題なら緩いオーダーを検討\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. compareAndSwap (CAS)
// ====================

fn demoCAS() void {
    std.debug.print("=== 6. compareAndSwap (CAS) ===\n\n", .{});

    std.debug.print("【CAS とは】\n", .{});
    std.debug.print("  期待値と一致したら新しい値に更新\n", .{});
    std.debug.print("  一致しなければ何もしない\n", .{});

    var val = Atomic.Value(u32).init(100);

    // 成功するCAS
    const result1 = val.cmpxchgStrong(100, 200, .seq_cst, .seq_cst);
    std.debug.print("\n【cmpxchgStrong(100, 200)】\n", .{});
    std.debug.print("  結果: {?d} (nullなら成功)\n", .{result1});
    std.debug.print("  現在値: {d}\n", .{val.load(.seq_cst)});

    // 失敗するCAS（期待値が異なる）
    const result2 = val.cmpxchgStrong(100, 300, .seq_cst, .seq_cst);
    std.debug.print("\n【cmpxchgStrong(100, 300)】期待値が違う\n", .{});
    std.debug.print("  結果: {?d} (実際の値)\n", .{result2});
    std.debug.print("  現在値: {d} (変更なし)\n", .{val.load(.seq_cst)});

    std.debug.print("\n【cmpxchgWeak】\n", .{});
    std.debug.print("  Strongより高速だが偽の失敗がある\n", .{});
    std.debug.print("  ループで再試行する場合に使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. スピンロックの実装
// ====================

const SpinLock = struct {
    locked: Atomic.Value(bool),

    const Self = @This();

    fn init() Self {
        return .{
            .locked = Atomic.Value(bool).init(false),
        };
    }

    fn lock(self: *Self) void {
        // CASでfalse→trueに変更を試みる
        while (self.locked.cmpxchgWeak(false, true, .acquire, .monotonic) != null) {
            // 失敗したらスピン（ビジーウェイト）
            Thread.yield() catch {};
        }
    }

    fn unlock(self: *Self) void {
        self.locked.store(false, .release);
    }
};

var spin_counter: u32 = 0;

fn spinWorker(spin_lock: *SpinLock) void {
    for (0..100) |_| {
        spin_lock.lock();
        spin_counter += 1;
        spin_lock.unlock();
    }
}

fn demoSpinLock() void {
    std.debug.print("=== 7. スピンロックの実装 ===\n\n", .{});

    spin_counter = 0;
    var spin_lock = SpinLock.init();

    const t1 = Thread.spawn(.{}, spinWorker, .{&spin_lock}) catch return;
    const t2 = Thread.spawn(.{}, spinWorker, .{&spin_lock}) catch return;

    t1.join();
    t2.join();

    std.debug.print("スピンロックでカウント: {d} (期待値: 200)\n\n", .{spin_counter});
}

// ====================
// 8. フラグとしての使用
// ====================

var should_stop = Atomic.Value(bool).init(false);
var work_counter: u32 = 0;

fn flagWorker() void {
    while (!should_stop.load(.acquire)) {
        work_counter += 1;
        if (work_counter >= 1000) {
            break;
        }
        Thread.sleep(1 * std.time.ns_per_ms);
    }
}

fn demoFlag() void {
    std.debug.print("=== 8. フラグとしての使用 ===\n\n", .{});

    should_stop.store(false, .seq_cst);
    work_counter = 0;

    std.debug.print("【よくあるパターン】\n", .{});
    std.debug.print("  var stop = Atomic.Value(bool).init(false);\n", .{});
    std.debug.print("  // ワーカー内: while (!stop.load(.acquire)) {{ ... }}\n", .{});
    std.debug.print("  // メイン: stop.store(true, .release);\n", .{});

    const worker = Thread.spawn(.{}, flagWorker, .{}) catch return;

    Thread.sleep(50 * std.time.ns_per_ms);

    // 停止フラグを立てる
    should_stop.store(true, .release);
    std.debug.print("\nstop フラグを true に設定\n", .{});

    worker.join();
    std.debug.print("ワーカー終了、カウント: {d}\n\n", .{work_counter});
}

// ====================
// 9. 使い分け
// ====================

fn demoUseCases() void {
    std.debug.print("=== 9. 使い分け ===\n\n", .{});

    std.debug.print("【Atomic が適切】\n", .{});
    std.debug.print("  - カウンタ（fetchAdd/fetchSub）\n", .{});
    std.debug.print("  - フラグ（load/store）\n", .{});
    std.debug.print("  - 状態遷移（CAS）\n", .{});
    std.debug.print("  - 単一の値の更新\n", .{});

    std.debug.print("\n【Mutex が適切】\n", .{});
    std.debug.print("  - 複数のフィールドを同時に更新\n", .{});
    std.debug.print("  - 複雑なデータ構造の保護\n", .{});
    std.debug.print("  - 長い操作のクリティカルセクション\n", .{});

    std.debug.print("\n【原則】\n", .{});
    std.debug.print("  シンプルな操作 → Atomic\n", .{});
    std.debug.print("  複雑な操作 → Mutex/RwLock\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== アトミック操作 まとめ ===\n\n", .{});

    std.debug.print("【基本操作】\n", .{});
    std.debug.print("  var v = Atomic.Value(T).init(val);\n", .{});
    std.debug.print("  v.load(.seq_cst)      // 読み取り\n", .{});
    std.debug.print("  v.store(x, .seq_cst)  // 書き込み\n", .{});

    std.debug.print("\n【算術/ビット演算】\n", .{});
    std.debug.print("  fetchAdd, fetchSub\n", .{});
    std.debug.print("  fetchOr, fetchAnd, fetchXor\n", .{});

    std.debug.print("\n【CAS】\n", .{});
    std.debug.print("  cmpxchgStrong / cmpxchgWeak\n", .{});

    std.debug.print("\n【メモリオーダー】\n", .{});
    std.debug.print("  迷ったら .seq_cst\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoAtomicConcept();
    demoAtomicValue();
    demoFetchAddSub();
    demoOtherOperations();
    demoMemoryOrdering();
    demoCAS();
    demoSpinLock();
    demoFlag();
    demoUseCases();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n100_thread_pool: スレッドプール\n", .{});
}

// ====================
// テスト
// ====================

test "atomic init and load" {
    var v = Atomic.Value(u32).init(42);
    try std.testing.expectEqual(@as(u32, 42), v.load(.seq_cst));
}

test "atomic store" {
    var v = Atomic.Value(u32).init(0);
    v.store(100, .seq_cst);
    try std.testing.expectEqual(@as(u32, 100), v.load(.seq_cst));
}

test "atomic fetchAdd" {
    var v = Atomic.Value(u32).init(10);
    const old = v.fetchAdd(5, .seq_cst);
    try std.testing.expectEqual(@as(u32, 10), old);
    try std.testing.expectEqual(@as(u32, 15), v.load(.seq_cst));
}

test "atomic fetchSub" {
    var v = Atomic.Value(i32).init(100);
    const old = v.fetchSub(30, .seq_cst);
    try std.testing.expectEqual(@as(i32, 100), old);
    try std.testing.expectEqual(@as(i32, 70), v.load(.seq_cst));
}

test "atomic cmpxchgStrong success" {
    var v = Atomic.Value(u32).init(10);
    const result = v.cmpxchgStrong(10, 20, .seq_cst, .seq_cst);
    try std.testing.expectEqual(@as(?u32, null), result);
    try std.testing.expectEqual(@as(u32, 20), v.load(.seq_cst));
}

test "atomic cmpxchgStrong failure" {
    var v = Atomic.Value(u32).init(10);
    const result = v.cmpxchgStrong(5, 20, .seq_cst, .seq_cst);
    try std.testing.expectEqual(@as(?u32, 10), result);
    try std.testing.expectEqual(@as(u32, 10), v.load(.seq_cst)); // 変更なし
}

test "SpinLock" {
    var lock = SpinLock.init();
    lock.lock();
    lock.unlock();
    // エラーなく完了すればOK
}

test "atomic counter thread safe" {
    var counter = Atomic.Value(u32).init(0);

    const Worker = struct {
        fn work(c: *Atomic.Value(u32)) void {
            for (0..100) |_| {
                _ = c.fetchAdd(1, .seq_cst);
            }
        }
    };

    const t1 = try Thread.spawn(.{}, Worker.work, .{&counter});
    const t2 = try Thread.spawn(.{}, Worker.work, .{&counter});

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 200), counter.load(.seq_cst));
}
