//! # クロスコンパイル
//!
//! Zigの強力なクロスコンパイル機能。
//! 異なるOS・アーキテクチャ向けのビルド方法。
//!
//! ## 主要概念
//! - Target: CPU・OS・ABIの組み合わせ
//! - standardTargetOptions: コマンドラインからの指定
//! - resolveTargetQuery: プログラムによる指定
//! - builtin.target: コンパイル時のターゲット情報

const std = @import("std");
const builtin = @import("builtin");

// ====================
// ターゲットの基本
// ====================

fn demoTargetBasics() void {
    std.debug.print("--- ターゲットの基本 ---\n", .{});

    // ターゲットは3つの要素で構成:
    // 1. CPU アーキテクチャ (x86_64, aarch64, arm, etc.)
    // 2. OS タグ (linux, windows, macos, etc.)
    // 3. ABI (gnu, musl, msvc, etc.)

    std.debug.print("  ターゲット形式: <arch>-<os>-<abi>\n", .{});
    std.debug.print("  例:\n", .{});
    std.debug.print("    x86_64-linux-gnu\n", .{});
    std.debug.print("    aarch64-macos-none\n", .{});
    std.debug.print("    x86_64-windows-msvc\n", .{});
    std.debug.print("    wasm32-wasi-musl\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 現在のターゲット情報
// ====================

fn demoCurrentTarget() void {
    std.debug.print("--- 現在のターゲット ---\n", .{});

    // builtin.target でコンパイル時のターゲット情報を取得
    std.debug.print("  CPU: {s}\n", .{@tagName(builtin.cpu.arch)});
    std.debug.print("  OS:  {s}\n", .{@tagName(builtin.os.tag)});

    // OS固有の情報
    switch (builtin.os.tag) {
        .macos => std.debug.print("  macOS バージョン情報あり\n", .{}),
        .linux => std.debug.print("  Linux カーネル情報あり\n", .{}),
        .windows => std.debug.print("  Windows バージョン情報あり\n", .{}),
        else => std.debug.print("  その他のOS\n", .{}),
    }

    std.debug.print("\n", .{});
}

// ====================
// コマンドラインターゲット
// ====================

fn demoCommandLineTarget() void {
    std.debug.print("--- コマンドラインターゲット ---\n", .{});

    // build.zigでの記述例:
    //
    // pub fn build(b: *std.Build) void {
    //     // -Dtarget= オプションを有効化
    //     const target = b.standardTargetOptions(.{});
    //
    //     const exe = b.addExecutable(.{
    //         .root_module = b.createModule(.{
    //             .target = target,
    //             ...
    //         }),
    //     });
    // }

    std.debug.print("  使用方法:\n", .{});
    std.debug.print("    zig build -Dtarget=x86_64-linux\n", .{});
    std.debug.print("    zig build -Dtarget=aarch64-macos\n", .{});
    std.debug.print("    zig build -Dtarget=x86_64-windows\n", .{});

    std.debug.print("  オプションの指定:\n", .{});
    std.debug.print("    -Dtarget=<triple>\n", .{});
    std.debug.print("    -Dcpu=<cpu-model>\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// プログラムによるターゲット指定
// ====================

fn demoProgrammaticTarget() void {
    std.debug.print("--- プログラムによる指定 ---\n", .{});

    // build.zigでの記述例:
    //
    // // 特定のターゲットを直接指定
    // const linux_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    //     .abi = .gnu,
    // });
    //
    // const exe = b.addExecutable(.{
    //     .root_module = b.createModule(.{
    //         .target = linux_target,
    //         ...
    //     }),
    // });

    std.debug.print("  resolveTargetQuery():\n", .{});
    std.debug.print("    .cpu_arch - CPU種類\n", .{});
    std.debug.print("    .os_tag   - OS種類\n", .{});
    std.debug.print("    .abi      - ABI種類\n", .{});

    std.debug.print("  b.graph.host:\n", .{});
    std.debug.print("    現在のマシンをターゲットに\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 複数ターゲットビルド
// ====================

fn demoMultipleTargets() void {
    std.debug.print("--- 複数ターゲットビルド ---\n", .{});

    // build.zigでの記述例:
    //
    // const targets = [_]std.Target.Query{
    //     .{ .cpu_arch = .x86_64, .os_tag = .linux },
    //     .{ .cpu_arch = .x86_64, .os_tag = .windows },
    //     .{ .cpu_arch = .aarch64, .os_tag = .macos },
    // };
    //
    // for (targets) |t| {
    //     const target = b.resolveTargetQuery(t);
    //     const exe = b.addExecutable(.{
    //         .name = b.fmt("app-{s}-{s}", .{
    //             @tagName(t.cpu_arch.?),
    //             @tagName(t.os_tag.?),
    //         }),
    //         .root_module = b.createModule(.{
    //             .target = target,
    //             ...
    //         }),
    //     });
    //     b.installArtifact(exe);
    // }

    std.debug.print("  一度に複数ターゲット:\n", .{});
    std.debug.print("    ループで各ターゲットを処理\n", .{});
    std.debug.print("    異なる名前で出力\n", .{});

    std.debug.print("  出力例:\n", .{});
    std.debug.print("    zig-out/bin/app-x86_64-linux\n", .{});
    std.debug.print("    zig-out/bin/app-x86_64-windows\n", .{});
    std.debug.print("    zig-out/bin/app-aarch64-macos\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// OS固有の条件分岐
// ====================

fn demoOsSpecific() void {
    std.debug.print("--- OS固有の条件分岐 ---\n", .{});

    // コード内でのOS分岐
    const message = switch (builtin.os.tag) {
        .macos => "macOS固有の処理",
        .linux => "Linux固有の処理",
        .windows => "Windows固有の処理",
        else => "その他のOS",
    };
    std.debug.print("  現在: {s}\n", .{message});

    // build.zigでの条件分岐例:
    //
    // const builtin = @import("builtin");
    //
    // switch (builtin.target.os.tag) {
    //     .windows => {
    //         exe.root_module.addCSourceFiles(.{
    //             .files = &windows_files,
    //         });
    //     },
    //     .linux => {
    //         exe.root_module.linkSystemLibrary("pthread", .{});
    //     },
    //     else => {},
    // }

    std.debug.print("  comptime分岐:\n", .{});
    std.debug.print("    コンパイル時に評価\n", .{});
    std.debug.print("    不要なコードは除去\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// CPU機能の検出
// ====================

fn demoCpuFeatures() void {
    std.debug.print("--- CPU機能の検出 ---\n", .{});

    // 現在のCPUモデル
    std.debug.print("  CPUモデル: {s}\n", .{builtin.cpu.model.name});

    // CPU機能の確認例（実行時）
    // if (std.Target.x86.featureSetHas(builtin.cpu.features, .avx2)) {
    //     // AVX2使用可能
    // }

    // build.zigでの記述例:
    //
    // // 特定のCPU機能を要求
    // const target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    //     .cpu_model = .{ .explicit = &std.Target.x86.cpu.skylake },
    // });
    //
    // // または baseline を指定
    // const baseline_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    //     .cpu_model = .baseline,
    // });

    std.debug.print("  CPU指定オプション:\n", .{});
    std.debug.print("    .baseline     - 最小互換性\n", .{});
    std.debug.print("    .native       - 現在のCPU\n", .{});
    std.debug.print("    .explicit     - 特定モデル\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// WASM/組み込み
// ====================

fn demoWasmEmbedded() void {
    std.debug.print("--- WASM/組み込み ---\n", .{});

    // build.zigでの記述例:
    //
    // // WebAssembly (WASI)
    // const wasm_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .wasm32,
    //     .os_tag = .wasi,
    // });
    //
    // // フリースタンディング（OS無し）
    // const embedded_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .thumb,
    //     .os_tag = .freestanding,
    //     .abi = .eabi,
    // });

    std.debug.print("  WebAssembly:\n", .{});
    std.debug.print("    wasm32-wasi      - WASI対応\n", .{});
    std.debug.print("    wasm32-freestanding - ブラウザ向け\n", .{});

    std.debug.print("  組み込み:\n", .{});
    std.debug.print("    thumb-freestanding-eabi  - ARM Cortex-M\n", .{});
    std.debug.print("    riscv32-freestanding     - RISC-V\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// libcの選択
// ====================

fn demoLibcSelection() void {
    std.debug.print("--- libcの選択 ---\n", .{});

    // build.zigでの記述例:
    //
    // // musl libc (静的リンク向け)
    // const musl_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    //     .abi = .musl,
    // });
    //
    // // glibc (動的リンク向け)
    // const glibc_target = b.resolveTargetQuery(.{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .linux,
    //     .abi = .gnu,
    // });

    std.debug.print("  Linux ABI:\n", .{});
    std.debug.print("    .gnu  - glibc（動的リンク）\n", .{});
    std.debug.print("    .musl - musl（静的リンク可）\n", .{});

    std.debug.print("  静的バイナリ:\n", .{});
    std.debug.print("    musl + 静的リンクで\n", .{});
    std.debug.print("    依存なし単一バイナリ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  ターゲット指定:\n", .{});
    std.debug.print("    -Dtarget=<triple>     - コマンドライン\n", .{});
    std.debug.print("    resolveTargetQuery()  - プログラム\n", .{});
    std.debug.print("    b.graph.host          - 現在のマシン\n", .{});

    std.debug.print("  主要ターゲット:\n", .{});
    std.debug.print("    x86_64-linux-gnu\n", .{});
    std.debug.print("    x86_64-windows-msvc\n", .{});
    std.debug.print("    aarch64-macos-none\n", .{});
    std.debug.print("    wasm32-wasi-musl\n", .{});

    std.debug.print("  コンパイル時情報:\n", .{});
    std.debug.print("    @import(\"builtin\")\n", .{});
    std.debug.print("    builtin.cpu.arch\n", .{});
    std.debug.print("    builtin.os.tag\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== クロスコンパイル ===\n\n", .{});

    demoTargetBasics();
    demoCurrentTarget();
    demoCommandLineTarget();
    demoProgrammaticTarget();
    demoMultipleTargets();
    demoOsSpecific();
    demoCpuFeatures();
    demoWasmEmbedded();
    demoLibcSelection();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・Zigは追加設定なしでクロスコンパイル可能\n", .{});
    std.debug.print("・libcも自動的にクロスコンパイル\n", .{});
    std.debug.print("・zig targets で対応ターゲット一覧\n", .{});
    std.debug.print("・builtin で条件分岐可能\n", .{});
}

// --- テスト ---

test "current target is valid" {
    // 現在のターゲットが有効（一般的なアーキテクチャのいずれか）
    try std.testing.expect(builtin.cpu.arch == .x86_64 or
        builtin.cpu.arch == .aarch64 or
        builtin.cpu.arch == .x86 or
        builtin.cpu.arch == .arm or
        builtin.cpu.arch == .riscv64 or
        builtin.cpu.arch == .wasm32);
    try std.testing.expect(builtin.os.tag == .linux or
        builtin.os.tag == .macos or
        builtin.os.tag == .windows or
        builtin.os.tag == .freebsd or
        builtin.os.tag == .freestanding);
}

test "cpu arch names" {
    // CPUアーキテクチャ名
    const archs = [_]std.Target.Cpu.Arch{
        .x86_64,
        .aarch64,
        .arm,
        .riscv64,
        .wasm32,
    };

    for (archs) |arch| {
        const name = @tagName(arch);
        try std.testing.expect(name.len > 0);
    }
}

test "os tag names" {
    // OSタグ名
    const tags = [_]std.Target.Os.Tag{
        .linux,
        .windows,
        .macos,
        .freebsd,
        .freestanding,
        .wasi,
    };

    for (tags) |tag| {
        const name = @tagName(tag);
        try std.testing.expect(name.len > 0);
    }
}

test "target triple format" {
    // ターゲットトリプルの形式
    const triples = [_][]const u8{
        "x86_64-linux-gnu",
        "aarch64-macos-none",
        "x86_64-windows-msvc",
        "wasm32-wasi-musl",
    };

    for (triples) |triple| {
        var parts: usize = 0;
        var iter = std.mem.splitScalar(u8, triple, '-');
        while (iter.next()) |_| {
            parts += 1;
        }
        // arch-os-abi の3パート
        try std.testing.expectEqual(@as(usize, 3), parts);
    }
}

test "conditional compilation works" {
    // 条件分岐がコンパイル時に解決される
    const value = if (builtin.os.tag == .linux)
        "linux"
    else if (builtin.os.tag == .macos)
        "macos"
    else if (builtin.os.tag == .windows)
        "windows"
    else
        "other";

    try std.testing.expect(value.len > 0);
}
