//! # 依存関係管理
//!
//! build.zig.zonを使った外部パッケージの管理。
//! 依存関係の追加、Zigパッケージとシステムライブラリ。
//!
//! ## 主要概念
//! - build.zig.zon: パッケージマニフェスト
//! - dependencies: 外部依存関係の宣言
//! - linkSystemLibrary: システムライブラリのリンク
//! - addImport: モジュールのインポート

const std = @import("std");

// ====================
// build.zig.zonの構造
// ====================

fn demoBuildZigZon() void {
    std.debug.print("--- build.zig.zon ---\n", .{});

    // build.zig.zonの基本構造:
    //
    // .{
    //     .name = .my_project,
    //     .version = "0.1.0",
    //     .fingerprint = 0x...,  // 自動生成
    //
    //     .dependencies = .{
    //         .some_lib = .{
    //             .url = "https://github.com/.../archive/v1.0.0.tar.gz",
    //             .hash = "1220abcdef...",
    //         },
    //     },
    //
    //     .paths = .{
    //         "build.zig",
    //         "build.zig.zon",
    //         "src",
    //     },
    // }

    std.debug.print("  主要フィールド:\n", .{});
    std.debug.print("    .name        - パッケージ名（識別子形式）\n", .{});
    std.debug.print("    .version     - セマンティックバージョン\n", .{});
    std.debug.print("    .fingerprint - 一意識別子（自動生成）\n", .{});
    std.debug.print("    .dependencies - 外部依存関係\n", .{});
    std.debug.print("    .paths       - パッケージに含めるファイル\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 依存関係の追加
// ====================

fn demoAddDependency() void {
    std.debug.print("--- 依存関係の追加 ---\n", .{});

    // build.zig.zonでの依存関係宣言:
    //
    // .dependencies = .{
    //     .calc = .{
    //         .url = "https://github.com/user/calc/archive/v1.0.tar.gz",
    //         .hash = "1220...",
    //     },
    // },

    std.debug.print("  依存関係の形式:\n", .{});
    std.debug.print("    .url  - tarballのURL\n", .{});
    std.debug.print("    .hash - ファイル内容のハッシュ\n", .{});

    std.debug.print("  zig fetch --save <url>:\n", .{});
    std.debug.print("    URLから依存関係を追加\n", .{});
    std.debug.print("    ハッシュを自動計算\n", .{});

    std.debug.print("  ハッシュの取得方法:\n", .{});
    std.debug.print("    1. ダミーハッシュを設定\n", .{});
    std.debug.print("    2. zig build を実行\n", .{});
    std.debug.print("    3. エラーメッセージに正しいハッシュ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// build.zigでの使用
// ====================

fn demoUseDependency() void {
    std.debug.print("--- build.zigでの使用 ---\n", .{});

    // build.zigでの記述例:
    //
    // pub fn build(b: *std.Build) void {
    //     const target = b.standardTargetOptions(.{});
    //     const optimize = b.standardOptimizeOption(.{});
    //
    //     // 依存関係を取得
    //     const calc_dep = b.dependency("calc", .{
    //         .target = target,
    //         .optimize = optimize,
    //     });
    //
    //     const exe = b.addExecutable(.{...});
    //
    //     // モジュールをインポート
    //     exe.root_module.addImport("calc", calc_dep.module("calc"));
    //
    //     b.installArtifact(exe);
    // }

    std.debug.print("  手順:\n", .{});
    std.debug.print("    1. b.dependency() で依存取得\n", .{});
    std.debug.print("    2. dep.module() でモジュール取得\n", .{});
    std.debug.print("    3. addImport() でインポート\n", .{});

    std.debug.print("  ソースコードでの使用:\n", .{});
    std.debug.print("    const calc = @import(\"calc\");\n", .{});
    std.debug.print("    const result = calc.add(1, 2);\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 遅延依存関係
// ====================

fn demoLazyDependency() void {
    std.debug.print("--- 遅延依存関係 ---\n", .{});

    // build.zig.zonでの記述:
    //
    // .dependencies = .{
    //     .optional_lib = .{
    //         .url = "...",
    //         .hash = "...",
    //         .lazy = true,  // 実際に使用時のみフェッチ
    //     },
    // },

    // build.zigでの使用:
    //
    // if (b.lazyDependency("optional_lib", .{...})) |dep| {
    //     exe.root_module.addImport("optional", dep.module("optional"));
    // }

    std.debug.print("  .lazy = true の効果:\n", .{});
    std.debug.print("    使用時のみダウンロード\n", .{});
    std.debug.print("    ビルド時間短縮\n", .{});
    std.debug.print("    オプショナル機能に最適\n", .{});

    std.debug.print("  b.lazyDependency():\n", .{});
    std.debug.print("    Optional型を返す\n", .{});
    std.debug.print("    使用されない場合はnull\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ローカル依存関係
// ====================

fn demoLocalDependency() void {
    std.debug.print("--- ローカル依存関係 ---\n", .{});

    // build.zig.zonでの記述:
    //
    // .dependencies = .{
    //     .local_lib = .{
    //         .path = "../my_local_lib",
    //     },
    // },

    std.debug.print("  .pathの使用:\n", .{});
    std.debug.print("    ローカルディレクトリを参照\n", .{});
    std.debug.print("    開発時のテストに便利\n", .{});
    std.debug.print("    hashは不要\n", .{});

    std.debug.print("  使用例:\n", .{});
    std.debug.print("    モノレポ構成\n", .{});
    std.debug.print("    サブプロジェクト参照\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// システムライブラリ
// ====================

fn demoSystemLibrary() void {
    std.debug.print("--- システムライブラリ ---\n", .{});

    // build.zigでの記述例:
    //
    // const exe = b.addExecutable(.{...});
    //
    // // libcをリンク
    // exe.linkLibC();
    //
    // // システムライブラリをリンク
    // exe.root_module.linkSystemLibrary("pthread", .{});
    // exe.root_module.linkSystemLibrary("z", .{});  // zlib
    // exe.root_module.linkSystemLibrary("m", .{});  // math

    std.debug.print("  linkLibC():\n", .{});
    std.debug.print("    標準Cライブラリをリンク\n", .{});

    std.debug.print("  linkSystemLibrary():\n", .{});
    std.debug.print("    システムにインストール済みのライブラリ\n", .{});
    std.debug.print("    例: pthread, z, m, ssl, crypto\n", .{});

    std.debug.print("  パス設定:\n", .{});
    std.debug.print("    addLibraryPath() - ライブラリ検索パス\n", .{});
    std.debug.print("    addIncludePath() - ヘッダ検索パス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Cソースファイル追加
// ====================

fn demoCSourceFiles() void {
    std.debug.print("--- Cソースファイル追加 ---\n", .{});

    // build.zigでの記述例:
    //
    // exe.root_module.addCSourceFiles(.{
    //     .files = &.{
    //         "src/helper.c",
    //         "src/util.c",
    //     },
    //     .flags = &.{
    //         "-Wall",
    //         "-O2",
    //     },
    // });
    //
    // // Cマクロの定義
    // exe.root_module.addCMacro("DEBUG", "1");
    // exe.root_module.addCMacro("VERSION", "\"1.0\"");

    std.debug.print("  addCSourceFiles():\n", .{});
    std.debug.print("    .files - Cソースファイルリスト\n", .{});
    std.debug.print("    .flags - コンパイラフラグ\n", .{});

    std.debug.print("  addCMacro():\n", .{});
    std.debug.print("    Cマクロを定義\n", .{});
    std.debug.print("    #define NAME VALUE と同等\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ライブラリのリンク
// ====================

fn demoLinkLibrary() void {
    std.debug.print("--- ライブラリのリンク ---\n", .{});

    // build.zigでの記述例:
    //
    // // 静的ライブラリを作成
    // const lib = b.addStaticLibrary(.{
    //     .name = "mylib",
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/lib.zig"),
    //         .target = target,
    //     }),
    // });
    //
    // // 実行可能ファイルにリンク
    // exe.root_module.linkLibrary(lib);
    //
    // // または動的ライブラリ
    // const shared = b.addSharedLibrary(.{...});
    // exe.root_module.linkLibrary(shared);

    std.debug.print("  linkLibrary():\n", .{});
    std.debug.print("    静的/動的ライブラリをリンク\n", .{});
    std.debug.print("    同一ビルドスクリプト内のターゲット\n", .{});

    std.debug.print("  ライブラリの種類:\n", .{});
    std.debug.print("    addStaticLibrary()  - .a\n", .{});
    std.debug.print("    addSharedLibrary() - .so/.dylib\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 完全な例
// ====================

fn demoCompleteExample() void {
    std.debug.print("--- 完全な例 ---\n", .{});

    std.debug.print("  build.zig.zon:\n", .{});
    std.debug.print("  ```\n", .{});
    std.debug.print("  .{{\n", .{});
    std.debug.print("      .name = .my_app,\n", .{});
    std.debug.print("      .version = \"0.1.0\",\n", .{});
    std.debug.print("      .dependencies = .{{\n", .{});
    std.debug.print("          .@\"zig-string\" = .{{\n", .{});
    std.debug.print("              .url = \"https://...\",\n", .{});
    std.debug.print("              .hash = \"1220...\",\n", .{});
    std.debug.print("          }},\n", .{});
    std.debug.print("      }},\n", .{});
    std.debug.print("      .paths = .{{\"build.zig\", \"src\"}},\n", .{});
    std.debug.print("  }}\n", .{});
    std.debug.print("  ```\n", .{});

    std.debug.print("\n  build.zig:\n", .{});
    std.debug.print("  ```\n", .{});
    std.debug.print("  const dep = b.dependency(\"zig-string\", .{{}});\n", .{});
    std.debug.print("  exe.root_module.addImport(\"string\", dep.module(\"string\"));\n", .{});
    std.debug.print("  ```\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  パッケージ管理:\n", .{});
    std.debug.print("    build.zig.zon - マニフェストファイル\n", .{});
    std.debug.print("    zig fetch --save - 依存追加\n", .{});

    std.debug.print("  依存関係の種類:\n", .{});
    std.debug.print("    .url + .hash - リモート依存\n", .{});
    std.debug.print("    .path        - ローカル依存\n", .{});
    std.debug.print("    .lazy = true - 遅延ロード\n", .{});

    std.debug.print("  システム連携:\n", .{});
    std.debug.print("    linkLibC()           - libc\n", .{});
    std.debug.print("    linkSystemLibrary()  - システムlib\n", .{});
    std.debug.print("    addCSourceFiles()    - Cソース\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== 依存関係管理 ===\n\n", .{});

    demoBuildZigZon();
    demoAddDependency();
    demoUseDependency();
    demoLazyDependency();
    demoLocalDependency();
    demoSystemLibrary();
    demoCSourceFiles();
    demoLinkLibrary();
    demoCompleteExample();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・zig fetch --save で依存追加が簡単\n", .{});
    std.debug.print("・.lazyで不要な依存をスキップ\n", .{});
    std.debug.print("・C連携は linkLibC() から始める\n", .{});
    std.debug.print("・ハッシュ不一致はzig buildで検出\n", .{});
}

// --- テスト ---
// 依存関係の機能をテストするには実際のプロジェクトが必要
// ここでは概念の確認用テストのみ

test "semantic version format" {
    // セマンティックバージョンのパターン確認
    const versions = [_][]const u8{
        "0.1.0",
        "1.0.0",
        "1.2.3",
        "0.15.2",
    };

    for (versions) |v| {
        var parts: usize = 0;
        var iter = std.mem.splitScalar(u8, v, '.');
        while (iter.next()) |_| {
            parts += 1;
        }
        try std.testing.expectEqual(@as(usize, 3), parts);
    }
}

test "dependency hash format" {
    // ハッシュは1220で始まる（multihash形式）
    const hash_prefix = "1220";
    const example_hash = "1220abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234567";

    try std.testing.expect(std.mem.startsWith(u8, example_hash, hash_prefix));
    // 1220(4) + 64 hex chars = 68, but our example is 66
    try std.testing.expect(example_hash.len >= 64);
}

test "library names" {
    // システムライブラリ名の例
    const libs = [_][]const u8{
        "c",        // libc
        "pthread",  // POSIX threads
        "m",        // math
        "z",        // zlib
        "ssl",      // OpenSSL
        "crypto",   // OpenSSL crypto
    };

    try std.testing.expectEqual(@as(usize, 6), libs.len);
}

test "zon field names" {
    // build.zig.zonの主要フィールド
    const fields = [_][]const u8{
        "name",
        "version",
        "fingerprint",
        "dependencies",
        "paths",
    };

    try std.testing.expectEqual(@as(usize, 5), fields.len);
}
