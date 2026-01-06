---
description: プロジェクトの進捗状況を表示する
allowed-tools: Read, Glob, Bash(ls:*)
---

# プロジェクト進捗状況を確認

## 実行手順

1. `.claude/progress.json` を読んで現在の進捗を確認
2. 実際に存在する `.zig` ファイルをスキャンして整合性を確認
3. 以下の形式で進捗を報告:

```
## Zig by Examples 日本語版 - 進捗状況

### 全体進捗: X / 110 ファイル (X%)

### ディレクトリ別進捗:
- [x] 01_basics/: X/15 完了
- [ ] 02_structs/: X/10 完了
...

### 次に作成するファイル:
- nXXX_topic.zig (XX_category/)

### 最近完成したファイル:
- nXXX_topic.zig
...
```

4. progress.json と実際のファイルに不整合があれば報告する
