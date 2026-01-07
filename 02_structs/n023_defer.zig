//! # defer と errdefer
//!
//! deferはスコープ終了時に実行される式を登録する。
//! errdeferはエラー発生時のみ実行される。
//!
//! ## 用途
//! - リソースの確実な解放
//! - クリーンアップ処理
//! - エラー時のロールバック
//!
//! ## 実行順序
//! - deferはLIFO（後入れ先出し）順

const std = @import("std");

// ====================
// 基本的なdefer
// ====================

fn basicDefer() void {
    std.debug.print("1. 関数開始\n", .{});

    defer std.debug.print("5. defer実行（最後に登録）\n", .{});
    defer std.debug.print("4. defer実行（最初に登録）\n", .{});

    std.debug.print("2. 処理中...\n", .{});
    std.debug.print("3. 関数終了前\n", .{});
    // スコープ終了時にdeferがLIFO順で実行される
}

// ====================
// ループ内のdefer
// ====================

fn deferInLoop() void {
    std.debug.print("ループ内のdefer:\n", .{});

    for (0..3) |i| {
        defer std.debug.print("  defer: i={d}\n", .{i});
        std.debug.print("  ループ i={d}\n", .{i});
    }

    std.debug.print("ループ終了\n", .{});
}

// ====================
// リソース管理パターン
// ====================

const Resource = struct {
    name: []const u8,
    acquired: bool,

    const Self = @This();

    pub fn acquire(name: []const u8) Self {
        std.debug.print("  リソース '{s}' を獲得\n", .{name});
        return Self{ .name = name, .acquired = true };
    }

    pub fn release(self: *Self) void {
        if (self.acquired) {
            std.debug.print("  リソース '{s}' を解放\n", .{self.name});
            self.acquired = false;
        }
    }
};

fn resourceManagement() void {
    std.debug.print("リソース管理パターン:\n", .{});

    var res1 = Resource.acquire("データベース接続");
    defer res1.release();

    var res2 = Resource.acquire("ファイルハンドル");
    defer res2.release();

    std.debug.print("  リソースを使用中...\n", .{});
    // スコープ終了時に自動的にres2, res1の順で解放
}

// ====================
// errdefer
// ====================

const ProcessError = error{
    InitFailed,
    ProcessFailed,
    CleanupFailed,
};

fn errdeferExample(should_fail: bool) ProcessError!void {
    std.debug.print("  処理開始\n", .{});

    // 成功時のみ実行されるdefer
    defer std.debug.print("  defer: 常に実行\n", .{});

    // エラー時のみ実行されるerrdefer
    errdefer std.debug.print("  errdefer: エラー発生時のみ実行\n", .{});

    if (should_fail) {
        std.debug.print("  エラー発生！\n", .{});
        return error.ProcessFailed;
    }

    std.debug.print("  処理成功\n", .{});
}

// ====================
// errdeferでのロールバック
// ====================

const Transaction = struct {
    steps_completed: u32,

    const Self = @This();

    pub fn init() Self {
        return Self{ .steps_completed = 0 };
    }

    pub fn step1(self: *Self) !void {
        std.debug.print("    Step 1 実行\n", .{});
        self.steps_completed = 1;
    }

    pub fn step2(self: *Self) !void {
        std.debug.print("    Step 2 実行\n", .{});
        self.steps_completed = 2;
    }

    pub fn step3(self: *Self, should_fail: bool) !void {
        if (should_fail) {
            return error.ProcessFailed;
        }
        std.debug.print("    Step 3 実行\n", .{});
        self.steps_completed = 3;
    }

    pub fn rollback(self: *Self) void {
        std.debug.print("    ロールバック: {d}ステップを戻す\n", .{self.steps_completed});
        self.steps_completed = 0;
    }
};

fn executeTransaction(should_fail: bool) !void {
    var tx = Transaction.init();
    errdefer tx.rollback();

    try tx.step1();
    try tx.step2();
    try tx.step3(should_fail);

    std.debug.print("    トランザクション完了\n", .{});
}

// ====================
// deferブロック
// ====================

fn deferBlock() void {
    std.debug.print("deferブロック:\n", .{});

    var value: i32 = 0;

    defer {
        value += 1;
        std.debug.print("  deferブロック実行: value={d}\n", .{value});
    }

    value = 10;
    std.debug.print("  関数内: value={d}\n", .{value});
}

// ====================
// errdeferとキャプチャ
// ====================

fn errdeferWithCapture() !i32 {
    var value: i32 = 0;

    // errdeferでエラー値をキャプチャ
    errdefer |err| {
        std.debug.print("  errdefer: エラー={s}, value={d}\n", .{ @errorName(err), value });
    }

    value = 42;
    return error.ProcessFailed;
}

// ====================
// 実用例: ファイル処理風
// ====================

const MockFile = struct {
    name: []const u8,
    is_open: bool,

    const Self = @This();

    pub fn open(name: []const u8) !Self {
        std.debug.print("  ファイル '{s}' を開く\n", .{name});
        return Self{ .name = name, .is_open = true };
    }

    pub fn close(self: *Self) void {
        if (self.is_open) {
            std.debug.print("  ファイル '{s}' を閉じる\n", .{self.name});
            self.is_open = false;
        }
    }

    pub fn write(self: *Self, data: []const u8) !void {
        if (!self.is_open) return error.FileNotOpen;
        std.debug.print("  ファイルに書き込み: {s}\n", .{data});
    }
};

fn processFile(should_fail: bool) !void {
    var file = try MockFile.open("test.txt");
    defer file.close();

    try file.write("Hello");

    if (should_fail) {
        return error.ProcessFailed;
    }

    try file.write("World");
}

pub fn main() void {
    std.debug.print("=== defer と errdefer ===\n\n", .{});

    // ====================
    // 基本的なdefer
    // ====================

    std.debug.print("--- 基本的なdefer ---\n", .{});
    basicDefer();
    std.debug.print("\n", .{});

    // ====================
    // ループ内のdefer
    // ====================

    std.debug.print("--- ループ内のdefer ---\n", .{});
    deferInLoop();
    std.debug.print("\n", .{});

    // ====================
    // リソース管理
    // ====================

    std.debug.print("--- リソース管理 ---\n", .{});
    resourceManagement();
    std.debug.print("\n", .{});

    // ====================
    // errdefer
    // ====================

    std.debug.print("--- errdefer（成功時） ---\n", .{});
    errdeferExample(false) catch {};
    std.debug.print("\n", .{});

    std.debug.print("--- errdefer（失敗時） ---\n", .{});
    errdeferExample(true) catch {};
    std.debug.print("\n", .{});

    // ====================
    // トランザクション
    // ====================

    std.debug.print("--- トランザクション（成功） ---\n", .{});
    executeTransaction(false) catch {};
    std.debug.print("\n", .{});

    std.debug.print("--- トランザクション（失敗） ---\n", .{});
    executeTransaction(true) catch {};
    std.debug.print("\n", .{});

    // ====================
    // deferブロック
    // ====================

    std.debug.print("--- deferブロック ---\n", .{});
    deferBlock();
    std.debug.print("\n", .{});

    // ====================
    // errdeferキャプチャ
    // ====================

    std.debug.print("--- errdeferキャプチャ ---\n", .{});
    _ = errdeferWithCapture() catch {};
    std.debug.print("\n", .{});

    // ====================
    // ファイル処理
    // ====================

    std.debug.print("--- ファイル処理（成功） ---\n", .{});
    processFile(false) catch {};
    std.debug.print("\n", .{});

    std.debug.print("--- ファイル処理（失敗） ---\n", .{});
    processFile(true) catch {};
    std.debug.print("\n", .{});

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・defer: スコープ終了時に必ず実行\n", .{});
    std.debug.print("・errdefer: エラー発生時のみ実行\n", .{});
    std.debug.print("・LIFO順（後入れ先出し）で実行\n", .{});
    std.debug.print("・リソース管理に最適\n", .{});
}

// --- テスト ---

test "defer execution order" {
    var order: [3]u8 = undefined;
    var idx: usize = 0;

    {
        defer {
            order[idx] = 3;
            idx += 1;
        }
        defer {
            order[idx] = 2;
            idx += 1;
        }
        defer {
            order[idx] = 1;
            idx += 1;
        }
    }

    // LIFO順: 3 -> 2 -> 1 の順で実行
    try std.testing.expect(order[0] == 1);
    try std.testing.expect(order[1] == 2);
    try std.testing.expect(order[2] == 3);
}

test "defer in loop" {
    var count: u32 = 0;

    for (0..3) |_| {
        defer {
            count += 1;
        }
    }

    try std.testing.expectEqual(@as(u32, 3), count);
}

test "errdefer on error" {
    var errdefer_called = false;

    const helper = struct {
        fn run(ptr: *bool) !void {
            errdefer {
                ptr.* = true;
            }
            return error.TestError;
        }
    };

    helper.run(&errdefer_called) catch {};
    try std.testing.expect(errdefer_called);
}

test "errdefer not called on success" {
    var errdefer_called = false;

    const helper = struct {
        fn run(ptr: *bool) !i32 {
            errdefer {
                ptr.* = true;
            }
            return 42;
        }
    };

    const result = try helper.run(&errdefer_called);
    try std.testing.expectEqual(@as(i32, 42), result);
    try std.testing.expect(!errdefer_called);
}

test "Resource acquire and release" {
    var res = Resource.acquire("test");
    try std.testing.expect(res.acquired);

    res.release();
    try std.testing.expect(!res.acquired);
}

test "MockFile operations" {
    var file = try MockFile.open("test.txt");
    try std.testing.expect(file.is_open);

    try file.write("data");

    file.close();
    try std.testing.expect(!file.is_open);

    // 閉じた後は書き込みエラー
    try std.testing.expectError(error.FileNotOpen, file.write("more"));
}

test "Transaction rollback on error" {
    // 失敗時にロールバックされることをテスト
    executeTransaction(true) catch |err| {
        try std.testing.expectEqual(error.ProcessFailed, err);
    };
}

test "Transaction success" {
    try executeTransaction(false);
}
