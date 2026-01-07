//! # 関数ポインタ
//!
//! 関数ポインタは関数への参照を保持し、動的に呼び出せる。
//! コールバック、イベントハンドラ、プラグインシステムで使用。
//!
//! ## 構文
//! - *const fn(args) ret: 関数ポインタ型
//! - fn(args) ret: 関数型（ポインタなし）
//!
//! ## 用途
//! - コールバック関数
//! - 関数テーブル
//! - 戦略パターン

const std = @import("std");

// ====================
// 基本的な関数ポインタ
// ====================

fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn subtract(a: i32, b: i32) i32 {
    return a - b;
}

fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

fn demoBasicFunctionPointer() void {
    std.debug.print("--- 基本的な関数ポインタ ---\n", .{});

    // 関数ポインタ型
    const FnPtr = *const fn (i32, i32) i32;

    // 関数のアドレスを取得
    const add_ptr: FnPtr = &add;
    const sub_ptr: FnPtr = &subtract;

    // 関数ポインタ経由で呼び出し
    const sum = add_ptr(10, 5);
    const diff = sub_ptr(10, 5);

    std.debug.print("  add_ptr(10, 5) = {d}\n", .{sum});
    std.debug.print("  sub_ptr(10, 5) = {d}\n", .{diff});

    std.debug.print("\n", .{});
}

// ====================
// 関数ポインタの変数
// ====================

fn demoFunctionPointerVariable() void {
    std.debug.print("--- 関数ポインタの変数 ---\n", .{});

    const FnPtr = *const fn (i32, i32) i32;

    // 変数に格納して切り替え
    var operation: FnPtr = &add;

    std.debug.print("  operation = add: {d}\n", .{operation(10, 3)});

    operation = &multiply;
    std.debug.print("  operation = multiply: {d}\n", .{operation(10, 3)});

    operation = &subtract;
    std.debug.print("  operation = subtract: {d}\n", .{operation(10, 3)});

    std.debug.print("\n", .{});
}

// ====================
// コールバックパターン
// ====================

fn processArray(arr: []const i32, callback: *const fn (i32) void) void {
    for (arr) |item| {
        callback(item);
    }
}

fn printItem(x: i32) void {
    std.debug.print("  item: {d}\n", .{x});
}

fn demoCallback() void {
    std.debug.print("--- コールバックパターン ---\n", .{});

    const data = [_]i32{ 1, 2, 3, 4, 5 };
    processArray(&data, &printItem);

    std.debug.print("\n", .{});
}

// ====================
// 関数テーブル
// ====================

const Operation = enum {
    add,
    subtract,
    multiply,
};

fn getOperation(op: Operation) *const fn (i32, i32) i32 {
    return switch (op) {
        .add => &add,
        .subtract => &subtract,
        .multiply => &multiply,
    };
}

fn demoFunctionTable() void {
    std.debug.print("--- 関数テーブル ---\n", .{});

    const ops = [_]Operation{ .add, .subtract, .multiply };
    const a: i32 = 20;
    const b: i32 = 4;

    for (ops) |op| {
        const func = getOperation(op);
        const result = func(a, b);
        std.debug.print("  {s}({d}, {d}) = {d}\n", .{ @tagName(op), a, b, result });
    }

    std.debug.print("\n", .{});
}

// ====================
// Optional関数ポインタ
// ====================

fn demoOptionalFunctionPointer() void {
    std.debug.print("--- Optional関数ポインタ ---\n", .{});

    const FnPtr = *const fn (i32, i32) i32;

    var maybe_fn: ?FnPtr = null;
    std.debug.print("  初期値: null\n", .{});

    maybe_fn = &add;
    if (maybe_fn) |func| {
        std.debug.print("  maybe_fn(5, 3) = {d}\n", .{func(5, 3)});
    }

    // orelseでデフォルト関数
    const default_fn: FnPtr = &subtract;
    const func = maybe_fn orelse default_fn;
    std.debug.print("  orelse: {d}\n", .{func(5, 3)});

    std.debug.print("\n", .{});
}

// ====================
// 構造体メソッドとの違い
// ====================

const Calculator = struct {
    value: i32,

    pub fn addValue(self: *Calculator, x: i32) void {
        self.value += x;
    }

    pub fn getValue(self: *const Calculator) i32 {
        return self.value;
    }
};

fn demoStructMethodDifference() void {
    std.debug.print("--- 構造体メソッドとの違い ---\n", .{});

    var calc = Calculator{ .value = 0 };

    // メソッド呼び出し
    calc.addValue(10);
    std.debug.print("  calc.value = {d}\n", .{calc.getValue()});

    // メソッドを関数として取得
    const method = Calculator.addValue;
    method(&calc, 5);
    std.debug.print("  method後: {d}\n", .{calc.getValue()});

    std.debug.print("  → メソッドも関数ポインタとして使える\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 戦略パターン
// ====================

const SortStrategy = *const fn ([]i32) void;

fn bubbleSort(arr: []i32) void {
    const n = arr.len;
    for (0..n) |i| {
        for (0..n - i - 1) |j| {
            if (arr[j] > arr[j + 1]) {
                const tmp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
            }
        }
    }
}

fn reverseSort(arr: []i32) void {
    var i: usize = 0;
    var j: usize = arr.len - 1;
    while (i < j) {
        const tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
        i += 1;
        j -= 1;
    }
}

fn demoStrategyPattern() void {
    std.debug.print("--- 戦略パターン ---\n", .{});

    var data = [_]i32{ 5, 2, 8, 1, 9 };

    std.debug.print("  元データ: ", .{});
    for (data) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    // 戦略を切り替え
    var strategy: SortStrategy = &bubbleSort;
    strategy(&data);

    std.debug.print("  bubbleSort後: ", .{});
    for (data) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    strategy = &reverseSort;
    strategy(&data);

    std.debug.print("  reverseSort後: ", .{});
    for (data) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 関数型の@typeInfo
// ====================

fn demoFunctionTypeInfo() void {
    std.debug.print("--- 関数型の@typeInfo ---\n", .{});

    const FnType = fn (i32, i32) i32;
    const info = @typeInfo(FnType).@"fn";

    std.debug.print("  fn (i32, i32) i32:\n", .{});
    std.debug.print("    params: {d}個\n", .{info.params.len});
    std.debug.print("    return_type: i32\n", .{});
    std.debug.print("    is_var_args: {}\n", .{info.is_var_args});

    std.debug.print("\n", .{});
}

// ====================
// 呼び出し規約
// ====================

fn demoCallingConvention() void {
    std.debug.print("--- 呼び出し規約 ---\n", .{});

    std.debug.print("  Zigの呼び出し規約:\n", .{});
    std.debug.print("    .auto     - Zig標準（デフォルト）\n", .{});
    std.debug.print("    .c        - C互換\n", .{});
    std.debug.print("    .naked    - プロローグ/エピローグなし\n", .{});
    std.debug.print("    .@\"async\" - 非同期\n", .{});

    // C呼び出し規約の関数ポインタ
    const CFnPtr = *const fn (c_int, c_int) callconv(.c) c_int;
    _ = CFnPtr;
    std.debug.print("  CFnPtr: *const fn(...) callconv(.c) ...\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== 関数ポインタ ===\n\n", .{});

    demoBasicFunctionPointer();
    demoFunctionPointerVariable();
    demoCallback();
    demoFunctionTable();
    demoOptionalFunctionPointer();
    demoStructMethodDifference();
    demoStrategyPattern();
    demoFunctionTypeInfo();
    demoCallingConvention();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・*const fn(args) ret で関数ポインタ型\n", .{});
    std.debug.print("・&function でアドレス取得\n", .{});
    std.debug.print("・コールバックや戦略パターンに使用\n", .{});
    std.debug.print("・callconv()で呼び出し規約を指定\n", .{});
}

// --- テスト ---

test "basic function pointer" {
    const FnPtr = *const fn (i32, i32) i32;
    const fn_ptr: FnPtr = &add;

    try std.testing.expectEqual(@as(i32, 15), fn_ptr(10, 5));
}

test "function pointer switching" {
    const FnPtr = *const fn (i32, i32) i32;
    var op: FnPtr = &add;

    try std.testing.expectEqual(@as(i32, 12), op(7, 5));

    op = &subtract;
    try std.testing.expectEqual(@as(i32, 2), op(7, 5));

    op = &multiply;
    try std.testing.expectEqual(@as(i32, 35), op(7, 5));
}

test "optional function pointer" {
    const FnPtr = *const fn (i32, i32) i32;

    var maybe_fn: ?FnPtr = null;
    try std.testing.expect(maybe_fn == null);

    maybe_fn = &add;
    try std.testing.expect(maybe_fn != null);

    if (maybe_fn) |func| {
        try std.testing.expectEqual(@as(i32, 8), func(5, 3));
    }
}

test "function table" {
    try std.testing.expectEqual(@as(i32, 24), getOperation(.add)(20, 4));
    try std.testing.expectEqual(@as(i32, 16), getOperation(.subtract)(20, 4));
    try std.testing.expectEqual(@as(i32, 80), getOperation(.multiply)(20, 4));
}

test "callback pattern" {
    // コールバックが呼ばれることを確認
    var call_count: usize = 0;
    _ = &call_count;

    const data = [_]i32{ 1, 2, 3 };
    processArray(&data, &printItem);
    // printItemが3回呼ばれる（出力は確認できないがクラッシュしないことを確認）
}

test "struct method as function" {
    var calc = Calculator{ .value = 10 };

    const method = Calculator.addValue;
    method(&calc, 5);

    try std.testing.expectEqual(@as(i32, 15), calc.value);
}

test "function type info" {
    const FnType = fn (i32, i32) i32;
    const info = @typeInfo(FnType).@"fn";

    try std.testing.expectEqual(@as(usize, 2), info.params.len);
}
