//! # 共用体（union）
//!
//! unionは複数の型のうち1つだけを保持できる型。
//! tagged unionを使うとswitch文で安全に分岐できる。
//!
//! ## 種類
//! - bare union: タグなし（安全でない）
//! - tagged union: enumタグ付き（推奨）
//!
//! ## 特徴
//! - 同時に1つのフィールドのみがアクティブ
//! - tagged unionはswitchで網羅性チェック
//! - メモリ効率が良い（最大のフィールドサイズ）

const std = @import("std");

// ====================
// tagged union（推奨）
// ====================

/// JSONの値を表す型
const JsonValue = union(enum) {
    null_value,
    boolean: bool,
    integer: i64,
    float: f64,
    string: []const u8,

    const Self = @This();

    pub fn format(self: Self) []const u8 {
        return switch (self) {
            .null_value => "null",
            .boolean => "boolean",
            .integer => "integer",
            .float => "float",
            .string => "string",
        };
    }
};

// ====================
// 明示的なenumタグ
// ====================

const NumberTag = enum {
    int,
    float,
};

const Number = union(NumberTag) {
    int: i32,
    float: f32,

    pub fn add(self: Number, other: Number) Number {
        return switch (self) {
            .int => |i| switch (other) {
                .int => |j| Number{ .int = i + j },
                .float => |f| Number{ .float = @as(f32, @floatFromInt(i)) + f },
            },
            .float => |f| switch (other) {
                .int => |i| Number{ .float = f + @as(f32, @floatFromInt(i)) },
                .float => |g| Number{ .float = f + g },
            },
        };
    }
};

// ====================
// 実用例: 計算式の抽象構文木
// ====================

const Expr = union(enum) {
    literal: i32,
    add: *const [2]Expr,
    mul: *const [2]Expr,
    neg: *const Expr,

    const Self = @This();

    /// 式を評価
    pub fn eval(self: Self) i32 {
        return switch (self) {
            .literal => |n| n,
            .add => |pair| pair[0].eval() + pair[1].eval(),
            .mul => |pair| pair[0].eval() * pair[1].eval(),
            .neg => |e| -e.eval(),
        };
    }
};

// ====================
// 実用例: Result型（エラーまたは値）
// ====================

fn Result(comptime T: type, comptime E: type) type {
    return union(enum) {
        ok: T,
        err: E,

        const Self = @This();

        pub fn isOk(self: Self) bool {
            return self == .ok;
        }

        pub fn isErr(self: Self) bool {
            return self == .err;
        }

        pub fn unwrap(self: Self) T {
            return switch (self) {
                .ok => |value| value,
                .err => unreachable,
            };
        }

        pub fn unwrapOr(self: Self, default: T) T {
            return switch (self) {
                .ok => |value| value,
                .err => default,
            };
        }
    };
}

// ====================
// 実用例: Option型
// ====================

fn Option(comptime T: type) type {
    return union(enum) {
        some: T,
        none,

        const Self = @This();

        pub fn isSome(self: Self) bool {
            return self == .some;
        }

        pub fn isNone(self: Self) bool {
            return self == .none;
        }

        pub fn unwrap(self: Self) T {
            return switch (self) {
                .some => |value| value,
                .none => unreachable,
            };
        }

        pub fn unwrapOr(self: Self, default: T) T {
            return switch (self) {
                .some => |value| value,
                .none => default,
            };
        }

        pub fn map(self: Self, f: fn (T) T) Self {
            return switch (self) {
                .some => |value| Self{ .some = f(value) },
                .none => .none,
            };
        }
    };
}

// ====================
// 実用例: イベントシステム
// ====================

const Event = union(enum) {
    key_press: struct {
        key: u8,
        modifiers: u8,
    },
    mouse_move: struct {
        x: i32,
        y: i32,
    },
    mouse_click: struct {
        button: enum { left, middle, right },
        x: i32,
        y: i32,
    },
    window_resize: struct {
        width: u32,
        height: u32,
    },
    quit,
};

fn handleEvent(event: Event) void {
    switch (event) {
        .key_press => |kp| {
            std.debug.print("Key pressed: {d}\n", .{kp.key});
        },
        .mouse_move => |mm| {
            std.debug.print("Mouse moved to: ({d}, {d})\n", .{ mm.x, mm.y });
        },
        .mouse_click => |mc| {
            std.debug.print("Mouse clicked: {} at ({d}, {d})\n", .{ mc.button, mc.x, mc.y });
        },
        .window_resize => |wr| {
            std.debug.print("Window resized: {d}x{d}\n", .{ wr.width, wr.height });
        },
        .quit => {
            std.debug.print("Quit event\n", .{});
        },
    }
}

pub fn main() void {
    std.debug.print("=== 共用体（union） ===\n\n", .{});

    // ====================
    // tagged union の基本
    // ====================

    std.debug.print("--- tagged union の基本 ---\n", .{});

    const json_int = JsonValue{ .integer = 42 };
    const json_str = JsonValue{ .string = "hello" };
    const json_bool = JsonValue{ .boolean = true };

    std.debug.print("json_int の型: {s}\n", .{json_int.format()});
    std.debug.print("json_str の型: {s}\n", .{json_str.format()});
    std.debug.print("json_bool の型: {s}\n", .{json_bool.format()});

    std.debug.print("\n", .{});

    // ====================
    // switchでの分岐
    // ====================

    std.debug.print("--- switchでの分岐 ---\n", .{});

    switch (json_int) {
        .integer => |n| std.debug.print("整数値: {d}\n", .{n}),
        .string => |s| std.debug.print("文字列: {s}\n", .{s}),
        .boolean => |b| std.debug.print("真偽値: {}\n", .{b}),
        .float => |f| std.debug.print("浮動小数: {d}\n", .{f}),
        .null_value => std.debug.print("null\n", .{}),
    }

    std.debug.print("\n", .{});

    // ====================
    // Number演算
    // ====================

    std.debug.print("--- Number演算 ---\n", .{});

    const a = Number{ .int = 5 };
    const b = Number{ .int = 3 };
    const c = Number{ .float = 2.5 };

    const result1 = a.add(b);
    switch (result1) {
        .int => |n| std.debug.print("5 + 3 = {d} (int)\n", .{n}),
        .float => |f| std.debug.print("5 + 3 = {d} (float)\n", .{f}),
    }

    const result2 = a.add(c);
    switch (result2) {
        .int => |n| std.debug.print("5 + 2.5 = {d} (int)\n", .{n}),
        .float => |f| std.debug.print("5 + 2.5 = {d:.1} (float)\n", .{f}),
    }

    std.debug.print("\n", .{});

    // ====================
    // 式の評価
    // ====================

    std.debug.print("--- 式の評価 ---\n", .{});

    // (3 + 4) * 2 = 14
    const three = Expr{ .literal = 3 };
    const four = Expr{ .literal = 4 };
    const add_pair = [2]Expr{ three, four };
    const sum = Expr{ .add = &add_pair };

    const two = Expr{ .literal = 2 };
    const mul_pair = [2]Expr{ sum, two };
    const expr = Expr{ .mul = &mul_pair };

    std.debug.print("(3 + 4) * 2 = {d}\n", .{expr.eval()});

    std.debug.print("\n", .{});

    // ====================
    // Result型
    // ====================

    std.debug.print("--- Result型 ---\n", .{});

    const IntResult = Result(i32, []const u8);

    const success: IntResult = .{ .ok = 42 };
    const failure: IntResult = .{ .err = "something went wrong" };

    std.debug.print("success.isOk(): {}\n", .{success.isOk()});
    std.debug.print("success.unwrap(): {d}\n", .{success.unwrap()});
    std.debug.print("failure.isErr(): {}\n", .{failure.isErr()});
    std.debug.print("failure.unwrapOr(0): {d}\n", .{failure.unwrapOr(0)});

    std.debug.print("\n", .{});

    // ====================
    // Option型
    // ====================

    std.debug.print("--- Option型 ---\n", .{});

    const IntOption = Option(i32);

    const some_value: IntOption = .{ .some = 100 };
    const no_value: IntOption = .none;

    std.debug.print("some_value.isSome(): {}\n", .{some_value.isSome()});
    std.debug.print("some_value.unwrap(): {d}\n", .{some_value.unwrap()});
    std.debug.print("no_value.isNone(): {}\n", .{no_value.isNone()});
    std.debug.print("no_value.unwrapOr(-1): {d}\n", .{no_value.unwrapOr(-1)});

    std.debug.print("\n", .{});

    // ====================
    // イベントシステム
    // ====================

    std.debug.print("--- イベントシステム ---\n", .{});

    const events = [_]Event{
        .{ .key_press = .{ .key = 65, .modifiers = 0 } },
        .{ .mouse_move = .{ .x = 100, .y = 200 } },
        .{ .mouse_click = .{ .button = .left, .x = 150, .y = 250 } },
        .quit,
    };

    for (events) |event| {
        handleEvent(event);
    }

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・union(enum): tagged union（推奨）\n", .{});
    std.debug.print("・switchで全パターンを網羅\n", .{});
    std.debug.print("・|value| でアクティブな値をキャプチャ\n", .{});
    std.debug.print("・同時に1つのフィールドのみアクティブ\n", .{});
}

// --- テスト ---

test "JsonValue types" {
    const int_val = JsonValue{ .integer = 42 };
    const str_val = JsonValue{ .string = "test" };
    const bool_val = JsonValue{ .boolean = true };
    const null_val = JsonValue{ .null_value = {} };
    const float_val = JsonValue{ .float = 3.14 };

    try std.testing.expect(std.mem.eql(u8, int_val.format(), "integer"));
    try std.testing.expect(std.mem.eql(u8, str_val.format(), "string"));
    try std.testing.expect(std.mem.eql(u8, bool_val.format(), "boolean"));
    try std.testing.expect(std.mem.eql(u8, null_val.format(), "null"));
    try std.testing.expect(std.mem.eql(u8, float_val.format(), "float"));
}

test "Number addition" {
    const a = Number{ .int = 5 };
    const b = Number{ .int = 3 };
    const c = Number{ .float = 2.5 };

    // int + int = int
    const r1 = a.add(b);
    switch (r1) {
        .int => |n| try std.testing.expectEqual(@as(i32, 8), n),
        .float => unreachable,
    }

    // int + float = float
    const r2 = a.add(c);
    switch (r2) {
        .int => unreachable,
        .float => |f| try std.testing.expect(@abs(f - 7.5) < 0.001),
    }
}

test "Expr evaluation" {
    const three = Expr{ .literal = 3 };
    const four = Expr{ .literal = 4 };
    const add_pair = [2]Expr{ three, four };
    const sum = Expr{ .add = &add_pair };

    try std.testing.expectEqual(@as(i32, 7), sum.eval());

    const neg_expr = Expr{ .neg = &three };
    try std.testing.expectEqual(@as(i32, -3), neg_expr.eval());
}

test "Result type" {
    const IntResult = Result(i32, []const u8);

    const success: IntResult = .{ .ok = 42 };
    const failure: IntResult = .{ .err = "error" };

    try std.testing.expect(success.isOk());
    try std.testing.expect(!success.isErr());
    try std.testing.expectEqual(@as(i32, 42), success.unwrap());

    try std.testing.expect(failure.isErr());
    try std.testing.expect(!failure.isOk());
    try std.testing.expectEqual(@as(i32, -1), failure.unwrapOr(-1));
}

test "Option type" {
    const IntOption = Option(i32);

    const some: IntOption = .{ .some = 100 };
    const none: IntOption = .none;

    try std.testing.expect(some.isSome());
    try std.testing.expect(!some.isNone());
    try std.testing.expectEqual(@as(i32, 100), some.unwrap());

    try std.testing.expect(none.isNone());
    try std.testing.expect(!none.isSome());
    try std.testing.expectEqual(@as(i32, 0), none.unwrapOr(0));
}

test "Option map" {
    const IntOption = Option(i32);

    const some: IntOption = .{ .some = 5 };
    const none: IntOption = .none;

    const doubled_some = some.map(struct {
        fn call(x: i32) i32 {
            return x * 2;
        }
    }.call);

    const doubled_none = none.map(struct {
        fn call(x: i32) i32 {
            return x * 2;
        }
    }.call);

    try std.testing.expect(doubled_some.isSome());
    try std.testing.expectEqual(@as(i32, 10), doubled_some.unwrap());
    try std.testing.expect(doubled_none.isNone());
}

test "tagged union comparison" {
    const a = JsonValue{ .integer = 42 };
    const b = JsonValue{ .integer = 42 };
    const c = JsonValue{ .string = "hello" };

    // タグの比較
    try std.testing.expect(a == .integer);
    try std.testing.expect(c == .string);
    try std.testing.expect(a != .string);

    // 異なるタグのunionは比較できない（タグで分岐）
    _ = b;
}

test "Event handling" {
    const event = Event{ .key_press = .{ .key = 65, .modifiers = 0 } };

    switch (event) {
        .key_press => |kp| {
            try std.testing.expectEqual(@as(u8, 65), kp.key);
            try std.testing.expectEqual(@as(u8, 0), kp.modifiers);
        },
        else => unreachable,
    }
}
