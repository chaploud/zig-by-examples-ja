//! # ポインタ
//!
//! ポインタはメモリアドレスを格納するオブジェクト。
//! Cに似ているが、Zigでは追加の安全性を提供。
//!
//! ## ポインタの種類
//! - *T: 単一要素ポインタ
//! - *const T: 定数へのポインタ
//! - [*]T: 複数要素ポインタ
//!
//! ## 演算子
//! - &: アドレス取得
//! - .*: 参照外し（デリファレンス）

const std = @import("std");

// ====================
// 基本的なポインタ
// ====================

fn demoBasicPointers() void {
    std.debug.print("--- 基本的なポインタ ---\n", .{});

    const number: u8 = 42;

    // &でアドレスを取得
    const ptr = &number;

    std.debug.print("  number = {d}\n", .{number});
    std.debug.print("  ptr = 0x{x}\n", .{@intFromPtr(ptr)});

    // .*で参照外し
    const value = ptr.*;
    std.debug.print("  ptr.* = {d}\n", .{value});

    // ポインタの型
    std.debug.print("  型: {any}\n", .{@TypeOf(ptr)});

    std.debug.print("\n", .{});
}

// ====================
// ポインタ経由での変更
// ====================

fn demoModifyThroughPointer() void {
    std.debug.print("--- ポインタ経由での変更 ---\n", .{});

    var number: u8 = 10;
    const ptr = &number;

    std.debug.print("  変更前: {d}\n", .{number});

    // ポインタ経由で値を変更
    ptr.* = 20;

    std.debug.print("  変更後: {d}\n", .{number});

    // 加算
    ptr.* += 5;
    std.debug.print("  +5後: {d}\n", .{number});

    std.debug.print("\n", .{});
}

// ====================
// const vs var ポインタ
// ====================

fn demoConstVsVarPointers() void {
    std.debug.print("--- const vs var ポインタ ---\n", .{});

    // 定数への定数ポインタ
    const c1: u8 = 10;
    const ptr_to_const = &c1;
    std.debug.print("  ptr_to_const.* = {d}\n", .{ptr_to_const.*});
    // ptr_to_const.* = 20; // エラー: 定数は変更不可

    // 変数への変更可能ポインタ
    var v1: u8 = 30;
    const ptr_to_var = &v1;
    ptr_to_var.* = 40;
    std.debug.print("  ptr_to_var.* = {d} (変更後)\n", .{ptr_to_var.*});

    // ポインタ自体を変更可能に
    const c2: u8 = 50;
    var changeable_ptr = &c1;
    std.debug.print("  changeable_ptr.* = {d}\n", .{changeable_ptr.*});
    changeable_ptr = &c2;
    std.debug.print("  再代入後: {d}\n", .{changeable_ptr.*});

    std.debug.print("  型の違い:\n", .{});
    std.debug.print("    *const T: 定数へのポインタ（値変更不可）\n", .{});
    std.debug.print("    *T: 変数へのポインタ（値変更可）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 単一要素 vs 複数要素ポインタ
// ====================

fn demoPointerTypes() void {
    std.debug.print("--- 単一要素 vs 複数要素ポインタ ---\n", .{});

    // 単一要素ポインタ (*T)
    const single: u32 = 100;
    const single_ptr: *const u32 = &single;
    std.debug.print("  *T (単一要素): {d}\n", .{single_ptr.*});

    // 複数要素ポインタ ([*]T)
    const arr = [_]i32{ 10, 20, 30, 40, 50 };
    const multi_ptr: [*]const i32 = &arr;
    std.debug.print("  [*]T (複数要素):\n", .{});
    std.debug.print("    multi_ptr[0] = {d}\n", .{multi_ptr[0]});
    std.debug.print("    multi_ptr[2] = {d}\n", .{multi_ptr[2]});
    std.debug.print("    multi_ptr[4] = {d}\n", .{multi_ptr[4]});

    // 配列へのポインタ (*[N]T)
    const arr_ptr: *const [5]i32 = &arr;
    std.debug.print("  *[N]T (配列へのポインタ): len={d}\n", .{arr_ptr.len});

    std.debug.print("\n", .{});
}

// ====================
// ポインタ演算
// ====================

fn demoPointerArithmetic() void {
    std.debug.print("--- ポインタ演算 ---\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    var ptr: [*]const i32 = &arr;

    std.debug.print("  初期位置:\n", .{});
    std.debug.print("    ptr[0] = {d}\n", .{ptr[0]});

    // ポインタを進める
    ptr += 1;
    std.debug.print("  +1後:\n", .{});
    std.debug.print("    ptr[0] = {d}\n", .{ptr[0]});

    ptr += 2;
    std.debug.print("  +2後:\n", .{});
    std.debug.print("    ptr[0] = {d}\n", .{ptr[0]});

    // 戻る
    ptr -= 1;
    std.debug.print("  -1後:\n", .{});
    std.debug.print("    ptr[0] = {d}\n", .{ptr[0]});

    std.debug.print("  → スライスの使用を推奨\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// スライス vs ポインタ演算
// ====================

fn demoSlicesVsPointers() void {
    std.debug.print("--- スライス vs ポインタ演算 ---\n", .{});

    const arr = [_]i32{ 10, 20, 30, 40, 50 };

    // ポインタ演算（非推奨）
    const ptr: [*]const i32 = &arr;
    std.debug.print("  ポインタ演算:\n", .{});
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        std.debug.print("    ptr[{d}] = {d}\n", .{ i, ptr[i] });
    }

    // スライス（推奨）
    const slice = arr[0..arr.len];
    std.debug.print("  スライス（推奨）:\n", .{});
    for (slice, 0..) |val, idx| {
        std.debug.print("    slice[{d}] = {d}\n", .{ idx, val });
    }

    std.debug.print("  → スライスは境界チェック付き\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Optionalポインタ
// ====================

fn demoOptionalPointers() void {
    std.debug.print("--- Optionalポインタ ---\n", .{});

    const value: u8 = 42;
    var opt_ptr: ?*const u8 = &value;

    // nullチェック
    if (opt_ptr) |ptr| {
        std.debug.print("  opt_ptr.* = {d}\n", .{ptr.*});
    } else {
        std.debug.print("  opt_ptr is null\n", .{});
    }

    // nullに設定
    opt_ptr = null;
    if (opt_ptr) |_| {
        std.debug.print("  ここには来ない\n", .{});
    } else {
        std.debug.print("  opt_ptr is null\n", .{});
    }

    // orelseでデフォルト
    const default_val: u8 = 0;
    const ptr = opt_ptr orelse &default_val;
    std.debug.print("  orelse後: {d}\n", .{ptr.*});

    std.debug.print("  → CのnullポインタよりOptionalで安全に\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体とポインタ
// ====================

const User = struct {
    id: u32,
    name: []const u8,

    pub fn greet(self: *const User) void {
        std.debug.print("Hello, I'm {s}!\n", .{self.name});
    }

    pub fn set_id(self: *User, new_id: u32) void {
        self.id = new_id;
    }
};

fn demoStructPointers() void {
    std.debug.print("--- 構造体とポインタ ---\n", .{});

    var user = User{ .id = 1, .name = "Alice" };
    const ptr = &user;

    // ポインタ経由でフィールドアクセス
    std.debug.print("  ptr.*.id = {d}\n", .{ptr.*.id});
    std.debug.print("  ptr.*.name = {s}\n", .{ptr.*.name});

    // 自動参照外し（Zigの便利機能）
    std.debug.print("  ptr.id = {d} (自動参照外し)\n", .{ptr.id});
    std.debug.print("  ptr.name = {s}\n", .{ptr.name});

    // メソッド呼び出し
    std.debug.print("  メソッド: ", .{});
    ptr.greet();

    // ポインタ経由での変更
    ptr.set_id(100);
    std.debug.print("  変更後: id = {d}\n", .{user.id});

    std.debug.print("\n", .{});
}

// ====================
// ポインタの比較
// ====================

fn demoPointerComparison() void {
    std.debug.print("--- ポインタの比較 ---\n", .{});

    var a: u32 = 10;
    var b: u32 = 10;

    const ptr_a1 = &a;
    const ptr_a2 = &a;
    const ptr_b = &b;

    // 同じオブジェクトを指す
    std.debug.print("  ptr_a1 == ptr_a2: {}\n", .{ptr_a1 == ptr_a2});

    // 異なるオブジェクト（値は同じ）
    std.debug.print("  ptr_a1 == ptr_b: {}\n", .{ptr_a1 == ptr_b});

    // 値の比較は参照外しで
    std.debug.print("  ptr_a1.* == ptr_b.*: {}\n", .{ptr_a1.* == ptr_b.*});

    std.debug.print("\n", .{});
}

// ====================
// @intFromPtr / @ptrFromInt
// ====================

fn demoIntPtrConversion() void {
    std.debug.print("--- @intFromPtr / @ptrFromInt ---\n", .{});

    var value: u32 = 12345;
    const ptr = &value;

    // ポインタから整数へ
    const addr = @intFromPtr(ptr);
    std.debug.print("  アドレス: 0x{x}\n", .{addr});

    // 整数からポインタへ（危険、デバッグ用）
    const restored: *u32 = @ptrFromInt(addr);
    std.debug.print("  復元後の値: {d}\n", .{restored.*});

    std.debug.print("  → @ptrFromIntは危険、通常は使用しない\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ポインタ ===\n\n", .{});

    demoBasicPointers();
    demoModifyThroughPointer();
    demoConstVsVarPointers();
    demoPointerTypes();
    demoPointerArithmetic();
    demoSlicesVsPointers();
    demoOptionalPointers();
    demoStructPointers();
    demoPointerComparison();
    demoIntPtrConversion();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・&でアドレス取得、.*で参照外し\n", .{});
    std.debug.print("・*T: 単一要素、[*]T: 複数要素\n", .{});
    std.debug.print("・*const T: 変更不可、*T: 変更可\n", .{});
    std.debug.print("・スライスはポインタ演算より安全\n", .{});
    std.debug.print("・Optional(?*T)でnull安全\n", .{});
}

// --- テスト ---

test "basic pointer dereferencing" {
    const num: u8 = 42;
    const ptr = &num;
    try std.testing.expectEqual(@as(u8, 42), ptr.*);
}

test "modify through pointer" {
    var num: u8 = 10;
    const ptr = &num;
    ptr.* = 20;
    try std.testing.expectEqual(@as(u8, 20), num);
}

test "pointer type const" {
    const val: u32 = 100;
    const ptr = &val;
    // ptr.*は変更不可（コンパイルエラーになる）
    try std.testing.expectEqual(*const u32, @TypeOf(ptr));
}

test "pointer type mutable" {
    var val: u32 = 100;
    const ptr = &val;
    try std.testing.expectEqual(*u32, @TypeOf(ptr));
}

test "multi-element pointer" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    const multi_ptr: [*]const i32 = &arr;

    try std.testing.expectEqual(@as(i32, 1), multi_ptr[0]);
    try std.testing.expectEqual(@as(i32, 3), multi_ptr[2]);
    try std.testing.expectEqual(@as(i32, 5), multi_ptr[4]);
}

test "pointer arithmetic" {
    const arr = [_]i32{ 10, 20, 30 };
    var ptr: [*]const i32 = &arr;

    try std.testing.expectEqual(@as(i32, 10), ptr[0]);
    ptr += 1;
    try std.testing.expectEqual(@as(i32, 20), ptr[0]);
    ptr += 1;
    try std.testing.expectEqual(@as(i32, 30), ptr[0]);
}

test "optional pointer unwrap" {
    const val: u8 = 42;
    const opt_ptr: ?*const u8 = &val;

    try std.testing.expect(opt_ptr != null);
    if (opt_ptr) |ptr| {
        try std.testing.expectEqual(@as(u8, 42), ptr.*);
    }
}

test "optional pointer null" {
    const opt_ptr: ?*const u8 = null;
    try std.testing.expect(opt_ptr == null);
}

test "struct auto-deref" {
    const user = User{ .id = 1, .name = "Test" };
    const ptr = &user;

    // 自動参照外し
    try std.testing.expectEqual(@as(u32, 1), ptr.id);
    try std.testing.expect(std.mem.eql(u8, "Test", ptr.name));
}

test "pointer comparison" {
    var a: u32 = 10;
    var b: u32 = 10;

    const ptr_a1 = &a;
    const ptr_a2 = &a;
    const ptr_b = &b;

    try std.testing.expect(ptr_a1 == ptr_a2);
    try std.testing.expect(ptr_a1 != ptr_b);
    try std.testing.expect(ptr_a1.* == ptr_b.*);
}

test "intFromPtr roundtrip" {
    var val: u32 = 999;
    const ptr = &val;
    const addr = @intFromPtr(ptr);
    const restored: *u32 = @ptrFromInt(addr);

    try std.testing.expectEqual(@as(u32, 999), restored.*);
}
