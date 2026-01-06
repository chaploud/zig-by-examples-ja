# トピック別検索キーワード

markdownからトピックに関連する情報をGrepで検索する際のキーワード。

## 01_basics (n001-n015)

| ファイル | トピック | 検索キーワード |
|---------|---------|---------------|
| n001 | Hello World | `print\|stdout\|Hello` |
| n002 | コメント | `コメント\|comment\|//\|/\\*` |
| n003 | 定数 | `const\|定数\|constant` |
| n004 | 変数 | `var\|変数\|variable\|undefined` |
| n005 | 整数型 | `整数\|integer\|i8\|i16\|i32\|u8\|u16\|u32\|isize\|usize` |
| n006 | 浮動小数点 | `浮動\|float\|f16\|f32\|f64` |
| n007 | 真偽値 | `bool\|true\|false\|ブール\|真偽` |
| n008 | Optional | `optional\|null\|orelse\|\?` |
| n009 | 配列 | `配列\|array\|\[_\]\|\[4\]` |
| n010 | スライス | `スライス\|slice\|\[\.\.\]` |
| n011 | 文字列 | `文字列\|string\|\\[\\]const u8` |
| n012 | if文 | `if\|else\|条件` |
| n013 | forループ | `for\|ループ\|繰り返し\|range` |
| n014 | whileループ | `while\|ループ` |
| n015 | switch文 | `switch\|case\|分岐` |

## 02_structs (n016-n025)

| ファイル | トピック | 検索キーワード |
|---------|---------|---------------|
| n016 | 構造体 | `struct\|構造体` |
| n017 | メソッド | `メソッド\|method\|self` |
| n018 | enum | `enum\|列挙` |
| n019 | union | `union` |
| n020 | タグ付きunion | `tagged\|union\|タグ` |
| n021 | 型変換 | `coercion\|@intCast\|@floatCast\|変換` |
| n022 | comptime | `comptime\|コンパイル時` |
| n023 | ジェネリクス | `generic\|anytype\|ジェネリック` |
| n024 | モジュール | `@import\|module\|モジュール` |
| n025 | defer | `defer\|遅延` |

## 03_memory (n026-n035)

| ファイル | トピック | 検索キーワード |
|---------|---------|---------------|
| n026 | スタック | `stack\|スタック` |
| n027 | ヒープ | `heap\|ヒープ` |
| n028 | アロケータ | `allocator\|Allocator\|アロケータ` |
| n029 | GPA | `GeneralPurposeAllocator\|gpa` |
| n030 | Arena | `ArenaAllocator\|arena` |
| n031 | FixedBuffer | `FixedBufferAllocator` |
| n032 | create/destroy | `create\|destroy` |
| n033 | alloc/free | `alloc\|free` |
| n034 | メモリ安全性 | `safety\|安全\|dangling\|leak` |
| n035 | センチネル | `sentinel\|:0\|終端` |

## 04_pointers (n036-n045)

| ファイル | トピック | 検索キーワード |
|---------|---------|---------------|
| n036 | 単一ポインタ | `\\*T\|pointer\|ポインタ` |
| n037 | 多要素ポインタ | `\\[\\*\\]\|many\|多要素` |
| n038 | ポインタ演算 | `演算\|arithmetic\|\\+\|-` |
| n039 | 配列ポインタ | `\\*\\[\|配列.*ポインタ` |
| n040 | constポインタ | `\\*const\|定数.*ポインタ` |
| n041 | アラインメント | `align\|アラインメント` |
| n042 | volatile | `volatile` |
| n043 | Optionalポインタ | `\\?\\*\|optional.*pointer` |
| n044 | センチネルポインタ | `\\[\\*:0\\]` |
| n045 | Cポインタ | `\\[\\*c\\]\|cポインタ` |

## 05_errors (n046-n055)

| ファイル | トピック | 検索キーワード |
|---------|---------|---------------|
| n046 | エラー基本 | `error\|エラー` |
| n047 | エラーセット | `error set\|エラーセット` |
| n048 | try | `try` |
| n049 | catch | `catch` |
| n050 | errdefer | `errdefer` |
| n051 | エラーユニオン | `!T\|error union` |
| n052 | エラートレース | `trace\|トレース\|@errorReturnTrace` |
| n053 | マージ | `merge\|\\|\\|.*error` |
| n054 | ペイロード | `payload\|ペイロード` |
| n055 | unreachable | `unreachable` |

## 06_data_structures 〜 12_simd

（必要に応じて追加）
