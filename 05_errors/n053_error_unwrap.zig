//! # エラーのアンラップ
//!
//! エラーユニオン(!T)から値を取り出す様々な方法を解説。
//! 状況に応じた適切なアンラップ手法を選択する。
//!
//! ## アンラップ方法
//! - try: エラーを伝播
//! - catch: デフォルト値またはハンドリング
//! - catch unreachable: エラーが起きないことを保証
//! - if-else: 条件分岐で処理
//!
//! ## 用途
//! - 関数チェーン内でのエラー伝播
//! - デフォルト値によるフォールバック
//! - 詳細なエラー分岐処理

const std = @import("std");

// ====================
// 基本的なエラーユニオン
// ====================

fn divide(a: i32, b: i32) error{DivisionByZero}!i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

fn demoErrorUnion() void {
    std.debug.print("--- 基本的なエラーユニオン ---\n", .{});

    std.debug.print("  error{{...}}!T:\n", .{});
    std.debug.print("    - エラーまたは成功値を持つ\n", .{});
    std.debug.print("    - 明示的にアンラップが必要\n", .{});

    // 成功ケース
    if (divide(10, 2)) |v| {
        std.debug.print("  divide(10, 2) = {d}\n", .{v});
    } else |_| {}

    // エラーケース
    if (divide(10, 0)) |_| {} else |err| {
        std.debug.print("  divide(10, 0): {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// try でアンラップ
// ====================

fn calculate(a: i32, b: i32) !i32 {
    // tryでエラーを即座に伝播
    const quotient = try divide(a, b);
    return quotient * 2;
}

fn demoTryUnwrap() void {
    std.debug.print("--- try でアンラップ ---\n", .{});

    std.debug.print("  try expr:\n", .{});
    std.debug.print("    - 成功なら値を取り出す\n", .{});
    std.debug.print("    - エラーなら即座に伝播\n", .{});

    if (calculate(10, 2)) |result| {
        std.debug.print("  calculate(10, 2) = {d}\n", .{result});
    } else |_| {}

    if (calculate(10, 0)) |_| {} else |err| {
        std.debug.print("  calculate(10, 0): {s}（伝播）\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// catch でデフォルト値
// ====================

fn demoCatchDefault() void {
    std.debug.print("--- catch でデフォルト値 ---\n", .{});

    // エラー時にデフォルト値
    const result1 = divide(10, 0) catch 0;
    std.debug.print("  divide(10, 0) catch 0 = {d}\n", .{result1});

    const result2 = divide(10, 2) catch 0;
    std.debug.print("  divide(10, 2) catch 0 = {d}\n", .{result2});

    // 式も可能
    const fallback: i32 = -1;
    const result3 = divide(10, 0) catch fallback;
    std.debug.print("  catch fallback = {d}\n", .{result3});

    std.debug.print("\n", .{});
}

// ====================
// catch ブロック
// ====================

fn demoCatchBlock() void {
    std.debug.print("--- catch ブロック ---\n", .{});

    // エラーを捕捉してハンドリング
    const result = divide(10, 0) catch |err| blk: {
        std.debug.print("  エラー捕捉: {s}\n", .{@errorName(err)});
        break :blk @as(i32, -999);
    };
    std.debug.print("  結果: {d}\n", .{result});

    // ログを出力してデフォルト値
    const result2 = divide(5, 0) catch |err| blk: {
        std.debug.print("  [WARN] {s}: using default\n", .{@errorName(err)});
        break :blk @as(i32, 0);
    };
    std.debug.print("  結果: {d}\n", .{result2});

    std.debug.print("\n", .{});
}

// ====================
// catch unreachable
// ====================

fn safeDivide(a: i32, b: i32) i32 {
    // bが0でないことを事前に確認済みの場合
    if (b == 0) return 0;
    return divide(a, b) catch unreachable;
}

fn demoCatchUnreachable() void {
    std.debug.print("--- catch unreachable ---\n", .{});

    std.debug.print("  catch unreachable:\n", .{});
    std.debug.print("    - エラーが起きないことを保証\n", .{});
    std.debug.print("    - エラー発生時はパニック\n", .{});
    std.debug.print("    - 事前チェック後に使用\n", .{});

    // 事前にチェックしているので安全
    const result = safeDivide(10, 2);
    std.debug.print("  safeDivide(10, 2) = {d}\n", .{result});

    std.debug.print("\n", .{});
}

// ====================
// if-else でアンラップ
// ====================

fn demoIfElseUnwrap() void {
    std.debug.print("--- if-else でアンラップ ---\n", .{});

    // 成功/エラーで分岐
    if (divide(10, 2)) |value| {
        std.debug.print("  成功: {d}\n", .{value});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    // エラーのみ処理
    if (divide(10, 0)) |_| {
        std.debug.print("  成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// オプショナルとの組み合わせ
// ====================

fn find(arr: []const i32, target: i32) error{InvalidArray}!?usize {
    if (arr.len == 0) return error.InvalidArray;

    for (arr, 0..) |v, i| {
        if (v == target) return i;
    }
    return null;
}

fn demoOptionalError() void {
    std.debug.print("--- オプショナルとの組み合わせ ---\n", .{});

    const arr = [_]i32{ 10, 20, 30 };

    // 成功（見つかった）
    if (find(&arr, 20)) |maybe_idx| {
        if (maybe_idx) |idx| {
            std.debug.print("  20: index={d}\n", .{idx});
        } else {
            std.debug.print("  20: not found\n", .{});
        }
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    // 成功（見つからない）
    if (find(&arr, 99)) |maybe_idx| {
        if (maybe_idx) |_| {} else {
            std.debug.print("  99: not found\n", .{});
        }
    } else |_| {}

    // エラー
    const empty: []const i32 = &.{};
    if (find(empty, 1)) |_| {} else |err| {
        std.debug.print("  empty array: {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// チェーンでのアンラップ
// ====================

fn step1(x: i32) !i32 {
    if (x < 0) return error.NegativeInput;
    return x + 1;
}

fn step2(x: i32) !i32 {
    if (x > 100) return error.TooLarge;
    return x * 2;
}

fn step3(x: i32) !i32 {
    if (x == 0) return error.ZeroResult;
    return x;
}

fn processChain(input: i32) !i32 {
    // tryで連続アンラップ
    const a = try step1(input);
    const b = try step2(a);
    const c = try step3(b);
    return c;
}

fn demoChainUnwrap() void {
    std.debug.print("--- チェーンでのアンラップ ---\n", .{});

    std.debug.print("  tryで連続アンラップ:\n", .{});

    // 成功
    if (processChain(5)) |result| {
        std.debug.print("  processChain(5) = {d}\n", .{result});
    } else |_| {}

    // step1でエラー
    if (processChain(-1)) |_| {} else |err| {
        std.debug.print("  processChain(-1): {s}\n", .{@errorName(err)});
    }

    // step2でエラー（100+1=101 > 100）
    if (processChain(100)) |_| {} else |err| {
        std.debug.print("  processChain(100): {s}\n", .{@errorName(err)});
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践パターン：デフォルト設定
// ====================

const Config = struct {
    timeout: u32,
    retries: u32,
    verbose: bool,
};

fn loadConfig(path: []const u8) error{ FileNotFound, ParseError }!Config {
    if (path.len == 0) return error.FileNotFound;
    if (std.mem.eql(u8, path, "invalid")) return error.ParseError;
    return Config{
        .timeout = 30,
        .retries = 3,
        .verbose = true,
    };
}

fn getConfig(path: []const u8) Config {
    // 設定読み込み失敗時はデフォルト
    return loadConfig(path) catch Config{
        .timeout = 60,
        .retries = 1,
        .verbose = false,
    };
}

fn demoDefaultConfig() void {
    std.debug.print("--- 実践パターン：デフォルト設定 ---\n", .{});

    // 設定ファイルあり
    const config1 = getConfig("config.json");
    std.debug.print("  config.json: timeout={d}\n", .{config1.timeout});

    // 設定ファイルなし（デフォルト使用）
    const config2 = getConfig("");
    std.debug.print("  (none): timeout={d}（デフォルト）\n", .{config2.timeout});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  try expr:\n", .{});
    std.debug.print("    値を取り出し、エラーは伝播\n", .{});

    std.debug.print("  catch value:\n", .{});
    std.debug.print("    エラー時にデフォルト値\n", .{});

    std.debug.print("  catch |err| blk:\n", .{});
    std.debug.print("    エラーをハンドリング\n", .{});

    std.debug.print("  catch unreachable:\n", .{});
    std.debug.print("    エラーが起きない保証\n", .{});

    std.debug.print("  if (expr) |val| else |err|:\n", .{});
    std.debug.print("    条件分岐で処理\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラーのアンラップ ===\n\n", .{});

    demoErrorUnion();
    demoTryUnwrap();
    demoCatchDefault();
    demoCatchBlock();
    demoCatchUnreachable();
    demoIfElseUnwrap();
    demoOptionalError();
    demoChainUnwrap();
    demoDefaultConfig();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・tryはエラー伝播に最適\n", .{});
    std.debug.print("・catchはフォールバックに便利\n", .{});
    std.debug.print("・if-elseは詳細な分岐処理に\n", .{});
    std.debug.print("・状況に応じて使い分け\n", .{});
}

// --- テスト ---

test "try unwrap success" {
    const result = try calculate(10, 2);
    try std.testing.expectEqual(@as(i32, 10), result);
}

test "try unwrap propagates error" {
    const result = calculate(10, 0);
    try std.testing.expectError(error.DivisionByZero, result);
}

test "catch default value" {
    const result = divide(10, 0) catch 0;
    try std.testing.expectEqual(@as(i32, 0), result);
}

test "catch block" {
    const result = divide(10, 0) catch -1;
    try std.testing.expectEqual(@as(i32, -1), result);
}

test "catch unreachable when no error" {
    // 事前にチェック済みなので安全
    const result = divide(10, 2) catch unreachable;
    try std.testing.expectEqual(@as(i32, 5), result);
}

test "if-else unwrap success" {
    if (divide(10, 2)) |value| {
        try std.testing.expectEqual(@as(i32, 5), value);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "if-else unwrap error" {
    if (divide(10, 0)) |_| {
        try std.testing.expect(false);
    } else |err| {
        try std.testing.expectEqual(error.DivisionByZero, err);
    }
}

test "chain unwrap success" {
    const result = try processChain(5);
    // (5 + 1) * 2 = 12
    try std.testing.expectEqual(@as(i32, 12), result);
}

test "chain unwrap error at step1" {
    const result = processChain(-1);
    try std.testing.expectError(error.NegativeInput, result);
}

test "chain unwrap error at step2" {
    // 100 + 1 = 101 > 100, step2でエラー
    const result = processChain(100);
    try std.testing.expectError(error.TooLarge, result);
}

test "optional error success found" {
    const arr = [_]i32{ 10, 20, 30 };
    if (find(&arr, 20)) |maybe| {
        try std.testing.expectEqual(@as(?usize, 1), maybe);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "optional error success not found" {
    const arr = [_]i32{ 10, 20, 30 };
    if (find(&arr, 99)) |maybe| {
        try std.testing.expect(maybe == null);
    } else |_| {
        try std.testing.expect(false);
    }
}

test "optional error returns error" {
    const empty: []const i32 = &.{};
    try std.testing.expectError(error.InvalidArray, find(empty, 1));
}

test "default config on error" {
    const config = getConfig("");
    try std.testing.expectEqual(@as(u32, 60), config.timeout);
    try std.testing.expect(!config.verbose);
}
