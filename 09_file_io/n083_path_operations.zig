//! # パス操作
//!
//! ファイルパスの解析・結合・変換。
//! クロスプラットフォーム対応のパスユーティリティ。
//!
//! ## 主要な関数 (std.fs.path)
//! - join(): パスの結合
//! - dirname(): ディレクトリ部分を取得
//! - basename(): ファイル名部分を取得
//! - extension(): 拡張子を取得
//! - stem(): 拡張子を除いたファイル名
//! - isAbsolute(): 絶対パスかどうか

const std = @import("std");
const path = std.fs.path;

// ====================
// パス結合
// ====================

fn demoJoin() !void {
    std.debug.print("--- パス結合 (join) ---\n", .{});

    const allocator = std.testing.allocator;

    // 複数のパスを結合
    const joined = try path.join(allocator, &.{ "home", "user", "documents" });
    defer allocator.free(joined);
    std.debug.print("  join: {s}\n", .{joined});

    // 既存のセパレータは重複しない
    const with_sep = try path.join(allocator, &.{ "home/", "/user", "file.txt" });
    defer allocator.free(with_sep);
    std.debug.print("  重複セパ: {s}\n", .{with_sep});

    // 空の要素はスキップ
    const with_empty = try path.join(allocator, &.{ "dir", "", "file" });
    defer allocator.free(with_empty);
    std.debug.print("  空要素: {s}\n", .{with_empty});

    std.debug.print("\n", .{});
}

// ====================
// ディレクトリ名 (dirname)
// ====================

fn demoDirname() void {
    std.debug.print("--- ディレクトリ名 (dirname) ---\n", .{});

    const paths = [_][]const u8{
        "/home/user/file.txt",
        "/home/user/",
        "relative/path/file.txt",
        "file.txt",
        "/",
    };

    for (paths) |p| {
        if (path.dirname(p)) |dir| {
            std.debug.print("  dirname(\"{s}\") = \"{s}\"\n", .{ p, dir });
        } else {
            std.debug.print("  dirname(\"{s}\") = null\n", .{p});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// ベース名 (basename)
// ====================

fn demoBasename() void {
    std.debug.print("--- ベース名 (basename) ---\n", .{});

    const paths = [_][]const u8{
        "/home/user/file.txt",
        "/home/user/",
        "relative/path/file.txt",
        "file.txt",
        "/",
        "",
    };

    for (paths) |p| {
        const base = path.basename(p);
        if (base.len > 0) {
            std.debug.print("  basename(\"{s}\") = \"{s}\"\n", .{ p, base });
        } else {
            std.debug.print("  basename(\"{s}\") = \"\"\n", .{p});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// 拡張子 (extension)
// ====================

fn demoExtension() void {
    std.debug.print("--- 拡張子 (extension) ---\n", .{});

    const paths = [_][]const u8{
        "file.txt",
        "archive.tar.gz",
        "no_extension",
        ".gitignore",
        ".image.png",
        "file.",
    };

    for (paths) |p| {
        const ext = path.extension(p);
        if (ext.len > 0) {
            std.debug.print("  extension(\"{s}\") = \"{s}\"\n", .{ p, ext });
        } else {
            std.debug.print("  extension(\"{s}\") = \"\"\n", .{p});
        }
    }

    std.debug.print("\n  注意:\n", .{});
    std.debug.print("    .gitignore → 拡張子なし（ドットファイル）\n", .{});
    std.debug.print("    archive.tar.gz → .gz（最後のドット以降）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ステム (stem) - 拡張子を除いたファイル名
// ====================

fn demoStem() void {
    std.debug.print("--- ステム (stem) ---\n", .{});

    const paths = [_][]const u8{
        "file.txt",
        "archive.tar.gz",
        "no_extension",
        "/path/to/document.pdf",
        ".gitignore",
    };

    for (paths) |p| {
        const s = path.stem(p);
        std.debug.print("  stem(\"{s}\") = \"{s}\"\n", .{ p, s });
    }

    std.debug.print("\n", .{});
}

// ====================
// 絶対パス判定 (isAbsolute)
// ====================

fn demoIsAbsolute() void {
    std.debug.print("--- 絶対パス判定 (isAbsolute) ---\n", .{});

    const paths = [_][]const u8{
        "/home/user",
        "relative/path",
        "./current",
        "../parent",
        "",
    };

    for (paths) |p| {
        const is_abs = path.isAbsolute(p);
        std.debug.print("  isAbsolute(\"{s}\") = {}\n", .{ p, is_abs });
    }

    std.debug.print("\n  POSIX:\n", .{});
    std.debug.print("    /で始まる → 絶対パス\n", .{});
    std.debug.print("  Windows:\n", .{});
    std.debug.print("    C:\\ や \\\\server\\ → 絶対パス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パス解決 (resolve)
// ====================

fn demoResolve() !void {
    std.debug.print("--- パス解決 (resolve) ---\n", .{});

    const allocator = std.testing.allocator;

    // 相対パスを解決
    const resolved = try path.resolve(allocator, &.{ "/home", "user", "..", "admin" });
    defer allocator.free(resolved);
    std.debug.print("  resolve: {s}\n", .{resolved});

    // 複数の相対パス
    const resolved2 = try path.resolve(allocator, &.{ "base", "./sub", "../other" });
    defer allocator.free(resolved2);
    std.debug.print("  相対解決: {s}\n", .{resolved2});

    std.debug.print("\n  resolve の動作:\n", .{});
    std.debug.print("    . と .. を解決\n", .{});
    std.debug.print("    正規化されたパスを返す\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 相対パス計算 (relative)
// ====================

fn demoRelative() !void {
    std.debug.print("--- 相対パス計算 (relative) ---\n", .{});

    const allocator = std.testing.allocator;

    // fromからtoへの相対パス
    const rel = try path.relative(allocator, "/home/user/docs", "/home/user/images");
    defer allocator.free(rel);
    std.debug.print("  /home/user/docs → /home/user/images\n", .{});
    std.debug.print("  相対パス: {s}\n", .{rel});

    const rel2 = try path.relative(allocator, "/a/b/c", "/a/d/e");
    defer allocator.free(rel2);
    std.debug.print("  /a/b/c → /a/d/e: {s}\n", .{rel2});

    std.debug.print("\n", .{});
}

// ====================
// セパレータ
// ====================

fn demoSeparator() void {
    std.debug.print("--- パスセパレータ ---\n", .{});

    std.debug.print("  ネイティブセパレータ: '{c}'\n", .{path.sep});

    // セパレータ判定
    std.debug.print("  isSep('/')  = {}\n", .{path.isSep('/')});
    std.debug.print("  isSep('\\') = {}\n", .{path.isSep('\\')});
    std.debug.print("  isSep('a')  = {}\n", .{path.isSep('a')});

    std.debug.print("\n  プラットフォーム:\n", .{});
    std.debug.print("    POSIX  : / のみ\n", .{});
    std.debug.print("    Windows: / と \\ の両方\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実用例
// ====================

fn demoPractical() !void {
    std.debug.print("--- 実用例 ---\n", .{});

    const allocator = std.testing.allocator;

    // ファイル名から情報を抽出
    const file_path = "/home/user/documents/report.pdf";

    std.debug.print("  ファイルパス: {s}\n", .{file_path});
    if (path.dirname(file_path)) |dir| {
        std.debug.print("    ディレクトリ: {s}\n", .{dir});
    }
    std.debug.print("    ファイル名:   {s}\n", .{path.basename(file_path)});
    std.debug.print("    拡張子:       {s}\n", .{path.extension(file_path)});
    std.debug.print("    ステム:       {s}\n", .{path.stem(file_path)});

    // 新しいファイルパスを構築
    const new_name = "summary.txt";
    if (path.dirname(file_path)) |dir| {
        const new_path = try path.join(allocator, &.{ dir, new_name });
        defer allocator.free(new_path);
        std.debug.print("\n  新しいパス: {s}\n", .{new_path});
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  パス分解:\n", .{});
    std.debug.print("    dirname()   : ディレクトリ部分\n", .{});
    std.debug.print("    basename()  : ファイル名部分\n", .{});
    std.debug.print("    extension() : 拡張子（.を含む）\n", .{});
    std.debug.print("    stem()      : 拡張子を除いた名前\n", .{});

    std.debug.print("\n  パス構築:\n", .{});
    std.debug.print("    join()      : パス結合\n", .{});
    std.debug.print("    resolve()   : 正規化と解決\n", .{});
    std.debug.print("    relative()  : 相対パス計算\n", .{});

    std.debug.print("\n  判定:\n", .{});
    std.debug.print("    isAbsolute(): 絶対パスか\n", .{});
    std.debug.print("    isSep()     : セパレータか\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== パス操作 ===\n\n", .{});

    try demoJoin();
    demoDirname();
    demoBasename();
    demoExtension();
    demoStem();
    demoIsAbsolute();
    try demoResolve();
    try demoRelative();
    demoSeparator();
    try demoPractical();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・std.fs.path でパス操作\n", .{});
    std.debug.print("・クロスプラットフォーム対応\n", .{});
    std.debug.print("・アロケータが必要なものに注意\n", .{});
}

// --- テスト ---

test "join" {
    const allocator = std.testing.allocator;

    const joined = try path.join(allocator, &.{ "home", "user", "file.txt" });
    defer allocator.free(joined);
    try std.testing.expectEqualStrings("home/user/file.txt", joined);
}

test "dirname" {
    try std.testing.expectEqualStrings("/home/user", path.dirname("/home/user/file.txt").?);
    try std.testing.expectEqualStrings("/", path.dirname("/file.txt").?);
    try std.testing.expectEqual(@as(?[]const u8, null), path.dirname("file.txt"));
}

test "basename" {
    try std.testing.expectEqualStrings("file.txt", path.basename("/home/user/file.txt"));
    try std.testing.expectEqualStrings("user", path.basename("/home/user/"));
    try std.testing.expectEqualStrings("file.txt", path.basename("file.txt"));
}

test "extension" {
    try std.testing.expectEqualStrings(".txt", path.extension("file.txt"));
    try std.testing.expectEqualStrings(".gz", path.extension("archive.tar.gz"));
    try std.testing.expectEqualStrings("", path.extension("no_extension"));
    try std.testing.expectEqualStrings("", path.extension(".gitignore"));
}

test "stem" {
    try std.testing.expectEqualStrings("file", path.stem("file.txt"));
    try std.testing.expectEqualStrings("archive.tar", path.stem("archive.tar.gz"));
    try std.testing.expectEqualStrings("no_extension", path.stem("no_extension"));
}

test "isAbsolute" {
    try std.testing.expect(path.isAbsolute("/home/user"));
    try std.testing.expect(!path.isAbsolute("relative/path"));
    try std.testing.expect(!path.isAbsolute("./current"));
}

test "resolve" {
    const allocator = std.testing.allocator;

    const resolved = try path.resolve(allocator, &.{ "/home", "user", "..", "admin" });
    defer allocator.free(resolved);
    try std.testing.expectEqualStrings("/home/admin", resolved);
}

test "relative" {
    const allocator = std.testing.allocator;

    const rel = try path.relative(allocator, "/a/b/c", "/a/d/e");
    defer allocator.free(rel);
    try std.testing.expectEqualStrings("../../d/e", rel);
}
