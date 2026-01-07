//! # errdefer
//!
//! errdeferはエラー時にのみ実行されるクリーンアップ処理。
//! リソース解放とエラー処理を組み合わせる際に便利。
//!
//! ## 特徴
//! - 関数がエラーを返す場合のみ実行
//! - 正常終了時は実行されない
//! - deferと組み合わせて使用
//!
//! ## 用途
//! - メモリ解放
//! - ファイルクローズ
//! - ロック解除
//! - ロールバック処理

const std = @import("std");

// ====================
// 基本的なerrdefer
// ====================

fn mayFail(should_fail: bool) !void {
    if (should_fail) {
        return error.Failure;
    }
}

fn demoBasicErrdefer() void {
    std.debug.print("--- 基本的なerrdefer ---\n", .{});

    // errdeferの基本構文
    const helper = struct {
        fn process(fail: bool) !void {
            errdefer std.debug.print("  → errdefer実行！\n", .{});

            std.debug.print("  処理開始\n", .{});
            try mayFail(fail);
            std.debug.print("  処理完了\n", .{});
        }
    };

    // 成功ケース
    std.debug.print("  [成功ケース]\n", .{});
    if (helper.process(false)) |_| {
        std.debug.print("  結果: 成功（errdeferは実行されない）\n", .{});
    } else |_| {}

    // エラーケース
    std.debug.print("  [エラーケース]\n", .{});
    if (helper.process(true)) |_| {} else |err| {
        std.debug.print("  結果: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// deferとerrdeferの比較
// ====================

fn demoDeferVsErrdefer() void {
    std.debug.print("--- defer vs errdefer ---\n", .{});

    const helper = struct {
        fn withBoth(fail: bool) !void {
            defer std.debug.print("    defer実行（常に）\n", .{});
            errdefer std.debug.print("    errdefer実行（エラー時のみ）\n", .{});

            std.debug.print("    処理中...\n", .{});
            try mayFail(fail);
        }
    };

    // 成功ケース
    std.debug.print("  [成功時]\n", .{});
    helper.withBoth(false) catch {};

    // エラーケース
    std.debug.print("  [エラー時]\n", .{});
    helper.withBoth(true) catch {};

    std.debug.print("\n", .{});
}

// ====================
// メモリ解放パターン
// ====================

fn demoMemoryCleanup() !void {
    std.debug.print("--- メモリ解放パターン ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const helper = struct {
        fn allocateAndProcess(alloc: std.mem.Allocator, fail: bool) ![]u8 {
            const buf = try alloc.alloc(u8, 100);
            errdefer alloc.free(buf);

            std.debug.print("  メモリ確保: 100 bytes\n", .{});

            // 途中でエラーが発生した場合、errdeferがメモリを解放
            try mayFail(fail);

            std.debug.print("  処理成功、メモリを返却\n", .{});
            return buf;
        }
    };

    // 成功ケース
    std.debug.print("  [成功ケース]\n", .{});
    if (helper.allocateAndProcess(allocator, false)) |buf| {
        std.debug.print("  呼び出し側でメモリ使用・解放\n", .{});
        allocator.free(buf);
    } else |_| {}

    // エラーケース
    std.debug.print("  [エラーケース]\n", .{});
    if (helper.allocateAndProcess(allocator, true)) |_| {} else |err| {
        std.debug.print("  エラー: {s}（errdeferがメモリ解放済み）\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 複数リソースの解放
// ====================

fn demoMultipleResources() void {
    std.debug.print("--- 複数リソースの解放 ---\n", .{});

    const Resource = struct {
        name: []const u8,
        pub fn acquire(name: []const u8) @This() {
            std.debug.print("    {s} 取得\n", .{name});
            return .{ .name = name };
        }
        pub fn release(self: @This()) void {
            std.debug.print("    {s} 解放\n", .{self.name});
        }
    };

    const helper = struct {
        fn processMultiple(fail_at: usize) !void {
            const r1 = Resource.acquire("リソース1");
            errdefer r1.release();

            if (fail_at == 1) return error.FailAtStep1;

            const r2 = Resource.acquire("リソース2");
            errdefer r2.release();

            if (fail_at == 2) return error.FailAtStep2;

            const r3 = Resource.acquire("リソース3");
            errdefer r3.release();

            if (fail_at == 3) return error.FailAtStep3;

            // 成功時は呼び出し側で解放
            std.debug.print("    処理成功\n", .{});
            r3.release();
            r2.release();
            r1.release();
        }
    };

    std.debug.print("  [ステップ2で失敗]\n", .{});
    helper.processMultiple(2) catch |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    };

    std.debug.print("\n", .{});
}

// ====================
// errdeferでエラー値を取得
// ====================

fn demoErrdeferWithPayload() void {
    std.debug.print("--- errdeferでエラー値を取得 ---\n", .{});

    const helper = struct {
        fn withPayload(fail_type: u8) !void {
            errdefer |err| std.debug.print("    errdefer: {s} をキャッチ\n", .{@errorName(err)});

            switch (fail_type) {
                1 => return error.TypeA,
                2 => return error.TypeB,
                3 => return error.TypeC,
                else => {},
            }
            std.debug.print("    成功\n", .{});
        }
    };

    std.debug.print("  TypeA:\n", .{});
    helper.withPayload(1) catch {};

    std.debug.print("  TypeB:\n", .{});
    helper.withPayload(2) catch {};

    std.debug.print("  成功:\n", .{});
    helper.withPayload(0) catch {};

    std.debug.print("\n", .{});
}

// ====================
// 実践的なパターン：初期化関数
// ====================

const Connection = struct {
    socket: bool,
    buffer: bool,
    initialized: bool,

    pub fn init() !Connection {
        var self = Connection{
            .socket = false,
            .buffer = false,
            .initialized = false,
        };

        // ソケット接続
        self.socket = true;
        errdefer self.closeSocket();
        std.debug.print("    ソケット接続\n", .{});

        // バッファ確保
        self.buffer = true;
        errdefer self.freeBuffer();
        std.debug.print("    バッファ確保\n", .{});

        // 初期化完了
        self.initialized = true;
        std.debug.print("    初期化完了\n", .{});

        return self;
    }

    pub fn initWithError() !Connection {
        var self = Connection{
            .socket = false,
            .buffer = false,
            .initialized = false,
        };

        self.socket = true;
        errdefer self.closeSocket();
        std.debug.print("    ソケット接続\n", .{});

        // バッファ確保でエラー
        return error.BufferAllocationFailed;
    }

    fn closeSocket(self: *Connection) void {
        if (self.socket) {
            std.debug.print("    errdefer: ソケット切断\n", .{});
            self.socket = false;
        }
    }

    fn freeBuffer(self: *Connection) void {
        if (self.buffer) {
            std.debug.print("    errdefer: バッファ解放\n", .{});
            self.buffer = false;
        }
    }

    pub fn deinit(self: *Connection) void {
        if (self.buffer) {
            std.debug.print("    バッファ解放\n", .{});
            self.buffer = false;
        }
        if (self.socket) {
            std.debug.print("    ソケット切断\n", .{});
            self.socket = false;
        }
    }
};

fn demoInitPattern() void {
    std.debug.print("--- 初期化パターン ---\n", .{});

    // 成功ケース
    std.debug.print("  [成功]\n", .{});
    if (Connection.init()) |*conn| {
        var c = conn.*;
        c.deinit();
    } else |_| {}

    // エラーケース
    std.debug.print("  [エラー]\n", .{});
    if (Connection.initWithError()) |_| {} else |err| {
        std.debug.print("    エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// errdeferの実行順序
// ====================

fn demoExecutionOrder() void {
    std.debug.print("--- errdeferの実行順序 ---\n", .{});

    const helper = struct {
        fn showOrder() !void {
            errdefer std.debug.print("    errdefer 1\n", .{});
            errdefer std.debug.print("    errdefer 2\n", .{});
            errdefer std.debug.print("    errdefer 3\n", .{});

            std.debug.print("    エラー発生\n", .{});
            return error.TestError;
        }
    };

    std.debug.print("  errdeferは逆順（LIFO）で実行:\n", .{});
    helper.showOrder() catch {};

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== errdefer ===\n\n", .{});

    demoBasicErrdefer();
    demoDeferVsErrdefer();
    try demoMemoryCleanup();
    demoMultipleResources();
    demoErrdeferWithPayload();
    demoInitPattern();
    demoExecutionOrder();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・errdeferはエラー時のみ実行\n", .{});
    std.debug.print("・deferは常に実行（正常時も）\n", .{});
    std.debug.print("・複数errdeferは逆順（LIFO）で実行\n", .{});
    std.debug.print("・リソース解放に最適\n", .{});
}

// --- テスト ---

test "errdefer executes on error" {
    var executed = false;

    const helper = struct {
        fn process(exec: *bool) !void {
            errdefer exec.* = true;
            return error.TestError;
        }
    };

    helper.process(&executed) catch {};
    try std.testing.expect(executed);
}

test "errdefer does not execute on success" {
    var executed = false;

    const helper = struct {
        fn process(exec: *bool) !void {
            errdefer exec.* = true;
            // 成功（returnなし）
        }
    };

    try helper.process(&executed);
    try std.testing.expect(!executed);
}

test "multiple errdefers execute in reverse order" {
    var order: [3]u8 = undefined;
    var idx: usize = 0;

    const helper = struct {
        fn process(ord: *[3]u8, i: *usize) !void {
            errdefer {
                ord[i.*] = 1;
                i.* += 1;
            }
            errdefer {
                ord[i.*] = 2;
                i.* += 1;
            }
            errdefer {
                ord[i.*] = 3;
                i.* += 1;
            }
            return error.TestError;
        }
    };

    helper.process(&order, &idx) catch {};

    // 逆順で実行: 3, 2, 1
    try std.testing.expectEqual(@as(u8, 3), order[0]);
    try std.testing.expectEqual(@as(u8, 2), order[1]);
    try std.testing.expectEqual(@as(u8, 1), order[2]);
}

test "errdefer with payload" {
    var captured_error: anyerror = undefined;

    const helper = struct {
        fn process(captured: *anyerror) !void {
            errdefer |err| captured.* = err;
            return error.SpecificError;
        }
    };

    helper.process(&captured_error) catch {};
    try std.testing.expectEqual(error.SpecificError, captured_error);
}

test "defer and errdefer combination" {
    var defer_executed = false;
    var errdefer_executed = false;

    const helper = struct {
        fn process(d: *bool, e: *bool, should_fail: bool) !void {
            defer d.* = true;
            errdefer e.* = true;

            if (should_fail) return error.TestError;
        }
    };

    // エラー時: 両方実行
    helper.process(&defer_executed, &errdefer_executed, true) catch {};
    try std.testing.expect(defer_executed);
    try std.testing.expect(errdefer_executed);

    // リセット
    defer_executed = false;
    errdefer_executed = false;

    // 成功時: deferのみ実行
    try helper.process(&defer_executed, &errdefer_executed, false);
    try std.testing.expect(defer_executed);
    try std.testing.expect(!errdefer_executed);
}
