//! n090_export_to_c - ビルド設定
//!
//! ZigコードをCから使えるライブラリとしてビルドする。
//!
//! ## ビルド・実行方法
//! ```
//! cd 10_c_interop/n090_export_to_c
//! zig build run          # 動作確認用実行ファイル
//! zig build              # 静的ライブラリを生成
//! zig build -Ddynamic=true  # 共有ライブラリを生成
//! ```
//!
//! ## テスト実行
//! ```
//! zig build test
//! ```
//!
//! ## 生成ファイル
//! - zig-out/lib/libexport_to_c.a  (静的)
//! - zig-out/lib/libexport_to_c.dylib (共有/macOS)
//! - zig-out/lib/libexport_to_c.so (共有/Linux)

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // オプション: 動的ライブラリか静的ライブラリか
    const dynamic = b.option(bool, "dynamic", "Build as shared library") orelse false;

    // ライブラリのビルド
    const lib = b.addLibrary(.{
        .name = "export_to_c",
        .linkage = if (dynamic) .dynamic else .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(lib);

    // 動作確認用の実行ファイル
    const exe = b.addExecutable(.{
        .name = "export_demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    // run ステップ
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "デモプログラムを実行");
    run_step.dependOn(&run_cmd.step);

    // テスト
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "テストを実行");
    test_step.dependOn(&run_unit_tests.step);
}
