//! # ディレクトリ操作
//!
//! ディレクトリの作成、削除、一覧取得。
//! Dir型を使ったファイルシステム操作。
//!
//! ## 主要メソッド
//! - makeDir(): ディレクトリ作成
//! - makePath(): 再帰的に作成
//! - deleteDir(): ディレクトリ削除
//! - openDir(): ディレクトリを開く
//! - iterate(): エントリ一覧

const std = @import("std");

// ====================
// ディレクトリの作成
// ====================

fn demoMakeDir() !void {
    std.debug.print("--- ディレクトリの作成 ---\n", .{});

    const cwd = std.fs.cwd();

    // makeDir で単一ディレクトリ作成
    cwd.makeDir("test_dir") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    defer cwd.deleteDir("test_dir") catch {};

    std.debug.print("  makeDir(\"test_dir\") 成功\n", .{});

    std.debug.print("  makeDir() の特徴:\n", .{});
    std.debug.print("    単一ディレクトリを作成\n", .{});
    std.debug.print("    親ディレクトリは存在必須\n", .{});
    std.debug.print("    既存なら PathAlreadyExists\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 再帰的な作成
// ====================

fn demoMakePath() !void {
    std.debug.print("--- 再帰的な作成 ---\n", .{});

    const cwd = std.fs.cwd();

    // makePath で複数階層を一度に作成
    cwd.makePath("parent/child/grandchild") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    defer {
        cwd.deleteDir("parent/child/grandchild") catch {};
        cwd.deleteDir("parent/child") catch {};
        cwd.deleteDir("parent") catch {};
    }

    std.debug.print("  makePath(\"parent/child/grandchild\") 成功\n", .{});

    std.debug.print("  makePath() の特徴:\n", .{});
    std.debug.print("    中間ディレクトリも自動作成\n", .{});
    std.debug.print("    mkdir -p と同等\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ディレクトリを開く
// ====================

fn demoOpenDir() !void {
    std.debug.print("--- ディレクトリを開く ---\n", .{});

    const cwd = std.fs.cwd();

    // テスト用ディレクトリ作成
    cwd.makeDir("open_test") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    defer cwd.deleteDir("open_test") catch {};

    // ディレクトリを開く
    var dir = try cwd.openDir("open_test", .{});
    defer dir.close();

    std.debug.print("  openDir() 成功\n", .{});

    std.debug.print("  openDir() オプション:\n", .{});
    std.debug.print("    .iterate = true  - 一覧取得可能に\n", .{});
    std.debug.print("    .access_sub_paths = true - サブパスアクセス\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// エントリの一覧
// ====================

fn demoIterate() !void {
    std.debug.print("--- エントリの一覧 ---\n", .{});

    const cwd = std.fs.cwd();

    // テスト用構造を作成
    cwd.makePath("iter_test/subdir") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    {
        const f = try cwd.createFile("iter_test/file1.txt", .{});
        f.close();
    }
    {
        const f = try cwd.createFile("iter_test/file2.txt", .{});
        f.close();
    }
    defer {
        cwd.deleteFile("iter_test/file1.txt") catch {};
        cwd.deleteFile("iter_test/file2.txt") catch {};
        cwd.deleteDir("iter_test/subdir") catch {};
        cwd.deleteDir("iter_test") catch {};
    }

    // イテレーション
    var dir = try cwd.openDir("iter_test", .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    std.debug.print("  iter_test/ の内容:\n", .{});
    while (try iter.next()) |entry| {
        const kind = switch (entry.kind) {
            .file => "FILE",
            .directory => "DIR ",
            else => "????",
        };
        std.debug.print("    [{s}] {s}\n", .{ kind, entry.name });
    }

    std.debug.print("  entry.kind の値:\n", .{});
    std.debug.print("    .file      - ファイル\n", .{});
    std.debug.print("    .directory - ディレクトリ\n", .{});
    std.debug.print("    .sym_link  - シンボリックリンク\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 相対パスでのファイル操作
// ====================

fn demoRelativePath() !void {
    std.debug.print("--- 相対パスでのファイル操作 ---\n", .{});

    const cwd = std.fs.cwd();

    // ディレクトリ作成
    cwd.makeDir("rel_test") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    defer cwd.deleteDir("rel_test") catch {};

    // ディレクトリを開いて、その中でファイル操作
    var dir = try cwd.openDir("rel_test", .{});
    defer dir.close();

    // dirを基準にファイル作成
    {
        const file = try dir.createFile("inside.txt", .{});
        defer file.close();
        try file.writeAll("Created inside rel_test/");
    }
    defer dir.deleteFile("inside.txt") catch {};

    std.debug.print("  rel_test/inside.txt を作成\n", .{});

    // 読み取りで確認
    {
        const file = try dir.openFile("inside.txt", .{});
        defer file.close();
        var buf: [64]u8 = undefined;
        const n = try file.readAll(&buf);
        std.debug.print("  内容: {s}\n", .{buf[0..n]});
    }

    std.debug.print("  Dir.createFile/openFile:\n", .{});
    std.debug.print("    そのディレクトリを基準にパス解決\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ディレクトリの削除
// ====================

fn demoDeleteDir() !void {
    std.debug.print("--- ディレクトリの削除 ---\n", .{});

    const cwd = std.fs.cwd();

    // テスト用ディレクトリ
    try cwd.makeDir("del_test");

    // 空ディレクトリの削除
    try cwd.deleteDir("del_test");
    std.debug.print("  deleteDir() 成功\n", .{});

    std.debug.print("  deleteDir() の制約:\n", .{});
    std.debug.print("    空ディレクトリのみ削除可能\n", .{});
    std.debug.print("    中身があると DirNotEmpty\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 再帰的な削除
// ====================

fn demoDeleteTree() !void {
    std.debug.print("--- 再帰的な削除 ---\n", .{});

    const cwd = std.fs.cwd();

    // テスト用構造
    try cwd.makePath("tree_test/sub1/sub2");
    {
        const f = try cwd.createFile("tree_test/file.txt", .{});
        f.close();
    }
    {
        const f = try cwd.createFile("tree_test/sub1/nested.txt", .{});
        f.close();
    }

    // deleteTree で再帰削除
    try cwd.deleteTree("tree_test");
    std.debug.print("  deleteTree() 成功\n", .{});

    std.debug.print("  deleteTree() の特徴:\n", .{});
    std.debug.print("    中身ごと再帰的に削除\n", .{});
    std.debug.print("    rm -rf と同等\n", .{});
    std.debug.print("    ※ 危険なので注意\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パスの結合
// ====================

fn demoPathJoin() !void {
    std.debug.print("--- パスの結合 ---\n", .{});

    const allocator = std.testing.allocator;

    // fs.path.join でパスを結合
    const path = try std.fs.path.join(allocator, &.{ "parent", "child", "file.txt" });
    defer allocator.free(path);

    std.debug.print("  結合結果: {s}\n", .{path});

    // 各種パス操作
    const dir = std.fs.path.dirname("parent/child/file.txt");
    const base = std.fs.path.basename("parent/child/file.txt");
    const ext = std.fs.path.extension("parent/child/file.txt");

    std.debug.print("  dirname:   {s}\n", .{dir orelse "(null)"});
    std.debug.print("  basename:  {s}\n", .{base});
    std.debug.print("  extension: {s}\n", .{ext});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  作成:\n", .{});
    std.debug.print("    makeDir()  - 単一ディレクトリ\n", .{});
    std.debug.print("    makePath() - 再帰的に作成\n", .{});

    std.debug.print("  削除:\n", .{});
    std.debug.print("    deleteDir()  - 空のディレクトリ\n", .{});
    std.debug.print("    deleteTree() - 再帰的に削除\n", .{});

    std.debug.print("  一覧:\n", .{});
    std.debug.print("    openDir(.iterate=true)\n", .{});
    std.debug.print("    dir.iterate()\n", .{});

    std.debug.print("  パス操作:\n", .{});
    std.debug.print("    fs.path.join/dirname/basename\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ディレクトリ操作 ===\n\n", .{});

    try demoMakeDir();
    try demoMakePath();
    try demoOpenDir();
    try demoIterate();
    try demoRelativePath();
    try demoDeleteDir();
    try demoDeleteTree();
    try demoPathJoin();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・makePath() で親ディレクトリも作成\n", .{});
    std.debug.print("・deleteTree() は危険、慎重に\n", .{});
    std.debug.print("・iterate には .iterate = true が必要\n", .{});
    std.debug.print("・パス結合は fs.path.join を使う\n", .{});
}

// --- テスト ---

test "makeDir and deleteDir" {
    const cwd = std.fs.cwd();

    try cwd.makeDir("test_mkdir");
    defer cwd.deleteDir("test_mkdir") catch {};

    // 同名で作成するとエラー
    try std.testing.expectError(error.PathAlreadyExists, cwd.makeDir("test_mkdir"));

    // 削除
    try cwd.deleteDir("test_mkdir");
}

test "makePath creates nested directories" {
    const cwd = std.fs.cwd();

    try cwd.makePath("test_nested/a/b/c");
    defer {
        cwd.deleteDir("test_nested/a/b/c") catch {};
        cwd.deleteDir("test_nested/a/b") catch {};
        cwd.deleteDir("test_nested/a") catch {};
        cwd.deleteDir("test_nested") catch {};
    }

    // 各階層が存在することを確認
    var dir = try cwd.openDir("test_nested/a/b/c", .{});
    dir.close();
}

test "iterate directory" {
    const cwd = std.fs.cwd();

    try cwd.makeDir("test_iter");
    {
        const f = try cwd.createFile("test_iter/a.txt", .{});
        f.close();
    }
    {
        const f = try cwd.createFile("test_iter/b.txt", .{});
        f.close();
    }
    defer {
        cwd.deleteFile("test_iter/a.txt") catch {};
        cwd.deleteFile("test_iter/b.txt") catch {};
        cwd.deleteDir("test_iter") catch {};
    }

    var dir = try cwd.openDir("test_iter", .{ .iterate = true });
    defer dir.close();

    var count: usize = 0;
    var iter = dir.iterate();
    while (try iter.next()) |_| {
        count += 1;
    }
    try std.testing.expectEqual(@as(usize, 2), count);
}

test "deleteTree" {
    const cwd = std.fs.cwd();

    try cwd.makePath("test_tree/sub");
    {
        const f = try cwd.createFile("test_tree/file.txt", .{});
        f.close();
    }

    try cwd.deleteTree("test_tree");

    // 存在しないことを確認
    try std.testing.expectError(error.FileNotFound, cwd.openDir("test_tree", .{}));
}

test "path operations" {
    const dir = std.fs.path.dirname("a/b/c.txt");
    try std.testing.expectEqualStrings("a/b", dir.?);

    const base = std.fs.path.basename("a/b/c.txt");
    try std.testing.expectEqualStrings("c.txt", base);

    const ext = std.fs.path.extension("a/b/c.txt");
    try std.testing.expectEqualStrings(".txt", ext);
}

test "path join" {
    const allocator = std.testing.allocator;

    const path = try std.fs.path.join(allocator, &.{ "a", "b", "c" });
    defer allocator.free(path);

    try std.testing.expectEqualStrings("a/b/c", path);
}
