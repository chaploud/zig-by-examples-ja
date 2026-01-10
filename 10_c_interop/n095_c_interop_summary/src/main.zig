//! # C連携 総まとめ
//!
//! ZigとCの相互運用に関する知識の総復習。
//!
//! ## 学んだこと
//! - n086: libc連携の基礎
//! - n087: 自作Cコード連携
//! - n088: translate-c
//! - n089: 外部Cライブラリ
//! - n090: Cへのエクスポート
//! - n091: C文字列変換
//! - n092: メモリレイアウト
//! - n093: opaque型
//! - n094: 実践パターン

const std = @import("std");

// ====================
// 1. Cヘッダーのインポート
// ====================

fn demoImport() void {
    std.debug.print("=== 1. Cヘッダーのインポート ===\n\n", .{});

    std.debug.print("【@cImport + @cInclude】\n", .{});
    std.debug.print("  const c = @cImport({{\n", .{});
    std.debug.print("      @cInclude(\"stdio.h\");\n", .{});
    std.debug.print("      @cInclude(\"stdlib.h\");\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【translate-c】\n", .{});
    std.debug.print("  zig translate-c header.h > binding.zig\n", .{});
    std.debug.print("  const c = @import(\"binding.zig\");\n", .{});

    std.debug.print("\n【使い分け】\n", .{});
    std.debug.print("  @cImport   : 簡単なヘッダー、開発時\n", .{});
    std.debug.print("  translate-c: 複雑なヘッダー、デバッグ時\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. build.zig の設定
// ====================

fn demoBuildZig() void {
    std.debug.print("=== 2. build.zig の設定 ===\n\n", .{});

    std.debug.print("【libc をリンク】\n", .{});
    std.debug.print("  .link_libc = true,\n", .{});

    std.debug.print("\n【Cソースを追加】\n", .{});
    std.debug.print("  exe.root_module.addCSourceFiles(.{{\n", .{});
    std.debug.print("      .root = b.path(\"c_src\"),\n", .{});
    std.debug.print("      .files = &.{{\"file.c\"}},\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n【インクルードパス】\n", .{});
    std.debug.print("  exe.root_module.addIncludePath(b.path(\"include\"));\n", .{});

    std.debug.print("\n【外部ライブラリ】\n", .{});
    std.debug.print("  exe.root_module.linkSystemLibrary(\"z\", .{{}});\n", .{});

    std.debug.print("\n【静的/共有ライブラリ生成】\n", .{});
    std.debug.print("  b.addLibrary(.{{ .linkage = .static, ... }});\n", .{});
    std.debug.print("  b.addLibrary(.{{ .linkage = .dynamic, ... }});\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 3. 型の対応
// ====================

fn demoTypes() void {
    std.debug.print("=== 3. 型の対応 ===\n\n", .{});

    std.debug.print("【整数型】\n", .{});
    std.debug.print("  int      → c_int\n", .{});
    std.debug.print("  long     → c_long\n", .{});
    std.debug.print("  size_t   → usize\n", .{});
    std.debug.print("  int32_t  → i32\n", .{});
    std.debug.print("  uint64_t → u64\n", .{});

    std.debug.print("\n【浮動小数点】\n", .{});
    std.debug.print("  float  → f32\n", .{});
    std.debug.print("  double → f64\n", .{});

    std.debug.print("\n【ポインタ】\n", .{});
    std.debug.print("  T*           → *T / ?*T / [*]T\n", .{});
    std.debug.print("  const T*     → *const T\n", .{});
    std.debug.print("  void*        → *anyopaque / ?*anyopaque\n", .{});
    std.debug.print("  const char*  → [*:0]const u8\n", .{});

    std.debug.print("\n【構造体】\n", .{});
    std.debug.print("  struct X {{ ... }} → extern struct {{ ... }}\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 4. 文字列変換
// ====================

fn demoStrings() void {
    std.debug.print("=== 4. 文字列変換 ===\n\n", .{});

    std.debug.print("【Zig → C】\n", .{});
    std.debug.print("  リテラル       : そのまま渡せる\n", .{});
    std.debug.print("  [:0]const u8   : .ptr を使用\n", .{});
    std.debug.print("  []const u8     : allocator.dupeZ() で変換\n", .{});

    std.debug.print("\n【C → Zig】\n", .{});
    std.debug.print("  std.mem.span(c_str)  → [:0]const u8\n", .{});
    std.debug.print("  allocator.dupe(u8, span)  → []u8 (コピー)\n", .{});

    std.debug.print("\n【フォーマット】\n", .{});
    std.debug.print("  std.fmt.allocPrintSentinel(alloc, fmt, args, 0)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 5. メモリレイアウト
// ====================

fn demoMemory() void {
    std.debug.print("=== 5. メモリレイアウト ===\n\n", .{});

    std.debug.print("【構造体の種類】\n", .{});
    std.debug.print("  struct        Zig最適化、C非互換\n", .{});
    std.debug.print("  extern struct C互換レイアウト\n", .{});
    std.debug.print("  packed struct ビットレベル制御\n", .{});

    std.debug.print("\n【便利な関数】\n", .{});
    std.debug.print("  @sizeOf(T)       サイズ\n", .{});
    std.debug.print("  @alignOf(T)      アライメント\n", .{});
    std.debug.print("  @offsetOf(T, f)  フィールドオフセット\n", .{});

    std.debug.print("\n【初期化】\n", .{});
    std.debug.print("  std.mem.zeroes(T)  ゼロ初期化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. 関数
// ====================

fn demoFunctions() void {
    std.debug.print("=== 6. 関数 ===\n\n", .{});

    std.debug.print("【C関数の呼び出し】\n", .{});
    std.debug.print("  const result = c.some_function(arg1, arg2);\n", .{});

    std.debug.print("\n【Zigからエクスポート】\n", .{});
    std.debug.print("  export fn add(a: i32, b: i32) i32 {{\n", .{});
    std.debug.print("      return a + b;\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【コールバック】\n", .{});
    std.debug.print("  const Callback = *const fn(i32) callconv(.c) void;\n", .{});
    std.debug.print("  \n", .{});
    std.debug.print("  fn myCallback(x: i32) callconv(.c) void {{ ... }}\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. opaque と anyopaque
// ====================

fn demoOpaque() void {
    std.debug.print("=== 7. opaque と anyopaque ===\n\n", .{});

    std.debug.print("【opaque型】\n", .{});
    std.debug.print("  const Handle = opaque {{}};\n", .{});
    std.debug.print("  使用: *Handle, ?*Handle\n", .{});

    std.debug.print("\n【anyopaque (void*)】\n", .{});
    std.debug.print("  *anyopaque      非NULL\n", .{});
    std.debug.print("  ?*anyopaque     NULL許容\n", .{});

    std.debug.print("\n【キャスト】\n", .{});
    std.debug.print("  const typed: *T = @ptrCast(@alignCast(void_ptr));\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 8. よくあるパターン
// ====================

fn demoPatterns() void {
    std.debug.print("=== 8. よくあるパターン ===\n\n", .{});

    std.debug.print("【リソース管理】\n", .{});
    std.debug.print("  const h = c.create_handle();\n", .{});
    std.debug.print("  defer c.destroy_handle(h);\n", .{});

    std.debug.print("\n【エラー変換】\n", .{});
    std.debug.print("  const ret = c.do_something();\n", .{});
    std.debug.print("  if (ret != 0) return convertError(ret);\n", .{});

    std.debug.print("\n【バッファ渡し】\n", .{});
    std.debug.print("  var buf: [256]u8 = undefined;\n", .{});
    std.debug.print("  const len = c.get_data(&buf, buf.len);\n", .{});

    std.debug.print("\n【user_dataパターン】\n", .{});
    std.debug.print("  var ctx = Context{{ ... }};\n", .{});
    std.debug.print("  c.set_callback(callback, &ctx);\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 9. 注意点
// ====================

fn demoCaveats() void {
    std.debug.print("=== 9. 注意点 ===\n\n", .{});

    std.debug.print("【メモリ管理】\n", .{});
    std.debug.print("  - Cがmallocしたものはfreeで解放\n", .{});
    std.debug.print("  - Zigがallocしたものはallocatorで解放\n", .{});
    std.debug.print("  - 所有権の明確化が重要\n", .{});

    std.debug.print("\n【文字列】\n", .{});
    std.debug.print("  - Cに渡す時はヌル終端を確認\n", .{});
    std.debug.print("  - []const u8 はヌル終端を保証しない\n", .{});

    std.debug.print("\n【アライメント】\n", .{});
    std.debug.print("  - extern struct を使う\n", .{});
    std.debug.print("  - @ptrCast時は@alignCastも\n", .{});

    std.debug.print("\n【生存期間】\n", .{});
    std.debug.print("  - user_dataのポインタが有効か確認\n", .{});
    std.debug.print("  - コールバック内でのアクセスに注意\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 10. チェックリスト
// ====================

fn demoChecklist() void {
    std.debug.print("=== 10. C連携チェックリスト ===\n\n", .{});

    std.debug.print("□ build.zig に link_libc = true\n", .{});
    std.debug.print("□ 必要なライブラリを linkSystemLibrary\n", .{});
    std.debug.print("□ インクルードパスを addIncludePath\n", .{});
    std.debug.print("□ @cImport で必要なヘッダーをインクルード\n", .{});
    std.debug.print("□ 構造体は extern struct を使用\n", .{});
    std.debug.print("□ 文字列はヌル終端を確認\n", .{});
    std.debug.print("□ ポインタのNULLチェック\n", .{});
    std.debug.print("□ defer でリソース解放\n", .{});
    std.debug.print("□ エラーコードの適切な変換\n", .{});
    std.debug.print("□ コールバックに callconv(.c)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoFinalSummary() void {
    std.debug.print("=== C連携 総まとめ ===\n\n", .{});

    std.debug.print("【Zigの強み】\n", .{});
    std.debug.print("  - Cとの優れた相互運用性\n", .{});
    std.debug.print("  - 型安全性を維持しつつCを利用\n", .{});
    std.debug.print("  - deferによる確実なリソース解放\n", .{});
    std.debug.print("  - エラー処理の統一\n", .{});

    std.debug.print("\n【基本フロー】\n", .{});
    std.debug.print("  1. build.zig で設定\n", .{});
    std.debug.print("  2. @cImport でインポート\n", .{});
    std.debug.print("  3. 型を適切に変換\n", .{});
    std.debug.print("  4. リソースは defer で管理\n", .{});

    std.debug.print("\n【このセクションで学んだファイル】\n", .{});
    std.debug.print("  n086: libc連携の基礎\n", .{});
    std.debug.print("  n087: 自作Cコード連携\n", .{});
    std.debug.print("  n088: translate-c\n", .{});
    std.debug.print("  n089: 外部Cライブラリ\n", .{});
    std.debug.print("  n090: Cへのエクスポート\n", .{});
    std.debug.print("  n091: C文字列変換\n", .{});
    std.debug.print("  n092: メモリレイアウト\n", .{});
    std.debug.print("  n093: opaque型\n", .{});
    std.debug.print("  n094: 実践パターン\n", .{});
    std.debug.print("  n095: 総まとめ（このファイル）\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoImport();
    demoBuildZig();
    demoTypes();
    demoStrings();
    demoMemory();
    demoFunctions();
    demoOpaque();
    demoPatterns();
    demoCaveats();
    demoChecklist();
    demoFinalSummary();

    std.debug.print("=== 次のセクション ===\n", .{});
    std.debug.print("・11_concurrency: スレッドと並行処理\n", .{});
}

// ====================
// テスト
// ====================

test "extern struct size" {
    const Point = extern struct {
        x: i32,
        y: i32,
    };
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(Point));
    try std.testing.expectEqual(@as(usize, 4), @alignOf(Point));
}

test "c_int size" {
    try std.testing.expectEqual(@as(usize, 4), @sizeOf(c_int));
}

test "string literal is null terminated" {
    const str: [*:0]const u8 = "Hello";
    try std.testing.expectEqual(@as(u8, 0), str[5]);
}

test "mem.zeroes" {
    const Data = extern struct {
        a: i32,
        b: i32,
        c: f64,
    };
    const d = std.mem.zeroes(Data);
    try std.testing.expectEqual(@as(i32, 0), d.a);
    try std.testing.expectEqual(@as(i32, 0), d.b);
    try std.testing.expectEqual(@as(f64, 0.0), d.c);
}

test "mem.span" {
    const c_str: [*:0]const u8 = "Hello";
    const span = std.mem.span(c_str);
    try std.testing.expectEqualStrings("Hello", span);
}
