---
description: 指定したZigファイルをテスト・検証する
allowed-tools: Read, Bash(zig run:*), Bash(zig test:*), Bash(zig fmt:*)
argument-hint: [file-path]
---

# Zigファイルを検証

`$ARGUMENTS` で指定されたファイル、または最後に作成したファイルを検証。

## 検証コマンド

```bash
zig fmt --check <file>  # フォーマット
zig run <file>          # 実行（main関数がある場合）
zig test <file>         # テスト
```

## 出力例

```
=== 検証: n005_integers.zig ===

フォーマット: OK
実行結果: (出力を表示)
テスト: 5 passed
```
