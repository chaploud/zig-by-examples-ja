//! n088_translate_c - ビルド設定
//!
//! zig translate-c の使い方を示すサンプル。
//!
//! ## ビルド・実行方法
//! ```
//! cd 10_c_interop/n088_translate_c
//! zig build run
//! ```
//!
//! ## テスト実行
//! ```
//! zig build test
//! ```
//!
//! ## translate-c の実行
//! ```
//! zig translate-c c_src/sample.h > src/sample_translated.zig
//! ```

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 実行可能ファイル
    const exe = b.addExecutable(.{
        .name = "translate_c",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    // Cソースファイルを追加
    exe.root_module.addCSourceFiles(.{
        .root = b.path("c_src"),
        .files = &.{"sample.c"},
    });

    // インクルードパスを追加
    exe.root_module.addIncludePath(b.path("c_src"));

    b.installArtifact(exe);

    // run ステップ
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "プログラムを実行");
    run_step.dependOn(&run_cmd.step);

    // テスト
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    unit_tests.root_module.addCSourceFiles(.{
        .root = b.path("c_src"),
        .files = &.{"sample.c"},
    });
    unit_tests.root_module.addIncludePath(b.path("c_src"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "テストを実行");
    test_step.dependOn(&run_unit_tests.step);
}
