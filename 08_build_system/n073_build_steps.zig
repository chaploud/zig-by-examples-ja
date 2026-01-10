//! # ビルドステップ
//!
//! build.zigにおけるステップ（step）の概念と依存関係。
//! カスタムビルドステップの作成と連携方法。
//!
//! ## 主要概念
//! - Step: ビルドプロセスの単位
//! - dependOn: ステップ間の依存関係
//! - installArtifact: 成果物のインストール
//! - addRunArtifact: 実行ステップ作成

const std = @import("std");

// ====================
// ステップの基本概念
// ====================

fn demoStepConcept() void {
    std.debug.print("--- ステップの基本概念 ---\n", .{});

    // build.zigでの典型的なステップ構成:
    //
    // build (default)
    //    └── install
    //         └── exe compilation
    //
    // run
    //    └── install
    //         └── exe compilation
    //
    // test
    //    └── unit tests compilation

    std.debug.print("  ステップの種類:\n", .{});
    std.debug.print("    default    - zig build で実行\n", .{});
    std.debug.print("    install    - 成果物インストール\n", .{});
    std.debug.print("    run        - 実行ステップ\n", .{});
    std.debug.print("    test       - テストステップ\n", .{});
    std.debug.print("    カスタム   - 任意の名前\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ステップの作成
// ====================

fn demoCreateSteps() void {
    std.debug.print("--- ステップの作成 ---\n", .{});

    // build.zigでの記述例:
    //
    // pub fn build(b: *std.Build) void {
    //     // 実行可能ファイルを作成
    //     const exe = b.addExecutable(.{
    //         .name = "my_app",
    //         .root_module = b.createModule(.{
    //             .root_source_file = b.path("src/main.zig"),
    //             .target = b.graph.host,
    //         }),
    //     });
    //
    //     // インストールステップに追加
    //     b.installArtifact(exe);
    //
    //     // 実行ステップを作成
    //     const run_cmd = b.addRunArtifact(exe);
    //
    //     // "run"という名前のステップを定義
    //     const run_step = b.step("run", "Run the application");
    //     run_step.dependOn(&run_cmd.step);
    // }

    std.debug.print("  ステップ作成メソッド:\n", .{});
    std.debug.print("    b.step(name, desc)     - カスタムステップ\n", .{});
    std.debug.print("    b.getInstallStep()     - インストールステップ取得\n", .{});
    std.debug.print("    b.addRunArtifact(exe)  - 実行アーティファクト\n", .{});
    std.debug.print("    b.addTest(...)         - テストアーティファクト\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 依存関係の設定
// ====================

fn demoDependencies() void {
    std.debug.print("--- 依存関係の設定 ---\n", .{});

    // build.zigでの記述例:
    //
    // // 実行前にインストールを完了させる
    // run_cmd.step.dependOn(b.getInstallStep());
    //
    // // runステップが実行コマンドに依存
    // run_step.dependOn(&run_cmd.step);
    //
    // 依存関係の流れ:
    // run_step → run_cmd → install → compile

    std.debug.print("  dependOn()の使い方:\n", .{});
    std.debug.print("    step.dependOn(&other.step)\n", .{});
    std.debug.print("    → stepはotherの完了後に実行\n", .{});

    std.debug.print("  典型的な依存チェーン:\n", .{});
    std.debug.print("    run → addRunArtifact → install → compile\n", .{});
    std.debug.print("    test → addRunArtifact → compile\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// インストールステップ
// ====================

fn demoInstallStep() void {
    std.debug.print("--- インストールステップ ---\n", .{});

    // build.zigでの記述例:
    //
    // const exe = b.addExecutable(...);
    // b.installArtifact(exe);  // zig-out/bin/に配置
    //
    // const lib = b.addStaticLibrary(...);
    // b.installArtifact(lib);  // zig-out/lib/に配置
    //
    // // ヘッダファイルのインストール
    // b.installFile("src/header.h", "include/header.h");
    //
    // // ディレクトリのインストール
    // b.installDirectory(.{
    //     .source_dir = b.path("assets"),
    //     .install_dir = .prefix,
    //     .install_subdir = "share/assets",
    // });

    std.debug.print("  installArtifact(target):\n", .{});
    std.debug.print("    実行可能 → zig-out/bin/\n", .{});
    std.debug.print("    ライブラリ → zig-out/lib/\n", .{});

    std.debug.print("  その他のインストール:\n", .{});
    std.debug.print("    installFile(src, dest)      - 単一ファイル\n", .{});
    std.debug.print("    installDirectory(opts)      - ディレクトリ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実行ステップ
// ====================

fn demoRunStep() void {
    std.debug.print("--- 実行ステップ ---\n", .{});

    // build.zigでの記述例:
    //
    // const run_cmd = b.addRunArtifact(exe);
    //
    // // コマンドライン引数を渡す
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }
    //
    // // 環境変数を設定
    // run_cmd.setEnvironmentVariable("DEBUG", "1");
    //
    // // 作業ディレクトリを設定
    // run_cmd.setCwd(b.path("working_dir"));
    //
    // const run_step = b.step("run", "Run the application");
    // run_step.dependOn(&run_cmd.step);

    std.debug.print("  addRunArtifact(exe) オプション:\n", .{});
    std.debug.print("    addArgs(args)              - 引数追加\n", .{});
    std.debug.print("    setEnvironmentVariable()   - 環境変数\n", .{});
    std.debug.print("    setCwd(path)               - 作業ディレクトリ\n", .{});

    std.debug.print("  実行時引数の渡し方:\n", .{});
    std.debug.print("    zig build run -- arg1 arg2\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// テストステップ
// ====================

fn demoTestStep() void {
    std.debug.print("--- テストステップ ---\n", .{});

    // build.zigでの記述例:
    //
    // const unit_tests = b.addTest(.{
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/main.zig"),
    //         .target = target,
    //         .optimize = optimize,
    //     }),
    // });
    //
    // const run_tests = b.addRunArtifact(unit_tests);
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_tests.step);

    std.debug.print("  テストステップの構成:\n", .{});
    std.debug.print("    1. addTest() でテストターゲット作成\n", .{});
    std.debug.print("    2. addRunArtifact() で実行ステップ作成\n", .{});
    std.debug.print("    3. step() で名前付きステップ作成\n", .{});
    std.debug.print("    4. dependOn() で依存関係設定\n", .{});

    std.debug.print("  実行方法:\n", .{});
    std.debug.print("    zig build test\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 複数ステップの構成
// ====================

fn demoMultipleSteps() void {
    std.debug.print("--- 複数ステップの構成 ---\n", .{});

    // build.zigでの記述例:
    //
    // // 複数の実行可能ファイル
    // const exe1 = b.addExecutable(.{ .name = "app1", ... });
    // const exe2 = b.addExecutable(.{ .name = "app2", ... });
    //
    // b.installArtifact(exe1);
    // b.installArtifact(exe2);
    //
    // // 個別のrunステップ
    // const run1 = b.step("run1", "Run app1");
    // run1.dependOn(&b.addRunArtifact(exe1).step);
    //
    // const run2 = b.step("run2", "Run app2");
    // run2.dependOn(&b.addRunArtifact(exe2).step);
    //
    // // 全てを実行するステップ
    // const run_all = b.step("run-all", "Run all apps");
    // run_all.dependOn(&b.addRunArtifact(exe1).step);
    // run_all.dependOn(&b.addRunArtifact(exe2).step);

    std.debug.print("  複数ターゲットの管理:\n", .{});
    std.debug.print("    個別ステップ: run1, run2, ...\n", .{});
    std.debug.print("    全体ステップ: run-all\n", .{});
    std.debug.print("    複数依存: step.dependOn()を複数回\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// カスタムステップ
// ====================

fn demoCustomSteps() void {
    std.debug.print("--- カスタムステップ ---\n", .{});

    // build.zigでの記述例:
    //
    // // システムコマンドを実行するステップ
    // const fmt_step = b.addSystemCommand(&.{
    //     "zig", "fmt", "src/",
    // });
    // const fmt = b.step("fmt", "Format source code");
    // fmt.dependOn(&fmt_step.step);
    //
    // // ドキュメント生成ステップ
    // const docs = b.addExecutable(...);
    // const install_docs = b.addInstallDirectory(.{
    //     .source_dir = docs.getEmittedDocs(),
    //     .install_dir = .prefix,
    //     .install_subdir = "docs",
    // });
    // const docs_step = b.step("docs", "Generate documentation");
    // docs_step.dependOn(&install_docs.step);

    std.debug.print("  addSystemCommand():\n", .{});
    std.debug.print("    外部コマンドを実行\n", .{});
    std.debug.print("    例: zig fmt, 外部ツール\n", .{});

    std.debug.print("  よくあるカスタムステップ:\n", .{});
    std.debug.print("    fmt   - コードフォーマット\n", .{});
    std.debug.print("    docs  - ドキュメント生成\n", .{});
    std.debug.print("    clean - クリーンアップ\n", .{});
    std.debug.print("    check - 静的解析\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 完全なbuild.zig例
// ====================

fn demoCompleteBuildZig() void {
    std.debug.print("--- 完全なbuild.zig例 ---\n", .{});

    std.debug.print("  典型的な構成:\n", .{});
    std.debug.print("  ```\n", .{});
    std.debug.print("  pub fn build(b: *std.Build) void {{\n", .{});
    std.debug.print("      const target = b.standardTargetOptions(.{{}});\n", .{});
    std.debug.print("      const optimize = b.standardOptimizeOption(.{{}});\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("      const exe = b.addExecutable(.{{...}});\n", .{});
    std.debug.print("      b.installArtifact(exe);\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("      // run step\n", .{});
    std.debug.print("      const run_cmd = b.addRunArtifact(exe);\n", .{});
    std.debug.print("      run_cmd.step.dependOn(b.getInstallStep());\n", .{});
    std.debug.print("      const run_step = b.step(\"run\", \"Run app\");\n", .{});
    std.debug.print("      run_step.dependOn(&run_cmd.step);\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("      // test step\n", .{});
    std.debug.print("      const tests = b.addTest(.{{...}});\n", .{});
    std.debug.print("      const test_step = b.step(\"test\", \"Run tests\");\n", .{});
    std.debug.print("      test_step.dependOn(&b.addRunArtifact(tests).step);\n", .{});
    std.debug.print("  }}\n", .{});
    std.debug.print("  ```\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  ステップの基本:\n", .{});
    std.debug.print("    b.step(name, desc)   - ステップ作成\n", .{});
    std.debug.print("    step.dependOn()      - 依存関係設定\n", .{});

    std.debug.print("  主要メソッド:\n", .{});
    std.debug.print("    installArtifact()    - 成果物インストール\n", .{});
    std.debug.print("    addRunArtifact()     - 実行ステップ\n", .{});
    std.debug.print("    addTest()            - テストターゲット\n", .{});
    std.debug.print("    addSystemCommand()   - 外部コマンド\n", .{});

    std.debug.print("  コマンド:\n", .{});
    std.debug.print("    zig build           - デフォルト\n", .{});
    std.debug.print("    zig build run       - runステップ\n", .{});
    std.debug.print("    zig build test      - testステップ\n", .{});
    std.debug.print("    zig build -l        - ステップ一覧\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== ビルドステップ ===\n\n", .{});

    demoStepConcept();
    demoCreateSteps();
    demoDependencies();
    demoInstallStep();
    demoRunStep();
    demoTestStep();
    demoMultipleSteps();
    demoCustomSteps();
    demoCompleteBuildZig();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・ステップは依存グラフを形成\n", .{});
    std.debug.print("・必要な部分のみ実行される\n", .{});
    std.debug.print("・zig build -l でステップ一覧表示\n", .{});
    std.debug.print("・-- 以降の引数はアプリに渡される\n", .{});
}

// --- テスト ---
// build.zigの機能をテストするには実際のプロジェクトが必要
// ここでは概念の確認用テストのみ

test "step names are valid identifiers" {
    // ステップ名として使える文字列のパターン確認
    const valid_names = [_][]const u8{
        "run",
        "test",
        "install",
        "run-all",
        "build_docs",
    };

    for (valid_names) |name| {
        try std.testing.expect(name.len > 0);
    }
}

test "dependency chain concept" {
    // 依存関係チェーンの概念確認
    // A -> B -> C (AはBに依存、BはCに依存)
    const Step = struct {
        name: []const u8,
        deps: []const usize,
    };

    const steps = [_]Step{
        .{ .name = "compile", .deps = &[_]usize{} },
        .{ .name = "install", .deps = &[_]usize{0} },
        .{ .name = "run", .deps = &[_]usize{1} },
    };

    // runはinstallに依存
    try std.testing.expectEqual(@as(usize, 1), steps[2].deps[0]);
    // installはcompileに依存
    try std.testing.expectEqual(@as(usize, 0), steps[1].deps[0]);
}

test "build commands" {
    // ビルドコマンドの形式確認
    const commands = [_][]const u8{
        "zig build",
        "zig build run",
        "zig build test",
        "zig build run -- arg1 arg2",
        "zig build -Doptimize=ReleaseFast",
    };

    try std.testing.expectEqual(@as(usize, 5), commands.len);
}
