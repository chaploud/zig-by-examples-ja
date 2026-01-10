//! # スレッドプール
//!
//! 再利用可能なワーカースレッドで効率的にタスクを処理。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n100_thread_pool.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - std.Thread.Pool の概念と利点
//! - Pool.Options による設定
//! - spawn() によるタスク投入
//! - WaitGroup との連携
//! - 実践的な使用パターン

const std = @import("std");
const Thread = std.Thread;
const Pool = std.Thread.Pool;
const WaitGroup = std.Thread.WaitGroup;
const Allocator = std.mem.Allocator;

// ====================
// 1. スレッドプールの概念
// ====================

fn demoPoolConcept() void {
    std.debug.print("=== 1. スレッドプールの概念 ===\n\n", .{});

    std.debug.print("【スレッドプールとは】\n", .{});
    std.debug.print("  事前に作成したスレッドを再利用する仕組み\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  - スレッド作成/破棄のオーバーヘッドを削減\n", .{});
    std.debug.print("  - スレッド数を制御できる\n", .{});
    std.debug.print("  - 多数の小タスクを効率的に処理\n", .{});

    std.debug.print("\n【使いどころ】\n", .{});
    std.debug.print("  - 並列処理（データ並列）\n", .{});
    std.debug.print("  - Webサーバーのリクエスト処理\n", .{});
    std.debug.print("  - バッチ処理\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 基本的な使い方
// ====================

fn simpleTask(id: *const u32) void {
    std.debug.print("  タスク {d}: 開始\n", .{id.*});
    Thread.sleep(50 * std.time.ns_per_ms);
    std.debug.print("  タスク {d}: 完了\n", .{id.*});
}

fn demoBasicUsage() !void {
    std.debug.print("=== 2. 基本的な使い方 ===\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // プールの設定
    const options = Pool.Options{
        .n_jobs = 4, // ワーカースレッド数
        .allocator = allocator,
    };

    // プールの初期化
    var pool: Pool = undefined;
    try pool.init(options);
    defer pool.deinit();

    std.debug.print("【初期化】\n", .{});
    std.debug.print("  var pool: Pool = undefined;\n", .{});
    std.debug.print("  try pool.init(.{{ .n_jobs = 4, .allocator = ... }});\n", .{});
    std.debug.print("  defer pool.deinit();\n", .{});

    std.debug.print("\n【タスク投入】\n", .{});
    const ids = [_]u32{ 1, 2, 3, 4, 5, 6 };
    for (&ids) |*id| {
        try pool.spawn(simpleTask, .{id});
    }

    std.debug.print("全タスク投入完了\n", .{});
    std.debug.print("（deinit()で全タスク完了を待機）\n\n", .{});
}

// ====================
// 3. WaitGroup との連携
// ====================

fn taskWithWaitGroup(wg: *WaitGroup, id: u32) void {
    defer wg.finish();
    std.debug.print("  [WG] タスク {d}: 処理中\n", .{id});
    Thread.sleep(30 * std.time.ns_per_ms);
    std.debug.print("  [WG] タスク {d}: 完了\n", .{id});
}

fn demoWaitGroup() !void {
    std.debug.print("=== 3. WaitGroup との連携 ===\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 2, .allocator = allocator });
    defer pool.deinit();

    var wg: WaitGroup = .{};

    std.debug.print("【WaitGroupの使い方】\n", .{});
    std.debug.print("  var wg: WaitGroup = .{{}};\n", .{});
    std.debug.print("  wg.start();  // タスク投入前\n", .{});
    std.debug.print("  // タスク内: defer wg.finish();\n", .{});
    std.debug.print("  wg.wait();   // 全タスク完了を待つ\n", .{});

    std.debug.print("\n【実行】\n", .{});

    // タスクを投入
    for (0..4) |i| {
        wg.start();
        try pool.spawn(taskWithWaitGroup, .{ &wg, @as(u32, @intCast(i + 1)) });
    }

    // 全タスクの完了を待つ
    wg.wait();

    std.debug.print("\n全タスク完了！\n\n", .{});
}

// ====================
// 4. n_jobs の設定
// ====================

fn demoNJobs() void {
    std.debug.print("=== 4. n_jobs の設定 ===\n\n", .{});

    std.debug.print("【n_jobs とは】\n", .{});
    std.debug.print("  ワーカースレッドの数\n", .{});

    std.debug.print("\n【設定の指針】\n", .{});
    std.debug.print("  CPU bound : CPUコア数程度\n", .{});
    std.debug.print("  I/O bound : コア数より多くてもOK\n", .{});

    std.debug.print("\n【CPUコア数の取得】\n", .{});
    const cpu_count = Thread.getCpuCount() catch 1;
    std.debug.print("  std.Thread.getCpuCount() = {d}\n", .{cpu_count});

    std.debug.print("\n【デフォルト】\n", .{});
    std.debug.print("  n_jobs = null → CPUコア数を使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 5. 並列データ処理
// ====================

fn processChunk(data: []u32, start: usize, end: usize, wg: *WaitGroup) void {
    defer wg.finish();
    for (start..end) |i| {
        data[i] *= 2;
    }
}

fn demoParallelProcessing() !void {
    std.debug.print("=== 5. 並列データ処理 ===\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 4, .allocator = allocator });
    defer pool.deinit();

    // データを準備
    var data: [100]u32 = undefined;
    for (0..data.len) |i| {
        data[i] = @intCast(i);
    }

    std.debug.print("【データ並列処理】\n", .{});
    std.debug.print("  データを分割して並列処理\n", .{});

    var wg: WaitGroup = .{};
    const chunk_size: usize = 25;

    // チャンクごとにタスクを投入
    var i: usize = 0;
    while (i < data.len) {
        const end = @min(i + chunk_size, data.len);
        wg.start();
        try pool.spawn(processChunk, .{ &data, i, end, &wg });
        i = end;
    }

    wg.wait();

    std.debug.print("\n処理前: 0, 1, 2, 3, ...\n", .{});
    std.debug.print("処理後: {d}, {d}, {d}, {d}, ...\n", .{
        data[0],
        data[1],
        data[2],
        data[3],
    });
    std.debug.print("最後: {d}\n\n", .{data[99]});
}

// ====================
// 6. エラー処理
// ====================

fn demoErrorHandling() void {
    std.debug.print("=== 6. エラー処理 ===\n\n", .{});

    std.debug.print("【pool.init() のエラー】\n", .{});
    std.debug.print("  - OutOfMemory: メモリ不足\n", .{});

    std.debug.print("\n【pool.spawn() のエラー】\n", .{});
    std.debug.print("  - OutOfMemory: タスクキューのメモリ不足\n", .{});

    std.debug.print("\n【タスク内のエラー】\n", .{});
    std.debug.print("  タスク関数はエラーを返せない\n", .{});
    std.debug.print("  結果は共有変数やチャンネルで伝える\n", .{});

    std.debug.print("\n【パターン】\n", .{});
    std.debug.print("  const Result = union {{ ok: T, err: anyerror }};\n", .{});
    std.debug.print("  var results: [N]Result = ...;\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 実践パターン
// ====================

fn demoPatterns() void {
    std.debug.print("=== 7. 実践パターン ===\n\n", .{});

    std.debug.print("【ファイル処理】\n", .{});
    std.debug.print("  複数ファイルを並列に読み込み/処理\n", .{});

    std.debug.print("\n【画像処理】\n", .{});
    std.debug.print("  画像を分割して並列にフィルタ適用\n", .{});

    std.debug.print("\n【Web スクレイピング】\n", .{});
    std.debug.print("  複数URLを並列にフェッチ\n", .{});

    std.debug.print("\n【計算処理】\n", .{});
    std.debug.print("  行列演算、物理シミュレーション\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 8. 注意点 ===\n\n", .{});

    std.debug.print("【共有データの保護】\n", .{});
    std.debug.print("  複数タスクが同じデータにアクセスする場合\n", .{});
    std.debug.print("  Mutex や Atomic で保護が必要\n", .{});

    std.debug.print("\n【ポインタの生存期間】\n", .{});
    std.debug.print("  タスクに渡すポインタは\n", .{});
    std.debug.print("  タスク完了まで有効である必要がある\n", .{});

    std.debug.print("\n【deinit の順序】\n", .{});
    std.debug.print("  pool.deinit() は全タスク完了を待つ\n", .{});
    std.debug.print("  他のリソースより先に解放しない\n", .{});

    std.debug.print("\n【タスク粒度】\n", .{});
    std.debug.print("  小さすぎる: オーバーヘッドが大きい\n", .{});
    std.debug.print("  大きすぎる: 並列性が低下\n", .{});
    std.debug.print("  適度なチャンクサイズを選ぶ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== スレッドプール まとめ ===\n\n", .{});

    std.debug.print("【初期化】\n", .{});
    std.debug.print("  var pool: Pool = undefined;\n", .{});
    std.debug.print("  try pool.init(.{{ .n_jobs = 4, .allocator = a }});\n", .{});
    std.debug.print("  defer pool.deinit();\n", .{});

    std.debug.print("\n【タスク投入】\n", .{});
    std.debug.print("  try pool.spawn(func, .{{args}});\n", .{});

    std.debug.print("\n【完了待機】\n", .{});
    std.debug.print("  WaitGroup を使用\n", .{});
    std.debug.print("  または deinit() で全体を待つ\n", .{});

    std.debug.print("\n【使いどころ】\n", .{});
    std.debug.print("  多数の独立したタスクを並列実行\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    demoPoolConcept();
    try demoBasicUsage();
    try demoWaitGroup();
    demoNJobs();
    try demoParallelProcessing();
    demoErrorHandling();
    demoPatterns();
    demoCaveats();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n101_wait_group: WaitGroup詳細\n", .{});
}

// ====================
// テスト
// ====================

test "Pool init and deinit" {
    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 2, .allocator = std.testing.allocator });
    pool.deinit();
}

test "Pool spawn simple task" {
    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 2, .allocator = std.testing.allocator });
    defer pool.deinit();

    var executed = false;
    try pool.spawn(struct {
        fn task(flag: *bool) void {
            flag.* = true;
        }
    }.task, .{&executed});

    // deinit でタスク完了を待つ
    pool.deinit();
    try std.testing.expect(executed);

    // 再初期化してdeferのdeinitに備える
    try pool.init(.{ .n_jobs = 2, .allocator = std.testing.allocator });
}

test "Pool with WaitGroup" {
    var pool: Pool = undefined;
    try pool.init(.{ .n_jobs = 2, .allocator = std.testing.allocator });
    defer pool.deinit();

    var wg: WaitGroup = .{};
    var counter = std.atomic.Value(u32).init(0);

    for (0..4) |_| {
        wg.start();
        try pool.spawn(struct {
            fn task(c: *std.atomic.Value(u32), w: *WaitGroup) void {
                defer w.finish();
                _ = c.fetchAdd(1, .seq_cst);
            }
        }.task, .{ &counter, &wg });
    }

    wg.wait();
    try std.testing.expectEqual(@as(u32, 4), counter.load(.seq_cst));
}

test "getCpuCount" {
    const count = Thread.getCpuCount() catch 1;
    try std.testing.expect(count > 0);
}
