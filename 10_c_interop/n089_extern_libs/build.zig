//! n089_extern_libs - ビルド設定
//!
//! 外部Cライブラリ（zlib）をリンクするサンプル。
//!
//! ## ビルド・実行方法
//! ```
//! cd 10_c_interop/n089_extern_libs
//! zig build run
//! ```
//!
//! ## テスト実行
//! ```
//! zig build test
//! ```
//!
//! ## 前提条件
//! zlib がシステムにインストールされていること
//!   macOS: brew install zlib
//!   Ubuntu: apt install zlib1g-dev

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 実行可能ファイル
    const exe = b.addExecutable(.{
        .name = "extern_libs",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true, // Cランタイムライブラリをリンク
        }),
    });

    // zlib をリンク
    // macOS/Linux では標準パスに zlib がある
    exe.root_module.linkSystemLibrary("z", .{});

    // 非標準パスの場合（例: Homebrew）
    // exe.root_module.addSystemIncludePath(.{
    //     .cwd_relative = "/opt/homebrew/include",
    // });
    // exe.root_module.addLibraryPath(.{
    //     .cwd_relative = "/opt/homebrew/lib",
    // });

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

    unit_tests.root_module.linkSystemLibrary("z", .{});

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "テストを実行");
    test_step.dependOn(&run_unit_tests.step);
}
