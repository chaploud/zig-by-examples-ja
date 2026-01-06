# Zig 0.15.2 API変更まとめ

zig-bookの元コードは古いZigバージョン向け。以下のAPI変更に注意。

## 変更一覧

| 項目 | 旧API (〜0.13) | 新API (0.15.2) |
|------|---------------|----------------|
| stdout出力 | `std.io.getStdOut().writer()` | `std.debug.print()` または `std.fs.File.stdout()` |
| build.zig | `.root_source_file = ...` 直接指定 | `.root_module = b.createModule(...)` |

## stdout出力

```zig
// 旧 (Zig 0.13以前):
// const stdout = std.io.getStdOut().writer();
// try stdout.print("Hello!\n", .{});

// 新 (Zig 0.15.2):
// Option 1: std.debug.print（最もシンプル、stderrに出力）
std.debug.print("Hello, {s}!\n", .{"world"});

// Option 2: std.fs.File.stdout() + buffered writer（stdoutに出力したい場合）
const stdout = std.fs.File.stdout();
var buffer: [1024]u8 = undefined;
var writer = stdout.writer(&buffer);
// writer.interface で書き込み
```

## build.zig テンプレート

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 0.15.2: root_module + createModule を使用
    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}
```

## 標準ライブラリ参照

APIが不明な場合は標準ライブラリのソースを確認:
- 場所: `/opt/homebrew/Cellar/zig/0.15.2/lib/zig/std/`
- Build API: `std/Build.zig`, `std/Build/Module.zig`
- IO API: `std/Io.zig`, `std/fs/File.zig`

## 新規発見時

新たなAPI変更を発見したら、このファイルに追記する。
