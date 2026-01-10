# Zig by Examples 日本語版

Zigを高速にキャッチアップするためのコード例集。Zig v0.15.2 でのコード例 (2026/01/07 最新安定版)

各ファイルは `zig run ファイル.zig` で実行、`zig test ファイル.zig` でテスト可能。

## 基礎

- [n001_hello_world.zig](./01_basics/n001_hello_world.zig) - Hello World
- [n002_comments.zig](./01_basics/n002_comments.zig) - コメント
- [n003_constants.zig](./01_basics/n003_constants.zig) - 定数
- [n004_variables.zig](./01_basics/n004_variables.zig) - 変数
- [n005_integers.zig](./01_basics/n005_integers.zig) - 整数型
- [n006_floats.zig](./01_basics/n006_floats.zig) - 浮動小数点型
- [n007_booleans.zig](./01_basics/n007_booleans.zig) - 真偽値型
- [n008_optionals.zig](./01_basics/n008_optionals.zig) - Optional型
- [n009_arrays.zig](./01_basics/n009_arrays.zig) - 配列
- [n010_slices.zig](./01_basics/n010_slices.zig) - スライス
- [n011_strings.zig](./01_basics/n011_strings.zig) - 文字列
- [n012_if.zig](./01_basics/n012_if.zig) - if文
- [n013_for.zig](./01_basics/n013_for.zig) - forループ
- [n014_while.zig](./01_basics/n014_while.zig) - whileループ
- [n015_switch.zig](./01_basics/n015_switch.zig) - switch文

## 構造体・型

- [n016_struct.zig](./02_structs/n016_struct.zig) - 構造体
- [n017_methods.zig](./02_structs/n017_methods.zig) - メソッド
- [n018_enum.zig](./02_structs/n018_enum.zig) - 列挙型
- [n019_union.zig](./02_structs/n019_union.zig) - 共用体
- [n020_comptime.zig](./02_structs/n020_comptime.zig) - コンパイル時計算
- [n021_functions.zig](./02_structs/n021_functions.zig) - 関数
- [n022_builtin.zig](./02_structs/n022_builtin.zig) - 組み込み関数
- [n023_defer.zig](./02_structs/n023_defer.zig) - deferとerrdefer
- [n024_blocks.zig](./02_structs/n024_blocks.zig) - ブロックとラベル
- [n025_import.zig](./02_structs/n025_import.zig) - @importとモジュール

## メモリ

- [n026_allocators.zig](./03_memory/n026_allocators.zig) - アロケータ
- [n027_stack_heap.zig](./03_memory/n027_stack_heap.zig) - スタックとヒープ
- [n028_sentinel.zig](./03_memory/n028_sentinel.zig) - センチネル終端配列
- [n029_alignment.zig](./03_memory/n029_alignment.zig) - メモリアライメント
- [n030_memory_layout.zig](./03_memory/n030_memory_layout.zig) - メモリレイアウト
- [n031_resize_realloc.zig](./03_memory/n031_resize_realloc.zig) - resizeとrealloc
- [n032_dupe_concat.zig](./03_memory/n032_dupe_concat.zig) - dupeとconcat
- [n033_memory_safety.zig](./03_memory/n033_memory_safety.zig) - メモリ安全性
- [n034_comptime_alloc.zig](./03_memory/n034_comptime_alloc.zig) - コンパイル時メモリ
- [n035_logging_allocator.zig](./03_memory/n035_logging_allocator.zig) - ロギングアロケータ

## ポインタ

- [n036_pointers.zig](./04_pointers/n036_pointers.zig) - ポインタ
- [n037_pointer_coercion.zig](./04_pointers/n037_pointer_coercion.zig) - ポインタ変換
- [n038_volatile.zig](./04_pointers/n038_volatile.zig) - Volatileポインタ
- [n039_allowzero.zig](./04_pointers/n039_allowzero.zig) - allowzeroポインタ
- [n040_address_space.zig](./04_pointers/n040_address_space.zig) - アドレス空間
- [n041_function_pointers.zig](./04_pointers/n041_function_pointers.zig) - 関数ポインタ
- [n042_multi_pointers.zig](./04_pointers/n042_multi_pointers.zig) - 複数要素ポインタ
- [n043_optional_pointers.zig](./04_pointers/n043_optional_pointers.zig) - Optionalポインタ
- [n044_pointer_arithmetic.zig](./04_pointers/n044_pointer_arithmetic.zig) - ポインタ演算
- [n045_pointer_summary.zig](./04_pointers/n045_pointer_summary.zig) - ポインタ総まとめ

## エラー処理

- [n046_errors.zig](./05_errors/n046_errors.zig) - エラー処理の基礎
- [n047_errdefer.zig](./05_errors/n047_errdefer.zig) - errdefer
- [n048_error_sets.zig](./05_errors/n048_error_sets.zig) - エラーセット
- [n049_error_payloads.zig](./05_errors/n049_error_payloads.zig) - エラーペイロード
- [n050_error_traces.zig](./05_errors/n050_error_traces.zig) - エラートレース
- [n051_error_handling_patterns.zig](./05_errors/n051_error_handling_patterns.zig) - エラーハンドリングパターン
- [n052_error_coercion.zig](./05_errors/n052_error_coercion.zig) - エラー型変換
- [n053_error_unwrap.zig](./05_errors/n053_error_unwrap.zig) - エラーのアンラップ
- [n054_optional_vs_error.zig](./05_errors/n054_optional_vs_error.zig) - OptionalとErrorの使い分け
- [n055_error_summary.zig](./05_errors/n055_error_summary.zig) - エラー処理総まとめ

## データ構造

- [n056_arraylist.zig](./06_data_structures/n056_arraylist.zig) - ArrayList
- [n057_hashmap.zig](./06_data_structures/n057_hashmap.zig) - HashMap
- [n058_linkedlist.zig](./06_data_structures/n058_linkedlist.zig) - LinkedList
- [n059_multiarraylist.zig](./06_data_structures/n059_multiarraylist.zig) - MultiArrayList
- [n060_priorityqueue.zig](./06_data_structures/n060_priorityqueue.zig) - PriorityQueue
- [n061_segmentedlist.zig](./06_data_structures/n061_segmentedlist.zig) - SegmentedList
- [n062_bitset.zig](./06_data_structures/n062_bitset.zig) - BitSet
- [n063_bufmap.zig](./06_data_structures/n063_bufmap.zig) - BufMap
- [n064_bufset.zig](./06_data_structures/n064_bufset.zig) - BufSet
- [n065_enum_collections.zig](./06_data_structures/n065_enum_collections.zig) - EnumSet/EnumMap/EnumArray

## テスト

- [n066_testing_basics.zig](./07_testing/n066_testing_basics.zig) - テストの基礎
- [n067_test_organization.zig](./07_testing/n067_test_organization.zig) - テストの構成
- [n068_test_patterns.zig](./07_testing/n068_test_patterns.zig) - テストパターン
- [n069_random_testing.zig](./07_testing/n069_random_testing.zig) - ランダムテスト
- [n070_test_summary.zig](./07_testing/n070_test_summary.zig) - テスト総まとめ

## ビルドシステム

- [n071_build_basics.zig](./08_build_system/n071_build_basics.zig) - ビルドシステム基礎
- [n072_build_options.zig](./08_build_system/n072_build_options.zig) - ビルドオプション

**ここまで実装済み (72/110)**

- n073_build_steps.zig - ビルドステップ
- n074_dependencies.zig - 依存関係
- n075_cross_compile.zig - クロスコンパイル

## ファイル・IO

- n076_file_open.zig - ファイルを開く
- n077_file_read.zig - ファイル読み込み
- n078_file_write.zig - ファイル書き込み
- n079_directories.zig - ディレクトリ操作
- n080_buffered_io.zig - バッファ付きIO
- n081_stdin_stdout.zig - 標準入出力
- n082_formatting.zig - フォーマット出力
- n083_json.zig - JSON
- n084_logging.zig - ロギング
- n085_random.zig - 乱数

## C連携

- n086_c_import.zig - @cImport
- n087_calling_c.zig - C関数の呼び出し
- n088_c_strings.zig - C文字列
- n089_c_structs.zig - C構造体
- n090_c_pointers.zig - Cポインタ型
- n091_linking.zig - リンク
- n092_translate_c.zig - translate-c
- n093_extern.zig - extern
- n094_packed_structs.zig - packed構造体
- n095_inline_assembly.zig - インラインアセンブリ

## 並行処理

- n096_threads.zig - スレッドの基本
- n097_spawn.zig - spawn
- n098_mutex.zig - Mutex
- n099_atomic.zig - アトミック操作
- n100_thread_local.zig - スレッドローカル
- n101_once.zig - Once
- n102_condition.zig - 条件変数
- n103_futures.zig - Future
- n104_async.zig - async/await
- n105_event_loop.zig - イベントループ

## SIMD

- n106_vectors.zig - ベクトル型
- n107_vector_ops.zig - ベクトル演算
- n108_reduce.zig - reduce
- n109_shuffle.zig - shuffle
- n110_simd_practical.zig - SIMD実践例

## Credit

### Original Work / 原著

**"Introduction to Zig: a project-based book"**
Copyright (c) 2024 Pedro Duarte Faria
Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
Repository: https://github.com/pedropark99/zig-book
Live Book: https://pedropark99.github.io/zig-book/

Based on the code and explanations from this book, modified to work with Zig 0.15.2 and added Japanese comments.

こちらの本のコードや説明を元にZig 0.15.2で動作するように改変、日本語コメントをつけました。
