//! # 構造体（struct）
//!
//! Zigの構造体は関連するデータをグループ化する。
//! メソッドも定義でき、OOP的な設計が可能。
//!
//! ## 特徴
//! - データメンバー（フィールド）を持つ
//! - メソッド（関連関数）を定義できる
//! - デフォルト値を設定できる
//! - コンパイル時に型情報が完全に既知

const std = @import("std");

// ====================
// 基本的な構造体
// ====================

const Point = struct {
    x: i32,
    y: i32,
};

// ====================
// デフォルト値を持つ構造体
// ====================

const Config = struct {
    width: u32 = 800,
    height: u32 = 600,
    title: []const u8 = "Untitled",
    fullscreen: bool = false,
};

// ====================
// メソッドを持つ構造体
// ====================

const Rectangle = struct {
    width: u32,
    height: u32,

    /// 面積を計算
    fn area(self: Rectangle) u32 {
        return self.width * self.height;
    }

    /// 周囲の長さを計算
    fn perimeter(self: Rectangle) u32 {
        return 2 * (self.width + self.height);
    }

    /// 正方形かどうか
    fn isSquare(self: Rectangle) bool {
        return self.width == self.height;
    }
};

// ====================
// init/deinitパターン
// ====================

const User = struct {
    id: u64,
    name: []const u8,
    email: []const u8,
    active: bool,

    /// コンストラクタ
    pub fn init(id: u64, name: []const u8, email: []const u8) User {
        return User{
            .id = id,
            .name = name,
            .email = email,
            .active = true,
        };
    }

    /// ユーザー情報を表示
    pub fn display(self: User) void {
        std.debug.print("User {{ id: {d}, name: {s}, email: {s} }}\n", .{ self.id, self.name, self.email });
    }

    /// 非アクティブ化
    pub fn deactivate(self: *User) void {
        self.active = false;
    }
};

// ====================
// selfポインタの使用
// ====================

const Counter = struct {
    value: i32,

    pub fn init() Counter {
        return Counter{ .value = 0 };
    }

    /// 値を増加（selfを変更するので *Counter）
    pub fn increment(self: *Counter) void {
        self.value += 1;
    }

    /// 値を減少
    pub fn decrement(self: *Counter) void {
        self.value -= 1;
    }

    /// 現在値を取得（変更しないので Counter）
    pub fn get(self: Counter) i32 {
        return self.value;
    }

    /// リセット
    pub fn reset(self: *Counter) void {
        self.value = 0;
    }
};

pub fn main() void {
    std.debug.print("=== 構造体（struct） ===\n\n", .{});

    // ====================
    // 基本的な使用
    // ====================

    const p1 = Point{ .x = 10, .y = 20 };
    std.debug.print("Point: ({d}, {d})\n", .{ p1.x, p1.y });

    // 一部のフィールドだけ指定（デフォルト値使用）
    const cfg = Config{ .title = "My App" };
    std.debug.print("Config: {d}x{d}, title={s}\n", .{ cfg.width, cfg.height, cfg.title });

    std.debug.print("\n", .{});

    // ====================
    // メソッドの呼び出し
    // ====================

    const rect = Rectangle{ .width = 10, .height = 5 };
    std.debug.print("Rectangle: {d}x{d}\n", .{ rect.width, rect.height });
    std.debug.print("  面積: {d}\n", .{rect.area()});
    std.debug.print("  周囲: {d}\n", .{rect.perimeter()});
    std.debug.print("  正方形: {}\n", .{rect.isSquare()});

    const square = Rectangle{ .width = 7, .height = 7 };
    std.debug.print("Square: 正方形={}\n", .{square.isSquare()});

    std.debug.print("\n", .{});

    // ====================
    // init/deinitパターン
    // ====================

    const user = User.init(1, "Alice", "alice@example.com");
    user.display();

    std.debug.print("\n", .{});

    // ====================
    // 状態を変更するメソッド
    // ====================

    var counter = Counter.init();
    std.debug.print("Counter初期値: {d}\n", .{counter.get()});

    counter.increment();
    counter.increment();
    counter.increment();
    std.debug.print("3回インクリメント後: {d}\n", .{counter.get()});

    counter.decrement();
    std.debug.print("1回デクリメント後: {d}\n", .{counter.get()});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・selfを変更する場合は *Self を使用\n", .{});
    std.debug.print("・init()/deinit() はコンストラクタ/デストラクタ\n", .{});
    std.debug.print("・pubでモジュール外に公開\n", .{});
}

// ====================
// 実用的な構造体例
// ====================

/// 2D座標を表すベクトル
const Vec2 = struct {
    x: f64,
    y: f64,

    pub fn init(x: f64, y: f64) Vec2 {
        return Vec2{ .x = x, .y = y };
    }

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn sub(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn scale(self: Vec2, factor: f64) Vec2 {
        return Vec2{ .x = self.x * factor, .y = self.y * factor };
    }

    pub fn dot(self: Vec2, other: Vec2) f64 {
        return self.x * other.x + self.y * other.y;
    }

    pub fn length(self: Vec2) f64 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn distance(self: Vec2, other: Vec2) f64 {
        return self.sub(other).length();
    }
};

/// スタック（後入れ先出し）
fn Stack(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,

        const Self = @This();

        pub fn push(self: *Self, item: T) !void {
            if (self.len >= capacity) return error.StackOverflow;
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }

        pub fn peek(self: Self) ?T {
            if (self.len == 0) return null;
            return self.items[self.len - 1];
        }

        pub fn isEmpty(self: Self) bool {
            return self.len == 0;
        }
    };
}

// --- テスト ---

test "basic struct" {
    const p = Point{ .x = 3, .y = 4 };
    try std.testing.expectEqual(@as(i32, 3), p.x);
    try std.testing.expectEqual(@as(i32, 4), p.y);
}

test "struct with defaults" {
    const cfg1 = Config{};
    try std.testing.expectEqual(@as(u32, 800), cfg1.width);
    try std.testing.expectEqual(@as(u32, 600), cfg1.height);

    const cfg2 = Config{ .width = 1920, .height = 1080 };
    try std.testing.expectEqual(@as(u32, 1920), cfg2.width);
    try std.testing.expect(std.mem.eql(u8, cfg2.title, "Untitled"));
}

test "struct methods" {
    const rect = Rectangle{ .width = 10, .height = 5 };
    try std.testing.expectEqual(@as(u32, 50), rect.area());
    try std.testing.expectEqual(@as(u32, 30), rect.perimeter());
    try std.testing.expect(!rect.isSquare());

    const square = Rectangle{ .width = 5, .height = 5 };
    try std.testing.expect(square.isSquare());
}

test "User init" {
    const user = User.init(1, "test", "test@example.com");
    try std.testing.expectEqual(@as(u64, 1), user.id);
    try std.testing.expect(std.mem.eql(u8, user.name, "test"));
    try std.testing.expect(user.active);
}

test "User deactivate" {
    var user = User.init(1, "test", "test@example.com");
    try std.testing.expect(user.active);

    user.deactivate();
    try std.testing.expect(!user.active);
}

test "Counter" {
    var counter = Counter.init();
    try std.testing.expectEqual(@as(i32, 0), counter.get());

    counter.increment();
    counter.increment();
    try std.testing.expectEqual(@as(i32, 2), counter.get());

    counter.decrement();
    try std.testing.expectEqual(@as(i32, 1), counter.get());

    counter.reset();
    try std.testing.expectEqual(@as(i32, 0), counter.get());
}

test "Vec2 operations" {
    const v1 = Vec2.init(3.0, 4.0);
    const v2 = Vec2.init(1.0, 2.0);

    const sum = v1.add(v2);
    try std.testing.expect(@abs(sum.x - 4.0) < 0.001);
    try std.testing.expect(@abs(sum.y - 6.0) < 0.001);

    const diff = v1.sub(v2);
    try std.testing.expect(@abs(diff.x - 2.0) < 0.001);
    try std.testing.expect(@abs(diff.y - 2.0) < 0.001);

    const scaled = v1.scale(2.0);
    try std.testing.expect(@abs(scaled.x - 6.0) < 0.001);
    try std.testing.expect(@abs(scaled.y - 8.0) < 0.001);

    try std.testing.expect(@abs(v1.length() - 5.0) < 0.001);
}

test "Vec2 dot product" {
    const v1 = Vec2.init(1.0, 0.0);
    const v2 = Vec2.init(0.0, 1.0);
    try std.testing.expect(@abs(v1.dot(v2)) < 0.001); // 直交

    const v3 = Vec2.init(2.0, 3.0);
    const v4 = Vec2.init(4.0, 5.0);
    try std.testing.expect(@abs(v3.dot(v4) - 23.0) < 0.001);
}

test "Stack generic" {
    const IntStack = Stack(i32, 10);
    var stack = IntStack{};

    try std.testing.expect(stack.isEmpty());

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try std.testing.expect(!stack.isEmpty());
    try std.testing.expectEqual(@as(?i32, 3), stack.peek());

    try std.testing.expectEqual(@as(?i32, 3), stack.pop());
    try std.testing.expectEqual(@as(?i32, 2), stack.pop());
    try std.testing.expectEqual(@as(?i32, 1), stack.pop());
    try std.testing.expect(stack.isEmpty());
    try std.testing.expect(stack.pop() == null);
}

test "anonymous struct literal" {
    const p = Point{ .x = 5, .y = 10 };

    // 匿名構造体
    const anon = .{ .x = 5, .y = 10 };
    try std.testing.expectEqual(p.x, anon.x);
    try std.testing.expectEqual(p.y, anon.y);
}

test "struct update syntax" {
    const p1 = Point{ .x = 1, .y = 2 };

    // 一部のフィールドだけ変更した新しい構造体を作成
    var p2 = p1;
    p2.x = 100;

    try std.testing.expectEqual(@as(i32, 1), p1.x);
    try std.testing.expectEqual(@as(i32, 100), p2.x);
    try std.testing.expectEqual(@as(i32, 2), p2.y);
}
