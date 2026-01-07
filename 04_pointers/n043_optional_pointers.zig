//! # Optionalポインタ
//!
//! Optionalポインタ ?*T はnullを許可するポインタ。
//! nullableな参照を型安全に表現。
//!
//! ## 特徴
//! - ?*T: nullまたは有効なポインタ
//! - ゼロコストの最適化（追加メモリなし）
//! - 明示的なnullチェックが必要
//!
//! ## 構文
//! - if (opt_ptr) |ptr| { ... }
//! - opt_ptr.?  // nullなら未定義動作
//! - orelse

const std = @import("std");

// ====================
// 基本的なOptionalポインタ
// ====================

fn demoBasicOptionalPointer() void {
    std.debug.print("--- 基本的なOptionalポインタ ---\n", .{});

    var value: i32 = 42;

    // Optionalポインタ（null）
    var opt_ptr: ?*i32 = null;
    std.debug.print("  初期値: null\n", .{});

    // 値を設定
    opt_ptr = &value;
    std.debug.print("  代入後: 非null\n", .{});

    // if でアンラップ
    if (opt_ptr) |ptr| {
        std.debug.print("  unwrap: {d}\n", .{ptr.*});
    } else {
        std.debug.print("  unwrap: null\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// nullチェックパターン
// ====================

fn demoNullCheckPatterns() void {
    std.debug.print("--- nullチェックパターン ---\n", .{});

    var value: i32 = 100;
    var opt_ptr: ?*i32 = &value;

    // パターン1: if でアンラップ
    if (opt_ptr) |ptr| {
        std.debug.print("  if unwrap: {d}\n", .{ptr.*});
    }

    // パターン2: orelse でデフォルト
    const default_val: i32 = 0;
    const val = if (opt_ptr) |ptr| ptr.* else default_val;
    std.debug.print("  orelse: {d}\n", .{val});

    // パターン3: .? で強制アンラップ（危険）
    // nullの場合は未定義動作
    const forced = opt_ptr.?;
    std.debug.print("  .? 強制アンラップ: {d}\n", .{forced.*});

    // パターン4: while でループ
    opt_ptr = &value;
    var count: i32 = 0;
    while (opt_ptr) |ptr| : (count += 1) {
        if (count >= 3) {
            opt_ptr = null;
        } else {
            ptr.* += 1;
        }
    }
    std.debug.print("  while後の値: {d}\n", .{value});

    std.debug.print("\n", .{});
}

// ====================
// 関数の戻り値として
// ====================

fn findValue(arr: []const i32, target: i32) ?*const i32 {
    for (arr) |*v| {
        if (v.* == target) {
            return v;
        }
    }
    return null;
}

fn demoFunctionReturn() void {
    std.debug.print("--- 関数の戻り値として ---\n", .{});

    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // 見つかる場合
    if (findValue(&arr, 30)) |ptr| {
        std.debug.print("  30を発見: {d}\n", .{ptr.*});
    }

    // 見つからない場合
    if (findValue(&arr, 99)) |ptr| {
        std.debug.print("  99を発見: {d}\n", .{ptr.*});
    } else {
        std.debug.print("  99: 見つかりません\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// 構造体での使用
// ====================

const Node = struct {
    value: i32,
    next: ?*Node,
};

fn demoLinkedList() void {
    std.debug.print("--- 連結リスト（構造体での使用） ---\n", .{});

    var node3 = Node{ .value = 30, .next = null };
    var node2 = Node{ .value = 20, .next = &node3 };
    var node1 = Node{ .value = 10, .next = &node2 };

    // リストを走査
    var current: ?*Node = &node1;
    std.debug.print("  リスト: ", .{});
    while (current) |node| {
        std.debug.print("{d} ", .{node.value});
        current = node.next;
    }
    std.debug.print("\n", .{});

    // ノード数をカウント
    current = &node1;
    var count: usize = 0;
    while (current) |node| : (count += 1) {
        current = node.next;
    }
    std.debug.print("  ノード数: {d}\n", .{count});

    std.debug.print("\n", .{});
}

// ====================
// ゼロコスト最適化
// ====================

fn demoZeroCost() void {
    std.debug.print("--- ゼロコスト最適化 ---\n", .{});

    std.debug.print("  *T のサイズ: {d} bytes\n", .{@sizeOf(*i32)});
    std.debug.print("  ?*T のサイズ: {d} bytes\n", .{@sizeOf(?*i32)});
    std.debug.print("  → 同じサイズ（nullは0アドレスで表現）\n", .{});

    // 非ポインタ型の場合は異なる
    std.debug.print("  i32 のサイズ: {d} bytes\n", .{@sizeOf(i32)});
    std.debug.print("  ?i32 のサイズ: {d} bytes\n", .{@sizeOf(?i32)});
    std.debug.print("  → ?i32 は追加フラグが必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optional配列ポインタ
// ====================

fn demoOptionalArrayPointer() void {
    std.debug.print("--- Optional配列ポインタ ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };

    // Optional複数要素ポインタ
    var multi_opt: ?[*]i32 = null;
    std.debug.print("  ?[*]i32 null: {}\n", .{multi_opt == null});

    multi_opt = &arr;
    if (multi_opt) |ptr| {
        std.debug.print("  ?[*]i32[0]: {d}\n", .{ptr[0]});
    }

    // Optionalスライス
    var slice_opt: ?[]i32 = null;
    std.debug.print("  ?[]i32 null: {}\n", .{slice_opt == null});

    slice_opt = &arr;
    if (slice_opt) |slice| {
        std.debug.print("  ?[]i32 len: {d}\n", .{slice.len});
    }

    std.debug.print("\n", .{});
}

// ====================
// @typeInfo での確認
// ====================

fn demoTypeInfo() void {
    std.debug.print("--- @typeInfo での確認 ---\n", .{});

    const OptPtr = ?*i32;
    const info = @typeInfo(OptPtr);

    if (info == .optional) {
        std.debug.print("  ?*i32 は Optional型\n", .{});
        const child_info = @typeInfo(info.optional.child);
        if (child_info == .pointer) {
            std.debug.print("    child: pointer\n", .{});
            std.debug.print("    size: {s}\n", .{@tagName(child_info.pointer.size)});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// Optionalポインタの比較
// ====================

fn demoComparison() void {
    std.debug.print("--- Optionalポインタの比較 ---\n", .{});

    var a: i32 = 10;
    var b: i32 = 20;

    const ptr_a: ?*i32 = &a;
    const ptr_b: ?*i32 = &b;
    const ptr_null: ?*i32 = null;

    // null比較
    std.debug.print("  ptr_a == null: {}\n", .{ptr_a == null});
    std.debug.print("  ptr_null == null: {}\n", .{ptr_null == null});

    // ポインタ同士の比較
    std.debug.print("  ptr_a == ptr_a: {}\n", .{ptr_a == ptr_a});
    std.debug.print("  ptr_a == ptr_b: {}\n", .{ptr_a == ptr_b});

    std.debug.print("\n", .{});
}

// ====================
// コールバックでの使用
// ====================

const Callback = ?*const fn (i32) void;

fn printValue(x: i32) void {
    std.debug.print("    コールバック: {d}\n", .{x});
}

fn executeCallback(cb: Callback, value: i32) void {
    if (cb) |callback| {
        callback(value);
    } else {
        std.debug.print("    コールバックなし\n", .{});
    }
}

fn demoCallback() void {
    std.debug.print("--- コールバックでの使用 ---\n", .{});

    // コールバックあり
    executeCallback(&printValue, 42);

    // コールバックなし
    executeCallback(null, 100);

    std.debug.print("\n", .{});
}

// ====================
// 安全なアンラップ
// ====================

fn demoSafeUnwrap() void {
    std.debug.print("--- 安全なアンラップ ---\n", .{});

    var value: i32 = 50;
    const opt: ?*i32 = &value;

    // 推奨: if でアンラップ
    if (opt) |ptr| {
        std.debug.print("  安全: {d}\n", .{ptr.*});
    }

    // 注意: .? は nullの場合に未定義動作
    // const unsafe = opt.?; // nullなら危険

    // orelse with unreachable (確実にnullでない場合のみ)
    const safe_ptr = opt orelse unreachable;
    std.debug.print("  orelse unreachable: {d}\n", .{safe_ptr.*});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== Optionalポインタ ===\n\n", .{});

    demoBasicOptionalPointer();
    demoNullCheckPatterns();
    demoFunctionReturn();
    demoLinkedList();
    demoZeroCost();
    demoOptionalArrayPointer();
    demoTypeInfo();
    demoComparison();
    demoCallback();
    demoSafeUnwrap();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・?*T はnullを許可するポインタ\n", .{});
    std.debug.print("・ポインタの場合はゼロコスト\n", .{});
    std.debug.print("・if/orelse でアンラップ\n", .{});
    std.debug.print("・.? は危険、確実な場合のみ使用\n", .{});
}

// --- テスト ---

test "optional pointer null" {
    const opt: ?*i32 = null;
    try std.testing.expect(opt == null);
}

test "optional pointer non-null" {
    var val: i32 = 42;
    const opt: ?*i32 = &val;

    try std.testing.expect(opt != null);
    if (opt) |ptr| {
        try std.testing.expectEqual(@as(i32, 42), ptr.*);
    }
}

test "optional pointer unwrap with if" {
    var val: i32 = 100;
    const opt: ?*i32 = &val;

    const result = if (opt) |ptr| ptr.* else @as(i32, 0);
    try std.testing.expectEqual(@as(i32, 100), result);
}

test "optional pointer null default" {
    const opt: ?*i32 = null;
    const result = if (opt) |ptr| ptr.* else @as(i32, -1);
    try std.testing.expectEqual(@as(i32, -1), result);
}

test "find value returns pointer" {
    const arr = [_]i32{ 10, 20, 30 };

    const found = findValue(&arr, 20);
    try std.testing.expect(found != null);
    if (found) |ptr| {
        try std.testing.expectEqual(@as(i32, 20), ptr.*);
    }
}

test "find value returns null" {
    const arr = [_]i32{ 10, 20, 30 };

    const not_found = findValue(&arr, 99);
    try std.testing.expect(not_found == null);
}

test "linked list traversal" {
    var node3 = Node{ .value = 3, .next = null };
    var node2 = Node{ .value = 2, .next = &node3 };
    var node1 = Node{ .value = 1, .next = &node2 };

    var current: ?*Node = &node1;
    var count: usize = 0;
    var sum: i32 = 0;

    while (current) |node| : (count += 1) {
        sum += node.value;
        current = node.next;
    }

    try std.testing.expectEqual(@as(usize, 3), count);
    try std.testing.expectEqual(@as(i32, 6), sum);
}

test "optional pointer size" {
    // ポインタのOptionalはゼロコスト
    try std.testing.expectEqual(@sizeOf(*i32), @sizeOf(?*i32));
}

test "optional pointer comparison" {
    var a: i32 = 10;
    const ptr: ?*i32 = &a;
    const null_ptr: ?*i32 = null;

    try std.testing.expect(ptr == ptr);
    try std.testing.expect(ptr != null_ptr);
    try std.testing.expect(null_ptr == null);
}

test "callback with optional function pointer" {
    var called = false;
    _ = &called;

    // コールバック実行（Optionalなので型安全）
    const cb: ?*const fn (i32) void = &printValue;
    try std.testing.expect(cb != null);
}
