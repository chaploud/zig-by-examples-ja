//! # ポインタ総まとめ
//!
//! Zigのポインタ型の全体像と使い分けをまとめる。
//!
//! ## ポインタ型一覧
//! - *T: 単一要素への非nullポインタ
//! - ?*T: Optionalポインタ（null許可）
//! - [*]T: 複数要素ポインタ（長さ不明）
//! - []T: スライス（ポインタ＋長さ）
//! - [*c]T: C互換ポインタ
//!
//! ## 修飾子
//! - const, volatile, allowzero, addrspace, align

const std = @import("std");

// ====================
// ポインタ型の比較
// ====================

fn demoPointerTypes() void {
    std.debug.print("--- ポインタ型の比較 ---\n", .{});

    var arr = [_]i32{ 10, 20, 30, 40, 50 };
    var single: i32 = 42;

    // *T: 単一要素ポインタ
    const ptr_single: *i32 = &single;
    std.debug.print("  *i32: 単一要素 = {d}\n", .{ptr_single.*});

    // *[N]T: 配列ポインタ
    const ptr_arr: *[5]i32 = &arr;
    std.debug.print("  *[5]i32: 配列全体, len={d}\n", .{ptr_arr.len});

    // []T: スライス
    const slice: []i32 = &arr;
    std.debug.print("  []i32: スライス, len={d}\n", .{slice.len});

    // [*]T: 複数要素ポインタ
    const multi: [*]i32 = &arr;
    std.debug.print("  [*]i32: 複数要素, [0]={d}\n", .{multi[0]});

    // ?*T: Optionalポインタ
    const opt: ?*i32 = &single;
    std.debug.print("  ?*i32: Optional, 非null={}\n", .{opt != null});

    // [*c]T: Cポインタ
    const c_ptr: [*c]i32 = &arr;
    std.debug.print("  [*c]i32: C互換, [0]={d}\n", .{c_ptr[0]});

    std.debug.print("\n", .{});
}

// ====================
// サイズ比較
// ====================

fn demoSizeComparison() void {
    std.debug.print("--- サイズ比較 ---\n", .{});

    std.debug.print("  単一ポインタ:\n", .{});
    std.debug.print("    *i32:        {d} bytes\n", .{@sizeOf(*i32)});
    std.debug.print("    ?*i32:       {d} bytes (ゼロコスト)\n", .{@sizeOf(?*i32)});
    std.debug.print("    *const i32:  {d} bytes\n", .{@sizeOf(*const i32)});

    std.debug.print("  複数要素ポインタ:\n", .{});
    std.debug.print("    [*]i32:      {d} bytes\n", .{@sizeOf([*]i32)});
    std.debug.print("    [*c]i32:     {d} bytes\n", .{@sizeOf([*c]i32)});

    std.debug.print("  スライス:\n", .{});
    std.debug.print("    []i32:       {d} bytes (ptr+len)\n", .{@sizeOf([]i32)});
    std.debug.print("    [:0]i32:     {d} bytes (センチネル)\n", .{@sizeOf([:0]i32)});

    std.debug.print("\n", .{});
}

// ====================
// 修飾子の組み合わせ
// ====================

fn demoModifiers() void {
    std.debug.print("--- 修飾子の組み合わせ ---\n", .{});

    std.debug.print("  const:\n", .{});
    std.debug.print("    *T        → 可変\n", .{});
    std.debug.print("    *const T  → 読み取り専用\n", .{});

    std.debug.print("  volatile:\n", .{});
    std.debug.print("    *volatile T      → 最適化抑制\n", .{});
    std.debug.print("    *const volatile T → 読み取り専用＋最適化抑制\n", .{});

    std.debug.print("  allowzero:\n", .{});
    std.debug.print("    *allowzero T  → アドレス0許可\n", .{});

    std.debug.print("  align:\n", .{});
    std.debug.print("    *align(16) T  → 16バイトアライメント\n", .{});

    std.debug.print("  addrspace:\n", .{});
    std.debug.print("    *addrspace(.generic) T → アドレス空間指定\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 暗黙的な変換
// ====================

fn demoImplicitConversion() void {
    std.debug.print("--- 暗黙的な変換 ---\n", .{});

    var arr = [_]i32{ 1, 2, 3, 4, 5 };

    // 可能な変換
    std.debug.print("  暗黙的に変換可能:\n", .{});

    // *[N]T → []T
    const ptr_arr: *[5]i32 = &arr;
    const slice: []i32 = ptr_arr;
    std.debug.print("    *[5]i32 → []i32: len={d}\n", .{slice.len});

    // *[N]T → [*]T
    const multi: [*]i32 = ptr_arr;
    std.debug.print("    *[5]i32 → [*]i32: [0]={d}\n", .{multi[0]});

    // *T → ?*T
    var val: i32 = 42;
    const ptr: *i32 = &val;
    const opt: ?*i32 = ptr;
    std.debug.print("    *i32 → ?*i32: 非null={}\n", .{opt != null});

    // *T → *const T
    const const_ptr: *const i32 = ptr;
    std.debug.print("    *i32 → *const i32: {d}\n", .{const_ptr.*});

    std.debug.print("\n", .{});
}

// ====================
// 明示的な変換
// ====================

fn demoExplicitConversion() void {
    std.debug.print("--- 明示的な変換 ---\n", .{});

    var arr = [_]i32{ 100, 200, 300 };

    std.debug.print("  @ptrCast: 型変換\n", .{});
    const bytes: [*]u8 = @ptrCast(&arr);
    std.debug.print("    [*]i32 → [*]u8: bytes[0]=0x{x}\n", .{bytes[0]});

    std.debug.print("  @alignCast: アライメント変換\n", .{});
    // 適切なアライメントがある場合のみ使用

    std.debug.print("  @intFromPtr / @ptrFromInt:\n", .{});
    const addr = @intFromPtr(&arr);
    std.debug.print("    ポインタ → 整数: 0x{x}\n", .{addr});

    std.debug.print("\n", .{});
}

// ====================
// 使い分けガイド
// ====================

fn demoUsageGuide() void {
    std.debug.print("--- 使い分けガイド ---\n", .{});

    std.debug.print("  推奨度（高→低）:\n", .{});
    std.debug.print("    1. []T / []const T: 最も安全（境界チェック付き）\n", .{});
    std.debug.print("    2. *T / *const T: 単一要素に最適\n", .{});
    std.debug.print("    3. *[N]T: 固定長配列に最適\n", .{});
    std.debug.print("    4. [*]T: C連携時のみ\n", .{});
    std.debug.print("    5. [*c]T: C連携でnull可能時\n", .{});

    std.debug.print("  特殊用途:\n", .{});
    std.debug.print("    ?*T: null許容が必要な場合\n", .{});
    std.debug.print("    *volatile T: ハードウェアアクセス\n", .{});
    std.debug.print("    *allowzero T: 組み込みシステム\n", .{});
    std.debug.print("    *align(N) T: SIMD/キャッシュ最適化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// よくあるパターン
// ====================

const Node = struct {
    value: i32,
    next: ?*Node,
};

fn demoCommonPatterns() void {
    std.debug.print("--- よくあるパターン ---\n", .{});

    // パターン1: 関数引数
    std.debug.print("  関数引数:\n", .{});
    std.debug.print("    読み取り: []const T または *const T\n", .{});
    std.debug.print("    変更: []T または *T\n", .{});

    // パターン2: 連結リスト
    std.debug.print("  連結リスト: ?*Node で次ノード\n", .{});
    var node2 = Node{ .value = 2, .next = null };
    var node1 = Node{ .value = 1, .next = &node2 };

    var current: ?*Node = &node1;
    var sum: i32 = 0;
    while (current) |n| : (current = n.next) {
        sum += n.value;
    }
    std.debug.print("    合計: {d}\n", .{sum});

    // パターン3: コールバック
    std.debug.print("  コールバック: *const fn(...) T\n", .{});

    // パターン4: スライス渡し
    std.debug.print("  スライス渡し: fn(items: []const T)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// @typeInfo でポインタ解析
// ====================

fn demoTypeInfoPointer() void {
    std.debug.print("--- @typeInfo でポインタ解析 ---\n", .{});

    const types = .{
        "*i32",
        "*const i32",
        "[*]i32",
        "[]i32",
        "?*i32",
    };

    inline for (types) |name| {
        const T = switch (name[0]) {
            '*' => if (name.len > 1 and name[1] == 'c') *const i32 else *i32,
            '[' => if (name[1] == '*') [*]i32 else []i32,
            '?' => ?*i32,
            else => *i32,
        };
        _ = T;
    }

    // 実際の解析例
    const PtrType = *const volatile i32;
    const info = @typeInfo(PtrType).pointer;

    std.debug.print("  *const volatile i32:\n", .{});
    std.debug.print("    size: {s}\n", .{@tagName(info.size)});
    std.debug.print("    is_const: {}\n", .{info.is_const});
    std.debug.print("    is_volatile: {}\n", .{info.is_volatile});
    std.debug.print("    child: i32\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ポインタの安全性
// ====================

fn demoPointerSafety() void {
    std.debug.print("--- ポインタの安全性 ---\n", .{});

    std.debug.print("  Zigの安全機能:\n", .{});
    std.debug.print("    - スライスの境界チェック\n", .{});
    std.debug.print("    - Optionalでnull明示\n", .{});
    std.debug.print("    - constでイミュータビリティ保証\n", .{});
    std.debug.print("    - アライメントチェック\n", .{});

    std.debug.print("  注意点:\n", .{});
    std.debug.print("    - [*]T は境界チェックなし\n", .{});
    std.debug.print("    - @ptrCast は型安全性を失う\n", .{});
    std.debug.print("    - ダングリングポインタに注意\n", .{});
    std.debug.print("    - use-after-freeに注意\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ表
// ====================

fn demoSummaryTable() void {
    std.debug.print("--- まとめ表 ---\n", .{});

    std.debug.print("  型        | 長さ | null | 演算 | 用途\n", .{});
    std.debug.print("  ----------|------|------|------|-------------\n", .{});
    std.debug.print("  *T        | 1    | ×    | ×    | 単一要素参照\n", .{});
    std.debug.print("  ?*T       | 1    | ○    | ×    | null可能参照\n", .{});
    std.debug.print("  *[N]T     | N    | ×    | ×    | 固定配列参照\n", .{});
    std.debug.print("  []T       | 可変 | ×    | ×    | 汎用配列操作\n", .{});
    std.debug.print("  [*]T      | 不明 | ×    | ○    | C連携/低レベル\n", .{});
    std.debug.print("  [*c]T     | 不明 | ○    | ○    | C関数引数\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ポインタ総まとめ ===\n\n", .{});

    demoPointerTypes();
    demoSizeComparison();
    demoModifiers();
    demoImplicitConversion();
    demoExplicitConversion();
    demoUsageGuide();
    demoCommonPatterns();
    demoTypeInfoPointer();
    demoPointerSafety();
    demoSummaryTable();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・スライス []T を優先的に使用\n", .{});
    std.debug.print("・*T は単一要素、*[N]T は固定配列\n", .{});
    std.debug.print("・[*]T はC連携時のみ\n", .{});
    std.debug.print("・修飾子で細かい制御が可能\n", .{});
}

// --- テスト ---

test "pointer type sizes" {
    // 単一ポインタ系は同サイズ
    try std.testing.expectEqual(@sizeOf(*i32), @sizeOf(?*i32));
    try std.testing.expectEqual(@sizeOf(*i32), @sizeOf(*const i32));
    try std.testing.expectEqual(@sizeOf(*i32), @sizeOf([*]i32));

    // スライスはポインタ+長さ
    try std.testing.expectEqual(@sizeOf(*i32) * 2, @sizeOf([]i32));
}

test "implicit conversion *[N]T to []T" {
    var arr = [_]i32{ 1, 2, 3 };
    const ptr_arr: *[3]i32 = &arr;
    const slice: []i32 = ptr_arr;

    try std.testing.expectEqual(@as(usize, 3), slice.len);
}

test "implicit conversion *[N]T to [*]T" {
    var arr = [_]i32{ 10, 20, 30 };
    const ptr_arr: *[3]i32 = &arr;
    const multi: [*]i32 = ptr_arr;

    try std.testing.expectEqual(@as(i32, 10), multi[0]);
    try std.testing.expectEqual(@as(i32, 20), multi[1]);
}

test "implicit conversion *T to ?*T" {
    var val: i32 = 42;
    const ptr: *i32 = &val;
    const opt: ?*i32 = ptr;

    try std.testing.expect(opt != null);
    if (opt) |p| {
        try std.testing.expectEqual(@as(i32, 42), p.*);
    }
}

test "implicit conversion *T to *const T" {
    var val: i32 = 100;
    const ptr: *i32 = &val;
    const const_ptr: *const i32 = ptr;

    try std.testing.expectEqual(@as(i32, 100), const_ptr.*);
}

test "linked list with optional pointer" {
    var node3 = Node{ .value = 30, .next = null };
    var node2 = Node{ .value = 20, .next = &node3 };
    var node1 = Node{ .value = 10, .next = &node2 };

    var current: ?*Node = &node1;
    var count: usize = 0;

    while (current) |n| : (current = n.next) {
        count += 1;
    }

    try std.testing.expectEqual(@as(usize, 3), count);
}

test "pointer typeinfo" {
    const T = *const volatile i32;
    const info = @typeInfo(T).pointer;

    try std.testing.expect(info.is_const);
    try std.testing.expect(info.is_volatile);
    try std.testing.expectEqual(std.builtin.Type.Pointer.Size.one, info.size);
}

test "slice bounds checking" {
    var arr = [_]i32{ 1, 2, 3 };
    const slice: []i32 = &arr;

    // 境界内アクセスは安全
    try std.testing.expectEqual(@as(i32, 1), slice[0]);
    try std.testing.expectEqual(@as(i32, 3), slice[2]);
}

test "c pointer null" {
    const c_ptr: [*c]i32 = null;
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(c_ptr));
}
