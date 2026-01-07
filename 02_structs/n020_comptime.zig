//! # コンパイル時計算（comptime）
//!
//! Zigのcomptimeはコンパイル時に値を計算する機能。
//! ジェネリクス、定数畳み込み、メタプログラミングの基盤。
//!
//! ## 用途
//! - コンパイル時定数の計算
//! - ジェネリック型・関数の生成
//! - 静的なコード生成
//! - 型情報の取得

const std = @import("std");

// ====================
// comptime変数
// ====================

/// コンパイル時に計算される定数
const comptime_result = blk: {
    var sum: u32 = 0;
    for (0..10) |i| {
        sum += @as(u32, @intCast(i));
    }
    break :blk sum; // 45
};

/// コンパイル時のフィボナッチ
fn comptimeFibonacci(n: u32) u32 {
    if (n <= 1) return n;
    return comptimeFibonacci(n - 1) + comptimeFibonacci(n - 2);
}

// コンパイル時に計算
const fib_10 = comptimeFibonacci(10); // 55

// ====================
// comptime引数（ジェネリクス）
// ====================

/// 任意の型のペアを作る
fn Pair(comptime T: type) type {
    return struct {
        first: T,
        second: T,

        const Self = @This();

        pub fn init(first: T, second: T) Self {
            return Self{ .first = first, .second = second };
        }

        pub fn swap(self: *Self) void {
            const tmp = self.first;
            self.first = self.second;
            self.second = tmp;
        }
    };
}

/// 固定サイズの配列を返す型
fn FixedArray(comptime T: type, comptime size: usize) type {
    return struct {
        data: [size]T,
        len: usize,

        const Self = @This();
        const capacity = size;

        pub fn init() Self {
            return Self{
                .data = undefined,
                .len = 0,
            };
        }

        pub fn push(self: *Self, item: T) !void {
            if (self.len >= capacity) return error.ArrayFull;
            self.data[self.len] = item;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.data[self.len];
        }

        pub fn items(self: *const Self) []const T {
            return self.data[0..self.len];
        }
    };
}

// ====================
// @typeInfo による型情報取得
// ====================

fn showTypeInfo(comptime T: type) void {
    const info = @typeInfo(T);
    switch (info) {
        .int => |int_info| {
            std.debug.print("Int: {s}{d}ビット\n", .{
                if (int_info.signedness == .signed) @as([]const u8, "符号付き") else @as([]const u8, "符号なし"),
                int_info.bits,
            });
        },
        .float => |float_info| {
            std.debug.print("Float: {d}ビット\n", .{float_info.bits});
        },
        .bool => {
            std.debug.print("Bool\n", .{});
        },
        .pointer => |ptr_info| {
            std.debug.print("Pointer: {s}\n", .{@tagName(ptr_info.size)});
        },
        .array => |arr_info| {
            std.debug.print("Array: [{d}]{s}\n", .{ arr_info.len, @typeName(arr_info.child) });
        },
        .@"struct" => {
            std.debug.print("Struct: {s}\n", .{@typeName(T)});
        },
        else => {
            std.debug.print("Other: {s}\n", .{@tagName(info)});
        },
    }
}

// ====================
// コンパイル時文字列操作
// ====================

fn comptimeConcat(comptime a: []const u8, comptime b: []const u8) []const u8 {
    return a ++ b;
}

fn comptimeRepeat(comptime s: []const u8, comptime n: usize) *const [n * s.len]u8 {
    return comptime blk: {
        var result: [n * s.len]u8 = undefined;
        for (0..n) |i| {
            for (s, 0..) |c, j| {
                result[i * s.len + j] = c;
            }
        }
        const final = result;
        break :blk &final;
    };
}

// ====================
// inline for（ループ展開）
// ====================

fn sumArray(comptime T: type, arr: []const T) T {
    var sum: T = 0;
    for (arr) |item| {
        sum += item;
    }
    return sum;
}

// ====================
// @field でフィールドアクセス
// ====================

const MyStruct = struct {
    x: i32,
    y: i32,
    z: i32,
};

fn getFieldByName(s: MyStruct, comptime field_name: []const u8) i32 {
    return @field(s, field_name);
}

fn setFieldByName(s: *MyStruct, comptime field_name: []const u8, value: i32) void {
    @field(s, field_name) = value;
}

// ====================
// コンパイル時配列生成
// ====================

fn generateSquares(comptime len: usize) [len]u32 {
    var arr: [len]u32 = undefined;
    for (0..len) |i| {
        arr[i] = @as(u32, @intCast(i * i));
    }
    return arr;
}

const squares = generateSquares(10);

// ====================
// コンパイル時型チェック
// ====================

fn isInteger(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .int, .comptime_int => true,
        else => false,
    };
}

fn isFloat(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .float, .comptime_float => true,
        else => false,
    };
}

fn isNumeric(comptime T: type) bool {
    return isInteger(T) or isFloat(T);
}

// 数値型のみ受け付ける関数
fn double(comptime T: type, value: T) T {
    comptime {
        if (!isNumeric(T)) {
            @compileError("double() requires a numeric type");
        }
    }
    return value * 2;
}

pub fn main() void {
    std.debug.print("=== コンパイル時計算（comptime） ===\n\n", .{});

    // ====================
    // コンパイル時定数
    // ====================

    std.debug.print("--- コンパイル時定数 ---\n", .{});
    std.debug.print("0から9の合計: {d}\n", .{comptime_result});
    std.debug.print("フィボナッチ(10): {d}\n", .{fib_10});

    std.debug.print("\n", .{});

    // ====================
    // ジェネリック型
    // ====================

    std.debug.print("--- ジェネリック型 ---\n", .{});

    const IntPair = Pair(i32);
    var pair = IntPair.init(10, 20);
    std.debug.print("Pair: ({d}, {d})\n", .{ pair.first, pair.second });
    pair.swap();
    std.debug.print("swap後: ({d}, {d})\n", .{ pair.first, pair.second });

    const StringPair = Pair([]const u8);
    const sp = StringPair.init("hello", "world");
    std.debug.print("StringPair: ({s}, {s})\n", .{ sp.first, sp.second });

    std.debug.print("\n", .{});

    // ====================
    // FixedArray
    // ====================

    std.debug.print("--- FixedArray ---\n", .{});

    const IntArray5 = FixedArray(i32, 5);
    var arr = IntArray5.init();
    arr.push(1) catch {};
    arr.push(2) catch {};
    arr.push(3) catch {};

    std.debug.print("FixedArray容量: {d}\n", .{IntArray5.capacity});
    std.debug.print("要素: ", .{});
    for (arr.items()) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});

    // ====================
    // 型情報
    // ====================

    std.debug.print("--- 型情報 ---\n", .{});
    std.debug.print("i32: ", .{});
    showTypeInfo(i32);
    std.debug.print("f64: ", .{});
    showTypeInfo(f64);
    std.debug.print("bool: ", .{});
    showTypeInfo(bool);
    std.debug.print("[5]u8: ", .{});
    showTypeInfo([5]u8);

    std.debug.print("\n", .{});

    // ====================
    // コンパイル時文字列
    // ====================

    std.debug.print("--- コンパイル時文字列 ---\n", .{});

    const greeting = comptimeConcat("Hello, ", "Zig!");
    std.debug.print("結合: {s}\n", .{greeting});

    const repeated = comptimeRepeat("ab", 3);
    std.debug.print("繰り返し: {s}\n", .{repeated});

    std.debug.print("\n", .{});

    // ====================
    // コンパイル時配列
    // ====================

    std.debug.print("--- コンパイル時配列 ---\n", .{});
    std.debug.print("squares: ", .{});
    for (squares) |sq| {
        std.debug.print("{d} ", .{sq});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});

    // ====================
    // @field
    // ====================

    std.debug.print("--- @field ---\n", .{});
    var ms = MyStruct{ .x = 1, .y = 2, .z = 3 };
    std.debug.print("x = {d}\n", .{getFieldByName(ms, "x")});
    std.debug.print("y = {d}\n", .{getFieldByName(ms, "y")});

    setFieldByName(&ms, "z", 100);
    std.debug.print("z = {d} (変更後)\n", .{ms.z});

    std.debug.print("\n", .{});

    // ====================
    // 型チェック
    // ====================

    std.debug.print("--- 型チェック ---\n", .{});
    std.debug.print("isInteger(i32): {}\n", .{isInteger(i32)});
    std.debug.print("isInteger(f64): {}\n", .{isInteger(f64)});
    std.debug.print("isFloat(f64): {}\n", .{isFloat(f64)});
    std.debug.print("isNumeric(i32): {}\n", .{isNumeric(i32)});
    std.debug.print("isNumeric(bool): {}\n", .{isNumeric(bool)});

    std.debug.print("\n", .{});

    // ====================
    // double関数
    // ====================

    std.debug.print("--- double関数（型制約付き） ---\n", .{});
    std.debug.print("double(i32, 21) = {d}\n", .{double(i32, 21)});
    std.debug.print("double(f64, 3.14) = {d:.2}\n", .{double(f64, 3.14)});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・comptime: コンパイル時に評価\n", .{});
    std.debug.print("・ジェネリクスはcomptime type引数で実現\n", .{});
    std.debug.print("・@typeInfo: 型の詳細情報を取得\n", .{});
    std.debug.print("・@field: 文字列からフィールドアクセス\n", .{});
}

// --- テスト ---

test "comptime constants" {
    try std.testing.expectEqual(@as(u32, 45), comptime_result);
    try std.testing.expectEqual(@as(u32, 55), fib_10);
}

test "generic Pair" {
    const IntPair = Pair(i32);
    var pair = IntPair.init(1, 2);

    try std.testing.expectEqual(@as(i32, 1), pair.first);
    try std.testing.expectEqual(@as(i32, 2), pair.second);

    pair.swap();
    try std.testing.expectEqual(@as(i32, 2), pair.first);
    try std.testing.expectEqual(@as(i32, 1), pair.second);
}

test "FixedArray" {
    const IntArray = FixedArray(i32, 3);
    var arr = IntArray.init();

    try arr.push(10);
    try arr.push(20);
    try arr.push(30);

    // 容量超過
    try std.testing.expectError(error.ArrayFull, arr.push(40));

    try std.testing.expectEqual(@as(usize, 3), arr.len);
    try std.testing.expectEqual(@as(?i32, 30), arr.pop());
    try std.testing.expectEqual(@as(?i32, 20), arr.pop());
    try std.testing.expectEqual(@as(?i32, 10), arr.pop());
    try std.testing.expect(arr.pop() == null);
}

test "comptime string" {
    const result = comptimeConcat("foo", "bar");
    try std.testing.expect(std.mem.eql(u8, result, "foobar"));

    const repeated = comptimeRepeat("x", 4);
    try std.testing.expect(std.mem.eql(u8, repeated, "xxxx"));
}

test "comptime array generation" {
    try std.testing.expectEqual(@as(u32, 0), squares[0]);
    try std.testing.expectEqual(@as(u32, 1), squares[1]);
    try std.testing.expectEqual(@as(u32, 4), squares[2]);
    try std.testing.expectEqual(@as(u32, 9), squares[3]);
    try std.testing.expectEqual(@as(u32, 81), squares[9]);
}

test "@field access" {
    var s = MyStruct{ .x = 1, .y = 2, .z = 3 };

    try std.testing.expectEqual(@as(i32, 1), getFieldByName(s, "x"));
    try std.testing.expectEqual(@as(i32, 2), getFieldByName(s, "y"));
    try std.testing.expectEqual(@as(i32, 3), getFieldByName(s, "z"));

    setFieldByName(&s, "x", 100);
    try std.testing.expectEqual(@as(i32, 100), s.x);
}

test "type checks" {
    try std.testing.expect(isInteger(i32));
    try std.testing.expect(isInteger(u64));
    try std.testing.expect(!isInteger(f32));
    try std.testing.expect(!isInteger(bool));

    try std.testing.expect(isFloat(f32));
    try std.testing.expect(isFloat(f64));
    try std.testing.expect(!isFloat(i32));

    try std.testing.expect(isNumeric(i32));
    try std.testing.expect(isNumeric(f64));
    try std.testing.expect(!isNumeric(bool));
    try std.testing.expect(!isNumeric([]const u8));
}

test "double function" {
    try std.testing.expectEqual(@as(i32, 84), double(i32, 42));
    try std.testing.expect(@abs(double(f64, 3.14) - 6.28) < 0.001);
}

test "sumArray" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), sumArray(i32, &arr));

    const floats = [_]f64{ 1.5, 2.5, 3.0 };
    try std.testing.expect(@abs(sumArray(f64, &floats) - 7.0) < 0.001);
}
