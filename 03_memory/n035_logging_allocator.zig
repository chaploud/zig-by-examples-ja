//! # ロギングアロケータ
//!
//! アロケータをラップしてメモリ操作を追跡・ログ出力する。
//! カスタムアロケータの実装パターンを学ぶ。
//!
//! ## 目的
//! - メモリリークの検出
//! - メモリ使用量の追跡
//! - デバッグ情報の出力
//!
//! ## Zigのログシステム
//! - std.log: 標準ログAPI
//! - scoped: 名前空間付きログ
//! - Level: debug, info, warn, err

const std = @import("std");

// ====================
// カスタムロギングアロケータ
// ====================

fn LoggingAllocator(comptime BackingAllocator: type) type {
    return struct {
        backing: BackingAllocator,
        total_allocated: usize = 0,
        total_freed: usize = 0,
        allocation_count: usize = 0,
        free_count: usize = 0,

        const Self = @This();
        const log = std.log.scoped(.logging_allocator);

        pub fn init(backing: BackingAllocator) Self {
            return Self{
                .backing = backing,
            };
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return .{
                .ptr = self,
                .vtable = &.{
                    .alloc = alloc,
                    .resize = resize,
                    .remap = remap,
                    .free = free,
                },
            };
        }

        fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const result = self.backing.rawAlloc(len, alignment, ret_addr);

            if (result) |ptr| {
                self.total_allocated += len;
                self.allocation_count += 1;
                log.debug("alloc: {d} bytes at 0x{x}", .{ len, @intFromPtr(ptr) });
            } else {
                log.warn("alloc failed: {d} bytes", .{len});
            }

            return result;
        }

        fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const old_len = buf.len;
            const result = self.backing.rawResize(buf, alignment, new_len, ret_addr);

            if (result) {
                if (new_len > old_len) {
                    self.total_allocated += new_len - old_len;
                } else {
                    self.total_freed += old_len - new_len;
                }
                log.debug("resize: {d} -> {d} bytes", .{ old_len, new_len });
            }

            return result;
        }

        fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const old_len = buf.len;
            const result = self.backing.rawRemap(buf, alignment, new_len, ret_addr);

            if (result) |_| {
                if (new_len > old_len) {
                    self.total_allocated += new_len - old_len;
                } else {
                    self.total_freed += old_len - new_len;
                }
                log.debug("remap: {d} -> {d} bytes", .{ old_len, new_len });
            }

            return result;
        }

        fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
            const self: *Self = @ptrCast(@alignCast(ctx));
            self.total_freed += buf.len;
            self.free_count += 1;
            log.debug("free: {d} bytes at 0x{x}", .{ buf.len, @intFromPtr(buf.ptr) });
            self.backing.rawFree(buf, alignment, ret_addr);
        }

        pub fn stats(self: *const Self) Stats {
            return Stats{
                .total_allocated = self.total_allocated,
                .total_freed = self.total_freed,
                .current_usage = self.total_allocated -| self.total_freed,
                .allocation_count = self.allocation_count,
                .free_count = self.free_count,
            };
        }

        pub const Stats = struct {
            total_allocated: usize,
            total_freed: usize,
            current_usage: usize,
            allocation_count: usize,
            free_count: usize,
        };
    };
}

fn demoLoggingAllocator() !void {
    std.debug.print("--- カスタムロギングアロケータ ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var logging = LoggingAllocator(std.mem.Allocator).init(gpa.allocator());
    const allocator = logging.allocator();

    // メモリ操作
    const data = try allocator.alloc(u8, 100);
    @memset(data, 'A');

    const more = try allocator.alloc(u8, 50);
    @memset(more, 'B');

    allocator.free(data);

    const stats = logging.stats();
    std.debug.print("  総割り当て: {d} bytes\n", .{stats.total_allocated});
    std.debug.print("  総解放: {d} bytes\n", .{stats.total_freed});
    std.debug.print("  現在使用: {d} bytes\n", .{stats.current_usage});
    std.debug.print("  割り当て回数: {d}\n", .{stats.allocation_count});
    std.debug.print("  解放回数: {d}\n", .{stats.free_count});

    allocator.free(more);

    std.debug.print("\n", .{});
}

// ====================
// std.log の基本
// ====================

const app_log = std.log.scoped(.app);

fn demoStdLog() void {
    std.debug.print("--- std.log の基本 ---\n", .{});

    // std.logの使い方（実際のログはstderrに出力）
    std.debug.print("  std.log.debug(...)  // デバッグ情報\n", .{});
    std.debug.print("  std.log.info(...)   // 一般情報\n", .{});
    std.debug.print("  std.log.warn(...)   // 警告\n", .{});
    std.debug.print("  std.log.err(...)    // エラー\n", .{});

    std.debug.print("  スコープ付きログ:\n", .{});
    std.debug.print("    const log = std.log.scoped(.my_scope);\n", .{});
    std.debug.print("    log.info(\"message\", .{{}});\n", .{});

    // 実際にログを出力（ビルドモードによってフィルタされる）
    app_log.info("アプリケーション開始", .{});

    std.debug.print("\n", .{});
}

// ====================
// DebugAllocator (旧GPA)
// ====================

fn demoDebugAllocator() !void {
    std.debug.print("--- DebugAllocator ---\n", .{});

    // std.heap.GeneralPurposeAllocator は
    // std.heap.DebugAllocator の別名（0.15で非推奨）
    var debug_alloc = std.heap.DebugAllocator(.{}){};
    const allocator = debug_alloc.allocator();

    // 使用例
    const data = try allocator.alloc(u8, 10);
    @memset(data, 'X');
    allocator.free(data);

    // deinitでリークチェック
    const result = debug_alloc.deinit();

    std.debug.print("  DebugAllocatorの機能:\n", .{});
    std.debug.print("    - リーク検出\n", .{});
    std.debug.print("    - 二重解放検出\n", .{});
    std.debug.print("    - スタックトレース\n", .{});
    std.debug.print("  deinit結果: {s}\n", .{if (result == .ok) "ok" else "leak"});

    std.debug.print("\n", .{});
}

// ====================
// カウントアロケータ
// ====================

fn CountingAllocator(comptime BackingAllocator: type) type {
    return struct {
        backing: BackingAllocator,
        count: usize = 0,
        bytes: usize = 0,
        peak_bytes: usize = 0,

        const Self = @This();

        pub fn init(backing: BackingAllocator) Self {
            return Self{ .backing = backing };
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return .{
                .ptr = self,
                .vtable = &.{
                    .alloc = alloc,
                    .resize = resize,
                    .remap = remap,
                    .free = free,
                },
            };
        }

        fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const result = self.backing.rawAlloc(len, alignment, ret_addr);
            if (result != null) {
                self.count += 1;
                self.bytes += len;
                self.peak_bytes = @max(self.peak_bytes, self.bytes);
            }
            return result;
        }

        fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const result = self.backing.rawResize(buf, alignment, new_len, ret_addr);
            if (result) {
                if (new_len > buf.len) {
                    self.bytes += new_len - buf.len;
                } else {
                    self.bytes -= buf.len - new_len;
                }
                self.peak_bytes = @max(self.peak_bytes, self.bytes);
            }
            return result;
        }

        fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            const result = self.backing.rawRemap(buf, alignment, new_len, ret_addr);
            if (result != null) {
                if (new_len > buf.len) {
                    self.bytes += new_len - buf.len;
                } else {
                    self.bytes -= buf.len - new_len;
                }
                self.peak_bytes = @max(self.peak_bytes, self.bytes);
            }
            return result;
        }

        fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
            const self: *Self = @ptrCast(@alignCast(ctx));
            self.bytes -= buf.len;
            self.backing.rawFree(buf, alignment, ret_addr);
        }
    };
}

fn demoCountingAllocator() !void {
    std.debug.print("--- カウントアロケータ ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var counting = CountingAllocator(std.mem.Allocator).init(gpa.allocator());
    const allocator = counting.allocator();

    // いくつかの割り当て
    const a = try allocator.alloc(u8, 100);
    const b = try allocator.alloc(u8, 200);
    const c = try allocator.alloc(u8, 300);

    std.debug.print("  3回割り当て後:\n", .{});
    std.debug.print("    count: {d}\n", .{counting.count});
    std.debug.print("    bytes: {d}\n", .{counting.bytes});
    std.debug.print("    peak: {d}\n", .{counting.peak_bytes});

    allocator.free(b);

    std.debug.print("  1つ解放後:\n", .{});
    std.debug.print("    bytes: {d}\n", .{counting.bytes});
    std.debug.print("    peak: {d} (変わらない)\n", .{counting.peak_bytes});

    allocator.free(a);
    allocator.free(c);

    std.debug.print("\n", .{});
}

// ====================
// アロケータVTable
// ====================

fn demoAllocatorVTable() void {
    std.debug.print("--- アロケータVTable ---\n", .{});

    std.debug.print("  std.mem.Allocator構造:\n", .{});
    std.debug.print("    ptr: *anyopaque     // 状態へのポインタ\n", .{});
    std.debug.print("    vtable: *VTable     // 関数テーブル\n", .{});

    std.debug.print("  VTable:\n", .{});
    std.debug.print("    alloc: fn(...) ?[*]u8\n", .{});
    std.debug.print("    resize: fn(...) bool\n", .{});
    std.debug.print("    remap: fn(...) ?[*]u8\n", .{});
    std.debug.print("    free: fn(...) void\n", .{});

    std.debug.print("  → 任意のアロケータを共通インターフェースで使用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// フェイルアロケータ（テスト用）
// ====================

fn FailingAllocator(comptime BackingAllocator: type) type {
    return struct {
        backing: BackingAllocator,
        fail_after: usize,
        current: usize = 0,

        const Self = @This();

        pub fn init(backing: BackingAllocator, fail_after: usize) Self {
            return Self{
                .backing = backing,
                .fail_after = fail_after,
            };
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return .{
                .ptr = self,
                .vtable = &.{
                    .alloc = alloc,
                    .resize = resize,
                    .remap = remap,
                    .free = free,
                },
            };
        }

        fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            if (self.current >= self.fail_after) {
                return null; // 意図的に失敗
            }
            self.current += 1;
            return self.backing.rawAlloc(len, alignment, ret_addr);
        }

        fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
            const self: *Self = @ptrCast(@alignCast(ctx));
            return self.backing.rawResize(buf, alignment, new_len, ret_addr);
        }

        fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));
            return self.backing.rawRemap(buf, alignment, new_len, ret_addr);
        }

        fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
            const self: *Self = @ptrCast(@alignCast(ctx));
            self.backing.rawFree(buf, alignment, ret_addr);
        }
    };
}

fn demoFailingAllocator() !void {
    std.debug.print("--- フェイルアロケータ（テスト用） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var failing = FailingAllocator(std.mem.Allocator).init(gpa.allocator(), 2);
    const allocator = failing.allocator();

    // 最初の2回は成功
    const a = try allocator.alloc(u8, 10);
    defer allocator.free(a);
    std.debug.print("  1回目: 成功\n", .{});

    const b = try allocator.alloc(u8, 10);
    defer allocator.free(b);
    std.debug.print("  2回目: 成功\n", .{});

    // 3回目は失敗
    if (allocator.alloc(u8, 10)) |_| {
        std.debug.print("  3回目: 成功\n", .{});
    } else |_| {
        std.debug.print("  3回目: 失敗（意図的）\n", .{});
    }

    std.debug.print("  → エラーパスのテストに有用\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// デバッグ用ベストプラクティス
// ====================

fn demoBestPractices() void {
    std.debug.print("--- デバッグ用ベストプラクティス ---\n", .{});

    std.debug.print("  1. 開発時:\n", .{});
    std.debug.print("     - DebugAllocatorでリーク検出\n", .{});
    std.debug.print("     - deinitでチェック\n", .{});

    std.debug.print("  2. テスト時:\n", .{});
    std.debug.print("     - std.testing.allocator使用\n", .{});
    std.debug.print("     - FailingAllocatorでエラーパステスト\n", .{});

    std.debug.print("  3. 本番時:\n", .{});
    std.debug.print("     - page_allocatorまたはc_allocator\n", .{});
    std.debug.print("     - 軽量なカウンタのみ\n", .{});

    std.debug.print("  4. ログ:\n", .{});
    std.debug.print("     - std.log.scopedで名前空間分離\n", .{});
    std.debug.print("     - ビルドモードでフィルタリング\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ロギングアロケータ ===\n\n", .{});

    try demoLoggingAllocator();
    demoStdLog();
    try demoDebugAllocator();
    try demoCountingAllocator();
    demoAllocatorVTable();
    try demoFailingAllocator();
    demoBestPractices();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・アロケータをラップしてログ出力\n", .{});
    std.debug.print("・VTableで共通インターフェース実装\n", .{});
    std.debug.print("・DebugAllocatorでリーク検出\n", .{});
    std.debug.print("・std.logでスコープ付きログ\n", .{});
    std.debug.print("・テスト用にFailingAllocator\n", .{});
}

// --- テスト ---

test "LoggingAllocator tracks allocations" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var logging = LoggingAllocator(std.mem.Allocator).init(gpa.allocator());
    const allocator = logging.allocator();

    const data = try allocator.alloc(u8, 100);
    defer allocator.free(data);

    const stats = logging.stats();
    try std.testing.expectEqual(@as(usize, 100), stats.total_allocated);
    try std.testing.expectEqual(@as(usize, 1), stats.allocation_count);
}

test "CountingAllocator tracks peak" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var counting = CountingAllocator(std.mem.Allocator).init(gpa.allocator());
    const allocator = counting.allocator();

    const a = try allocator.alloc(u8, 100);
    const b = try allocator.alloc(u8, 200);
    // peak = 300
    try std.testing.expectEqual(@as(usize, 300), counting.peak_bytes);

    allocator.free(b);
    // bytes = 100, but peak still 300
    try std.testing.expectEqual(@as(usize, 100), counting.bytes);
    try std.testing.expectEqual(@as(usize, 300), counting.peak_bytes);

    allocator.free(a);
}

test "FailingAllocator fails after N allocations" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var failing = FailingAllocator(std.mem.Allocator).init(gpa.allocator(), 1);
    const allocator = failing.allocator();

    // 1回目は成功
    const a = try allocator.alloc(u8, 10);
    defer allocator.free(a);

    // 2回目は失敗（OutOfMemoryエラー）
    const result = allocator.alloc(u8, 10);
    try std.testing.expectError(error.OutOfMemory, result);
}

test "DebugAllocator no leak" {
    var debug_alloc = std.heap.DebugAllocator(.{}){};
    const allocator = debug_alloc.allocator();

    const data = try allocator.alloc(u8, 10);
    allocator.free(data);

    const result = debug_alloc.deinit();
    try std.testing.expectEqual(.ok, result);
}

test "allocator vtable interface" {
    // 異なるアロケータが同じインターフェースで使える
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator: std.mem.Allocator = gpa.allocator();

    // Allocatorインターフェース経由で操作
    const data = try allocator.alloc(u8, 10);
    defer allocator.free(data);

    try std.testing.expectEqual(@as(usize, 10), data.len);
}
