# zig-by-examples-ja

## プロジェクト概要

zig-book（日本語翻訳済み）の内容を、コード主体で高速にZigをキャッチアップできる形式に再構成。

## カスタムコマンド

| コマンド | 説明 |
|---------|------|
| `/next` | 次のファイルを1つ作成→検証→進捗更新 |
| `/continue` | ユーザーが割り込むまで連続実行 |
| `/status` | 進捗状況を表示 |
| `/verify [file]` | 指定ファイルをテスト・検証 |

## 参照情報

詳細は `.claude/skills/zig-examples/` を参照:

- **SKILL.md**: 概要とコメントスタイル
- **REFERENCE.md**: ディレクトリ・章対応表
- **TOPICS.md**: トピック別Grep検索キーワード
- **API_CHANGES.md**: Zig 0.15.2 API変更まとめ

## 参照元パス

| 種類 | パス |
|------|------|
| 翻訳済みmarkdown | `/Users/shota.508/Documents/Learn/zig-book/chapters-ja/` |
| 0.15.2対応コード例 | `/Users/shota.508/Documents/Learn/zig-book/examples/` |
| Zig標準ライブラリ | `/opt/homebrew/Cellar/zig/0.15.2/lib/zig/std/` |

## 重要事項

- **Zig 0.15.2** 使用
- markdownは大きいので**Grepで検索**（Readで全体を読まない）
- 古いAPIはexamples/を参照

## 10_c_interop セクションの構造

C連携セクション(n086-n095)は単体.zigファイルではなく、**build.zigを含むディレクトリ構造**で作成する：

```
10_c_interop/
├── n086_libc_basics/
│   ├── build.zig
│   └── src/main.zig
├── n087_custom_c/
│   ├── build.zig
│   ├── src/main.zig
│   └── c_src/
│       ├── mathlib.h
│       └── mathlib.c
└── n088_.../
```

理由: @cImportやCソースのリンクにはbuild.zigでの設定が必要なため。

## 進捗管理

`.claude/progress.json` で管理
