//! # スレッドの基礎
//!
//! Zigのスレッド機能を使った並行処理の基本。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n096_threads.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - std.Thread の基本的な使い方
//! - spawn() によるスレッド作成
//! - join() によるスレッド待機
//! - スレッドへの引数渡し
//! - Thread.sleep() による一時停止

const std = @import("std");
const Thread = std.Thread;

// ====================
// 1. 基本的なスレッド作成
// ====================

fn simpleWork() void {
    std.debug.print("  [Worker] 作業を開始\n", .{});
    Thread.sleep(100 * std.time.ns_per_ms);
    std.debug.print("  [Worker] 作業を完了\n", .{});
}

fn demoBasicThread() void {
    std.debug.print("=== 1. 基本的なスレッド作成 ===\n\n", .{});

    std.debug.print("[Main] スレッドを作成中...\n", .{});

    // Thread.spawn() でスレッドを作成
    // 引数: (.config, .function, .args)
    const thread = Thread.spawn(.{}, simpleWork, .{}) catch |err| {
        std.debug.print("スレッド作成エラー: {}\n", .{err});
        return;
    };

    std.debug.print("[Main] スレッド作成完了、待機中...\n", .{});

    // join() でスレッドの終了を待つ
    thread.join();

    std.debug.print("[Main] スレッド終了\n\n", .{});
}

// ====================
// 2. 引数を渡す
// ====================

fn workWithArgs(id: u32, message: []const u8) void {
    std.debug.print("  [Thread {d}] メッセージ: {s}\n", .{ id, message });
    Thread.sleep(50 * std.time.ns_per_ms);
    std.debug.print("  [Thread {d}] 完了\n", .{id});
}

fn demoThreadWithArgs() void {
    std.debug.print("=== 2. 引数を渡す ===\n\n", .{});

    // 複数のスレッドを異なる引数で作成
    const thread1 = Thread.spawn(.{}, workWithArgs, .{ 1, "こんにちは" }) catch return;
    const thread2 = Thread.spawn(.{}, workWithArgs, .{ 2, "さようなら" }) catch return;
    const thread3 = Thread.spawn(.{}, workWithArgs, .{ 3, "おはよう" }) catch return;

    // すべてのスレッドを待機
    thread1.join();
    thread2.join();
    thread3.join();

    std.debug.print("\n", .{});
}

// ====================
// 3. ポインタ引数
// ====================

fn workWithPointer(counter: *u32) void {
    // ポインタを通じて値を変更
    counter.* += 10;
    std.debug.print("  [Thread] カウンタを更新: {d}\n", .{counter.*});
}

fn demoPointerArgs() void {
    std.debug.print("=== 3. ポインタ引数 ===\n\n", .{});

    var counter: u32 = 0;
    std.debug.print("[Main] 初期値: {d}\n", .{counter});

    // 注意: データ競合の可能性あり（次章で対策）
    const thread = Thread.spawn(.{}, workWithPointer, .{&counter}) catch return;
    thread.join();

    std.debug.print("[Main] 最終値: {d}\n\n", .{counter});
}

// ====================
// 4. SpawnConfig
// ====================

fn stackSizeDemo() void {
    // スタック上に大きな配列を確保
    var buffer: [1024]u8 = undefined;
    @memset(&buffer, 'X');
    std.debug.print("  [Thread] バッファサイズ: {d}\n", .{buffer.len});
}

fn demoSpawnConfig() void {
    std.debug.print("=== 4. SpawnConfig ===\n\n", .{});

    std.debug.print("【SpawnConfigのフィールド】\n", .{});
    std.debug.print("  stack_size: スタックサイズ（デフォルト: null = OS依存）\n", .{});
    std.debug.print("  allocator: カスタムアロケータ\n", .{});

    // カスタムスタックサイズを指定
    const thread = Thread.spawn(.{
        .stack_size = 1024 * 1024, // 1MB
    }, stackSizeDemo, .{}) catch return;
    thread.join();

    std.debug.print("\n", .{});
}

// ====================
// 5. Thread.sleep
// ====================

fn demoSleep() void {
    std.debug.print("=== 5. Thread.sleep ===\n\n", .{});

    std.debug.print("【時間単位定数】\n", .{});
    std.debug.print("  ns_per_ms  = {d}\n", .{std.time.ns_per_ms});
    std.debug.print("  ns_per_s   = {d}\n", .{std.time.ns_per_s});
    std.debug.print("  ms_per_s   = {d}\n", .{std.time.ms_per_s});

    std.debug.print("\n【使用例】\n", .{});
    std.debug.print("  Thread.sleep(100 * std.time.ns_per_ms)  // 100ms\n", .{});
    std.debug.print("  Thread.sleep(1 * std.time.ns_per_s)     // 1秒\n", .{});

    const start = std.time.milliTimestamp();
    Thread.sleep(50 * std.time.ns_per_ms);
    const elapsed = std.time.milliTimestamp() - start;
    std.debug.print("\n実測: 約 {d}ms スリープ\n\n", .{elapsed});
}

// ====================
// 6. Thread.yield
// ====================

fn demoYield() void {
    std.debug.print("=== 6. Thread.yield ===\n\n", .{});

    std.debug.print("【yield()の役割】\n", .{});
    std.debug.print("  - 現在のスレッドの実行を一時停止\n", .{});
    std.debug.print("  - OSスケジューラに制御を戻す\n", .{});
    std.debug.print("  - 他のスレッドに実行機会を与える\n", .{});

    std.debug.print("\n【使用例】\n", .{});
    std.debug.print("  Thread.yield();\n", .{});

    // yield() を呼び出す（エラーを無視）
    Thread.yield() catch {};

    std.debug.print("\nyield()後に再開\n\n", .{});
}

// ====================
// 7. detach vs join
// ====================

fn detachedWork() void {
    std.debug.print("  [Detached] 作業中...\n", .{});
    Thread.sleep(50 * std.time.ns_per_ms);
    std.debug.print("  [Detached] 完了（メインが待たない）\n", .{});
}

fn demoDetachVsJoin() void {
    std.debug.print("=== 7. detach vs join ===\n\n", .{});

    std.debug.print("【join()】\n", .{});
    std.debug.print("  - スレッドの終了を待つ\n", .{});
    std.debug.print("  - リソースを確実に解放\n", .{});
    std.debug.print("  - 通常はこちらを使用\n", .{});

    std.debug.print("\n【detach()】\n", .{});
    std.debug.print("  - スレッドを切り離す\n", .{});
    std.debug.print("  - メインは待たない\n", .{});
    std.debug.print("  - リソースはOS任せ\n", .{});
    std.debug.print("  - 注意: メイン終了時に強制終了される\n", .{});

    // detach の例（実際には join すべき場合が多い）
    const thread = Thread.spawn(.{}, detachedWork, .{}) catch return;

    // 通常は join() を使う
    // thread.detach();  // これを使うとメインが待たない
    thread.join(); // 安全のため join を使用

    std.debug.print("\n", .{});
}

// ====================
// 8. 複数スレッドの管理
// ====================

fn worker(id: u8) void {
    std.debug.print("  Worker {d}: 開始\n", .{id});
    Thread.sleep(20 * std.time.ns_per_ms * @as(u64, id));
    std.debug.print("  Worker {d}: 完了\n", .{id});
}

fn demoMultipleThreads() void {
    std.debug.print("=== 8. 複数スレッドの管理 ===\n\n", .{});

    const num_threads = 4;
    var threads: [num_threads]Thread = undefined;

    // スレッドを作成
    for (0..num_threads) |i| {
        threads[i] = Thread.spawn(.{}, worker, .{@as(u8, @intCast(i + 1))}) catch {
            std.debug.print("Thread {d} の作成に失敗\n", .{i});
            continue;
        };
    }

    std.debug.print("[Main] すべてのスレッドを待機中...\n", .{});

    // すべてのスレッドを待機
    for (&threads) |*t| {
        t.join();
    }

    std.debug.print("[Main] 全スレッド完了\n\n", .{});
}

// ====================
// 9. スレッド情報
// ====================

fn threadInfo() void {
    // 現在のスレッドIDを取得
    const current = Thread.getCurrentId();
    std.debug.print("  [Worker] スレッドID: {d}\n", .{current});
}

fn demoThreadInfo() void {
    std.debug.print("=== 9. スレッド情報 ===\n\n", .{});

    const main_id = Thread.getCurrentId();
    std.debug.print("[Main] メインスレッドID: {d}\n", .{main_id});

    const thread = Thread.spawn(.{}, threadInfo, .{}) catch return;
    thread.join();

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== スレッドの基礎 まとめ ===\n\n", .{});

    std.debug.print("【基本操作】\n", .{});
    std.debug.print("  const t = try Thread.spawn(.{{}}, func, .{{args}});\n", .{});
    std.debug.print("  t.join();      // 終了を待つ\n", .{});
    std.debug.print("  t.detach();    // 切り離し\n", .{});

    std.debug.print("\n【時間操作】\n", .{});
    std.debug.print("  Thread.sleep(ns)  // スリープ\n", .{});
    std.debug.print("  Thread.yield()    // 譲る\n", .{});

    std.debug.print("\n【情報取得】\n", .{});
    std.debug.print("  Thread.getCurrentId()  // 現在のスレッドID\n", .{});

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  - 共有データにはロックが必要（次章）\n", .{});
    std.debug.print("  - join()かdetach()を必ず呼ぶ\n", .{});
    std.debug.print("  - メイン終了時にスレッドも終了\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoBasicThread();
    demoThreadWithArgs();
    demoPointerArgs();
    demoSpawnConfig();
    demoSleep();
    demoYield();
    demoDetachVsJoin();
    demoMultipleThreads();
    demoThreadInfo();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n097_mutex: ミューテックス\n", .{});
}

// ====================
// テスト
// ====================

test "thread spawn and join" {
    var called = false;
    const thread = try Thread.spawn(.{}, struct {
        fn work(flag: *bool) void {
            flag.* = true;
        }
    }.work, .{&called});

    thread.join();
    try std.testing.expect(called);
}

test "thread with return value via pointer" {
    var result: u32 = 0;
    const thread = try Thread.spawn(.{}, struct {
        fn compute(ptr: *u32) void {
            ptr.* = 42;
        }
    }.compute, .{&result});

    thread.join();
    try std.testing.expectEqual(@as(u32, 42), result);
}

test "multiple threads" {
    const num_threads = 3;
    var threads: [num_threads]Thread = undefined;
    var results: [num_threads]u8 = .{ 0, 0, 0 };

    for (0..num_threads) |i| {
        threads[i] = try Thread.spawn(.{}, struct {
            fn work(idx: usize, res: *[num_threads]u8) void {
                res[idx] = @intCast(idx + 1);
            }
        }.work, .{ i, &results });
    }

    for (&threads) |*t| {
        t.join();
    }

    try std.testing.expectEqual(@as(u8, 1), results[0]);
    try std.testing.expectEqual(@as(u8, 2), results[1]);
    try std.testing.expectEqual(@as(u8, 3), results[2]);
}

test "Thread.getCurrentId" {
    const id = Thread.getCurrentId();
    try std.testing.expect(id > 0 or id == 0); // ID は 0 以上
}

test "Thread.sleep" {
    const start = std.time.milliTimestamp();
    Thread.sleep(10 * std.time.ns_per_ms);
    const elapsed = std.time.milliTimestamp() - start;
    try std.testing.expect(elapsed >= 9); // 少なくとも 9ms 経過
}
