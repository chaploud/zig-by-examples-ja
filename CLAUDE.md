# zig-by-examples-ja

## プロジェクト概要

zig-book（日本語翻訳済み）の内容を、コード主体で高速にZigをキャッチアップできる形式に再構成したプロジェクト。

## 作業の進め方（重要）

### 参照元

- `/Users/shota.508/Documents/Learn/zig-book/chapters-ja/` の翻訳済みmarkdown
- 各章のmarkdownを読み、説明を理解した上でコードにまとめる

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

### stdout出力

```zig
// Zig 0.15.2 では std.debug.print を使用
std.debug.print("Hello, {s}!\n", .{"world"});
```

### build.zig テンプレート（Zig 0.15.2）

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

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

| 章 | ファイル | 対応ディレクトリ |
|----|---------|---------------|
| 1 | 01-introducing-zig.md | 01_basics/ |
| 2 | 02-control-flow-structs.md | 01_basics/, 02_structs/ |
| 3 | 03-memory.md | 03_memory/ |
| 4 | 04-base64-project.md | （プロジェクト例） |
| 5 | 05-debugging.md | 07_testing/ |
| 6 | 06-pointers.md | 04_pointers/ |
| 7 | 07-http-server.md | （プロジェクト例） |
| 8 | 08-unit-tests.md | 07_testing/ |
| 9 | 09-build-system.md | 08_build_system/ |
| 10 | 10-error-handling.md | 05_errors/ |
| 11 | 11-data-structures.md | 06_data_structures/ |
| 12 | 12-stack-project.md | （プロジェクト例） |
| 13 | 13-file-operations.md | 09_file_io/ |
| 14 | 14-c-interop.md | 10_c_interop/ |
| 15 | 15-image-filter.md | （プロジェクト例） |
| 16 | 16-threads.md | 11_concurrency/ |
| 17 | 17-vectors.md | 12_simd/ |
