//! # チャンネルパターン
//!
//! スレッド間でデータを安全にやり取りする方法。
//!
//! ## 実行方法
//! ```
//! zig run 11_concurrency/n102_channel.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - チャンネルの概念
//! - Mutex + 条件を使った実装
//! - 単純なリングバッファ型チャンネル
//! - Producer-Consumer パターン
//!
//! 注意: Zig標準ライブラリにはGoスタイルのチャンネルはない
//! 必要に応じて自作するか、サードパーティライブラリを使用

const std = @import("std");
const Thread = std.Thread;
const Mutex = std.Thread.Mutex;
const Atomic = std.atomic;
const Allocator = std.mem.Allocator;

// ====================
// 1. チャンネルの概念
// ====================

fn demoChannelConcept() void {
    std.debug.print("=== 1. チャンネルの概念 ===\n\n", .{});

    std.debug.print("【チャンネルとは】\n", .{});
    std.debug.print("  スレッド間でメッセージを送受信する仕組み\n", .{});
    std.debug.print("  Go言語で有名: ch <- value / value := <-ch\n", .{});

    std.debug.print("\n【Zigでの状況】\n", .{});
    std.debug.print("  標準ライブラリにはチャンネルなし\n", .{});
    std.debug.print("  代わりに:\n", .{});
    std.debug.print("  - Mutex + 共有変数\n", .{});
    std.debug.print("  - Atomic変数\n", .{});
    std.debug.print("  - 自作チャンネル\n", .{});
    std.debug.print("  - サードパーティライブラリ\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  共有メモリより安全\n", .{});
    std.debug.print("  「メモリを共有するな、通信で共有せよ」\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 単純なチャンネル実装
// ====================

fn Channel(comptime T: type, comptime capacity: usize) type {
    return struct {
        buffer: [capacity]T,
        read_index: usize,
        write_index: usize,
        count: usize,
        mutex: Mutex,
        closed: Atomic.Value(bool),

        const Self = @This();

        fn init() Self {
            return .{
                .buffer = undefined,
                .read_index = 0,
                .write_index = 0,
                .count = 0,
                .mutex = .{},
                .closed = Atomic.Value(bool).init(false),
            };
        }

        // 送信（バッファが満杯なら待機せずエラー）
        fn trySend(self: *Self, value: T) !void {
            if (self.closed.load(.acquire)) {
                return error.ChannelClosed;
            }

            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.count >= capacity) {
                return error.BufferFull;
            }

            self.buffer[self.write_index] = value;
            self.write_index = (self.write_index + 1) % capacity;
            self.count += 1;
        }

        // 受信（バッファが空なら待機せずエラー）
        fn tryReceive(self: *Self) !T {
            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.count == 0) {
                if (self.closed.load(.acquire)) {
                    return error.ChannelClosed;
                }
                return error.BufferEmpty;
            }

            const value = self.buffer[self.read_index];
            self.read_index = (self.read_index + 1) % capacity;
            self.count -= 1;
            return value;
        }

        fn close(self: *Self) void {
            self.closed.store(true, .release);
        }

        fn isClosed(self: *Self) bool {
            return self.closed.load(.acquire);
        }

        fn len(self: *Self) usize {
            self.mutex.lock();
            defer self.mutex.unlock();
            return self.count;
        }
    };
}

fn demoSimpleChannel() void {
    std.debug.print("=== 2. 単純なチャンネル実装 ===\n\n", .{});

    var ch = Channel(i32, 4).init();

    std.debug.print("【構造】\n", .{});
    std.debug.print("  リングバッファ + Mutex\n", .{});

    // 送信
    ch.trySend(10) catch {};
    ch.trySend(20) catch {};
    ch.trySend(30) catch {};

    std.debug.print("\n送信: 10, 20, 30\n", .{});
    std.debug.print("バッファ内: {d}個\n", .{ch.len()});

    // 受信
    std.debug.print("\n受信: ", .{});
    while (ch.tryReceive()) |val| {
        std.debug.print("{d} ", .{val});
    } else |_| {}
    std.debug.print("\n\n", .{});
}

// ====================
// 3. Producer-Consumer パターン
// ====================

const MessageChannel = Channel(u32, 8);

fn producer(ch: *MessageChannel, id: u8) void {
    for (0..3) |i| {
        const val = @as(u32, id) * 100 + @as(u32, @intCast(i));
        while (ch.trySend(val)) |_| {
            std.debug.print("  Producer{d}: 送信 {d}\n", .{ id, val });
            break;
        } else |err| {
            if (err == error.BufferFull) {
                Thread.sleep(10 * std.time.ns_per_ms);
                continue;
            }
            break;
        }
        Thread.sleep(20 * std.time.ns_per_ms);
    }
}

fn consumer(ch: *MessageChannel, id: u8) void {
    var received: u32 = 0;
    while (received < 4) {
        if (ch.tryReceive()) |val| {
            std.debug.print("  Consumer{d}: 受信 {d}\n", .{ id, val });
            received += 1;
        } else |_| {
            if (ch.isClosed()) break;
            Thread.sleep(15 * std.time.ns_per_ms);
        }
    }
}

fn demoProducerConsumer() void {
    std.debug.print("=== 3. Producer-Consumer パターン ===\n\n", .{});

    var ch = MessageChannel.init();

    const p1 = Thread.spawn(.{}, producer, .{ &ch, 1 }) catch return;
    const p2 = Thread.spawn(.{}, producer, .{ &ch, 2 }) catch return;
    const c1 = Thread.spawn(.{}, consumer, .{ &ch, 1 }) catch return;

    p1.join();
    p2.join();

    Thread.sleep(50 * std.time.ns_per_ms);
    ch.close();

    c1.join();

    std.debug.print("\n", .{});
}

// ====================
// 4. 結果チャンネル
// ====================

const Result = union(enum) {
    ok: i32,
    err: []const u8,
};

fn computeTask(input: i32, result: *Result) void {
    if (input >= 0) {
        result.* = .{ .ok = input * input };
    } else {
        result.* = .{ .err = "negative input" };
    }
}

fn demoResultChannel() void {
    std.debug.print("=== 4. 結果チャンネル ===\n\n", .{});

    std.debug.print("【パターン】\n", .{});
    std.debug.print("  タスク完了を結果で通知\n", .{});

    var results: [3]Result = undefined;
    const inputs = [_]i32{ 5, -1, 3 };

    for (0..3) |i| {
        _ = Thread.spawn(.{}, struct {
            fn work(inp: i32, res: *Result) void {
                computeTask(inp, res);
            }
        }.work, .{ inputs[i], &results[i] }) catch continue;
    }

    Thread.sleep(50 * std.time.ns_per_ms);

    std.debug.print("\n【結果】\n", .{});
    for (results, inputs) |r, inp| {
        std.debug.print("  入力 {d}: ", .{inp});
        switch (r) {
            .ok => |v| std.debug.print("OK({d})\n", .{v}),
            .err => |e| std.debug.print("Error({s})\n", .{e}),
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// 5. Atomic フラグによる完了通知
// ====================

fn demoAtomicCompletion() void {
    std.debug.print("=== 5. Atomic フラグによる完了通知 ===\n\n", .{});

    std.debug.print("【シンプルな通知パターン】\n", .{});
    std.debug.print("  Atomic(bool) で完了を通知\n", .{});

    var done = Atomic.Value(bool).init(false);
    var result: i32 = 0;

    const worker = Thread.spawn(.{}, struct {
        fn work(d: *Atomic.Value(bool), r: *i32) void {
            Thread.sleep(30 * std.time.ns_per_ms);
            r.* = 42;
            d.store(true, .release);
        }
    }.work, .{ &done, &result }) catch return;

    std.debug.print("計算中...\n", .{});

    // ポーリングで待機
    while (!done.load(.acquire)) {
        Thread.sleep(10 * std.time.ns_per_ms);
    }

    std.debug.print("結果: {d}\n\n", .{result});
    worker.join();
}

// ====================
// 6. 代替手段
// ====================

fn demoAlternatives() void {
    std.debug.print("=== 6. 代替手段 ===\n\n", .{});

    std.debug.print("【標準ライブラリの選択肢】\n", .{});
    std.debug.print("  std.Thread.Pool - ワーカースレッドプール\n", .{});
    std.debug.print("  std.Thread.Mutex - 共有データ保護\n", .{});
    std.debug.print("  std.atomic.Value - ロックフリー通信\n", .{});
    std.debug.print("  std.Thread.WaitGroup - 完了待機\n", .{});

    std.debug.print("\n【外部ライブラリ】\n", .{});
    std.debug.print("  zig-async - 非同期プリミティブ\n", .{});
    std.debug.print("  各種キュー実装\n", .{});

    std.debug.print("\n【選び方】\n", .{});
    std.debug.print("  単純な同期 → Atomic/Mutex\n", .{});
    std.debug.print("  タスク並列 → ThreadPool + WaitGroup\n", .{});
    std.debug.print("  メッセージパッシング → 自作Channel\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 設計上の注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 7. 設計上の注意点 ===\n\n", .{});

    std.debug.print("【バッファサイズ】\n", .{});
    std.debug.print("  小さい: 生産者がブロックしやすい\n", .{});
    std.debug.print("  大きい: メモリ使用量増加\n", .{});
    std.debug.print("  無限: メモリ枯渇のリスク\n", .{});

    std.debug.print("\n【閉じるタイミング】\n", .{});
    std.debug.print("  早すぎ: データが失われる\n", .{});
    std.debug.print("  遅すぎ: 受信側がブロック\n", .{});

    std.debug.print("\n【エラー処理】\n", .{});
    std.debug.print("  送信失敗: リトライ or ドロップ\n", .{});
    std.debug.print("  受信失敗: ポーリング or ブロック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== チャンネルパターン まとめ ===\n\n", .{});

    std.debug.print("【Zigの状況】\n", .{});
    std.debug.print("  標準ライブラリにチャンネルなし\n", .{});
    std.debug.print("  Mutex/Atomic で代替可能\n", .{});

    std.debug.print("\n【自作チャンネル】\n", .{});
    std.debug.print("  リングバッファ + Mutex + Atomic\n", .{});

    std.debug.print("\n【パターン】\n", .{});
    std.debug.print("  Producer-Consumer\n", .{});
    std.debug.print("  結果チャンネル\n", .{});
    std.debug.print("  完了通知\n", .{});

    std.debug.print("\n【実用的な選択】\n", .{});
    std.debug.print("  ThreadPool + WaitGroup が多くの場合十分\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoChannelConcept();
    demoSimpleChannel();
    demoProducerConsumer();
    demoResultChannel();
    demoAtomicCompletion();
    demoAlternatives();
    demoCaveats();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n103_futex: Futex（低レベル同期）\n", .{});
}

// ====================
// テスト
// ====================

test "Channel init" {
    var ch = Channel(i32, 4).init();
    try std.testing.expectEqual(@as(usize, 0), ch.len());
    try std.testing.expect(!ch.isClosed());
}

test "Channel send and receive" {
    var ch = Channel(i32, 4).init();

    try ch.trySend(10);
    try ch.trySend(20);

    try std.testing.expectEqual(@as(usize, 2), ch.len());

    const v1 = try ch.tryReceive();
    const v2 = try ch.tryReceive();

    try std.testing.expectEqual(@as(i32, 10), v1);
    try std.testing.expectEqual(@as(i32, 20), v2);
    try std.testing.expectEqual(@as(usize, 0), ch.len());
}

test "Channel buffer full" {
    var ch = Channel(i32, 2).init();

    try ch.trySend(1);
    try ch.trySend(2);

    const result = ch.trySend(3);
    try std.testing.expectError(error.BufferFull, result);
}

test "Channel empty" {
    var ch = Channel(i32, 2).init();
    const result = ch.tryReceive();
    try std.testing.expectError(error.BufferEmpty, result);
}

test "Channel close" {
    var ch = Channel(i32, 2).init();
    ch.close();
    try std.testing.expect(ch.isClosed());

    const result = ch.trySend(1);
    try std.testing.expectError(error.ChannelClosed, result);
}

test "Channel ring buffer wrapping" {
    var ch = Channel(i32, 3).init();

    // Fill and drain multiple times
    for (0..2) |_| {
        try ch.trySend(1);
        try ch.trySend(2);
        try ch.trySend(3);

        _ = try ch.tryReceive();
        _ = try ch.tryReceive();
        _ = try ch.tryReceive();
    }

    try std.testing.expectEqual(@as(usize, 0), ch.len());
}
