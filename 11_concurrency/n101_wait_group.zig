//! # WaitGroup
//!
//! 複数のタスク完了を待機する同期プリミティブ。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n101_wait_group.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - WaitGroup の概念と用途
//! - start() / finish() / wait()
//! - スレッドとの組み合わせ
//! - スレッドプールとの組み合わせ
//! - 実践パターン

const std = @import("std");
const Thread = std.Thread;
const WaitGroup = std.Thread.WaitGroup;
const Pool = std.Thread.Pool;

// ====================
// 1. WaitGroup の概念
// ====================

fn demoWaitGroupConcept() void {
    std.debug.print("=== 1. WaitGroup の概念 ===\n\n", .{});

    std.debug.print("【WaitGroup とは】\n", .{});
    std.debug.print("  複数のタスクの完了を待つための仕組み\n", .{});

    std.debug.print("\n【基本的な流れ】\n", .{});
    std.debug.print("  1. wg.start()  - タスク開始をカウント\n", .{});
    std.debug.print("  2. タスク内で defer wg.finish()\n", .{});
    std.debug.print("  3. wg.wait()   - 全タスク完了を待機\n", .{});

    std.debug.print("\n【内部動作】\n", .{});
    std.debug.print("  start()  → カウンタ+1\n", .{});
    std.debug.print("  finish() → カウンタ-1\n", .{});
    std.debug.print("  wait()   → カウンタが0になるまでブロック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 基本的な使い方
// ====================

fn basicWorker(id: u8, wg: *WaitGroup) void {
    defer wg.finish(); // 必ず呼ぶ

    std.debug.print("  Worker {d}: 開始\n", .{id});
    Thread.sleep(30 * std.time.ns_per_ms);
    std.debug.print("  Worker {d}: 完了\n", .{id});
}

fn demoBasicUsage() void {
    std.debug.print("=== 2. 基本的な使い方 ===\n\n", .{});

    var wg: WaitGroup = .{};

    std.debug.print("【コード例】\n", .{});
    std.debug.print("  var wg: WaitGroup = .{{}};\n", .{});
    std.debug.print("  wg.start();\n", .{});
    std.debug.print("  // ... スレッド内で defer wg.finish();\n", .{});
    std.debug.print("  wg.wait();\n", .{});

    std.debug.print("\n【実行】\n", .{});

    // スレッドを起動
    for (1..4) |i| {
        wg.start();
        _ = Thread.spawn(.{}, basicWorker, .{ @as(u8, @intCast(i)), &wg }) catch {
            wg.finish(); // スレッド作成失敗時は自分でfinish
            continue;
        };
    }

    std.debug.print("[Main] 全スレッドの完了を待機中...\n", .{});
    wg.wait();
    std.debug.print("[Main] 全スレッド完了！\n\n", .{});
}

// ====================
// 3. defer パターン
// ====================

fn demoDeferPattern() void {
    std.debug.print("=== 3. defer パターン ===\n\n", .{});

    std.debug.print("【重要】finish() は defer で呼ぶ\n\n", .{});

    std.debug.print("【良いパターン】\n", .{});
    std.debug.print("  fn worker(wg: *WaitGroup) void {{\n", .{});
    std.debug.print("      defer wg.finish();  // 早期リターンでも安全\n", .{});
    std.debug.print("      // ... 処理 ...\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【悪いパターン】\n", .{});
    std.debug.print("  fn worker(wg: *WaitGroup) void {{\n", .{});
    std.debug.print("      // ... 処理 ...\n", .{});
    std.debug.print("      wg.finish();  // 途中でreturnすると漏れる\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【なぜ重要？】\n", .{});
    std.debug.print("  finish()を忘れるとwait()が永遠にブロック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 4. スレッドプールとの組み合わせ
// ====================

fn poolTask(id: u32, wg: *WaitGroup) void {
    defer wg.finish();
    std.debug.print("  Task {d}: 処理中\n", .{id});
    Thread.sleep(20 * std.time.ns_per_ms);
}

fn demoWithPool() !void {
    std.debug.print("=== 4. スレッドプールとの組み合わせ ===\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 3, .allocator = gpa.allocator() });
    defer pool.deinit();

    var wg: WaitGroup = .{};

    std.debug.print("【パターン】\n", .{});
    std.debug.print("  wg.start();\n", .{});
    std.debug.print("  try pool.spawn(task, .{{..., &wg}});\n", .{});
    std.debug.print("  // タスク内: defer wg.finish();\n", .{});
    std.debug.print("  wg.wait();  // pool.deinit()より前に待機\n", .{});

    std.debug.print("\n【実行】\n", .{});

    for (1..7) |i| {
        wg.start();
        try pool.spawn(poolTask, .{ @as(u32, @intCast(i)), &wg });
    }

    wg.wait();
    std.debug.print("[Main] 全タスク完了\n\n", .{});
}

// ====================
// 5. 複数グループ
// ====================

fn phase1Worker(id: u8, wg: *WaitGroup) void {
    defer wg.finish();
    std.debug.print("  Phase1-{d}: 実行\n", .{id});
    Thread.sleep(20 * std.time.ns_per_ms);
}

fn phase2Worker(id: u8, wg: *WaitGroup) void {
    defer wg.finish();
    std.debug.print("  Phase2-{d}: 実行\n", .{id});
    Thread.sleep(15 * std.time.ns_per_ms);
}

fn demoMultipleGroups() void {
    std.debug.print("=== 5. 複数グループ ===\n\n", .{});

    std.debug.print("【フェーズ分割】\n", .{});
    std.debug.print("  Phase1 → wait → Phase2 → wait\n", .{});

    // Phase 1
    var wg1: WaitGroup = .{};
    std.debug.print("\n[Phase 1 開始]\n", .{});

    for (1..4) |i| {
        wg1.start();
        _ = Thread.spawn(.{}, phase1Worker, .{ @as(u8, @intCast(i)), &wg1 }) catch {
            wg1.finish();
            continue;
        };
    }
    wg1.wait();
    std.debug.print("[Phase 1 完了]\n", .{});

    // Phase 2
    var wg2: WaitGroup = .{};
    std.debug.print("\n[Phase 2 開始]\n", .{});

    for (1..4) |i| {
        wg2.start();
        _ = Thread.spawn(.{}, phase2Worker, .{ @as(u8, @intCast(i)), &wg2 }) catch {
            wg2.finish();
            continue;
        };
    }
    wg2.wait();
    std.debug.print("[Phase 2 完了]\n\n", .{});
}

// ====================
// 6. 結果の収集
// ====================

const Result = struct {
    id: u32,
    value: u32,
};

fn computeWorker(id: u32, results: []Result, wg: *WaitGroup) void {
    defer wg.finish();
    // 何らかの計算
    results[id].id = id;
    results[id].value = id * id;
}

fn demoResultCollection() void {
    std.debug.print("=== 6. 結果の収集 ===\n\n", .{});

    std.debug.print("【パターン】\n", .{});
    std.debug.print("  結果配列を事前に確保\n", .{});
    std.debug.print("  各タスクが自分の領域に書き込み\n", .{});
    std.debug.print("  wait後にまとめて読み取り\n", .{});

    const n = 4;
    var results: [n]Result = undefined;
    var wg: WaitGroup = .{};

    for (0..n) |i| {
        wg.start();
        _ = Thread.spawn(.{}, computeWorker, .{
            @as(u32, @intCast(i)),
            &results,
            &wg,
        }) catch {
            wg.finish();
            continue;
        };
    }

    wg.wait();

    std.debug.print("\n【結果】\n", .{});
    for (results) |r| {
        std.debug.print("  id={d}, value={d}\n", .{ r.id, r.value });
    }

    std.debug.print("\n", .{});
}

// ====================
// 7. エラーハンドリング
// ====================

fn demoErrorHandling() void {
    std.debug.print("=== 7. エラーハンドリング ===\n\n", .{});

    std.debug.print("【スレッド作成失敗時】\n", .{});
    std.debug.print("  wg.start();\n", .{});
    std.debug.print("  _ = Thread.spawn(...) catch {{\n", .{});
    std.debug.print("      wg.finish();  // 自分でfinish\n", .{});
    std.debug.print("      return;\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【タスク内エラー】\n", .{});
    std.debug.print("  fn task(wg: *WaitGroup, err_flag: *bool) void {{\n", .{});
    std.debug.print("      defer wg.finish();\n", .{});
    std.debug.print("      // エラー発生時\n", .{});
    std.debug.print("      err_flag.* = true;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  タスク関数はエラーを返せない\n", .{});
    std.debug.print("  フラグや結果構造体でエラーを伝える\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 8. 注意点 ===\n\n", .{});

    std.debug.print("【カウンタの一致】\n", .{});
    std.debug.print("  start()の回数 = finish()の回数\n", .{});
    std.debug.print("  不一致だとデッドロックや不正動作\n", .{});

    std.debug.print("\n【再利用】\n", .{});
    std.debug.print("  wait()後は新しいWaitGroupを作成\n", .{});
    std.debug.print("  同じインスタンスの再利用は非推奨\n", .{});

    std.debug.print("\n【スコープ】\n", .{});
    std.debug.print("  WaitGroupはスタック上に置ける\n", .{});
    std.debug.print("  タスクより長く生存させること\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== WaitGroup まとめ ===\n\n", .{});

    std.debug.print("【基本操作】\n", .{});
    std.debug.print("  var wg: WaitGroup = .{{}};\n", .{});
    std.debug.print("  wg.start();   // タスク開始前\n", .{});
    std.debug.print("  wg.finish();  // タスク完了時（deferで）\n", .{});
    std.debug.print("  wg.wait();    // 全完了を待つ\n", .{});

    std.debug.print("\n【黄金パターン】\n", .{});
    std.debug.print("  wg.start();\n", .{});
    std.debug.print("  _ = Thread.spawn(...) catch {{\n", .{});
    std.debug.print("      wg.finish();\n", .{});
    std.debug.print("      return;\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【用途】\n", .{});
    std.debug.print("  複数スレッド/タスクの完了同期\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    demoWaitGroupConcept();
    demoBasicUsage();
    demoDeferPattern();
    try demoWithPool();
    demoMultipleGroups();
    demoResultCollection();
    demoErrorHandling();
    demoCaveats();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n102_channel: チャンネル通信\n", .{});
}

// ====================
// テスト
// ====================

test "WaitGroup basic" {
    var wg: WaitGroup = .{};
    wg.start();
    wg.finish();
    wg.wait();
    // デッドロックせずに完了すればOK
}

test "WaitGroup with thread" {
    var wg: WaitGroup = .{};
    var done = false;

    wg.start();
    const thread = try Thread.spawn(.{}, struct {
        fn work(d: *bool, w: *WaitGroup) void {
            defer w.finish();
            d.* = true;
        }
    }.work, .{ &done, &wg });

    _ = thread; // スレッドハンドルは不要（WaitGroupで待つ）
    wg.wait();

    try std.testing.expect(done);
}

test "WaitGroup multiple tasks" {
    var wg: WaitGroup = .{};
    var counter = std.atomic.Value(u32).init(0);

    for (0..5) |_| {
        wg.start();
        _ = try Thread.spawn(.{}, struct {
            fn work(c: *std.atomic.Value(u32), w: *WaitGroup) void {
                defer w.finish();
                _ = c.fetchAdd(1, .seq_cst);
            }
        }.work, .{ &counter, &wg });
    }

    wg.wait();
    try std.testing.expectEqual(@as(u32, 5), counter.load(.seq_cst));
}

test "WaitGroup multiple start finish" {
    var wg: WaitGroup = .{};

    // 複数のstart/finish
    wg.start();
    wg.start();
    wg.start();
    wg.finish();
    wg.finish();
    wg.finish();
    wg.wait();
}
