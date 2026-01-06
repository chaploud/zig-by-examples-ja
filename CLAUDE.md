# zig-by-examples-ja

## プロジェクト概要

zig-book（日本語翻訳済み）の内容を、コード主体で高速にZigをキャッチアップできる形式に再構成したプロジェクト。

## 作業の進め方（重要）

### 参照元

1. **翻訳済みmarkdown**: `/Users/shota.508/Documents/Learn/zig-book/chapters-ja/`
   - 各章のmarkdownを読み、説明を理解した上でコードにまとめる

2. **Zig 0.15.2対応済みコード例**: `/Users/shota.508/Documents/Learn/zig-book/examples/`
   - **重要**: zig-bookの元コードは古いZigバージョン向け。examples/は0.15.2対応済み
   - APIが動かない場合はここを参照して正しい書き方を確認する
   - 章ごとにディレクトリ分け: `ch01/`, `ch02/`, ... `ch17/`

### コード作成方針

1. markdownで断片的に説明されているコードを、**実行可能な完成形**にまとめる
2. 別の話題は別ファイルに分ける
3. `zig run` と `zig test` の両方で動作確認する

### コメントスタイル

| 種類 | 用途 |
|------|------|
| `//!` | ファイル冒頭のトピック説明（概要） |
| `///` | 関数・型のdoc comment |
| `//` | コード内のインラインコメント |

**コメント方針（重要）**:
- インラインコメントは「最小限」ではなく「適切に」入れる
- 関数トップにベタ書きするより、該当コードの近くにコメントがある方が見やすい場合はインラインで記述
- 翻訳済みmarkdownの説明を理解した上で、読者がコードを読むだけで概念を理解できるようにコメントを付ける

### ファイル・ディレクトリ命名

- **ディレクトリ**: `NN_category/` 形式（見出しの粒度）
- **zigファイル**: `nNNN_topic.zig` 形式（プロジェクト全体の通し連番）
- **サブディレクトリ**: 必要に応じて作成可（ビルドシステムの例など）

## ディレクトリ・トピック一覧

| Dir | ディレクトリ名 | 連番範囲 | 内容 |
|-----|---------------|---------|------|
| 01 | 01_basics/ | n001-n015 | Hello World, 変数, 型, 制御フロー |
| 02 | 02_structs/ | n016-n025 | 構造体, enum, union, comptime |
| 03 | 03_memory/ | n026-n035 | allocator, スタック/ヒープ |
| 04 | 04_pointers/ | n036-n045 | ポインタ各種 |
| 05 | 05_errors/ | n046-n055 | エラー処理 |
| 06 | 06_data_structures/ | n056-n065 | ArrayList, HashMap等 |
| 07 | 07_testing/ | n066-n070 | テスト |
| 08 | 08_build_system/ | n071-n075 | ビルドシステム |
| 09 | 09_file_io/ | n076-n085 | ファイル・IO |
| 10 | 10_c_interop/ | n086-n095 | C連携 |
| 11 | 11_concurrency/ | n096-n105 | スレッド・並行処理 |
| 12 | 12_simd/ | n106-n110 | SIMD・ベクトル |

## 進捗管理

進捗状態は `.claude/progress.json` で管理（`/status` で確認可能）。

## カスタムコマンド

| コマンド | 説明 |
|---------|------|
| `/next` | 次のファイルを自動作成→検証→進捗更新まで一気通貫 |
| `/status` | 進捗状況を表示 |
| `/verify [file]` | 指定ファイルをテスト・検証 |

## Zig 0.15.2 注意点

このプロジェクトは **Zig 0.15.2** を使用（`/opt/homebrew/Cellar/zig/0.15.2/`）。

zig-bookの元コードは古いZigバージョン向けのため、API変更に注意が必要。
**動かないコードがあれば `/Users/shota.508/Documents/Learn/zig-book/examples/` を参照**。

### API変更まとめ

| 項目 | 旧API (〜0.13) | 新API (0.15.2) |
|------|---------------|----------------|
| stdout出力 | `std.io.getStdOut().writer()` | `std.debug.print()` または `std.fs.File.stdout()` |
| build.zig | `.root_source_file = ...` 直接指定 | `.root_module = b.createModule(...)` |

### stdout出力

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

### build.zig テンプレート（Zig 0.15.2）

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

### 標準ライブラリ参照

APIが不明な場合は標準ライブラリのソースを確認:
- 場所: `/opt/homebrew/Cellar/zig/0.15.2/lib/zig/std/`
- Build API: `std/Build.zig`, `std/Build/Module.zig`
- IO API: `std/Io.zig`, `std/fs/File.zig`

## 作業コマンド

```bash
# 実行
zig run ファイル.zig

# テスト
zig test ファイル.zig

# フォーマット
zig fmt ファイル.zig
```

## zig-book章対応表

| 章 | markdown | examples/ | 対応ディレクトリ |
|----|---------|-----------|---------------|
| 1 | 01-introducing-zig.md | ch01/ | 01_basics/ |
| 2 | 02-control-flow-structs.md | ch02/ | 01_basics/, 02_structs/ |
| 3 | 03-memory.md | ch03/ | 03_memory/ |
| 4 | 04-base64-project.md | ch04/ | （プロジェクト例） |
| 5 | 05-debugging.md | ch05/ | 07_testing/ |
| 6 | 06-pointers.md | ch06/ | 04_pointers/ |
| 7 | 07-http-server.md | ch07/ | （プロジェクト例） |
| 8 | 08-unit-tests.md | ch08/ | 07_testing/ |
| 9 | 09-build-system.md | ch09/ | 08_build_system/ |
| 10 | 10-error-handling.md | ch10/ | 05_errors/ |
| 11 | 11-data-structures.md | ch11/ | 06_data_structures/ |
| 12 | 12-stack-project.md | ch12/ | （プロジェクト例） |
| 13 | 13-file-operations.md | ch13/ | 09_file_io/ |
| 14 | 14-c-interop.md | ch14/ | 10_c_interop/ |
| 15 | 15-image-filter.md | ch15/ | （プロジェクト例） |
| 16 | 16-threads.md | ch16/ | 11_concurrency/ |
| 17 | 17-vectors.md | ch17/ | 12_simd/ |

**examples/パス**: `/Users/shota.508/Documents/Learn/zig-book/examples/`
