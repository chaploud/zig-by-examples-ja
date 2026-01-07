//! # resize と realloc
//!
//! 既存のメモリ割り当てサイズを変更する方法。
//! resize、remap、reallocの違いを理解する。
//!
//! ## 関数の違い
//! - resize: 移動なし、失敗時false
//! - remap: 移動あり、失敗時null
//! - realloc: 必ず成功（OutOfMemory以外）
//!
//! ## 用途
//! - 動的配列のサイズ変更
//! - バッファの拡張/縮小

const std = @import("std");

// ====================
// resize（移動なし）
// ====================

fn demoResize() !void {
    std.debug.print("--- resize（移動なし） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 初期割り当て
    var data = try allocator.alloc(u8, 10);
    defer allocator.free(data);

    @memset(data, 'A');
    std.debug.print("  初期サイズ: {d} bytes\n", .{data.len});
    std.debug.print("  内容: {s}\n", .{data});

    // resize: 移動せずにサイズ変更を試みる
    // 成功: true、失敗: false
    if (allocator.resize(data, 5)) {
        data = data[0..5]; // 縮小成功、スライスを更新
        std.debug.print("  縮小成功: {d} bytes\n", .{data.len});
    } else {
        std.debug.print("  縮小失敗（移動が必要）\n", .{});
    }

    // 拡大の試み（失敗する可能性が高い）
    if (allocator.resize(data, 20)) {
        data = data.ptr[0..20];
        std.debug.print("  拡大成功: {d} bytes\n", .{data.len});
    } else {
        std.debug.print("  拡大失敗（移動が必要）\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// remap（移動あり、失敗可）
// ====================

fn demoRemap() !void {
    std.debug.print("--- remap（移動あり、失敗可） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 初期割り当て
    var data = try allocator.alloc(u8, 10);
    @memset(data, 'B');

    std.debug.print("  初期サイズ: {d} bytes\n", .{data.len});
    const initial_ptr = @intFromPtr(data.ptr);
    std.debug.print("  初期アドレス: 0x{x}\n", .{initial_ptr});

    // remap: 必要なら移動してサイズ変更
    // 成功: 新しいスライス、失敗: null
    if (allocator.remap(data, 20)) |new_data| {
        data = new_data;
        const new_ptr = @intFromPtr(data.ptr);
        std.debug.print("  remap成功: {d} bytes\n", .{data.len});
        std.debug.print("  新アドレス: 0x{x}\n", .{new_ptr});
        if (initial_ptr == new_ptr) {
            std.debug.print("  → 同じ位置で拡大\n", .{});
        } else {
            std.debug.print("  → 移動して拡大\n", .{});
        }
    } else {
        std.debug.print("  remap失敗（手動でcopy & freeが必要）\n", .{});
    }

    allocator.free(data);

    std.debug.print("\n", .{});
}

// ====================
// realloc（必ず成功）
// ====================

fn demoRealloc() !void {
    std.debug.print("--- realloc（必ず成功） ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 初期割り当て
    var data = try allocator.alloc(u8, 10);
    for (data, 0..) |*b, i| {
        b.* = @as(u8, @intCast(i + '0'));
    }

    std.debug.print("  初期: len={d}, content={s}\n", .{ data.len, data });

    // realloc: 必ずサイズ変更が成功（OutOfMemoryのみ失敗）
    data = try allocator.realloc(data, 20);
    std.debug.print("  拡大後: len={d}\n", .{data.len});
    std.debug.print("  元データ保持: {s}\n", .{data[0..10]});

    // 新しい領域を初期化
    @memset(data[10..], 'X');
    std.debug.print("  初期化後: {s}\n", .{data});

    // 縮小
    data = try allocator.realloc(data, 5);
    std.debug.print("  縮小後: len={d}, content={s}\n", .{ data.len, data });

    allocator.free(data);

    std.debug.print("\n", .{});
}

// ====================
// 動的バッファの例
// ====================

fn DynamicBuffer(comptime T: type) type {
    return struct {
        data: []T,
        len: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .data = &[_]T{},
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.data.len > 0) {
                self.allocator.free(self.data);
            }
        }

        pub fn append(self: *Self, item: T) !void {
            if (self.len >= self.data.len) {
                // 容量を2倍にする（最小1）
                const new_cap = if (self.data.len == 0) 1 else self.data.len * 2;
                self.data = try self.allocator.realloc(self.data, new_cap);
            }
            self.data[self.len] = item;
            self.len += 1;
        }

        pub fn items(self: *const Self) []const T {
            return self.data[0..self.len];
        }
    };
}

fn demoDynamicBuffer() !void {
    std.debug.print("--- 動的バッファの例 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var buf = DynamicBuffer(i32).init(allocator);
    defer buf.deinit();

    for (0..10) |i| {
        try buf.append(@as(i32, @intCast(i * 10)));
        std.debug.print("  append {d}: len={d}, cap={d}\n", .{ i * 10, buf.len, buf.data.len });
    }

    std.debug.print("  最終データ: ", .{});
    for (buf.items()) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 縮小の活用
// ====================

fn demoShrink() !void {
    std.debug.print("--- 縮小の活用 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 大きめに確保
    var data = try allocator.alloc(u8, 1000);
    @memset(data[0..100], 'D');

    std.debug.print("  確保: {d} bytes\n", .{data.len});

    // 実際に使う分だけに縮小（メモリ節約）
    data = try allocator.realloc(data, 100);
    std.debug.print("  縮小: {d} bytes\n", .{data.len});
    std.debug.print("  内容: {s}\n", .{data[0..10]});

    allocator.free(data);

    std.debug.print("\n", .{});
}

// ====================
// resize vs realloc の使い分け
// ====================

fn demoComparison() !void {
    std.debug.print("--- resize vs realloc の使い分け ---\n", .{});

    std.debug.print("  resize:\n", .{});
    std.debug.print("    - 移動しない\n", .{});
    std.debug.print("    - 失敗時 false\n", .{});
    std.debug.print("    - ポインタ不変を保証したい時\n", .{});

    std.debug.print("  remap:\n", .{});
    std.debug.print("    - 移動の可能性あり\n", .{});
    std.debug.print("    - 失敗時 null\n", .{});
    std.debug.print("    - 最適化を試みつつ、失敗は許容\n", .{});

    std.debug.print("  realloc:\n", .{});
    std.debug.print("    - 常に成功（OutOfMemory以外）\n", .{});
    std.debug.print("    - 必要なら新規alloc + copy + free\n", .{});
    std.debug.print("    - 確実にサイズ変更したい時\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== resize と realloc ===\n\n", .{});

    try demoResize();
    try demoRemap();
    try demoRealloc();
    try demoDynamicBuffer();
    try demoShrink();
    try demoComparison();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・resize: 移動なし、bool返却\n", .{});
    std.debug.print("・remap: 移動可能、null返却\n", .{});
    std.debug.print("・realloc: 必ず成功、Error返却\n", .{});
    std.debug.print("・縮小はほぼ常に成功\n", .{});
    std.debug.print("・拡大は移動が必要な場合あり\n", .{});
}

// --- テスト ---

test "resize shrink" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var data = try allocator.alloc(u8, 100);
    defer allocator.free(data);

    // 縮小は通常成功
    const success = allocator.resize(data, 50);
    if (success) {
        data = data[0..50];
    }
    try std.testing.expect(data.len <= 100);
}

test "realloc grow" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var data = try allocator.alloc(u8, 10);
    @memset(data, 'A');

    // realloc で拡大
    data = try allocator.realloc(data, 20);

    try std.testing.expectEqual(@as(usize, 20), data.len);
    // 元データが保持されている
    try std.testing.expectEqual(@as(u8, 'A'), data[0]);
    try std.testing.expectEqual(@as(u8, 'A'), data[9]);

    allocator.free(data);
}

test "realloc shrink" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var data = try allocator.alloc(u8, 100);
    for (data, 0..) |*b, i| {
        b.* = @as(u8, @intCast(i));
    }

    data = try allocator.realloc(data, 10);

    try std.testing.expectEqual(@as(usize, 10), data.len);
    // 元データが保持されている
    for (data, 0..) |b, i| {
        try std.testing.expectEqual(@as(u8, @intCast(i)), b);
    }

    allocator.free(data);
}

test "realloc to zero frees" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();

    var data = try allocator.alloc(u8, 10);

    // reallocで0にするとfreeと同等
    data = try allocator.realloc(data, 0);
    try std.testing.expectEqual(@as(usize, 0), data.len);

    // deinitでリークチェック
    const result = gpa.deinit();
    try std.testing.expectEqual(.ok, result);
}

test "DynamicBuffer" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var buf = DynamicBuffer(i32).init(allocator);
    defer buf.deinit();

    try buf.append(10);
    try buf.append(20);
    try buf.append(30);

    try std.testing.expectEqual(@as(usize, 3), buf.len);
    try std.testing.expectEqual(@as(i32, 10), buf.items()[0]);
    try std.testing.expectEqual(@as(i32, 20), buf.items()[1]);
    try std.testing.expectEqual(@as(i32, 30), buf.items()[2]);
}

test "remap behavior" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var data = try allocator.alloc(u8, 10);

    // remapは成功/失敗の両方がありうる
    if (allocator.remap(data, 20)) |new_data| {
        data = new_data;
        try std.testing.expectEqual(@as(usize, 20), data.len);
    }
    // 失敗しても元のdataは有効

    allocator.free(data);
}
