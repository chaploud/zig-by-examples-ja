//! # 関数
//!
//! Zigの関数は、値を受け取り処理を行い値を返す。
//! anytype、comptime引数、エラー戻り値など多彩な機能がある。
//!
//! ## 特徴
//! - 引数はイミュータブル
//! - anytypeでダックタイピング
//! - comptimeで型引数
//! - エラー戻り値（!）

const std = @import("std");

// ====================
// 基本的な関数
// ====================

/// 二つの数を加算
fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// 引数なし、戻り値なし
fn sayHello() void {
    std.debug.print("Hello!\n", .{});
}

/// 複数の戻り値（タプル風）
fn divmod(a: i32, b: i32) struct { quotient: i32, remainder: i32 } {
    return .{
        .quotient = @divTrunc(a, b),
        .remainder = @mod(a, b),
    };
}

// ====================
// エラーを返す関数
// ====================

const MathError = error{
    DivisionByZero,
    Overflow,
    InvalidInput,
};

/// エラーを返す可能性のある除算
fn safeDivide(a: i32, b: i32) MathError!i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

/// anyerror（任意のエラー型）
fn parseNumber(s: []const u8) anyerror!i32 {
    return std.fmt.parseInt(i32, s, 10);
}

// ====================
// anytype（ダックタイピング）
// ====================

/// 任意の型に対して動作
fn printValue(value: anytype) void {
    const T = @TypeOf(value);
    const info = @typeInfo(T);
    switch (info) {
        .int, .comptime_int => std.debug.print("整数: {d}\n", .{value}),
        .float, .comptime_float => std.debug.print("浮動小数: {d:.2}\n", .{value}),
        .bool => std.debug.print("真偽値: {}\n", .{value}),
        .pointer => |ptr| {
            if (ptr.size == .slice and ptr.child == u8) {
                std.debug.print("文字列: {s}\n", .{value});
            } else if (ptr.size == .one) {
                // 単一ポインタ（配列へのポインタ等）
                const child_info = @typeInfo(ptr.child);
                if (child_info == .array and child_info.array.child == u8) {
                    std.debug.print("文字列: {s}\n", .{value});
                } else {
                    std.debug.print("ポインタ\n", .{});
                }
            } else {
                std.debug.print("ポインタ\n", .{});
            }
        },
        else => std.debug.print("その他の型: {any}\n", .{value}),
    }
}

/// anytypeでの比較関数
fn maximum(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return if (a > b) a else b;
}

/// anytypeでのスワップ
fn swap(a: anytype, b: *@TypeOf(a.*)) void {
    const tmp = a.*;
    a.* = b.*;
    b.* = tmp;
}

// ====================
// 関数ポインタ
// ====================

const BinaryOp = *const fn (i32, i32) i32;

fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

fn subtract(a: i32, b: i32) i32 {
    return a - b;
}

fn applyOperation(op: BinaryOp, x: i32, y: i32) i32 {
    return op(x, y);
}

// ====================
// インライン関数
// ====================

/// 常にインライン化される
inline fn square(x: i32) i32 {
    return x * x;
}

// ====================
// 再帰関数
// ====================

fn factorial(n: u64) u64 {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

fn gcd(a: u64, b: u64) u64 {
    if (b == 0) return a;
    return gcd(b, a % b);
}

// ====================
// クロージャ風（構造体を使用）
// ====================

fn createCounter(start: i32) struct {
    value: i32,

    const Self = @This();

    pub fn increment(self: *Self) i32 {
        const old = self.value;
        self.value += 1;
        return old;
    }

    pub fn decrement(self: *Self) i32 {
        const old = self.value;
        self.value -= 1;
        return old;
    }

    pub fn get(self: Self) i32 {
        return self.value;
    }
} {
    return .{ .value = start };
}

// ====================
// オプション引数（デフォルト値風）
// ====================

const PrintOptions = struct {
    prefix: []const u8 = "",
    suffix: []const u8 = "",
    uppercase: bool = false,
};

fn printWithOptions(text: []const u8, options: PrintOptions) void {
    std.debug.print("{s}", .{options.prefix});
    if (options.uppercase) {
        for (text) |c| {
            const upper = if (c >= 'a' and c <= 'z') c - 32 else c;
            std.debug.print("{c}", .{upper});
        }
    } else {
        std.debug.print("{s}", .{text});
    }
    std.debug.print("{s}\n", .{options.suffix});
}

// ====================
// 高階関数風
// ====================

fn mapArray(comptime T: type, arr: []const T, f: *const fn (T) T) []T {
    var result: [100]T = undefined; // 固定サイズバッファ
    const len = @min(arr.len, 100);
    for (arr[0..len], 0..) |item, i| {
        result[i] = f(item);
    }
    // 注意: 実際のコードではアロケータを使用すべき
    return result[0..len];
}

fn doubleInt(x: i32) i32 {
    return x * 2;
}

pub fn main() void {
    std.debug.print("=== 関数 ===\n\n", .{});

    // ====================
    // 基本的な関数
    // ====================

    std.debug.print("--- 基本的な関数 ---\n", .{});
    std.debug.print("add(3, 4) = {d}\n", .{add(3, 4)});
    sayHello();

    const result = divmod(17, 5);
    std.debug.print("17 / 5 = {d} 余り {d}\n", .{ result.quotient, result.remainder });

    std.debug.print("\n", .{});

    // ====================
    // エラーを返す関数
    // ====================

    std.debug.print("--- エラーを返す関数 ---\n", .{});

    if (safeDivide(10, 3)) |value| {
        std.debug.print("10 / 3 = {d}\n", .{value});
    } else |err| {
        std.debug.print("Error: {}\n", .{err});
    }

    if (safeDivide(10, 0)) |value| {
        std.debug.print("10 / 0 = {d}\n", .{value});
    } else |err| {
        std.debug.print("10 / 0 = Error: {}\n", .{err});
    }

    // catchでデフォルト値
    const safe_result = safeDivide(10, 0) catch 0;
    std.debug.print("10 / 0 (catch 0) = {d}\n", .{safe_result});

    std.debug.print("\n", .{});

    // ====================
    // anytype
    // ====================

    std.debug.print("--- anytype ---\n", .{});
    printValue(@as(i32, 42));
    printValue(@as(f64, 3.14));
    printValue(true);
    printValue("hello");

    std.debug.print("max(3, 7) = {d}\n", .{maximum(@as(i32, 3), @as(i32, 7))});
    std.debug.print("max(3.14, 2.71) = {d:.2}\n", .{maximum(@as(f64, 3.14), @as(f64, 2.71))});

    std.debug.print("\n", .{});

    // ====================
    // 関数ポインタ
    // ====================

    std.debug.print("--- 関数ポインタ ---\n", .{});

    const ops: [3]struct { name: []const u8, op: BinaryOp } = .{
        .{ .name = "add", .op = add },
        .{ .name = "multiply", .op = multiply },
        .{ .name = "subtract", .op = subtract },
    };

    for (ops) |item| {
        std.debug.print("{s}(5, 3) = {d}\n", .{ item.name, applyOperation(item.op, 5, 3) });
    }

    std.debug.print("\n", .{});

    // ====================
    // 再帰
    // ====================

    std.debug.print("--- 再帰関数 ---\n", .{});
    std.debug.print("factorial(5) = {d}\n", .{factorial(5)});
    std.debug.print("factorial(10) = {d}\n", .{factorial(10)});
    std.debug.print("gcd(48, 18) = {d}\n", .{gcd(48, 18)});

    std.debug.print("\n", .{});

    // ====================
    // カウンター
    // ====================

    std.debug.print("--- クロージャ風 ---\n", .{});

    var counter = createCounter(10);
    std.debug.print("初期値: {d}\n", .{counter.get()});
    _ = counter.increment();
    _ = counter.increment();
    std.debug.print("2回インクリメント後: {d}\n", .{counter.get()});
    _ = counter.decrement();
    std.debug.print("1回デクリメント後: {d}\n", .{counter.get()});

    std.debug.print("\n", .{});

    // ====================
    // オプション引数
    // ====================

    std.debug.print("--- オプション引数（構造体） ---\n", .{});

    printWithOptions("hello", .{});
    printWithOptions("hello", .{ .prefix = ">>> " });
    printWithOptions("hello", .{ .uppercase = true });
    printWithOptions("hello", .{ .prefix = "[", .suffix = "]", .uppercase = true });

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・引数はイミュータブル\n", .{});
    std.debug.print("・anytypeでジェネリック関数\n", .{});
    std.debug.print("・!でエラー戻り値を示す\n", .{});
    std.debug.print("・関数ポインタで動的ディスパッチ\n", .{});
}

// --- テスト ---

test "basic functions" {
    try std.testing.expectEqual(@as(i32, 7), add(3, 4));
    try std.testing.expectEqual(@as(i32, -1), add(2, -3));
}

test "divmod" {
    const result = divmod(17, 5);
    try std.testing.expectEqual(@as(i32, 3), result.quotient);
    try std.testing.expectEqual(@as(i32, 2), result.remainder);
}

test "safeDivide success" {
    const result = try safeDivide(10, 3);
    try std.testing.expectEqual(@as(i32, 3), result);
}

test "safeDivide error" {
    try std.testing.expectError(error.DivisionByZero, safeDivide(10, 0));
}

test "maximum" {
    try std.testing.expectEqual(@as(i32, 7), maximum(@as(i32, 3), @as(i32, 7)));
    try std.testing.expectEqual(@as(i32, 7), maximum(@as(i32, 7), @as(i32, 3)));
    try std.testing.expect(@abs(maximum(@as(f64, 3.14), @as(f64, 2.71)) - 3.14) < 0.001);
}

test "swap" {
    var a: i32 = 1;
    var b: i32 = 2;
    swap(&a, &b);
    try std.testing.expectEqual(@as(i32, 2), a);
    try std.testing.expectEqual(@as(i32, 1), b);
}

test "function pointer" {
    try std.testing.expectEqual(@as(i32, 8), applyOperation(add, 3, 5));
    try std.testing.expectEqual(@as(i32, 15), applyOperation(multiply, 3, 5));
    try std.testing.expectEqual(@as(i32, -2), applyOperation(subtract, 3, 5));
}

test "inline square" {
    try std.testing.expectEqual(@as(i32, 25), square(5));
    try std.testing.expectEqual(@as(i32, 0), square(0));
    try std.testing.expectEqual(@as(i32, 1), square(-1));
}

test "factorial" {
    try std.testing.expectEqual(@as(u64, 1), factorial(0));
    try std.testing.expectEqual(@as(u64, 1), factorial(1));
    try std.testing.expectEqual(@as(u64, 120), factorial(5));
    try std.testing.expectEqual(@as(u64, 3628800), factorial(10));
}

test "gcd" {
    try std.testing.expectEqual(@as(u64, 6), gcd(48, 18));
    try std.testing.expectEqual(@as(u64, 1), gcd(17, 13));
    try std.testing.expectEqual(@as(u64, 5), gcd(15, 25));
}

test "counter" {
    var counter = createCounter(0);
    try std.testing.expectEqual(@as(i32, 0), counter.get());

    _ = counter.increment();
    _ = counter.increment();
    try std.testing.expectEqual(@as(i32, 2), counter.get());

    _ = counter.decrement();
    try std.testing.expectEqual(@as(i32, 1), counter.get());
}

test "parseNumber" {
    const result = parseNumber("42") catch unreachable;
    try std.testing.expectEqual(@as(i32, 42), result);

    const negative = parseNumber("-123") catch unreachable;
    try std.testing.expectEqual(@as(i32, -123), negative);

    // 無効な入力
    const invalid = parseNumber("abc");
    try std.testing.expectError(error.InvalidCharacter, invalid);
}
