---
description: 指定したZigファイルをテスト・検証する
allowed-tools: Read, Bash(zig:*)
argument-hint: [file-path]
---

# Zigファイルを検証

指定されたファイル（または最新のファイル）を検証する。

## 引数

`$ARGUMENTS` - 検証するファイルのパス（省略時は最新のファイル）

## 検証項目

1. **コンパイル確認**: `zig build-exe` が通るか
2. **実行確認**: `zig run` で実行できるか
3. **テスト確認**: `zig test` が通るか
4. **フォーマット確認**: `zig fmt --check` でフォーマットが正しいか

## 実行コマンド

```bash
# 実行テスト
zig run <file>

# ユニットテスト
zig test <file>

# フォーマットチェック
zig fmt --check <file>
```

## 成功基準

- 全てのテストがパスすること
- 実行時エラーがないこと
- フォーマットが正しいこと
