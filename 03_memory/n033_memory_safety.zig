//! # メモリ安全性
//!
//! Zigはコンパイル時と実行時のチェックでメモリ安全を保証。
//! Cより安全、手動管理で高性能を両立。
//!
//! ## 安全機能
//! - 境界チェック（配列・スライス）
//! - nullポインタ検出
//! - 未定義動作の検出
//! - アライメントチェック
//!
//! ## 注意点
//! - ReleaseでもSafe/Smallは安全チェック有効
//! - ReleaseFastは最適化優先

const std = @import("std");

// ====================
// 境界チェック
// ====================

fn demoBoundsCheck() void {
    std.debug.print("--- 境界チェック ---\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    // 安全なアクセス
    std.debug.print("  arr[2] = {d}\n", .{arr[2]});

    // コンパイル時に検出される境界外アクセス
    // const bad = arr[10]; // コンパイルエラー

    // 実行時の境界外アクセス（デバッグモードでパニック）
    var idx: usize = 10;
    _ = &idx;
    // const bad = arr[idx]; // 実行時パニック

    std.debug.print("  → 境界外アクセスはコンパイル/実行時に検出\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スライスの安全性
// ====================

fn demoSliceSafety() void {
    std.debug.print("--- スライスの安全性 ---\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    // 安全なスライス
    const slice = arr[1..4];
    std.debug.print("  slice[0..3]: ", .{});
    for (slice) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});

    // 範囲外のスライス作成は検出
    // const bad = arr[3..10]; // パニック

    std.debug.print("  → スライス範囲も境界チェック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optional型でnull安全
// ====================

fn findValue(arr: []const i32, target: i32) ?usize {
    for (arr, 0..) |v, i| {
        if (v == target) return i;
    }
    return null;
}

fn demoNullSafety() void {
    std.debug.print("--- Optional型でnull安全 ---\n", .{});

    const arr = [_]i32{ 10, 20, 30 };

    // 存在する値
    if (findValue(&arr, 20)) |idx| {
        std.debug.print("  20は位置{d}に存在\n", .{idx});
    }

    // 存在しない値
    if (findValue(&arr, 99)) |idx| {
        std.debug.print("  99は位置{d}に存在\n", .{idx});
    } else {
        std.debug.print("  99は存在しない\n", .{});
    }

    // orelseでデフォルト値
    const result = findValue(&arr, 99) orelse 0;
    std.debug.print("  orelse: {d}\n", .{result});

    std.debug.print("  → nullは型で表現、強制的にチェック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// undefinedの扱い
// ====================

fn demoUndefined() void {
    std.debug.print("--- undefinedの扱い ---\n", .{});

    // undefinedは初期化されていない状態
    var buffer: [10]u8 = undefined;

    // 読む前に書く必要がある
    @memset(&buffer, 'X');

    std.debug.print("  初期化後: {s}\n", .{&buffer});

    // デバッグモードではundefinedを読むとパニック
    // var x: i32 = undefined;
    // std.debug.print("{d}\n", .{x}); // パニック

    std.debug.print("  → undefinedは初期化前に使うとパニック\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 整数オーバーフロー検出
// ====================

fn demoOverflowCheck() void {
    std.debug.print("--- 整数オーバーフロー検出 ---\n", .{});

    // 通常の演算はオーバーフローでパニック（デバッグモード）
    const a: u8 = 200;
    const b: u8 = 50;

    // const c = a + b; // オーバーフローでパニック

    // 明示的なラッピング演算
    const wrapped = a +% b;
    std.debug.print("  200 +%% 50 = {d} (ラッピング)\n", .{wrapped});

    // 飽和演算
    const saturated = a +| b;
    std.debug.print("  200 +| 50 = {d} (飽和)\n", .{saturated});

    // オーバーフローチェック付き
    const result = @addWithOverflow(a, b);
    if (result[1] == 1) {
        std.debug.print("  200 + 50: オーバーフロー検出\n", .{});
    }

    std.debug.print("  → 意図しないオーバーフローを検出\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ポインタの安全性
// ====================

fn demoPointerSafety() void {
    std.debug.print("--- ポインタの安全性 ---\n", .{});

    var value: i32 = 42;
    const ptr: *i32 = &value;

    std.debug.print("  ptr.* = {d}\n", .{ptr.*});

    // Zigにはnullポインタがない（Optionalを使う）
    var opt_ptr: ?*i32 = &value;
    if (opt_ptr) |p| {
        std.debug.print("  opt_ptr.* = {d}\n", .{p.*});
    }

    opt_ptr = null;
    if (opt_ptr) |_| {
        std.debug.print("  ここには来ない\n", .{});
    } else {
        std.debug.print("  opt_ptr is null\n", .{});
    }

    std.debug.print("  → Optionalでnullポインタを型で管理\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// アロケータのリーク検出
// ====================

fn demoLeakDetection() !void {
    std.debug.print("--- リーク検出 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 正常なケース
    {
        const data = try allocator.alloc(u8, 10);
        defer allocator.free(data);
        @memset(data, 'A');
        std.debug.print("  正常: allocate → free\n", .{});
    }

    // リークを検出
    _ = try allocator.alloc(u8, 10); // freeを忘れる

    const result = gpa.deinit();
    if (result == .leak) {
        std.debug.print("  リーク検出！\n", .{});
    }

    std.debug.print("  → GPAはリークを報告\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// testing.allocatorでテスト
// ====================

fn demoTestingAllocator() void {
    std.debug.print("--- testing.allocator ---\n", .{});

    // std.testing.allocatorはテスト時にリークを厳密にチェック
    // テストが終了時にリークがあればテスト失敗

    std.debug.print("  テストでstd.testing.allocatorを使用すると:\n", .{});
    std.debug.print("    - 各テスト終了時にリーク検出\n", .{});
    std.debug.print("    - リークがあればテスト失敗\n", .{});
    std.debug.print("    - 二重解放も検出\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ビルドモードと安全性
// ====================

fn demoBuildModes() void {
    std.debug.print("--- ビルドモードと安全性 ---\n", .{});

    std.debug.print("  Debug:\n", .{});
    std.debug.print("    - 全ての安全チェック有効\n", .{});
    std.debug.print("    - 最適化なし\n", .{});

    std.debug.print("  ReleaseSafe:\n", .{});
    std.debug.print("    - 安全チェック有効\n", .{});
    std.debug.print("    - 最適化あり\n", .{});

    std.debug.print("  ReleaseSmall:\n", .{});
    std.debug.print("    - 安全チェック有効\n", .{});
    std.debug.print("    - サイズ最適化\n", .{});

    std.debug.print("  ReleaseFast:\n", .{});
    std.debug.print("    - 安全チェック無効\n", .{});
    std.debug.print("    - 最大速度最適化\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== メモリ安全性 ===\n\n", .{});

    demoBoundsCheck();
    demoSliceSafety();
    demoNullSafety();
    demoUndefined();
    demoOverflowCheck();
    demoPointerSafety();
    try demoLeakDetection();
    demoTestingAllocator();
    demoBuildModes();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・境界チェックで安全なアクセス\n", .{});
    std.debug.print("・Optionalでnull安全\n", .{});
    std.debug.print("・undefinedは使用前に初期化必須\n", .{});
    std.debug.print("・GPAでリーク検出\n", .{});
    std.debug.print("・ビルドモードで安全性/速度を選択\n", .{});
}

// --- テスト ---

test "bounds check" {
    const arr = [_]i32{ 1, 2, 3 };
    try std.testing.expectEqual(@as(i32, 2), arr[1]);
}

test "slice safety" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const slice = arr[1..4];
    try std.testing.expectEqual(@as(usize, 3), slice.len);
}

test "optional null safety" {
    const arr = [_]i32{ 10, 20, 30 };

    // 存在する
    const found = findValue(&arr, 20);
    try std.testing.expect(found != null);
    try std.testing.expectEqual(@as(usize, 1), found.?);

    // 存在しない
    const not_found = findValue(&arr, 99);
    try std.testing.expect(not_found == null);
}

test "wrapping operations" {
    const a: u8 = 200;
    const b: u8 = 100;

    // ラッピング
    const wrapped = a +% b;
    try std.testing.expectEqual(@as(u8, 44), wrapped); // 300 - 256 = 44

    // 飽和
    const saturated = a +| b;
    try std.testing.expectEqual(@as(u8, 255), saturated);
}

test "overflow detection" {
    const a: u8 = 200;
    const b: u8 = 100;

    const result = @addWithOverflow(a, b);
    // result[0]は結果、result[1]はオーバーフローフラグ
    try std.testing.expectEqual(@as(u1, 1), result[1]); // オーバーフロー発生
}

test "no leak with testing allocator" {
    const allocator = std.testing.allocator;

    const data = try allocator.alloc(u8, 10);
    defer allocator.free(data);

    @memset(data, 0);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
}

test "GPA leak detection" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 正常に解放
    const data = try allocator.alloc(u8, 10);
    allocator.free(data);

    const result = gpa.deinit();
    try std.testing.expectEqual(.ok, result);
}

test "pointer optional" {
    var value: i32 = 42;
    var opt_ptr: ?*i32 = &value;

    try std.testing.expect(opt_ptr != null);
    try std.testing.expectEqual(@as(i32, 42), opt_ptr.?.*);

    opt_ptr = null;
    try std.testing.expect(opt_ptr == null);
}
