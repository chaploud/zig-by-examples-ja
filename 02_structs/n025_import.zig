//! # @import とモジュール
//!
//! Zigでは@importを使って他のファイルや標準ライブラリを読み込む。
//! 各.zigファイルは暗黙的にモジュール。
//!
//! ## 基本
//! - @import("std") で標準ライブラリ
//! - @import("file.zig") でローカルファイル
//! - pubで公開、なしで非公開

const std = @import("std");

// ====================
// 標準ライブラリのインポート
// ====================

// std から特定のモジュールを取り出す
const mem = std.mem;
const fmt = std.fmt;
const testing = std.testing;
const math = std.math;

// ====================
// 組み込みモジュール
// ====================

// @import("builtin") でビルド情報を取得
const builtin = @import("builtin");

fn showBuiltinInfo() void {
    std.debug.print("--- ビルド情報 (@import(\"builtin\")) ---\n", .{});

    // CPUアーキテクチャ
    std.debug.print("CPU: {s}\n", .{@tagName(builtin.cpu.arch)});

    // OS
    std.debug.print("OS: {s}\n", .{@tagName(builtin.os.tag)});

    // 最適化モード
    std.debug.print("最適化: {s}\n", .{@tagName(builtin.mode)});

    // デバッグビルドかどうか
    if (builtin.mode == .Debug) {
        std.debug.print("デバッグビルド\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// pubキーワード
// ====================

// pub: 他のファイルから参照可能
pub const PublicConstant: i32 = 42;

// pubなし: このファイル内でのみ使用可能
const PrivateConstant: i32 = 100;

// pub struct
pub const Point = struct {
    x: i32,
    y: i32,

    // pubメソッド
    pub fn distance(self: Point, other: Point) f64 {
        const dx: f64 = @floatFromInt(self.x - other.x);
        const dy: f64 = @floatFromInt(self.y - other.y);
        return @sqrt(dx * dx + dy * dy);
    }

    // 非pubメソッド（このモジュール内でのみ使用可能）
    fn privateHelper(self: Point) i32 {
        return self.x + self.y;
    }
};

// pub fn
pub fn publicFunction() void {
    std.debug.print("publicFunction() が呼ばれました\n", .{});
}

fn privateFunction() void {
    std.debug.print("privateFunction() が呼ばれました\n", .{});
}

// ====================
// 名前空間としてのstruct
// ====================

pub const MathUtils = struct {
    pub const PI: f64 = 3.14159265358979;
    pub const E: f64 = 2.71828182845904;

    pub fn square(x: f64) f64 {
        return x * x;
    }

    pub fn cube(x: f64) f64 {
        return x * x * x;
    }

    pub fn clamp(value: f64, min_val: f64, max_val: f64) f64 {
        return @max(min_val, @min(max_val, value));
    }
};

// ====================
// 遅延評価（usingnamespace風）
// ====================

// 必要な時だけコンパイルされる
fn lazyEvalDemo() void {
    // 使用されなければコンパイルされない
    _ = struct {
        fn unused() void {
            @compileError("This should not be compiled");
        }
    };
}

// ====================
// std の主要モジュール紹介
// ====================

fn stdModulesDemo() void {
    std.debug.print("--- std の主要モジュール ---\n", .{});

    // std.mem: メモリ操作
    const str1 = "hello";
    const str2 = "hello";
    std.debug.print("std.mem.eql: {s} == {s} ? {}\n", .{ str1, str2, mem.eql(u8, str1, str2) });

    // std.math: 数学関数
    std.debug.print("std.math.sqrt(16) = {d}\n", .{math.sqrt(@as(f64, 16))});
    std.debug.print("std.math.pow(2, 10) = {d}\n", .{math.pow(f64, 2, 10)});

    // std.fmt: フォーマット
    var buffer: [100]u8 = undefined;
    const formatted = fmt.bufPrint(&buffer, "x={d}, y={d}", .{ 10, 20 }) catch "error";
    std.debug.print("std.fmt.bufPrint: {s}\n", .{formatted});

    std.debug.print("\n", .{});
}

// ====================
// @embedFile
// ====================

// @embedFile でファイル内容をバイナリに埋め込む（コンパイル時）
// const embedded_data = @embedFile("data.txt");

// ====================
// @This() の活用
// ====================

pub const Counter = struct {
    value: i32,

    // @This() で自身の型を参照
    const Self = @This();

    pub fn init(start: i32) Self {
        return Self{ .value = start };
    }

    pub fn increment(self: *Self) void {
        self.value += 1;
    }

    pub fn get(self: Self) i32 {
        return self.value;
    }
};

// ====================
// 条件付きインポート
// ====================

fn conditionalImportDemo() void {
    std.debug.print("--- 条件付きコンパイル ---\n", .{});

    // OS依存の処理
    if (builtin.os.tag == .macos) {
        std.debug.print("macOS固有の処理\n", .{});
    } else if (builtin.os.tag == .linux) {
        std.debug.print("Linux固有の処理\n", .{});
    } else if (builtin.os.tag == .windows) {
        std.debug.print("Windows固有の処理\n", .{});
    } else {
        std.debug.print("その他のOS\n", .{});
    }

    // デバッグビルドでのみ有効
    if (builtin.mode == .Debug) {
        std.debug.print("デバッグ専用コード\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// ファイル構造の例
// ====================

fn fileStructureExample() void {
    std.debug.print("--- ファイル構造の例 ---\n", .{});
    std.debug.print(
        \\典型的なプロジェクト構造:
        \\
        \\  project/
        \\  ├── build.zig       # ビルド設定
        \\  ├── src/
        \\  │   ├── main.zig    # エントリポイント
        \\  │   ├── lib.zig     # ライブラリのルート
        \\  │   ├── utils/
        \\  │   │   ├── math.zig
        \\  │   │   └── string.zig
        \\  │   └── types/
        \\  │       └── point.zig
        \\  └── tests/
        \\      └── test_main.zig
        \\
    , .{});

    std.debug.print(
        \\インポート例:
        \\  const std = @import("std");
        \\  const math = @import("utils/math.zig");
        \\  const Point = @import("types/point.zig").Point;
        \\
    , .{});
    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== @import とモジュール ===\n\n", .{});

    showBuiltinInfo();

    // ====================
    // pubの確認
    // ====================

    std.debug.print("--- pub/非pub ---\n", .{});
    std.debug.print("PublicConstant = {d}\n", .{PublicConstant});
    std.debug.print("PrivateConstant = {d}\n", .{PrivateConstant}); // 同ファイル内なのでOK

    publicFunction();
    privateFunction(); // 同ファイル内なのでOK

    const p1 = Point{ .x = 0, .y = 0 };
    const p2 = Point{ .x = 3, .y = 4 };
    std.debug.print("距離: {d:.1}\n", .{p1.distance(p2)});
    std.debug.print("privateHelper: {d}\n", .{p1.privateHelper()}); // 同ファイル内なのでOK

    std.debug.print("\n", .{});

    // ====================
    // 名前空間
    // ====================

    std.debug.print("--- 名前空間としてのstruct ---\n", .{});
    std.debug.print("MathUtils.PI = {d:.5}\n", .{MathUtils.PI});
    std.debug.print("MathUtils.square(3) = {d}\n", .{MathUtils.square(3)});
    std.debug.print("MathUtils.clamp(15, 0, 10) = {d}\n", .{MathUtils.clamp(15, 0, 10)});
    std.debug.print("\n", .{});

    stdModulesDemo();
    conditionalImportDemo();
    fileStructureExample();

    // ====================
    // Counter
    // ====================

    std.debug.print("--- @This() の活用 ---\n", .{});
    var counter = Counter.init(0);
    counter.increment();
    counter.increment();
    std.debug.print("Counter.get() = {d}\n", .{counter.get()});
    std.debug.print("\n", .{});

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・@import(\"std\"): 標準ライブラリ\n", .{});
    std.debug.print("・@import(\"file.zig\"): ローカルファイル\n", .{});
    std.debug.print("・@import(\"builtin\"): ビルド情報\n", .{});
    std.debug.print("・pub: 外部に公開\n", .{});
    std.debug.print("・@This(): 自身の型を取得\n", .{});
}

// --- テスト ---

test "Point distance" {
    const p1 = Point{ .x = 0, .y = 0 };
    const p2 = Point{ .x = 3, .y = 4 };
    try testing.expect(@abs(p1.distance(p2) - 5.0) < 0.001);
}

test "MathUtils" {
    try testing.expect(@abs(MathUtils.PI - 3.14159) < 0.001);
    try testing.expect(@abs(MathUtils.square(3) - 9.0) < 0.001);
    try testing.expect(@abs(MathUtils.cube(2) - 8.0) < 0.001);
    try testing.expect(@abs(MathUtils.clamp(15, 0, 10) - 10.0) < 0.001);
    try testing.expect(@abs(MathUtils.clamp(-5, 0, 10) - 0.0) < 0.001);
}

test "Counter" {
    var counter = Counter.init(0);
    try testing.expectEqual(@as(i32, 0), counter.get());

    counter.increment();
    try testing.expectEqual(@as(i32, 1), counter.get());

    counter.increment();
    counter.increment();
    try testing.expectEqual(@as(i32, 3), counter.get());
}

test "std.mem.eql" {
    try testing.expect(mem.eql(u8, "hello", "hello"));
    try testing.expect(!mem.eql(u8, "hello", "world"));
}

test "std.math" {
    try testing.expect(@abs(math.sqrt(@as(f64, 16)) - 4.0) < 0.001);
    try testing.expect(@abs(math.pow(f64, 2, 3) - 8.0) < 0.001);
}

test "builtin info available" {
    // builtinモジュールが正しくインポートされていることを確認
    _ = builtin.cpu.arch;
    _ = builtin.os.tag;
    _ = builtin.mode;
}

test "fmt.bufPrint" {
    var buffer: [50]u8 = undefined;
    const result = fmt.bufPrint(&buffer, "value={d}", .{42}) catch unreachable;
    try testing.expect(mem.eql(u8, result, "value=42"));
}
