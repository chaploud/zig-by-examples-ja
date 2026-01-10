//! # テスト総まとめ
//!
//! Zigのテスト機能の総合的なレビュー。
//! 実践的なテストの書き方とベストプラクティス。
//!
//! ## 学習した内容
//! 1. テスト基礎（expect, expectEqual, etc.）
//! 2. テスト構成（refAllDecls, 名前付け）
//! 3. テストパターン（モック, DI, テーブル駆動）
//! 4. ランダムテスト（性質ベース検証）

const std = @import("std");

// ====================
// 総合的なテスト例
// ====================

// 被テスト構造体
const Stack = struct {
    const Self = @This();

    items: []i32,
    len: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
        return .{
            .items = try allocator.alloc(i32, capacity),
            .len = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.items);
    }

    pub fn push(self: *Self, value: i32) !void {
        if (self.len >= self.items.len) return error.StackOverflow;
        self.items[self.len] = value;
        self.len += 1;
    }

    pub fn pop(self: *Self) !i32 {
        if (self.len == 0) return error.StackUnderflow;
        self.len -= 1;
        return self.items[self.len];
    }

    pub fn peek(self: Self) ?i32 {
        if (self.len == 0) return null;
        return self.items[self.len - 1];
    }

    pub fn isEmpty(self: Self) bool {
        return self.len == 0;
    }

    pub fn count(self: Self) usize {
        return self.len;
    }
};

// ====================
// 1. 基本テスト（expect系）
// ====================

test "basic: push and pop" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 10);
    defer stack.deinit();

    // 基本操作
    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    // expectEqual
    try std.testing.expectEqual(@as(usize, 3), stack.count());

    // pop順序
    try std.testing.expectEqual(@as(i32, 3), try stack.pop());
    try std.testing.expectEqual(@as(i32, 2), try stack.pop());
    try std.testing.expectEqual(@as(i32, 1), try stack.pop());

    // expect
    try std.testing.expect(stack.isEmpty());
}

test "basic: peek does not remove" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 5);
    defer stack.deinit();

    try stack.push(42);

    // peekは削除しない
    try std.testing.expectEqual(@as(?i32, 42), stack.peek());
    try std.testing.expectEqual(@as(usize, 1), stack.count());

    // 再度peekしても同じ
    try std.testing.expectEqual(@as(?i32, 42), stack.peek());
}

// ====================
// 2. エラーテスト
// ====================

test "error: stack overflow" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 2);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);

    // 3つ目でオーバーフロー
    try std.testing.expectError(error.StackOverflow, stack.push(3));
}

test "error: stack underflow" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 5);
    defer stack.deinit();

    // 空スタックからpop
    try std.testing.expectError(error.StackUnderflow, stack.pop());
}

test "error: peek on empty returns null" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 5);
    defer stack.deinit();

    try std.testing.expectEqual(@as(?i32, null), stack.peek());
}

// ====================
// 3. テーブル駆動テスト
// ====================

test "table driven: multiple push/pop sequences" {
    const TestCase = struct {
        pushes: []const i32,
        expected_pops: []const i32,
    };

    const cases = [_]TestCase{
        .{ .pushes = &[_]i32{ 1, 2, 3 }, .expected_pops = &[_]i32{ 3, 2, 1 } },
        .{ .pushes = &[_]i32{42}, .expected_pops = &[_]i32{42} },
        .{ .pushes = &[_]i32{ -1, 0, 1 }, .expected_pops = &[_]i32{ 1, 0, -1 } },
    };

    const allocator = std.testing.allocator;

    for (cases) |case| {
        var stack = try Stack.init(allocator, 10);
        defer stack.deinit();

        for (case.pushes) |v| {
            try stack.push(v);
        }

        for (case.expected_pops) |expected| {
            const actual = try stack.pop();
            try std.testing.expectEqual(expected, actual);
        }
    }
}

// ====================
// 4. プロパティベーステスト
// ====================

test "property: push count equals pop count" {
    const allocator = std.testing.allocator;
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    for (0..10) |_| {
        const count = random.intRangeAtMost(usize, 1, 20);

        var stack = try Stack.init(allocator, count);
        defer stack.deinit();

        // ランダムな値をpush
        for (0..count) |_| {
            try stack.push(random.int(i32));
        }

        // 同じ数だけpop可能
        for (0..count) |_| {
            _ = try stack.pop();
        }

        // 全てpopした後は空
        try std.testing.expect(stack.isEmpty());
    }
}

test "property: LIFO order preserved" {
    const allocator = std.testing.allocator;
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    var pushed: [20]i32 = undefined;
    const count = random.intRangeAtMost(usize, 5, 20);

    var stack = try Stack.init(allocator, 20);
    defer stack.deinit();

    // pushした値を記録
    for (0..count) |i| {
        pushed[i] = random.int(i32);
        try stack.push(pushed[i]);
    }

    // 逆順でpopされる
    var i = count;
    while (i > 0) {
        i -= 1;
        const popped = try stack.pop();
        try std.testing.expectEqual(pushed[i], popped);
    }
}

// ====================
// 5. 境界値テスト
// ====================

test "boundary: capacity 1 stack" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 1);
    defer stack.deinit();

    try stack.push(42);
    try std.testing.expectError(error.StackOverflow, stack.push(43));

    try std.testing.expectEqual(@as(i32, 42), try stack.pop());
    try std.testing.expectError(error.StackUnderflow, stack.pop());
}

test "boundary: extreme values" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 3);
    defer stack.deinit();

    try stack.push(std.math.minInt(i32));
    try stack.push(0);
    try stack.push(std.math.maxInt(i32));

    try std.testing.expectEqual(std.math.maxInt(i32), try stack.pop());
    try std.testing.expectEqual(@as(i32, 0), try stack.pop());
    try std.testing.expectEqual(std.math.minInt(i32), try stack.pop());
}

// ====================
// 6. メモリリークテスト
// ====================

test "memory: no leaks on normal use" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 100);
    defer stack.deinit();

    for (0..50) |i| {
        try stack.push(@as(i32, @intCast(i)));
    }

    for (0..25) |_| {
        _ = try stack.pop();
    }

    // deferで解放されるのでリークなし
}

test "memory: no leaks on error" {
    const allocator = std.testing.allocator;

    var stack = try Stack.init(allocator, 2);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);

    // エラーが発生してもメモリリークなし
    _ = stack.push(3) catch {};
}

// ====================
// まとめ: ベストプラクティス
// ====================

// 1. 正常系と異常系の両方をテスト
// 2. 境界値を必ず含める
// 3. テーブル駆動で重複削減
// 4. プロパティで不変条件検証
// 5. std.testing.allocatorでリーク検出
// 6. 名前で意図を明確に
// 7. 小さく独立したテスト

pub fn main() void {
    std.debug.print("=== テスト総まとめ ===\n\n", .{});

    std.debug.print("--- テスト関数一覧 ---\n", .{});
    std.debug.print("  expect(bool)             : 条件がtrue\n", .{});
    std.debug.print("  expectEqual(exp, act)    : 値が等しい\n", .{});
    std.debug.print("  expectEqualStrings(a, b) : 文字列比較\n", .{});
    std.debug.print("  expectEqualSlices(T,a,b) : 配列比較\n", .{});
    std.debug.print("  expectError(err, expr)   : エラー期待\n", .{});
    std.debug.print("  expectApproxEqAbs(a,b,e) : 近似比較\n", .{});

    std.debug.print("\n--- テストパターン ---\n", .{});
    std.debug.print("  基本テスト       : 正常系・異常系\n", .{});
    std.debug.print("  テーブル駆動     : データ配列でケース管理\n", .{});
    std.debug.print("  プロパティベース : 不変条件検証\n", .{});
    std.debug.print("  境界値テスト     : 極端な値\n", .{});
    std.debug.print("  メモリテスト     : リーク検出\n", .{});

    std.debug.print("\n--- テスト実行 ---\n", .{});
    std.debug.print("  zig test file.zig                # 全テスト\n", .{});
    std.debug.print("  zig test --test-filter \"name\"    # フィルタ\n", .{});

    std.debug.print("\n--- ベストプラクティス ---\n", .{});
    std.debug.print("  1. 正常系と異常系を両方テスト\n", .{});
    std.debug.print("  2. 境界値を必ず含める\n", .{});
    std.debug.print("  3. std.testing.allocatorでリーク検出\n", .{});
    std.debug.print("  4. テスト名で意図を明確に\n", .{});
    std.debug.print("  5. 小さく独立したテスト\n", .{});
}
