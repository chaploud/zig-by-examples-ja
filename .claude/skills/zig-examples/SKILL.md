---
name: zig-examples
description: Zig by Examples日本語版のファイル作成を支援。ディレクトリ構成、章対応表、トピック別検索キーワード、API変更情報を提供。Zigサンプルファイル作成、進捗管理、zig-book参照時に使用。
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Zig by Examples 作成支援

このスキルはZigサンプルファイル作成時に参照情報を提供する。

## 参照元

1. **翻訳済みmarkdown**: `/Users/shota.508/Documents/Learn/zig-book/chapters-ja/`
   - Grepでトピック関連キーワードを検索（Readで全体を読まない）

2. **Zig 0.15.2対応コード例**: `/Users/shota.508/Documents/Learn/zig-book/examples/`
   - 古いAPIが動かない場合はここを参照

## コメントスタイル

| 種類 | 用途 |
|------|------|
| `//!` | ファイル冒頭のトピック説明 |
| `///` | 関数・型のdoc comment |
| `//` | インラインコメント（適切に） |

## 詳細情報

- ディレクトリ・章対応: [REFERENCE.md](REFERENCE.md)
- トピック別検索キーワード: [TOPICS.md](TOPICS.md)
- API変更まとめ: [API_CHANGES.md](API_CHANGES.md)
