//! # 並行処理 総まとめ
//!
//! Zigのスレッドと同期プリミティブの総復習。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n105_concurrency_summary.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - 並行処理の全体像
//! - 同期プリミティブの使い分け
//! - よくあるパターン
//! - 注意点とベストプラクティス

const std = @import("std");
const Thread = std.Thread;
const Mutex = std.Thread.Mutex;
const RwLock = std.Thread.RwLock;
const Pool = std.Thread.Pool;
const WaitGroup = std.Thread.WaitGroup;
const Futex = std.Thread.Futex;
const Atomic = std.atomic;

// ====================
// 1. スレッドの基礎
// ====================

fn demoThreadBasics() void {
    std.debug.print("=== 1. スレッドの基礎 ===\n\n", .{});

    std.debug.print("【Thread.spawn】\n", .{});
    std.debug.print("  const t = try Thread.spawn(.{{}}, func, .{{args}});\n", .{});
    std.debug.print("  t.join();   // 完了を待つ\n", .{});
    std.debug.print("  t.detach(); // 切り離し\n", .{});

    std.debug.print("\n【SpawnConfig】\n", .{});
    std.debug.print("  .stack_size = ...  // スタックサイズ\n", .{});
    std.debug.print("  .allocator = ...   // カスタムアロケータ\n", .{});

    std.debug.print("\n【ユーティリティ】\n", .{});
    std.debug.print("  Thread.sleep(ns)       // スリープ\n", .{});
    std.debug.print("  Thread.yield()         // 譲る\n", .{});
    std.debug.print("  Thread.getCurrentId()  // スレッドID\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 排他制御
// ====================

fn demoMutualExclusion() void {
    std.debug.print("=== 2. 排他制御 ===\n\n", .{});

    std.debug.print("【Mutex】 - 排他ロック\n", .{});
    std.debug.print("  var mutex: Mutex = .{{}};\n", .{});
    std.debug.print("  mutex.lock();\n", .{});
    std.debug.print("  defer mutex.unlock();\n", .{});
    std.debug.print("  // クリティカルセクション\n", .{});

    std.debug.print("\n【RwLock】 - 読み書きロック\n", .{});
    std.debug.print("  var lock: RwLock = .{{}};\n", .{});
    std.debug.print("  lock.lockShared();    // 読み取り（複数同時OK）\n", .{});
    std.debug.print("  lock.unlockShared();\n", .{});
    std.debug.print("  lock.lock();          // 書き込み（排他）\n", .{});
    std.debug.print("  lock.unlock();\n", .{});

    std.debug.print("\n【使い分け】\n", .{});
    std.debug.print("  Mutex:  読み書きが同程度、シンプル\n", .{});
    std.debug.print("  RwLock: 読み取りが多い場合\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 3. アトミック操作
// ====================

fn demoAtomicOps() void {
    std.debug.print("=== 3. アトミック操作 ===\n\n", .{});

    std.debug.print("【Atomic.Value】\n", .{});
    std.debug.print("  var v = Atomic.Value(u32).init(0);\n", .{});
    std.debug.print("  v.load(.seq_cst)        // 読み取り\n", .{});
    std.debug.print("  v.store(x, .seq_cst)    // 書き込み\n", .{});

    std.debug.print("\n【算術演算】\n", .{});
    std.debug.print("  v.fetchAdd(1, .seq_cst)  // 加算\n", .{});
    std.debug.print("  v.fetchSub(1, .seq_cst)  // 減算\n", .{});
    std.debug.print("  v.fetchOr(...), fetchAnd(...), fetchXor(...)\n", .{});

    std.debug.print("\n【CAS】\n", .{});
    std.debug.print("  v.cmpxchgStrong(expected, new, ...)\n", .{});
    std.debug.print("  v.cmpxchgWeak(expected, new, ...)  // ループ向け\n", .{});

    std.debug.print("\n【メモリオーダー】\n", .{});
    std.debug.print("  .seq_cst   - 最も安全（迷ったらこれ）\n", .{});
    std.debug.print("  .acquire   - ロード用\n", .{});
    std.debug.print("  .release   - ストア用\n", .{});
    std.debug.print("  .monotonic - 順序保証なし\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 4. スレッドプールとWaitGroup
// ====================

fn demoPoolAndWaitGroup() void {
    std.debug.print("=== 4. スレッドプールとWaitGroup ===\n\n", .{});

    std.debug.print("【ThreadPool】\n", .{});
    std.debug.print("  var pool: Pool = undefined;\n", .{});
    std.debug.print("  try pool.init(.{{ .n_jobs = 4, .allocator = a }});\n", .{});
    std.debug.print("  defer pool.deinit();\n", .{});
    std.debug.print("  try pool.spawn(func, .{{args}});\n", .{});

    std.debug.print("\n【WaitGroup】\n", .{});
    std.debug.print("  var wg: WaitGroup = .{{}};\n", .{});
    std.debug.print("  wg.start();           // タスク開始前\n", .{});
    std.debug.print("  defer wg.finish();    // タスク内\n", .{});
    std.debug.print("  wg.wait();            // 全完了を待つ\n", .{});

    std.debug.print("\n【組み合わせ】\n", .{});
    std.debug.print("  wg.start();\n", .{});
    std.debug.print("  try pool.spawn(task, .{{&wg, ...}});\n", .{});
    std.debug.print("  // タスク内: defer wg.finish();\n", .{});
    std.debug.print("  wg.wait();\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 5. 低レベルプリミティブ
// ====================

fn demoLowLevel() void {
    std.debug.print("=== 5. 低レベルプリミティブ ===\n\n", .{});

    std.debug.print("【Futex】 - 高速ユーザー空間Mutex\n", .{});
    std.debug.print("  Futex.wait(&var, expected)  // 待機\n", .{});
    std.debug.print("  Futex.wake(&var, count)     // 起床\n", .{});
    std.debug.print("  Futex.timedWait(...)        // タイムアウト付き\n", .{});

    std.debug.print("\n【Once】 - 一度だけ初期化\n", .{});
    std.debug.print("  var once = std.once(initFn);\n", .{});
    std.debug.print("  once.call();  // 最初の1回だけ実行\n", .{});

    std.debug.print("\n【通常使用しない理由】\n", .{});
    std.debug.print("  Mutex, RwLock 等が内部で使用\n", .{});
    std.debug.print("  高レベルAPIで十分なケースが大半\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. よくあるパターン
// ====================

fn demoCommonPatterns() void {
    std.debug.print("=== 6. よくあるパターン ===\n\n", .{});

    std.debug.print("【スレッドセーフ構造体】\n", .{});
    std.debug.print("  const SafeCounter = struct {{\n", .{});
    std.debug.print("      value: u32,\n", .{});
    std.debug.print("      mutex: Mutex,\n", .{});
    std.debug.print("      fn increment(self: *Self) void {{\n", .{});
    std.debug.print("          self.mutex.lock();\n", .{});
    std.debug.print("          defer self.mutex.unlock();\n", .{});
    std.debug.print("          self.value += 1;\n", .{});
    std.debug.print("      }}\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【シングルトン】\n", .{});
    std.debug.print("  var instance: T = undefined;\n", .{});
    std.debug.print("  var once = std.once(init);\n", .{});
    std.debug.print("  fn getInstance() *T {{\n", .{});
    std.debug.print("      once.call();\n", .{});
    std.debug.print("      return &instance;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【並列データ処理】\n", .{});
    std.debug.print("  データを分割 → Pool + WaitGroup → 結果を集約\n", .{});

    std.debug.print("\n【停止フラグ】\n", .{});
    std.debug.print("  var stop = Atomic.Value(bool).init(false);\n", .{});
    std.debug.print("  // ワーカー: while (!stop.load(.acquire)) {{...}}\n", .{});
    std.debug.print("  // メイン: stop.store(true, .release);\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 選び方ガイド
// ====================

fn demoSelectionGuide() void {
    std.debug.print("=== 7. 選び方ガイド ===\n\n", .{});

    std.debug.print("【単純な共有カウンタ】\n", .{});
    std.debug.print("  → Atomic.Value + fetchAdd/fetchSub\n", .{});

    std.debug.print("\n【複雑なデータ構造】\n", .{});
    std.debug.print("  → Mutex で保護\n", .{});

    std.debug.print("\n【読み取り多め】\n", .{});
    std.debug.print("  → RwLock\n", .{});

    std.debug.print("\n【多数の独立タスク】\n", .{});
    std.debug.print("  → ThreadPool + WaitGroup\n", .{});

    std.debug.print("\n【一度だけの初期化】\n", .{});
    std.debug.print("  → std.once()\n", .{});

    std.debug.print("\n【フラグ通知】\n", .{});
    std.debug.print("  → Atomic.Value(bool)\n", .{});

    std.debug.print("\n【カスタム同期】\n", .{});
    std.debug.print("  → Futex（上級者向け）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 8. 注意点 ===\n\n", .{});

    std.debug.print("【デッドロック防止】\n", .{});
    std.debug.print("  - ロック順序を統一\n", .{});
    std.debug.print("  - defer でアンロック\n", .{});
    std.debug.print("  - ロックスコープを最小化\n", .{});

    std.debug.print("\n【データ競合防止】\n", .{});
    std.debug.print("  - 共有データは常に保護\n", .{});
    std.debug.print("  - 可能なら所有権を分離\n", .{});

    std.debug.print("\n【リソース管理】\n", .{});
    std.debug.print("  - join() か detach() を必ず呼ぶ\n", .{});
    std.debug.print("  - pool.deinit() でタスク完了を待つ\n", .{});

    std.debug.print("\n【メモリオーダリング】\n", .{});
    std.debug.print("  - 迷ったら .seq_cst\n", .{});
    std.debug.print("  - 最適化は測定してから\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 9. このセクションの内容
// ====================

fn demoSectionContents() void {
    std.debug.print("=== 9. このセクションの内容 ===\n\n", .{});

    std.debug.print("【学んだファイル】\n", .{});
    std.debug.print("  n096: スレッドの基礎\n", .{});
    std.debug.print("  n097: ミューテックス\n", .{});
    std.debug.print("  n098: 読み書きロック\n", .{});
    std.debug.print("  n099: アトミック操作\n", .{});
    std.debug.print("  n100: スレッドプール\n", .{});
    std.debug.print("  n101: WaitGroup\n", .{});
    std.debug.print("  n102: チャンネルパターン\n", .{});
    std.debug.print("  n103: Futex\n", .{});
    std.debug.print("  n104: Once\n", .{});
    std.debug.print("  n105: 総まとめ（このファイル）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoFinalSummary() void {
    std.debug.print("=== 並行処理 総まとめ ===\n\n", .{});

    std.debug.print("【Zigの並行処理の特徴】\n", .{});
    std.debug.print("  - 明示的なメモリ管理\n", .{});
    std.debug.print("  - 低レベル制御が可能\n", .{});
    std.debug.print("  - 高レベルAPIも充実\n", .{});
    std.debug.print("  - C互換のスレッドモデル\n", .{});

    std.debug.print("\n【基本の組み合わせ】\n", .{});
    std.debug.print("  Thread + Mutex  基本的な並行処理\n", .{});
    std.debug.print("  Pool + WaitGroup  タスク並列\n", .{});
    std.debug.print("  Atomic  ロックフリー操作\n", .{});

    std.debug.print("\n【鉄則】\n", .{});
    std.debug.print("  1. 共有データは必ず保護\n", .{});
    std.debug.print("  2. defer でリソース解放\n", .{});
    std.debug.print("  3. シンプルな設計を優先\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoThreadBasics();
    demoMutualExclusion();
    demoAtomicOps();
    demoPoolAndWaitGroup();
    demoLowLevel();
    demoCommonPatterns();
    demoSelectionGuide();
    demoCaveats();
    demoSectionContents();
    demoFinalSummary();

    std.debug.print("=== 次のセクション ===\n", .{});
    std.debug.print("・12_simd: SIMD（ベクトル演算）\n", .{});
}

// ====================
// テスト
// ====================

test "Thread spawn and join" {
    var done = false;
    const t = try Thread.spawn(.{}, struct {
        fn work(d: *bool) void {
            d.* = true;
        }
    }.work, .{&done});
    t.join();
    try std.testing.expect(done);
}

test "Mutex protects data" {
    var mutex: Mutex = .{};
    var counter: u32 = 0;

    mutex.lock();
    counter += 1;
    mutex.unlock();

    try std.testing.expectEqual(@as(u32, 1), counter);
}

test "Atomic operations" {
    var v = Atomic.Value(u32).init(0);
    _ = v.fetchAdd(5, .seq_cst);
    try std.testing.expectEqual(@as(u32, 5), v.load(.seq_cst));
}

test "WaitGroup basic" {
    var wg: WaitGroup = .{};
    wg.start();
    wg.finish();
    wg.wait();
}
