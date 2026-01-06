---
description: ユーザーが割り込むまで次のZigファイルを連続で自動作成・検証・進捗更新
allowed-tools: Read, Write, Edit, Bash(zig run:*), Bash(zig test:*), Bash(zig fmt:*), Bash(mkdir:*), Bash(ls:*), Glob
---

# 連続ファイル作成モード

このコマンドは `/next` を**ユーザーが割り込むまで繰り返し実行**する。

## 動作フロー

```
┌─────────────────────────────────────┐
│  1. /next と同じ処理を実行          │
│     - 進捗確認                      │
│     - 参照読み込み                  │
│     - ファイル作成                  │
│     - 検証 (zig run / zig test)    │
│     - 進捗更新                      │
├─────────────────────────────────────┤
│  2. 完了報告（簡潔に）              │
├─────────────────────────────────────┤
│  3. 自動的に次のファイルへ進む      │
│     → Step 1 に戻る                 │
└─────────────────────────────────────┘
```

## 停止条件

- ユーザーが割り込んだ場合
- 全ファイル完了（n110まで）
- 修正不能なエラーが発生した場合

---

## 各イテレーションの処理内容

### Step 1: 進捗確認

`.claude/progress.json` を読んで以下を確認:
- `next_number`: 次のファイル番号
- `next_file`: 次のファイル名
- どのディレクトリに配置するか

### Step 2: 参照読み込み

1. README.md から該当ファイルのトピックを確認
2. 番号からディレクトリを特定:
   - n001-n015 → 01_basics/
   - n016-n025 → 02_structs/
   - n026-n035 → 03_memory/
   - n036-n045 → 04_pointers/
   - n046-n055 → 05_errors/
   - n056-n065 → 06_data_structures/
   - n066-n070 → 07_testing/
   - n071-n075 → 08_build_system/
   - n076-n085 → 09_file_io/
   - n086-n095 → 10_c_interop/
   - n096-n105 → 11_concurrency/
   - n106-n110 → 12_simd/

3. `/Users/shota.508/Documents/Learn/zig-book/chapters-ja/` の対応markdownを読む:
   - 01_basics → 01-introducing-zig.md, 02-control-flow-structs.md
   - 02_structs → 02-control-flow-structs.md
   - 03_memory → 03-memory.md
   - 04_pointers → 06-pointers.md
   - 05_errors → 10-error-handling.md
   - 06_data_structures → 11-data-structures.md
   - 07_testing → 05-debugging.md, 08-unit-tests.md
   - 08_build_system → 09-build-system.md
   - 09_file_io → 13-file-operations.md
   - 10_c_interop → 14-c-interop.md
   - 11_concurrency → 16-threads.md
   - 12_simd → 17-vectors.md

4. **Zig 0.15.2対応コード例** `/Users/shota.508/Documents/Learn/zig-book/examples/` を参照

### Step 3: Zigファイル作成

コメントスタイル:
```zig
//! ファイル冒頭のトピック説明（概要）

const std = @import("std");

/// 関数・型のdoc comment
pub fn example() void {
    // インラインコメント（適切に、概念が理解できるように）
}

test "テスト名" {
    // テストコード
}
```

必須要素:
- 「//!」でトピックの概要説明
- 「pub fn main()」で実行可能に（適切な場合）
- 「test」ブロックでテスト可能に
- 読者がコードを読むだけで概念を理解できるコメント

### Step 4: 検証

```bash
zig run <file>   # main関数がある場合
zig test <file>  # ユニットテスト
```

両方成功することを確認。失敗したら修正。

### Step 5: 進捗更新

`.claude/progress.json` を更新

### Step 6: 簡潔な報告

```
✓ n00X_topic.zig 作成完了 (テスト: X passed)
→ 次: n00Y_next_topic.zig
```

### Step 7: 次のイテレーションへ

**自動的にStep 1に戻り、次のファイルの作成を開始する。**

---

## 実行開始

上記フローを繰り返し実行する。各イテレーションの報告は簡潔に。

## API変更を発見した場合

1. `/Users/shota.508/Documents/Learn/zig-book/examples/` で正しい書き方を確認
2. 正しいAPIでコードを修正
3. 新たに発見したAPI変更は `CLAUDE.md` の「API変更まとめ」テーブルに追記
