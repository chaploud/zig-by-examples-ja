//! # 外部Cライブラリのリンク
//!
//! システムにインストールされたCライブラリをZigからリンク・使用する方法。
//!
//! ## このファイルで学ぶこと
//! - linkSystemLibrary() の使い方
//! - addLibraryPath() でパスを追加
//! - addSystemIncludePath() でヘッダーパスを追加
//! - pkg-config との連携
//! - 静的/動的リンクの違い
//!
//! ## 注意
//! このサンプルは zlib がシステムにインストールされている前提です。
//! macOS: brew install zlib
//! Ubuntu: apt install zlib1g-dev

const std = @import("std");

// ====================
// @cImport で zlib をインポート
// ====================

const c = @cImport({
    @cInclude("zlib.h");
});

// ====================
// zlib バージョン確認
// ====================

fn demoZlibVersion() void {
    std.debug.print("=== zlib バージョン ===\n\n", .{});

    // zlibVersion() は文字列を返す
    const version = c.zlibVersion();
    std.debug.print("  zlib version: {s}\n", .{version});

    // コンパイル時のバージョン
    std.debug.print("  ZLIB_VERSION: {s}\n", .{c.ZLIB_VERSION});

    std.debug.print("\n", .{});
}

// ====================
// 圧縮のデモ
// ====================

fn demoCompression() !void {
    std.debug.print("=== zlib 圧縮 ===\n\n", .{});

    // 圧縮するデータ
    const source = "Hello, Zig! This is a test string for compression. " ++
        "Let's see how well zlib compresses this repeated text. " **
        5;

    std.debug.print("【元データ】\n", .{});
    std.debug.print("  サイズ: {d} bytes\n", .{source.len});

    // 圧縮先バッファ（十分なサイズを確保）
    var dest: [1024]u8 = undefined;
    var dest_len: c_ulong = dest.len;

    // compress() で圧縮
    const ret = c.compress(&dest, &dest_len, source.ptr, source.len);

    if (ret == c.Z_OK) {
        std.debug.print("\n【圧縮結果】\n", .{});
        std.debug.print("  圧縮後サイズ: {d} bytes\n", .{dest_len});
        std.debug.print("  圧縮率: {d:.1}%\n", .{
            @as(f64, @floatFromInt(dest_len)) / @as(f64, @floatFromInt(source.len)) * 100,
        });

        // 展開して確認
        var decomp: [1024]u8 = undefined;
        var decomp_len: c_ulong = decomp.len;

        const ret2 = c.uncompress(&decomp, &decomp_len, &dest, dest_len);
        if (ret2 == c.Z_OK) {
            std.debug.print("\n【展開確認】\n", .{});
            std.debug.print("  展開後サイズ: {d} bytes\n", .{decomp_len});
            std.debug.print("  データ一致: {}\n", .{
                std.mem.eql(u8, decomp[0..decomp_len], source),
            });
        }
    } else {
        std.debug.print("  圧縮エラー: {d}\n", .{ret});
    }

    std.debug.print("\n", .{});
}

// ====================
// CRC32 計算
// ====================

fn demoCrc32() void {
    std.debug.print("=== CRC32 計算 ===\n\n", .{});

    const data1 = "Hello, World!";
    const data2 = "Zig is awesome!";

    // crc32() でチェックサム計算
    const crc1 = c.crc32(0, data1.ptr, data1.len);
    const crc2 = c.crc32(0, data2.ptr, data2.len);

    std.debug.print("  \"{s}\" → CRC32: 0x{x:0>8}\n", .{ data1, crc1 });
    std.debug.print("  \"{s}\" → CRC32: 0x{x:0>8}\n", .{ data2, crc2 });

    // 連続計算（前の結果を引き継ぐ）
    var crc_combined = c.crc32(0, data1.ptr, data1.len);
    crc_combined = c.crc32(crc_combined, data2.ptr, data2.len);
    std.debug.print("\n  連結計算: 0x{x:0>8}\n", .{crc_combined});

    std.debug.print("\n", .{});
}

// ====================
// Adler32 計算
// ====================

fn demoAdler32() void {
    std.debug.print("=== Adler32 計算 ===\n\n", .{});

    const data = "Hello, Zig!";

    // adler32() でチェックサム計算（CRC32より高速）
    const adler = c.adler32(1, data.ptr, data.len);

    std.debug.print("  \"{s}\" → Adler32: 0x{x:0>8}\n", .{ data, adler });

    std.debug.print("\n【CRC32 vs Adler32】\n", .{});
    std.debug.print("  CRC32:   エラー検出に優れる、計算が遅い\n", .{});
    std.debug.print("  Adler32: 計算が速い、エラー検出は弱い\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// build.zig の設定解説
// ====================

fn demoBuildSettings() void {
    std.debug.print("=== build.zig の設定 ===\n\n", .{});

    std.debug.print("【基本設定】\n", .{});
    std.debug.print("  .link_libc = true,  // Cランタイム必須\n", .{});

    std.debug.print("\n【ライブラリリンク】\n", .{});
    std.debug.print("  // システムライブラリをリンク\n", .{});
    std.debug.print("  exe.root_module.linkSystemLibrary(\"z\", .{{}});\n", .{});

    std.debug.print("\n【パス設定（必要な場合）】\n", .{});
    std.debug.print("  // インクルードパス\n", .{});
    std.debug.print("  exe.root_module.addSystemIncludePath(\n", .{});
    std.debug.print("      .{{ .cwd_relative = \"/opt/homebrew/include\" }}\n", .{});
    std.debug.print("  );\n", .{});
    std.debug.print("\n  // ライブラリパス\n", .{});
    std.debug.print("  exe.root_module.addLibraryPath(\n", .{});
    std.debug.print("      .{{ .cwd_relative = \"/opt/homebrew/lib\" }}\n", .{});
    std.debug.print("  );\n", .{});

    std.debug.print("\n【静的リンク】\n", .{});
    std.debug.print("  exe.root_module.linkSystemLibrary(\"z\", .{{\n", .{});
    std.debug.print("      .preferred_link_mode = .static,\n", .{});
    std.debug.print("  }});\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// よく使うライブラリ例
// ====================

fn demoCommonLibraries() void {
    std.debug.print("=== よく使う外部Cライブラリ ===\n\n", .{});

    std.debug.print("【圧縮】\n", .{});
    std.debug.print("  zlib     : linkSystemLibrary(\"z\")\n", .{});
    std.debug.print("  bzip2    : linkSystemLibrary(\"bz2\")\n", .{});
    std.debug.print("  lz4      : linkSystemLibrary(\"lz4\")\n", .{});
    std.debug.print("  zstd     : linkSystemLibrary(\"zstd\")\n", .{});

    std.debug.print("\n【暗号】\n", .{});
    std.debug.print("  OpenSSL  : linkSystemLibrary(\"ssl\")\n", .{});
    std.debug.print("             linkSystemLibrary(\"crypto\")\n", .{});

    std.debug.print("\n【データベース】\n", .{});
    std.debug.print("  SQLite   : linkSystemLibrary(\"sqlite3\")\n", .{});
    std.debug.print("  PostgreSQL: linkSystemLibrary(\"pq\")\n", .{});

    std.debug.print("\n【画像】\n", .{});
    std.debug.print("  libpng   : linkSystemLibrary(\"png\")\n", .{});
    std.debug.print("  libjpeg  : linkSystemLibrary(\"jpeg\")\n", .{});

    std.debug.print("\n【ネットワーク】\n", .{});
    std.debug.print("  curl     : linkSystemLibrary(\"curl\")\n", .{});

    std.debug.print("\n【macOS フレームワーク】\n", .{});
    std.debug.print("  exe.root_module.linkFramework(\"CoreFoundation\");\n", .{});
    std.debug.print("  exe.root_module.linkFramework(\"Security\");\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// pkg-config 連携
// ====================

fn demoPkgConfig() void {
    std.debug.print("=== pkg-config 連携 ===\n\n", .{});

    std.debug.print("【pkg-config とは】\n", .{});
    std.debug.print("  ライブラリのコンパイルフラグを取得するツール\n", .{});
    std.debug.print("  $ pkg-config --cflags --libs zlib\n", .{});
    std.debug.print("  → -I/path/to/include -L/path/to/lib -lz\n", .{});

    std.debug.print("\n【Zigでの利用】\n", .{});
    std.debug.print("  linkSystemLibrary() は自動で pkg-config を使う\n", .{});
    std.debug.print("  パスが見つからない場合に pkg-config を参照\n", .{});

    std.debug.print("\n【手動設定が必要な場合】\n", .{});
    std.debug.print("  1. 非標準パスにインストールされた場合\n", .{});
    std.debug.print("  2. pkg-config がない環境\n", .{});
    std.debug.print("  3. 特殊なビルドオプションが必要な場合\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// トラブルシューティング
// ====================

fn demoTroubleshooting() void {
    std.debug.print("=== トラブルシューティング ===\n\n", .{});

    std.debug.print("【ヘッダーが見つからない】\n", .{});
    std.debug.print("  error: 'zlib.h' file not found\n", .{});
    std.debug.print("  → addSystemIncludePath() でパスを追加\n", .{});

    std.debug.print("\n【ライブラリが見つからない】\n", .{});
    std.debug.print("  error: unable to find library 'z'\n", .{});
    std.debug.print("  → addLibraryPath() でパスを追加\n", .{});
    std.debug.print("  → ライブラリがインストールされているか確認\n", .{});

    std.debug.print("\n【シンボルが見つからない】\n", .{});
    std.debug.print("  error: undefined symbol: someFunction\n", .{});
    std.debug.print("  → 正しいライブラリをリンクしているか確認\n", .{});
    std.debug.print("  → link_libc = true が設定されているか確認\n", .{});

    std.debug.print("\n【バージョン不一致】\n", .{});
    std.debug.print("  → ヘッダーとライブラリのバージョンを合わせる\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== 外部Cライブラリ連携 まとめ ===\n\n", .{});

    std.debug.print("【必須設定】\n", .{});
    std.debug.print("  1. .link_libc = true\n", .{});
    std.debug.print("  2. linkSystemLibrary(\"name\")\n", .{});

    std.debug.print("\n【オプション設定】\n", .{});
    std.debug.print("  addSystemIncludePath() - ヘッダーパス\n", .{});
    std.debug.print("  addLibraryPath()       - ライブラリパス\n", .{});
    std.debug.print("  linkFramework()        - macOSフレームワーク\n", .{});

    std.debug.print("\n【リンクモード】\n", .{});
    std.debug.print("  .dynamic - 動的リンク（デフォルト）\n", .{});
    std.debug.print("  .static  - 静的リンク\n", .{});

    std.debug.print("\n【確認コマンド】\n", .{});
    std.debug.print("  pkg-config --cflags --libs <lib>\n", .{});
    std.debug.print("  otool -L <binary>  # macOS\n", .{});
    std.debug.print("  ldd <binary>       # Linux\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    demoZlibVersion();
    try demoCompression();
    demoCrc32();
    demoAdler32();
    demoBuildSettings();
    demoCommonLibraries();
    demoPkgConfig();
    demoTroubleshooting();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・ZigからCへのエクスポート\n", .{});
    std.debug.print("・C文字列とZig文字列の変換\n", .{});
    std.debug.print("・実践的なC連携パターン\n", .{});
}

// ====================
// テスト
// ====================

test "zlibVersion" {
    const version = c.zlibVersion();
    try std.testing.expect(version[0] != 0);
}

test "crc32" {
    const data = "Hello";
    const crc = c.crc32(0, data.ptr, data.len);
    try std.testing.expect(crc != 0);
}

test "adler32" {
    const data = "Hello";
    const adler = c.adler32(1, data.ptr, data.len);
    try std.testing.expect(adler != 0);
}

test "compress and uncompress" {
    // 繰り返しデータは圧縮効率が良い
    const source = "Test data for compression. " ** 10;
    var dest: [512]u8 = undefined;
    var dest_len: c_ulong = dest.len;

    const ret1 = c.compress(&dest, &dest_len, source.ptr, source.len);
    try std.testing.expectEqual(c.Z_OK, ret1);

    var decomp: [512]u8 = undefined;
    var decomp_len: c_ulong = decomp.len;

    const ret2 = c.uncompress(&decomp, &decomp_len, &dest, dest_len);
    try std.testing.expectEqual(c.Z_OK, ret2);
    try std.testing.expectEqual(source.len, decomp_len);
    try std.testing.expectEqualStrings(source, decomp[0..decomp_len]);
}

test "crc32 incremental" {
    const data1 = "Hello, ";
    const data2 = "World!";

    var crc = c.crc32(0, data1.ptr, data1.len);
    crc = c.crc32(crc, data2.ptr, data2.len);

    const combined = "Hello, World!";
    const crc_single = c.crc32(0, combined.ptr, combined.len);

    try std.testing.expectEqual(crc_single, crc);
}
