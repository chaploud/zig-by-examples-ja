//! n086_libc_basics - ビルド設定
//!
//! libcをリンクしてC関数を呼び出す基本例。
//!
//! ## ビルド・実行方法
//! ```
//! cd 10_c_interop/n086_libc_basics
//! zig build run
//! ```
//!
//! ## テスト実行
//! ```
//! zig build test
//! ```

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 実行可能ファイル
    const exe = b.addExecutable(.{
        .name = "libc_basics",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true, // libc をリンク
        }),
    });

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

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "テストを実行");
    test_step.dependOn(&run_unit_tests.step);
}
