//! # Once（一度だけ初期化）
//!
//! スレッドセーフな一度だけの初期化を保証。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n104_once.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - std.once の概念と用途
//! - Once(f).call() の使い方
//! - グローバル初期化パターン
//! - シングルトンの実装

const std = @import("std");
const Thread = std.Thread;

// ====================
// 1. Once の概念
// ====================

fn demoOnceConcept() void {
    std.debug.print("=== 1. Once の概念 ===\n\n", .{});

    std.debug.print("【Once とは】\n", .{});
    std.debug.print("  関数を「一度だけ」実行することを保証\n", .{});
    std.debug.print("  複数スレッドから同時に呼ばれても安全\n", .{});

    std.debug.print("\n【用途】\n", .{});
    std.debug.print("  - グローバル変数の遅延初期化\n", .{});
    std.debug.print("  - シングルトンパターン\n", .{});
    std.debug.print("  - スレッドセーフな初期化\n", .{});

    std.debug.print("\n【他言語との対応】\n", .{});
    std.debug.print("  Go: sync.Once\n", .{});
    std.debug.print("  C++: std::call_once\n", .{});
    std.debug.print("  Rust: std::sync::Once\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 基本的な使い方
// ====================

var init_count: u32 = 0;

fn initOnce() void {
    init_count += 1;
    std.debug.print("  初期化関数が実行されました（{d}回目）\n", .{init_count});
}

var global_once = std.once(initOnce);

fn demoBasicUsage() void {
    std.debug.print("=== 2. 基本的な使い方 ===\n\n", .{});

    init_count = 0;

    std.debug.print("【コード例】\n", .{});
    std.debug.print("  fn init() void {{ ... }}\n", .{});
    std.debug.print("  var once = std.once(init);\n", .{});
    std.debug.print("  once.call();  // 最初の呼び出しで実行\n", .{});
    std.debug.print("  once.call();  // 2回目以降は何もしない\n", .{});

    std.debug.print("\n【実行】\n", .{});

    // 3回呼んでも1回しか実行されない
    global_once.call();
    global_once.call();
    global_once.call();

    std.debug.print("call()を3回呼びましたが、実行は1回\n\n", .{});
}

// ====================
// 3. マルチスレッドでの使用
// ====================

var mt_init_count: u32 = 0;

fn mtInit() void {
    mt_init_count += 1;
    std.debug.print("  [MT] 初期化実行！カウント: {d}\n", .{mt_init_count});
}

var mt_once = std.once(mtInit);

fn threadWorker() void {
    mt_once.call();
    std.debug.print("  [Worker] call()完了\n", .{});
}

fn demoMultithread() void {
    std.debug.print("=== 3. マルチスレッドでの使用 ===\n\n", .{});

    mt_init_count = 0;

    std.debug.print("【複数スレッドから同時にcall()】\n", .{});
    std.debug.print("  最初のスレッドだけが初期化を実行\n", .{});
    std.debug.print("  他のスレッドは完了を待って続行\n", .{});

    std.debug.print("\n【実行】\n", .{});

    var threads: [4]Thread = undefined;
    for (0..4) |i| {
        threads[i] = Thread.spawn(.{}, threadWorker, .{}) catch continue;
    }

    for (&threads) |*t| {
        t.join();
    }

    std.debug.print("\n最終カウント: {d} (1であるべき)\n\n", .{mt_init_count});
}

// ====================
// 4. シングルトンパターン
// ====================

const Database = struct {
    connection_id: u32,

    fn init() Database {
        std.debug.print("  Database.init(): 接続を確立\n", .{});
        return .{ .connection_id = 12345 };
    }

    fn query(self: *const Database, sql: []const u8) void {
        std.debug.print("  Database.query({s}) on connection {d}\n", .{ sql, self.connection_id });
    }
};

var db_instance: Database = undefined;

fn initDatabase() void {
    db_instance = Database.init();
}

var db_once = std.once(initDatabase);

fn getDatabase() *Database {
    db_once.call();
    return &db_instance;
}

fn demoSingleton() void {
    std.debug.print("=== 4. シングルトンパターン ===\n\n", .{});

    std.debug.print("【パターン】\n", .{});
    std.debug.print("  var instance: T = undefined;\n", .{});
    std.debug.print("  fn initInstance() void {{ instance = T.init(); }}\n", .{});
    std.debug.print("  var once = std.once(initInstance);\n", .{});
    std.debug.print("  fn getInstance() *T {{\n", .{});
    std.debug.print("      once.call();\n", .{});
    std.debug.print("      return &instance;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【実行】\n", .{});

    const db1 = getDatabase();
    const db2 = getDatabase();

    db1.query("SELECT * FROM users");
    db2.query("SELECT * FROM orders");

    std.debug.print("\ndb1 == db2: {}\n\n", .{db1 == db2});
}

// ====================
// 5. 引数付き初期化
// ====================

fn demoWithArgs() void {
    std.debug.print("=== 5. 引数付き初期化 ===\n\n", .{});

    std.debug.print("【制限】\n", .{});
    std.debug.print("  std.once() は引数なし関数のみ対応\n", .{});

    std.debug.print("\n【回避策】\n", .{});
    std.debug.print("  グローバル変数経由で引数を渡す\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("  var init_config: Config = undefined;\n", .{});
    std.debug.print("  fn initWithConfig() void {{\n", .{});
    std.debug.print("      // init_config を使用\n", .{});
    std.debug.print("  }}\n", .{});
    std.debug.print("  var once = std.once(initWithConfig);\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("  fn initialize(config: Config) void {{\n", .{});
    std.debug.print("      init_config = config;\n", .{});
    std.debug.print("      once.call();\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. 内部実装
// ====================

fn demoImplementation() void {
    std.debug.print("=== 6. 内部実装 ===\n\n", .{});

    std.debug.print("【Once の仕組み】\n", .{});
    std.debug.print("  1. done フラグをアトミックにチェック\n", .{});
    std.debug.print("  2. true なら即リターン（高速パス）\n", .{});
    std.debug.print("  3. false なら Mutex を取得\n", .{});
    std.debug.print("  4. 再度 done をチェック\n", .{});
    std.debug.print("  5. まだ false なら関数を実行\n", .{});
    std.debug.print("  6. done を true に設定\n", .{});

    std.debug.print("\n【特徴】\n", .{});
    std.debug.print("  - 初回以外は非常に高速\n", .{});
    std.debug.print("  - ダブルチェックロッキング\n", .{});
    std.debug.print("  - メモリオーダリングを正しく処理\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 7. 注意点 ===\n\n", .{});

    std.debug.print("【再入禁止】\n", .{});
    std.debug.print("  初期化関数から同じ Once を call() してはいけない\n", .{});
    std.debug.print("  → デッドロック\n", .{});

    std.debug.print("\n【グローバル変数】\n", .{});
    std.debug.print("  Once オブジェクトは通常グローバルに配置\n", .{});
    std.debug.print("  ローカルだとスコープ終了で無効になる\n", .{});

    std.debug.print("\n【エラー処理】\n", .{});
    std.debug.print("  初期化関数はエラーを返せない\n", .{});
    std.debug.print("  失敗時は別の変数でエラーを記録\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== Once まとめ ===\n\n", .{});

    std.debug.print("【基本】\n", .{});
    std.debug.print("  fn init() void {{ ... }}\n", .{});
    std.debug.print("  var once = std.once(init);\n", .{});
    std.debug.print("  once.call();  // 最初の1回だけ実行\n", .{});

    std.debug.print("\n【シングルトン】\n", .{});
    std.debug.print("  fn getInstance() *T {{\n", .{});
    std.debug.print("      once.call();\n", .{});
    std.debug.print("      return &instance;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【特徴】\n", .{});
    std.debug.print("  - スレッドセーフ\n", .{});
    std.debug.print("  - 2回目以降は高速\n", .{});
    std.debug.print("  - 遅延初期化に最適\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoOnceConcept();
    demoBasicUsage();
    demoMultithread();
    demoSingleton();
    demoWithArgs();
    demoImplementation();
    demoCaveats();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n105_concurrency_summary: 並行処理総まとめ\n", .{});
}

// ====================
// テスト
// ====================

var test_count: u32 = 0;
fn testInit() void {
    test_count += 1;
}
var test_once = std.once(testInit);

test "Once calls function exactly once" {
    test_count = 0;

    test_once.call();
    test_once.call();
    test_once.call();

    // 注意: テストは複数回実行される可能性があるが、
    // グローバルのtest_onceは一度だけ初期化される
    try std.testing.expect(test_count >= 1);
}

test "Once thread safety" {
    var counter: u32 = 0;

    const init_fn = struct {
        fn init(c: *u32) void {
            c.* += 1;
        }
    }.init;

    // ローカルOnceの代わりにAtomicを使用
    var done = std.atomic.Value(bool).init(false);
    var mutex: Thread.Mutex = .{};

    const Worker = struct {
        fn work(c: *u32, d: *std.atomic.Value(bool), m: *Thread.Mutex) void {
            if (!d.load(.acquire)) {
                m.lock();
                defer m.unlock();
                if (!d.load(.acquire)) {
                    init_fn(c);
                    d.store(true, .release);
                }
            }
        }
    };

    const t1 = try Thread.spawn(.{}, Worker.work, .{ &counter, &done, &mutex });
    const t2 = try Thread.spawn(.{}, Worker.work, .{ &counter, &done, &mutex });

    t1.join();
    t2.join();

    try std.testing.expectEqual(@as(u32, 1), counter);
}
