# Zig by Examples 日本語版

Zigを高速にキャッチアップするためのコード例集。

各ファイルは `zig run ファイル.zig` で実行、`zig test ファイル.zig` でテスト可能。

## 基礎

- [n001_hello_world.zig](./01_basics/n001_hello_world.zig) - Hello World
- [n002_comments.zig](./01_basics/n002_comments.zig) - コメント
- [n003_constants.zig](./01_basics/n003_constants.zig) - 定数 (const)
- [n004_variables.zig](./01_basics/n004_variables.zig) - 変数 (var)
- [n005_integers.zig](./01_basics/n005_integers.zig) - 整数型
- [n006_floats.zig](./01_basics/n006_floats.zig) - 浮動小数点型
- [n007_booleans.zig](./01_basics/n007_booleans.zig) - 真偽値
- [n008_optionals.zig](./01_basics/n008_optionals.zig) - Optional型
- [n009_arrays.zig](./01_basics/n009_arrays.zig) - 配列
- [n010_slices.zig](./01_basics/n010_slices.zig) - スライス
- [n011_strings.zig](./01_basics/n011_strings.zig) - 文字列
- [n012_if.zig](./01_basics/n012_if.zig) - if文
- [n013_for.zig](./01_basics/n013_for.zig) - forループ
- [n014_while.zig](./01_basics/n014_while.zig) - whileループ
- [n015_switch.zig](./01_basics/n015_switch.zig) - switch文

## 構造体・型

- [n016_structs.zig](./02_structs/n016_structs.zig) - 構造体
- [n017_struct_methods.zig](./02_structs/n017_struct_methods.zig) - 構造体のメソッド
- [n018_enums.zig](./02_structs/n018_enums.zig) - 列挙型
- [n019_unions.zig](./02_structs/n019_unions.zig) - Union型
- [n020_tagged_unions.zig](./02_structs/n020_tagged_unions.zig) - タグ付きUnion
- [n021_type_coercion.zig](./02_structs/n021_type_coercion.zig) - 型変換
- [n022_comptime.zig](./02_structs/n022_comptime.zig) - コンパイル時計算
- [n023_generics.zig](./02_structs/n023_generics.zig) - ジェネリクス
- [n024_modules.zig](./02_structs/n024_modules.zig) - モジュール
- [n025_defer.zig](./02_structs/n025_defer.zig) - defer

## メモリ

- [n026_stack_memory.zig](./03_memory/n026_stack_memory.zig) - スタックメモリ
- [n027_heap_memory.zig](./03_memory/n027_heap_memory.zig) - ヒープメモリ
- [n028_allocators.zig](./03_memory/n028_allocators.zig) - アロケータ概要
- [n029_general_purpose_allocator.zig](./03_memory/n029_general_purpose_allocator.zig) - GeneralPurposeAllocator
- [n030_arena_allocator.zig](./03_memory/n030_arena_allocator.zig) - ArenaAllocator
- [n031_fixed_buffer_allocator.zig](./03_memory/n031_fixed_buffer_allocator.zig) - FixedBufferAllocator
- [n032_create_destroy.zig](./03_memory/n032_create_destroy.zig) - create/destroy
- [n033_alloc_free.zig](./03_memory/n033_alloc_free.zig) - alloc/free
- [n034_memory_safety.zig](./03_memory/n034_memory_safety.zig) - メモリ安全性
- [n035_sentinel_terminated.zig](./03_memory/n035_sentinel_terminated.zig) - センチネル終端

## ポインタ

- [n036_single_pointers.zig](./04_pointers/n036_single_pointers.zig) - 単一ポインタ
- [n037_many_pointers.zig](./04_pointers/n037_many_pointers.zig) - 多要素ポインタ
- [n038_pointer_arithmetic.zig](./04_pointers/n038_pointer_arithmetic.zig) - ポインタ演算
- [n039_pointer_to_array.zig](./04_pointers/n039_pointer_to_array.zig) - 配列へのポインタ
- [n040_const_pointers.zig](./04_pointers/n040_const_pointers.zig) - constポインタ
- [n041_alignment.zig](./04_pointers/n041_alignment.zig) - アラインメント
- [n042_volatile.zig](./04_pointers/n042_volatile.zig) - volatile
- [n043_optional_pointers.zig](./04_pointers/n043_optional_pointers.zig) - Optionalポインタ
- [n044_sentinel_pointers.zig](./04_pointers/n044_sentinel_pointers.zig) - センチネルポインタ
- [n045_c_pointers.zig](./04_pointers/n045_c_pointers.zig) - Cポインタ

## エラー処理

- [n046_error_basics.zig](./05_errors/n046_error_basics.zig) - エラーの基本
- [n047_error_sets.zig](./05_errors/n047_error_sets.zig) - エラーセット
- [n048_try.zig](./05_errors/n048_try.zig) - tryキーワード
- [n049_catch.zig](./05_errors/n049_catch.zig) - catchキーワード
- [n050_errdefer.zig](./05_errors/n050_errdefer.zig) - errdefer
- [n051_error_union.zig](./05_errors/n051_error_union.zig) - エラーユニオン
- [n052_error_return_trace.zig](./05_errors/n052_error_return_trace.zig) - エラーリターントレース
- [n053_merging_error_sets.zig](./05_errors/n053_merging_error_sets.zig) - エラーセットのマージ
- [n054_error_payloads.zig](./05_errors/n054_error_payloads.zig) - エラーペイロード
- [n055_unreachable.zig](./05_errors/n055_unreachable.zig) - unreachable

## データ構造

- [n056_arraylist.zig](./06_data_structures/n056_arraylist.zig) - ArrayList
- [n057_hashmap.zig](./06_data_structures/n057_hashmap.zig) - HashMap
- [n058_stringhashmap.zig](./06_data_structures/n058_stringhashmap.zig) - StringHashMap
- [n059_linkedlist.zig](./06_data_structures/n059_linkedlist.zig) - LinkedList
- [n060_priority_queue.zig](./06_data_structures/n060_priority_queue.zig) - PriorityQueue
- [n061_bounded_array.zig](./06_data_structures/n061_bounded_array.zig) - BoundedArray
- [n062_multi_array_list.zig](./06_data_structures/n062_multi_array_list.zig) - MultiArrayList
- [n063_segmented_list.zig](./06_data_structures/n063_segmented_list.zig) - SegmentedList
- [n064_ring_buffer.zig](./06_data_structures/n064_ring_buffer.zig) - RingBuffer
- [n065_bit_set.zig](./06_data_structures/n065_bit_set.zig) - BitSet

## テスト

- [n066_test_basics.zig](./07_testing/n066_test_basics.zig) - テストの基本
- [n067_test_expect.zig](./07_testing/n067_test_expect.zig) - expect系関数
- [n068_test_allocator.zig](./07_testing/n068_test_allocator.zig) - テスト用アロケータ
- [n069_test_skip.zig](./07_testing/n069_test_skip.zig) - テストのスキップ
- [n070_doc_tests.zig](./07_testing/n070_doc_tests.zig) - ドキュメントテスト

## ビルドシステム

- [n071_build_zig_basics.zig](./08_build_system/n071_build_zig_basics.zig) - build.zigの基本
- [n072_build_options.zig](./08_build_system/n072_build_options.zig) - ビルドオプション
- [n073_dependencies.zig](./08_build_system/n073_dependencies.zig) - 依存関係
- [n074_build_modes.zig](./08_build_system/n074_build_modes.zig) - ビルドモード
- [n075_cross_compile.zig](./08_build_system/n075_cross_compile.zig) - クロスコンパイル

## ファイル・IO

- [n076_file_open.zig](./09_file_io/n076_file_open.zig) - ファイルを開く
- [n077_file_read.zig](./09_file_io/n077_file_read.zig) - ファイル読み込み
- [n078_file_write.zig](./09_file_io/n078_file_write.zig) - ファイル書き込み
- [n079_directories.zig](./09_file_io/n079_directories.zig) - ディレクトリ操作
- [n080_buffered_io.zig](./09_file_io/n080_buffered_io.zig) - バッファ付きIO
- [n081_stdin_stdout.zig](./09_file_io/n081_stdin_stdout.zig) - 標準入出力
- [n082_formatting.zig](./09_file_io/n082_formatting.zig) - フォーマット出力
- [n083_json.zig](./09_file_io/n083_json.zig) - JSON
- [n084_logging.zig](./09_file_io/n084_logging.zig) - ロギング
- [n085_random.zig](./09_file_io/n085_random.zig) - 乱数

## C連携

- [n086_c_import.zig](./10_c_interop/n086_c_import.zig) - @cImport
- [n087_calling_c.zig](./10_c_interop/n087_calling_c.zig) - C関数の呼び出し
- [n088_c_strings.zig](./10_c_interop/n088_c_strings.zig) - C文字列
- [n089_c_structs.zig](./10_c_interop/n089_c_structs.zig) - C構造体
- [n090_c_pointers.zig](./10_c_interop/n090_c_pointers.zig) - Cポインタ型
- [n091_linking.zig](./10_c_interop/n091_linking.zig) - リンク
- [n092_translate_c.zig](./10_c_interop/n092_translate_c.zig) - translate-c
- [n093_extern.zig](./10_c_interop/n093_extern.zig) - extern
- [n094_packed_structs.zig](./10_c_interop/n094_packed_structs.zig) - packed構造体
- [n095_inline_assembly.zig](./10_c_interop/n095_inline_assembly.zig) - インラインアセンブリ

## 並行処理

- [n096_threads.zig](./11_concurrency/n096_threads.zig) - スレッドの基本
- [n097_spawn.zig](./11_concurrency/n097_spawn.zig) - spawn
- [n098_mutex.zig](./11_concurrency/n098_mutex.zig) - Mutex
- [n099_atomic.zig](./11_concurrency/n099_atomic.zig) - アトミック操作
- [n100_thread_local.zig](./11_concurrency/n100_thread_local.zig) - スレッドローカル
- [n101_once.zig](./11_concurrency/n101_once.zig) - Once
- [n102_condition.zig](./11_concurrency/n102_condition.zig) - 条件変数
- [n103_futures.zig](./11_concurrency/n103_futures.zig) - Future
- [n104_async.zig](./11_concurrency/n104_async.zig) - async/await
- [n105_event_loop.zig](./11_concurrency/n105_event_loop.zig) - イベントループ

## SIMD

- [n106_vectors.zig](./12_simd/n106_vectors.zig) - ベクトル型
- [n107_vector_ops.zig](./12_simd/n107_vector_ops.zig) - ベクトル演算
- [n108_reduce.zig](./12_simd/n108_reduce.zig) - reduce
- [n109_shuffle.zig](./12_simd/n109_shuffle.zig) - shuffle
- [n110_simd_practical.zig](./12_simd/n110_simd_practical.zig) - SIMD実践例
