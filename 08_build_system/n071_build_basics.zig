//! # ビルドシステム基礎
//!
//! Zigのビルドシステム（build.zig）の基本概念。
//! zig buildコマンドで使用するbuild.zigの書き方。
//!
//! ## 重要概念
//! - build.zig: ビルド設定ファイル
//! - std.Build: ビルドAPI
//! - ターゲット: 実行可能/ライブラリ
//! - ステップ: ビルドの各段階
//!
//! 注: このファイルはbuild.zigの概念説明用

const std = @import("std");

// ====================
// build.zigの基本構造
// ====================

// 以下はbuild.zigで使用するパターンの説明

// build.zig は以下の形式:
//
// const std = @import("std");
//
// pub fn build(b: *std.Build) void {
//     // ビルド設定をここに記述
// }

// ====================
// ターゲットの種類
// ====================

fn demoTargetTypes() void {
    std.debug.print("--- ターゲットの種類 ---\n", .{});

    std.debug.print("  addExecutable()     - 実行可能ファイル\n", .{});
    std.debug.print("  addStaticLibrary()  - 静的ライブラリ (.a)\n", .{});
    std.debug.print("  addSharedLibrary() - 動的ライブラリ (.so/.dylib)\n", .{});
    std.debug.print("  addObject()         - オブジェクトファイル (.o)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実行可能ターゲット例
// ====================

fn demoExecutableTarget() void {
    std.debug.print("--- 実行可能ターゲット ---\n", .{});

    // build.zigでの記述例:
    // const exe = b.addExecutable(.{
    //     .name = "my_app",
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/main.zig"),
    //     }),
    //     .target = b.graph.host,
    //     .optimize = .Debug,
    // });
    // b.installArtifact(exe);

    std.debug.print("  .name             - 出力ファイル名\n", .{});
    std.debug.print("  .root_source_file - メインソース\n", .{});
    std.debug.print("  .target           - ターゲットプラットフォーム\n", .{});
    std.debug.print("  .optimize         - 最適化レベル\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 最適化レベル
// ====================

fn demoOptimizeLevels() void {
    std.debug.print("--- 最適化レベル ---\n", .{});

    std.debug.print("  .Debug          - デバッグ情報付き、最適化なし\n", .{});
    std.debug.print("  .ReleaseSafe    - 安全性チェック付き最適化\n", .{});
    std.debug.print("  .ReleaseFast    - 最大パフォーマンス\n", .{});
    std.debug.print("  .ReleaseSmall   - 最小バイナリサイズ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// クロスコンパイル
// ====================

fn demoCrossCompile() void {
    std.debug.print("--- クロスコンパイル ---\n", .{});

    // build.zigでの記述例:
    // const target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    // });
    // const exe = b.addExecutable(.{
    //     .target = target,
    //     ...
    // });

    std.debug.print("  ホストマシン: b.graph.host\n", .{});
    std.debug.print("  指定ターゲット: b.resolveTargetQuery(...)\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("  例: x86_64-linux\n", .{});
    std.debug.print("  例: aarch64-macos\n", .{});
    std.debug.print("  例: x86_64-windows\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ビルドステップ
// ====================

fn demoBuildSteps() void {
    std.debug.print("--- ビルドステップ ---\n", .{});

    // build.zigでの記述例:
    // const run_cmd = b.addRunArtifact(exe);
    // const run_step = b.step("run", "Run the application");
    // run_step.dependOn(&run_cmd.step);

    std.debug.print("  デフォルトステップ:\n", .{});
    std.debug.print("    zig build         - default ステップ\n", .{});
    std.debug.print("    zig build install - インストール\n", .{});

    std.debug.print("  カスタムステップ:\n", .{});
    std.debug.print("    zig build run     - 実行\n", .{});
    std.debug.print("    zig build test    - テスト実行\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// テストの追加
// ====================

fn demoAddTests() void {
    std.debug.print("--- テストの追加 ---\n", .{});

    // build.zigでの記述例:
    // const unit_tests = b.addTest(.{
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/main.zig"),
    //     }),
    // });
    // const run_tests = b.addRunArtifact(unit_tests);
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_tests.step);

    std.debug.print("  addTest()         - テストターゲット作成\n", .{});
    std.debug.print("  addRunArtifact()  - 実行ステップ作成\n", .{});
    std.debug.print("  step()            - カスタムステップ定義\n", .{});
    std.debug.print("  dependOn()        - 依存関係設定\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 依存関係の追加
// ====================

fn demoDependencies() void {
    std.debug.print("--- 依存関係 ---\n", .{});

    // build.zigでの記述例:
    // const dep = b.dependency("some_package", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe.root_module.addImport("some_package", dep.module("some_package"));

    std.debug.print("  dependency()  - 外部パッケージ取得\n", .{});
    std.debug.print("  addImport()   - モジュールをインポート\n", .{});
    std.debug.print("  linkLibrary() - ライブラリをリンク\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Cライブラリリンク
// ====================

fn demoCLinking() void {
    std.debug.print("--- Cライブラリリンク ---\n", .{});

    // build.zigでの記述例:
    // exe.linkLibC();  // libc
    // exe.linkSystemLibrary("pthread");

    std.debug.print("  linkLibC()           - libc をリンク\n", .{});
    std.debug.print("  linkSystemLibrary()  - システムライブラリ\n", .{});
    std.debug.print("  addIncludePath()     - ヘッダパス追加\n", .{});
    std.debug.print("  addLibraryPath()     - ライブラリパス追加\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ビルドオプション
// ====================

fn demoBuildOptions() void {
    std.debug.print("--- ビルドオプション ---\n", .{});

    // build.zigでの記述例:
    // const optimize = b.standardOptimizeOption(.{});
    // const target = b.standardTargetOptions(.{});

    std.debug.print("  コマンドライン引数:\n", .{});
    std.debug.print("    zig build -Doptimize=ReleaseFast\n", .{});
    std.debug.print("    zig build -Dtarget=x86_64-linux\n", .{});

    std.debug.print("  カスタムオプション:\n", .{});
    std.debug.print("    const debug = b.option(bool, \"debug\", \"Enable debug\");\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  build.zigの役割:\n", .{});
    std.debug.print("    - ビルド設定を宣言的に記述\n", .{});
    std.debug.print("    - クロスコンパイル対応\n", .{});
    std.debug.print("    - 依存関係管理\n", .{});
    std.debug.print("    - テスト統合\n", .{});

    std.debug.print("  主要コマンド:\n", .{});
    std.debug.print("    zig build        - ビルド実行\n", .{});
    std.debug.print("    zig build run    - ビルド+実行\n", .{});
    std.debug.print("    zig build test   - テスト実行\n", .{});
    std.debug.print("    zig build -h     - ヘルプ表示\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ビルドシステム基礎 ===\n\n", .{});

    demoTargetTypes();
    demoExecutableTarget();
    demoOptimizeLevels();
    demoCrossCompile();
    demoBuildSteps();
    demoAddTests();
    demoDependencies();
    demoCLinking();
    demoBuildOptions();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・build.zigはZig言語で記述\n", .{});
    std.debug.print("・Makefileの代替として機能\n", .{});
    std.debug.print("・クロスコンパイルが標準サポート\n", .{});
    std.debug.print("・zig init で雛形生成可能\n", .{});
}

// --- テスト ---
// build.zigの機能をテストするには実際のプロジェクトが必要
// ここでは概念の確認用テストのみ

test "optimize levels are valid" {
    // 最適化レベルの列挙型確認
    const levels = [_]std.builtin.OptimizeMode{
        .Debug,
        .ReleaseSafe,
        .ReleaseFast,
        .ReleaseSmall,
    };

    try std.testing.expectEqual(@as(usize, 4), levels.len);
}

test "target architectures" {
    // アーキテクチャの確認
    const arch = std.Target.Cpu.Arch.x86_64;
    try std.testing.expectEqual(std.Target.Cpu.Arch.x86_64, arch);
}

test "os tags" {
    // OSタグの確認
    const os = std.Target.Os.Tag.linux;
    try std.testing.expect(os == .linux);
}
