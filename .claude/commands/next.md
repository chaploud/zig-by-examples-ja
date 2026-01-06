---
description: 次のZigサンプルファイルを1つ作成・検証・進捗更新（単発実行）
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(zig run:*), Bash(zig test:*), Bash(zig fmt:*), Bash(mkdir:*), Bash(ls:*)
---

# 次のZigファイルを自動作成（単発）

**単発実行**: 1ファイルを作成して終了。連続実行は `/continue` を使用。

## 手順

1. `.claude/progress.json` から次のファイル番号・名前を確認
2. README.md からトピックを確認
3. **zig-examplesスキル**の参照情報を使用:
   - REFERENCE.md: ディレクトリ・章対応
   - TOPICS.md: Grep検索キーワード
   - API_CHANGES.md: Zig 0.15.2対応
4. Grepでzig-book/chapters-ja/の対応markdownを検索
5. Zigファイル作成（`//!`, `///`, `//`コメント付き）
6. `zig run` と `zig test` で検証
7. progress.json を更新
8. 結果を報告

## 検証コマンド

```bash
zig run <file>   # main関数がある場合
zig test <file>  # ユニットテスト
```

## API変更発見時

zig-book/examples/で正しい書き方を確認し、API_CHANGES.mdに追記。
