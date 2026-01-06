---
description: 次のZigサンプルファイルを自動で作成・検証・進捗更新まで一気通貫で実行
allowed-tools: Read, Write, Edit, Bash(zig:*), Bash(mkdir:*), Glob
---

# 次のZigファイルを自動作成（一気通貫）

このコマンドは以下を **全て自動で** 実行する：

1. **進捗確認** - `.claude/progress.json` から次に作成すべきファイルを特定
2. **参照読み込み** - README.mdとzig-bookの対応markdownを読む
3. **ファイル作成** - Zigコードを作成
4. **検証** - `zig run` と `zig test` で動作確認
5. **進捗更新** - progress.jsonを更新

---

## Step 1: 進捗確認

`.claude/progress.json` を読んで以下を確認:
- `next_number`: 次のファイル番号
- `next_file`: 次のファイル名
- どのディレクトリに配置するか

## Step 2: 参照読み込み

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

## Step 3: Zigファイル作成

以下のルールに従う：

### コメントスタイル
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

### 必須要素
- `//!` でトピックの概要説明
- `pub fn main()` で実行可能に（適切な場合）
- `test` ブロックでテスト可能に
- 読者がコードを読むだけで概念を理解できるコメント

## Step 4: 検証

```bash
# 実行テスト（main関数がある場合）
zig run <file>

# ユニットテスト
zig test <file>
```

両方成功することを確認。失敗したら修正。

## Step 5: 進捗更新

`.claude/progress.json` を更新:
- `current_file`: 作成したファイル名
- `next_file`: 次のファイル名（README.mdから取得）
- `next_number`: 次の番号
- `completed`: 配列に追加
- `directories.XX.completed`: インクリメント
- `total_completed`: インクリメント

---

## 実行開始

上記Step 1〜5を順番に実行し、完了したら以下を報告:
- 作成したファイル名とパス
- 実行結果（zig run の出力）
- テスト結果（zig test の結果）
- 次に作成するファイル
