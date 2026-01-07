//! # エラートレース
//!
//! Zigはエラーの伝播経路を追跡するエラーリターントレースを提供。
//! デバッグビルドでスタックトレースと組み合わせて使用可能。
//!
//! ## 特徴
//! - @errorReturnTrace(): エラートレース取得
//! - std.debug.dumpStackTrace(): スタックトレース出力
//! - デバッグ時のみ有効（リリースではnull）
//!
//! ## 用途
//! - エラー発生箇所の特定
//! - エラー伝播経路の追跡
//! - デバッグ効率化

const std = @import("std");

// ====================
// @errorReturnTrace の基本
// ====================

fn level3() !void {
    return error.Level3Error;
}

fn level2() !void {
    try level3();
}

fn level1() !void {
    try level2();
}

fn demoBasicTrace() void {
    std.debug.print("--- @errorReturnTrace の基本 ---\n", .{});

    std.debug.print("  @errorReturnTrace():\n", .{});
    std.debug.print("    - エラー伝播経路を取得\n", .{});
    std.debug.print("    - デバッグビルドで有効\n", .{});
    std.debug.print("    - リリースビルドではnull\n", .{});

    // エラートレースの確認
    if (level1()) |_| {
        std.debug.print("  成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});

        // デバッグビルドではトレース取得可能
        if (@errorReturnTrace()) |trace| {
            std.debug.print("  トレースindex: {d}\n", .{trace.index});
            std.debug.print("  アドレス数: {d}\n", .{trace.instruction_addresses.len});
        } else {
            std.debug.print("  トレースなし（リリースビルド）\n", .{});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// エラートレースの構造
// ====================

fn demoTraceStructure() void {
    std.debug.print("--- エラートレースの構造 ---\n", .{});

    std.debug.print("  std.builtin.StackTrace:\n", .{});
    std.debug.print("    index: usize              // 現在の位置\n", .{});
    std.debug.print("    instruction_addresses: []usize // 戻りアドレス\n", .{});

    std.debug.print("  用途:\n", .{});
    std.debug.print("    - エラー発生位置の特定\n", .{});
    std.debug.print("    - 呼び出しチェーンの追跡\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 現在のスタックトレース取得
// ====================

fn innerFunction() void {
    std.debug.print("  innerFunction から現在位置取得\n", .{});

    // 現在の戻りアドレスを取得
    const return_addr = @returnAddress();
    std.debug.print("    @returnAddress(): 0x{x}\n", .{return_addr});
}

fn outerFunction() void {
    innerFunction();
}

fn demoCurrentStack() void {
    std.debug.print("--- 現在のスタック情報 ---\n", .{});

    outerFunction();

    std.debug.print("  @returnAddress(): 現在の戻りアドレス\n", .{});
    std.debug.print("  デバッグ情報と組み合わせて行番号取得可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// エラートレース付きエラー処理
// ====================

const ProcessError = error{
    InvalidInput,
    ProcessingFailed,
    OutputError,
};

fn step3(input: i32) ProcessError!i32 {
    if (input < 0) {
        return error.InvalidInput;
    }
    return input * 3;
}

fn step2(input: i32) ProcessError!i32 {
    const result = try step3(input);
    if (result > 100) {
        return error.ProcessingFailed;
    }
    return result + 10;
}

fn step1(input: i32) ProcessError!i32 {
    const result = try step2(input);
    return result * 2;
}

fn demoTracedError() void {
    std.debug.print("--- エラートレース付きエラー処理 ---\n", .{});

    // 正常ケース
    if (step1(5)) |result| {
        std.debug.print("  step1(5) = {d}\n", .{result});
    } else |_| {}

    // エラーケース
    if (step1(-1)) |_| {} else |err| {
        std.debug.print("  step1(-1): {s}\n", .{@errorName(err)});

        // トレース情報の確認
        if (@errorReturnTrace()) |trace| {
            std.debug.print("  トレース取得成功\n", .{});
            std.debug.print("    記録されたアドレス数: {d}\n", .{trace.index});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// errdeferでトレース確認
// ====================

fn withErrdeferTrace() !void {
    errdefer {
        std.debug.print("  errdefer内:\n", .{});
        if (@errorReturnTrace()) |trace| {
            std.debug.print("    トレースあり (index={d})\n", .{trace.index});
        } else {
            std.debug.print("    トレースなし\n", .{});
        }
    }

    return error.TestError;
}

fn demoErrdeferTrace() void {
    std.debug.print("--- errdeferでトレース確認 ---\n", .{});

    withErrdeferTrace() catch |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    };

    std.debug.print("\n", .{});
}

// ====================
// ビルドモードとトレース
// ====================

fn demoBuildModes() void {
    std.debug.print("--- ビルドモードとトレース ---\n", .{});

    std.debug.print("  Debug:\n", .{});
    std.debug.print("    - エラートレース有効\n", .{});
    std.debug.print("    - 全てのチェック有効\n", .{});

    std.debug.print("  ReleaseSafe:\n", .{});
    std.debug.print("    - 安全性チェック有効\n", .{});
    std.debug.print("    - エラートレース無効\n", .{});

    std.debug.print("  ReleaseFast:\n", .{});
    std.debug.print("    - 最適化優先\n", .{});
    std.debug.print("    - トレース無効\n", .{});

    std.debug.print("  ReleaseSmall:\n", .{});
    std.debug.print("    - サイズ最適化\n", .{});
    std.debug.print("    - トレース無効\n", .{});

    // 現在のビルドモードを確認
    const mode = @import("builtin").mode;
    std.debug.print("  現在のモード: {s}\n", .{@tagName(mode)});

    std.debug.print("\n", .{});
}

// ====================
// 手動スタックトレースキャプチャ
// ====================

fn demoManualCapture() void {
    std.debug.print("--- 手動スタックトレースキャプチャ ---\n", .{});

    std.debug.print("  std.debug.captureStackTrace():\n", .{});
    std.debug.print("    - 現在のスタック情報を手動取得\n", .{});
    std.debug.print("    - バッファに戻りアドレスを記録\n", .{});

    // スタックトレースバッファ
    var addrs: [16]usize = undefined;
    var trace = std.builtin.StackTrace{
        .index = 0,
        .instruction_addresses = &addrs,
    };

    // 現在位置をキャプチャ
    std.debug.captureStackTrace(null, &trace);

    std.debug.print("  キャプチャ結果:\n", .{});
    std.debug.print("    記録アドレス数: {d}\n", .{trace.index});

    // 最初のいくつかのアドレスを表示
    const count = @min(trace.index, 3);
    for (0..count) |i| {
        std.debug.print("    [{d}] 0x{x}\n", .{ i, addrs[i] });
    }

    std.debug.print("\n", .{});
}

// ====================
// 実践パターン：ロギング
// ====================

fn logError(err: anyerror) void {
    std.debug.print("  [ERROR] {s}\n", .{@errorName(err)});

    // デバッグビルドでは位置情報も出力
    if (@errorReturnTrace()) |trace| {
        if (trace.index > 0) {
            std.debug.print("    at 0x{x}\n", .{trace.instruction_addresses[0]});
        }
    }
}

fn riskyOperation(fail: bool) !void {
    if (fail) {
        return error.RiskyOperationFailed;
    }
}

fn demoLoggingPattern() void {
    std.debug.print("--- 実践パターン：ロギング ---\n", .{});

    if (riskyOperation(true)) |_| {} else |err| {
        logError(err);
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  @errorReturnTrace():\n", .{});
    std.debug.print("    - エラー伝播経路を追跡\n", .{});
    std.debug.print("    - デバッグビルドで自動有効\n", .{});

    std.debug.print("  @returnAddress():\n", .{});
    std.debug.print("    - 現在の戻りアドレス取得\n", .{});

    std.debug.print("  std.debug.captureStackTrace():\n", .{});
    std.debug.print("    - 手動でスタック情報取得\n", .{});

    std.debug.print("  ビルドモード:\n", .{});
    std.debug.print("    - Debugでトレース有効\n", .{});
    std.debug.print("    - Releaseでは無効\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== エラートレース ===\n\n", .{});

    demoBasicTrace();
    demoTraceStructure();
    demoCurrentStack();
    demoTracedError();
    demoErrdeferTrace();
    demoBuildModes();
    demoManualCapture();
    demoLoggingPattern();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・@errorReturnTrace()でエラー経路取得\n", .{});
    std.debug.print("・デバッグビルドで自動的に有効\n", .{});
    std.debug.print("・リリースビルドではnull\n", .{});
    std.debug.print("・デバッグ効率化に活用\n", .{});
}

// --- テスト ---

test "error return trace in debug" {
    // デバッグモードではトレースが取得可能
    const mode = @import("builtin").mode;

    level1() catch {
        const trace = @errorReturnTrace();
        if (mode == .Debug) {
            // デバッグビルドではトレースあり
            try std.testing.expect(trace != null);
        }
        return;
    };
}

test "return address is non-zero" {
    const addr = @returnAddress();
    try std.testing.expect(addr != 0);
}

test "stack trace capture" {
    var addrs: [16]usize = undefined;
    var trace = std.builtin.StackTrace{
        .index = 0,
        .instruction_addresses = &addrs,
    };

    std.debug.captureStackTrace(null, &trace);

    // 何かしらのアドレスが記録される
    try std.testing.expect(trace.index > 0);
}

test "error propagation chain" {
    // エラーが正しく伝播することを確認
    const result = step1(-5);
    try std.testing.expectError(error.InvalidInput, result);
}

test "successful processing" {
    const result = try step1(10);
    // (10 * 3 + 10) * 2 = 80
    try std.testing.expectEqual(@as(i32, 80), result);
}

test "processing overflow error" {
    // 入力が大きすぎると ProcessingFailed
    const result = step1(50);
    try std.testing.expectError(error.ProcessingFailed, result);
}
