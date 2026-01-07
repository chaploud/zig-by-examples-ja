//! # メソッド
//!
//! 構造体に関連付けられた関数をメソッドと呼ぶ。
//! self引数の型によって、読み取り専用か状態変更かが決まる。
//!
//! ## selfの型
//! - `self: T` — 読み取り専用（コピーを受け取る）
//! - `self: *T` — 状態変更可能（ポインタを受け取る）
//! - `self: *const T` — 読み取り専用（ポインタだがconst）

const std = @import("std");
const m = std.math;

// ====================
// 基本的なメソッド
// ====================

const Point = struct {
    x: f64,
    y: f64,

    /// 原点からの距離（読み取り専用メソッド）
    /// self: Point なので、構造体の値を変更しない
    pub fn distanceFromOrigin(self: Point) f64 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    /// 2点間の距離
    pub fn distanceTo(self: Point, other: Point) f64 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        return @sqrt(dx * dx + dy * dy);
    }

    /// 座標を移動（状態変更メソッド）
    /// self: *Point なので、構造体の値を変更できる
    pub fn translate(self: *Point, dx: f64, dy: f64) void {
        self.x += dx;
        self.y += dy;
    }

    /// スケーリング
    pub fn scale(self: *Point, factor: f64) void {
        self.x *= factor;
        self.y *= factor;
    }

    /// 原点にリセット
    pub fn reset(self: *Point) void {
        self.x = 0.0;
        self.y = 0.0;
    }
};

// ====================
// @This() を使った自己参照
// ====================

const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    // @This() で自身の型を取得
    const Self = @This();

    pub fn init(x: f64, y: f64, z: f64) Self {
        return Self{ .x = x, .y = y, .z = z };
    }

    pub fn add(self: Self, other: Self) Self {
        return Self{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn length(self: Self) f64 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    /// 正規化（状態変更）
    pub fn normalize(self: *Self) void {
        const len = @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        if (len > 0.0) {
            self.x /= len;
            self.y /= len;
            self.z /= len;
        }
    }

    /// 外積
    pub fn cross(self: Self, other: Self) Self {
        return Self{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    /// 内積
    pub fn dot(self: Self, other: Self) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

// ====================
// メソッドチェーン風パターン
// ====================

const StringBuilder = struct {
    buffer: [256]u8,
    len: usize,

    const Self = @This();

    pub fn init() Self {
        return Self{
            .buffer = [_]u8{0} ** 256,
            .len = 0,
        };
    }

    /// 文字列を追加して自分自身のポインタを返す
    pub fn append(self: *Self, text: []const u8) *Self {
        for (text) |c| {
            if (self.len < 256) {
                self.buffer[self.len] = c;
                self.len += 1;
            }
        }
        return self;
    }

    /// 現在の文字列を取得
    /// 注意: *const Self を使うのは、値渡しだとコピーからスライスを返し
    ///       ダングリングポインタになるため
    pub fn str(self: *const Self) []const u8 {
        return self.buffer[0..self.len];
    }

    pub fn clear(self: *Self) *Self {
        self.len = 0;
        return self;
    }
};

// ====================
// 静的メソッド（selfを取らない）
// ====================

const MathUtils = struct {
    // 静的メソッド（インスタンス不要）
    pub fn max(a: i32, b: i32) i32 {
        return if (a > b) a else b;
    }

    pub fn min(a: i32, b: i32) i32 {
        return if (a < b) a else b;
    }

    pub fn clamp(value: i32, lower: i32, upper: i32) i32 {
        return min(max(value, lower), upper);
    }

    pub fn abs(value: i32) i32 {
        return if (value < 0) -value else value;
    }
};

// ====================
// 状態管理の例
// ====================

const BankAccount = struct {
    balance: i64,
    transaction_count: u32,

    const Self = @This();

    pub fn init(initial_balance: i64) Self {
        return Self{
            .balance = initial_balance,
            .transaction_count = 0,
        };
    }

    /// 残高を確認（読み取り専用）
    pub fn getBalance(self: Self) i64 {
        return self.balance;
    }

    /// 入金（状態変更）
    pub fn deposit(self: *Self, amount: i64) !void {
        if (amount <= 0) return error.InvalidAmount;
        self.balance += amount;
        self.transaction_count += 1;
    }

    /// 出金（状態変更）
    pub fn withdraw(self: *Self, amount: i64) !void {
        if (amount <= 0) return error.InvalidAmount;
        if (amount > self.balance) return error.InsufficientFunds;
        self.balance -= amount;
        self.transaction_count += 1;
    }

    /// 取引回数を取得
    pub fn getTransactionCount(self: Self) u32 {
        return self.transaction_count;
    }
};

pub fn main() void {
    std.debug.print("=== メソッド ===\n\n", .{});

    // ====================
    // 読み取り専用 vs 状態変更
    // ====================

    std.debug.print("--- 読み取り専用 vs 状態変更 ---\n", .{});

    var p = Point{ .x = 3.0, .y = 4.0 };
    std.debug.print("Point: ({d:.1}, {d:.1})\n", .{ p.x, p.y });
    std.debug.print("原点からの距離: {d:.1}\n", .{p.distanceFromOrigin()});

    // 状態変更メソッド
    p.translate(1.0, 1.0);
    std.debug.print("translate(1,1)後: ({d:.1}, {d:.1})\n", .{ p.x, p.y });

    p.scale(2.0);
    std.debug.print("scale(2)後: ({d:.1}, {d:.1})\n", .{ p.x, p.y });

    std.debug.print("\n", .{});

    // ====================
    // @This() の使用
    // ====================

    std.debug.print("--- @This() を使った自己参照 ---\n", .{});

    var v1 = Vec3.init(1.0, 0.0, 0.0);
    const v2 = Vec3.init(0.0, 1.0, 0.0);

    std.debug.print("v1: ({d:.1}, {d:.1}, {d:.1})\n", .{ v1.x, v1.y, v1.z });
    std.debug.print("v2: ({d:.1}, {d:.1}, {d:.1})\n", .{ v2.x, v2.y, v2.z });

    const cross_product = v1.cross(v2);
    std.debug.print("v1 × v2 = ({d:.1}, {d:.1}, {d:.1})\n", .{ cross_product.x, cross_product.y, cross_product.z });

    std.debug.print("v1 · v2 = {d:.1}\n", .{v1.dot(v2)});

    std.debug.print("\n", .{});

    // ====================
    // 静的メソッド
    // ====================

    std.debug.print("--- 静的メソッド（selfを取らない） ---\n", .{});

    std.debug.print("MathUtils.max(5, 3) = {d}\n", .{MathUtils.max(5, 3)});
    std.debug.print("MathUtils.min(5, 3) = {d}\n", .{MathUtils.min(5, 3)});
    std.debug.print("MathUtils.clamp(15, 0, 10) = {d}\n", .{MathUtils.clamp(15, 0, 10)});
    std.debug.print("MathUtils.abs(-42) = {d}\n", .{MathUtils.abs(-42)});

    std.debug.print("\n", .{});

    // ====================
    // メソッドチェーン風
    // ====================

    std.debug.print("--- メソッドチェーン風パターン ---\n", .{});

    var sb = StringBuilder.init();
    // チェーン呼び出し
    _ = sb.append("Hello");
    _ = sb.append(", ");
    _ = sb.append("Zig");
    _ = sb.append("!");
    std.debug.print("StringBuilder結果: {s}\n", .{sb.str()});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・self: T  — 値を変更しない（読み取り専用）\n", .{});
    std.debug.print("・self: *T — 値を変更する（状態変更）\n", .{});
    std.debug.print("・@This() — 構造体内で自身の型を取得\n", .{});
    std.debug.print("・selfなし — 静的メソッド（インスタンス不要）\n", .{});
}

// --- テスト ---

test "Point read-only methods" {
    const p1 = Point{ .x = 3.0, .y = 4.0 };
    const p2 = Point{ .x = 0.0, .y = 0.0 };

    try std.testing.expect(@abs(p1.distanceFromOrigin() - 5.0) < 0.001);
    try std.testing.expect(@abs(p1.distanceTo(p2) - 5.0) < 0.001);
}

test "Point mutation methods" {
    var p = Point{ .x = 1.0, .y = 2.0 };

    p.translate(3.0, 4.0);
    try std.testing.expect(@abs(p.x - 4.0) < 0.001);
    try std.testing.expect(@abs(p.y - 6.0) < 0.001);

    p.scale(2.0);
    try std.testing.expect(@abs(p.x - 8.0) < 0.001);
    try std.testing.expect(@abs(p.y - 12.0) < 0.001);

    p.reset();
    try std.testing.expect(@abs(p.x) < 0.001);
    try std.testing.expect(@abs(p.y) < 0.001);
}

test "Vec3 operations" {
    const v1 = Vec3.init(1.0, 2.0, 3.0);
    const v2 = Vec3.init(4.0, 5.0, 6.0);

    const sum = v1.add(v2);
    try std.testing.expect(@abs(sum.x - 5.0) < 0.001);
    try std.testing.expect(@abs(sum.y - 7.0) < 0.001);
    try std.testing.expect(@abs(sum.z - 9.0) < 0.001);

    try std.testing.expect(@abs(v1.dot(v2) - 32.0) < 0.001);
}

test "Vec3 cross product" {
    const i = Vec3.init(1.0, 0.0, 0.0);
    const j = Vec3.init(0.0, 1.0, 0.0);

    const k = i.cross(j); // i × j = k
    try std.testing.expect(@abs(k.x) < 0.001);
    try std.testing.expect(@abs(k.y) < 0.001);
    try std.testing.expect(@abs(k.z - 1.0) < 0.001);
}

test "Vec3 normalize" {
    var v = Vec3.init(3.0, 0.0, 0.0);
    v.normalize();

    try std.testing.expect(@abs(v.x - 1.0) < 0.001);
    try std.testing.expect(@abs(v.length() - 1.0) < 0.001);
}

test "MathUtils static methods" {
    try std.testing.expectEqual(@as(i32, 10), MathUtils.max(5, 10));
    try std.testing.expectEqual(@as(i32, 5), MathUtils.min(5, 10));
    try std.testing.expectEqual(@as(i32, 5), MathUtils.clamp(5, 0, 10));
    try std.testing.expectEqual(@as(i32, 0), MathUtils.clamp(-5, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), MathUtils.clamp(15, 0, 10));
    try std.testing.expectEqual(@as(i32, 42), MathUtils.abs(-42));
}

test "StringBuilder" {
    var sb = StringBuilder.init();

    _ = sb.append("Hello");
    try std.testing.expect(std.mem.eql(u8, sb.str(), "Hello"));

    _ = sb.append(" World");
    try std.testing.expect(std.mem.eql(u8, sb.str(), "Hello World"));

    _ = sb.clear();
    try std.testing.expectEqual(@as(usize, 0), sb.len);
}

test "BankAccount" {
    var account = BankAccount.init(1000);
    try std.testing.expectEqual(@as(i64, 1000), account.getBalance());
    try std.testing.expectEqual(@as(u32, 0), account.getTransactionCount());

    try account.deposit(500);
    try std.testing.expectEqual(@as(i64, 1500), account.getBalance());
    try std.testing.expectEqual(@as(u32, 1), account.getTransactionCount());

    try account.withdraw(200);
    try std.testing.expectEqual(@as(i64, 1300), account.getBalance());
    try std.testing.expectEqual(@as(u32, 2), account.getTransactionCount());

    // エラーケース
    try std.testing.expectError(error.InsufficientFunds, account.withdraw(10000));
    try std.testing.expectError(error.InvalidAmount, account.deposit(-100));
}
