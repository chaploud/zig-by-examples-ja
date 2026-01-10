//! # ビルドオプション
//!
//! build.zigでのユーザー提供オプションとコンパイル時設定。
//! 条件付きコンパイルとフィーチャーフラグの実現方法。
//!
//! ## 主要機能
//! - standardOptimizeOption: 最適化レベル選択
//! - standardTargetOptions: ターゲット選択
//! - option: カスタムオプション
//! - @import("build_options"): ソースからオプション参照

const std = @import("std");
const builtin = @import("builtin");

// ====================
// 標準オプション
// ====================

fn demoStandardOptions() void {
    std.debug.print("--- 標準オプション ---\n", .{});

    // build.zigでの記述例:
    // pub fn build(b: *std.Build) void {
    //     const optimize = b.standardOptimizeOption(.{});
    //     const target = b.standardTargetOptions(.{});
    //     ...
    // }

    std.debug.print("  standardOptimizeOption:\n", .{});
    std.debug.print("    zig build -Doptimize=Debug\n", .{});
    std.debug.print("    zig build -Doptimize=ReleaseSafe\n", .{});
    std.debug.print("    zig build -Doptimize=ReleaseFast\n", .{});
    std.debug.print("    zig build -Doptimize=ReleaseSmall\n", .{});

    std.debug.print("  standardTargetOptions:\n", .{});
    std.debug.print("    zig build -Dtarget=x86_64-linux\n", .{});
    std.debug.print("    zig build -Dtarget=aarch64-macos\n", .{});
    std.debug.print("    zig build -Dtarget=x86_64-windows-gnu\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// カスタムオプション
// ====================

fn demoCustomOptions() void {
    std.debug.print("--- カスタムオプション ---\n", .{});

    // build.zigでの記述例:
    // const enable_logging = b.option(
    //     bool,
    //     "enable_logging",
    //     "Enable debug logging",
    // ) orelse false;
    //
    // const log_level = b.option(
    //     enum { debug, info, warn, err },
    //     "log_level",
    //     "Set log level",
    // ) orelse .info;

    std.debug.print("  b.option() パラメータ:\n", .{});
    std.debug.print("    型       - bool, i32, enum, []const u8 など\n", .{});
    std.debug.print("    名前     - コマンドラインで使用\n", .{});
    std.debug.print("    説明     - -h で表示\n", .{});

    std.debug.print("  使用例:\n", .{});
    std.debug.print("    zig build -Denable_logging=true\n", .{});
    std.debug.print("    zig build -Dlog_level=debug\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ソースへのオプション伝達
// ====================

fn demoBuildOptionsModule() void {
    std.debug.print("--- ソースへのオプション伝達 ---\n", .{});

    // build.zigでの記述例:
    // const options = b.addOptions();
    // options.addOption(bool, "enable_logging", enable_logging);
    // options.addOption(u32, "max_connections", max_connections orelse 100);
    //
    // exe.root_module.addOptions("config", options);

    // ソースファイル (main.zig) での使用:
    // const config = @import("config");
    // if (config.enable_logging) {
    //     std.debug.print("Logging enabled\n", .{});
    // }

    std.debug.print("  build.zig側:\n", .{});
    std.debug.print("    const options = b.addOptions();\n", .{});
    std.debug.print("    options.addOption(type, name, value);\n", .{});
    std.debug.print("    exe.root_module.addOptions(\"config\", options);\n", .{});

    std.debug.print("  ソース側:\n", .{});
    std.debug.print("    const config = @import(\"config\");\n", .{});
    std.debug.print("    if (config.enable_logging) { ... }\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 条件付きコンパイル
// ====================

// 実際のコードでの条件付きコンパイル例

fn demoConditionalCompilation() void {
    std.debug.print("--- 条件付きコンパイル ---\n", .{});

    // 最適化モードによる分岐
    switch (builtin.mode) {
        .Debug => std.debug.print("  現在: Debug モード\n", .{}),
        .ReleaseSafe => std.debug.print("  現在: ReleaseSafe モード\n", .{}),
        .ReleaseFast => std.debug.print("  現在: ReleaseFast モード\n", .{}),
        .ReleaseSmall => std.debug.print("  現在: ReleaseSmall モード\n", .{}),
    }

    // OSによる分岐
    std.debug.print("  現在のOS: {s}\n", .{@tagName(builtin.os.tag)});

    // CPUアーキテクチャによる分岐
    std.debug.print("  現在のCPU: {s}\n", .{@tagName(builtin.cpu.arch)});

    std.debug.print("\n", .{});
}

// ====================
// フィーチャーフラグパターン
// ====================

fn demoFeatureFlags() void {
    std.debug.print("--- フィーチャーフラグ ---\n", .{});

    // build.zigでの典型的なパターン:
    // const features = struct {
    //     enable_ssl: bool = true,
    //     enable_compression: bool = false,
    //     max_threads: u32 = 4,
    // };
    //
    // const ssl = b.option(bool, "ssl", "Enable SSL") orelse features.enable_ssl;
    // const compression = b.option(bool, "compression", "Enable compression") orelse features.enable_compression;

    std.debug.print("  典型的なフィーチャー:\n", .{});
    std.debug.print("    -Dssl=true          - SSL有効化\n", .{});
    std.debug.print("    -Dcompression=true  - 圧縮有効化\n", .{});
    std.debug.print("    -Dmax_threads=8     - スレッド数設定\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 環境変数との連携
// ====================

fn demoEnvironmentVars() void {
    std.debug.print("--- 環境変数 ---\n", .{});

    // build.zigでの記述例:
    // const env_value = b.graph.env_map.get("MY_CONFIG");
    // const config_path = env_value orelse "/etc/myapp/config";

    std.debug.print("  環境変数の取得:\n", .{});
    std.debug.print("    b.graph.env_map.get(\"VAR_NAME\")\n", .{});

    // 実際に環境変数を読む例
    const path = std.posix.getenv("PATH");
    if (path) |p| {
        // 最初の50文字だけ表示
        const display_len = @min(p.len, 50);
        std.debug.print("  PATH (先頭): {s}...\n", .{p[0..display_len]});
    }

    std.debug.print("\n", .{});
}

// ====================
// デバッグビルド用設定
// ====================

fn demoDebugSettings() void {
    std.debug.print("--- デバッグビルド設定 ---\n", .{});

    // build.zigでの記述例:
    // if (optimize == .Debug) {
    //     exe.root_module.addOptions("debug", debug_options);
    //     exe.root_module.addCSourceFile(.{
    //         .file = b.path("src/debug_helpers.c"),
    //     });
    // }

    std.debug.print("  Debugモード専用設定:\n", .{});
    std.debug.print("    追加のログ出力\n", .{});
    std.debug.print("    デバッグヘルパー関数\n", .{});
    std.debug.print("    アサーションの有効化\n", .{});

    std.debug.print("  Releaseモード専用設定:\n", .{});
    std.debug.print("    最適化の有効化\n", .{});
    std.debug.print("    デバッグ情報の除去\n", .{});
    std.debug.print("    LTOの有効化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  オプションの種類:\n", .{});
    std.debug.print("    標準オプション - optimize, target\n", .{});
    std.debug.print("    カスタムオプション - b.option()\n", .{});

    std.debug.print("  ソースへの伝達:\n", .{});
    std.debug.print("    b.addOptions() + addOption()\n", .{});
    std.debug.print("    @import(\"config\") で参照\n", .{});

    std.debug.print("  条件付きコンパイル:\n", .{});
    std.debug.print("    std.builtin.mode\n", .{});
    std.debug.print("    @import(\"builtin\")\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ビルドオプション ===\n\n", .{});

    demoStandardOptions();
    demoCustomOptions();
    demoBuildOptionsModule();
    demoConditionalCompilation();
    demoFeatureFlags();
    demoEnvironmentVars();
    demoDebugSettings();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・オプションはzig build -hで一覧表示\n", .{});
    std.debug.print("・デフォルト値を設定して使いやすく\n", .{});
    std.debug.print("・条件付きコンパイルでコードサイズ削減\n", .{});
    std.debug.print("・@import(\"builtin\")で実行環境情報取得\n", .{});
}

// --- テスト ---

test "builtin mode check" {
    // テスト実行時は通常Debugモード
    try std.testing.expect(builtin.mode == .Debug or
        builtin.mode == .ReleaseSafe or
        builtin.mode == .ReleaseFast or
        builtin.mode == .ReleaseSmall);
}

test "builtin os check" {
    // 何らかのOSで実行されている
    try std.testing.expect(builtin.os.tag == .linux or
        builtin.os.tag == .macos or
        builtin.os.tag == .windows or
        builtin.os.tag == .freebsd or
        builtin.os.tag == .freestanding);
}

test "builtin arch check" {
    // 何らかのアーキテクチャで実行されている
    try std.testing.expect(builtin.cpu.arch == .x86_64 or
        builtin.cpu.arch == .aarch64 or
        builtin.cpu.arch == .x86 or
        builtin.cpu.arch == .arm or
        builtin.cpu.arch == .riscv64 or
        builtin.cpu.arch == .wasm32);
}

test "conditional debug code" {
    // Debugモードでのみ実行されるコード例
    if (builtin.mode == .Debug) {
        // デバッグ専用のアサーション
        std.debug.assert(1 + 1 == 2);
    }
    try std.testing.expect(true);
}
