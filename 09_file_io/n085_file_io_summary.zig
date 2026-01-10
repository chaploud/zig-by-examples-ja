//! # ファイルI/O 総まとめ
//!
//! ファイル操作に関する知識の整理と実践的なパターン。
//!
//! ## 学んだ内容
//! - ファイルを開く/作成
//! - 読み込み/書き込み
//! - ディレクトリ操作
//! - バッファードI/O
//! - シーク位置
//! - 標準入出力
//! - パス操作
//! - ファイル情報取得 (stat)

const std = @import("std");
const fs = std.fs;
const path = fs.path;

// ====================
// ファイル操作の基本パターン
// ====================

fn demoBasicPatterns() !void {
    std.debug.print("=== ファイル操作の基本パターン ===\n\n", .{});

    const cwd = fs.cwd();

    // --- ファイル作成と書き込み ---
    std.debug.print("【ファイル作成と書き込み】\n", .{});
    {
        const file = try cwd.createFile("example.txt", .{});
        defer file.close();
        _ = try file.write("Hello, Zig!");
    }
    std.debug.print("  createFile → write → close\n", .{});

    // --- ファイル読み込み ---
    std.debug.print("\n【ファイル読み込み】\n", .{});
    {
        const file = try cwd.openFile("example.txt", .{});
        defer file.close();
        var buffer: [128]u8 = undefined;
        const len = try file.readAll(&buffer);
        std.debug.print("  内容: {s}\n", .{buffer[0..len]});
    }

    // --- 追記 ---
    std.debug.print("\n【追記】\n", .{});
    {
        const file = try cwd.openFile("example.txt", .{
            .mode = .read_write,
        });
        defer file.close();
        try file.seekFromEnd(0);
        _ = try file.write(" (appended)");
    }

    // --- ファイル全体を読む ---
    std.debug.print("\n【ファイル全体を読む】\n", .{});
    {
        const file = try cwd.openFile("example.txt", .{});
        defer file.close();
        const allocator = std.testing.allocator;
        const content = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(content);
        std.debug.print("  全内容: {s}\n", .{content});
    }

    // 後片付け
    try cwd.deleteFile("example.txt");

    std.debug.print("\n", .{});
}

// ====================
// ディレクトリ操作パターン
// ====================

fn demoDirPatterns() !void {
    std.debug.print("=== ディレクトリ操作パターン ===\n\n", .{});

    const cwd = fs.cwd();

    // --- ディレクトリ作成 ---
    std.debug.print("【ディレクトリ作成】\n", .{});
    cwd.makeDir("test_dir") catch |e| switch (e) {
        error.PathAlreadyExists => std.debug.print("  既に存在\n", .{}),
        else => return e,
    };

    // --- 再帰的作成 ---
    std.debug.print("【再帰的作成】\n", .{});
    try cwd.makePath("test_dir/sub/deep");
    std.debug.print("  makePath で階層作成\n", .{});

    // --- ディレクトリ内のファイル一覧 ---
    std.debug.print("\n【ディレクトリ走査】\n", .{});
    {
        // テストファイル作成
        const tmp = try cwd.createFile("test_dir/file1.txt", .{});
        tmp.close();
        const tmp2 = try cwd.createFile("test_dir/file2.txt", .{});
        tmp2.close();

        var dir = try cwd.openDir("test_dir", .{ .iterate = true });
        defer dir.close();

        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            std.debug.print("  {s} ({})\n", .{ entry.name, entry.kind });
        }
    }

    // --- クリーンアップ ---
    cwd.deleteFile("test_dir/file1.txt") catch {};
    cwd.deleteFile("test_dir/file2.txt") catch {};
    cwd.deleteDir("test_dir/sub/deep") catch {};
    cwd.deleteDir("test_dir/sub") catch {};
    cwd.deleteDir("test_dir") catch {};

    std.debug.print("\n", .{});
}

// ====================
// バッファードI/Oパターン
// ====================

fn demoBufferedPatterns() !void {
    std.debug.print("=== バッファードI/Oパターン ===\n\n", .{});

    // --- fixedBufferStream ---
    std.debug.print("【メモリバッファへの書き込み】\n", .{});
    var buffer: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    try fbs.writer().print("Name: {s}, Value: {d}\n", .{ "Test", 42 });
    std.debug.print("  {s}", .{fbs.getWritten()});

    // --- Writer.Allocating ---
    std.debug.print("\n【動的バッファ】\n", .{});
    {
        const allocator = std.testing.allocator;
        var aw: std.io.Writer.Allocating = .init(allocator);
        defer aw.deinit();

        try aw.writer.print("Dynamic content: {d}\n", .{123});
        std.debug.print("  {s}", .{aw.writer.buffered()});
    }

    // --- ファイルへの効率的な書き込み ---
    std.debug.print("\n【効率的なファイル書き込み】\n", .{});
    std.debug.print("  1. fixedBufferStream でメモリに書き込み\n", .{});
    std.debug.print("  2. file.write() で一括書き込み\n", .{});
    std.debug.print("  → syscall を最小化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パス操作パターン
// ====================

fn demoPathPatterns() !void {
    std.debug.print("=== パス操作パターン ===\n\n", .{});

    const allocator = std.testing.allocator;

    const file_path = "/home/user/documents/report.pdf";

    std.debug.print("【パス分解】\n", .{});
    std.debug.print("  元のパス: {s}\n", .{file_path});
    if (path.dirname(file_path)) |dir| {
        std.debug.print("  dirname:   {s}\n", .{dir});
    }
    std.debug.print("  basename:  {s}\n", .{path.basename(file_path)});
    std.debug.print("  extension: {s}\n", .{path.extension(file_path)});
    std.debug.print("  stem:      {s}\n", .{path.stem(file_path)});

    std.debug.print("\n【パス結合】\n", .{});
    const joined = try path.join(allocator, &.{ "dir", "subdir", "file.txt" });
    defer allocator.free(joined);
    std.debug.print("  join: {s}\n", .{joined});

    std.debug.print("\n", .{});
}

// ====================
// エラー処理パターン
// ====================

fn demoErrorPatterns() !void {
    std.debug.print("=== エラー処理パターン ===\n\n", .{});

    const cwd = fs.cwd();

    std.debug.print("【ファイルが存在しない場合】\n", .{});
    const result = cwd.openFile("nonexistent.txt", .{});
    if (result) |file| {
        file.close();
    } else |err| {
        std.debug.print("  エラー: {}\n", .{err});
    }

    std.debug.print("\n【存在確認パターン】\n", .{});
    const exists = blk: {
        const file = cwd.openFile("test.txt", .{}) catch break :blk false;
        file.close();
        break :blk true;
    };
    std.debug.print("  ファイル存在: {}\n", .{exists});

    std.debug.print("\n【リソース管理: defer】\n", .{});
    std.debug.print("  const file = try openFile(...);\n", .{});
    std.debug.print("  defer file.close();  // 確実にクローズ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 標準入出力パターン
// ====================

fn demoStdioPatterns() void {
    std.debug.print("=== 標準入出力パターン ===\n\n", .{});

    std.debug.print("【stdout/stderr】\n", .{});
    std.debug.print("  std.fs.File.stdout() → 標準出力\n", .{});
    std.debug.print("  std.fs.File.stderr() → 標準エラー\n", .{});
    std.debug.print("  std.fs.File.stdin()  → 標準入力\n", .{});

    std.debug.print("\n【デバッグ出力】\n", .{});
    std.debug.print("  std.debug.print(\"...\", .{...});\n", .{});
    std.debug.print("  → stderr に出力、エラー無視\n", .{});

    std.debug.print("\n【フォーマット】\n", .{});
    std.debug.print("  {{s}} 文字列, {{d}} 整数, {{x}} 16進\n", .{});
    std.debug.print("  {{d:.2}} 小数2桁, {{d:0>5}} ゼロ埋め5桁\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// stat パターン
// ====================

fn demoStatPatterns() !void {
    std.debug.print("=== ファイル情報取得パターン ===\n\n", .{});

    const cwd = fs.cwd();

    {
        const file = try cwd.createFile("stat_example.txt", .{});
        defer file.close();
        _ = try file.write("Example content");
    }
    defer cwd.deleteFile("stat_example.txt") catch {};

    const file = try cwd.openFile("stat_example.txt", .{});
    defer file.close();

    const st = try file.stat();

    std.debug.print("【stat() の情報】\n", .{});
    std.debug.print("  .size:  {d} bytes\n", .{st.size});
    std.debug.print("  .kind:  {}\n", .{st.kind});
    std.debug.print("  .inode: {d}\n", .{st.inode});
    std.debug.print("  .mode:  0o{o}\n", .{st.mode});

    std.debug.print("\n【サイズ取得の別方法】\n", .{});
    std.debug.print("  file.getEndPos() → {d}\n", .{try file.getEndPos()});

    std.debug.print("\n", .{});
}

// ====================
// チートシート
// ====================

fn demoCheatSheet() void {
    std.debug.print("=== ファイルI/O チートシート ===\n\n", .{});

    std.debug.print("【ファイル操作】\n", .{});
    std.debug.print("  fs.cwd()                  カレントディレクトリ\n", .{});
    std.debug.print("  dir.createFile(name, .{}) ファイル作成\n", .{});
    std.debug.print("  dir.openFile(name, .{})   ファイルを開く\n", .{});
    std.debug.print("  file.write(data)          書き込み\n", .{});
    std.debug.print("  file.read(&buf)           読み込み\n", .{});
    std.debug.print("  file.readAll(&buf)        全部読み込み\n", .{});
    std.debug.print("  file.close()              クローズ\n", .{});

    std.debug.print("\n【シーク】\n", .{});
    std.debug.print("  file.seekTo(pos)          絶対位置\n", .{});
    std.debug.print("  file.seekBy(offset)       相対移動\n", .{});
    std.debug.print("  file.seekFromEnd(offset)  終端から\n", .{});
    std.debug.print("  file.getPos()             現在位置\n", .{});
    std.debug.print("  file.getEndPos()          ファイルサイズ\n", .{});

    std.debug.print("\n【ディレクトリ】\n", .{});
    std.debug.print("  dir.makeDir(name)         作成\n", .{});
    std.debug.print("  dir.makePath(path)        再帰的作成\n", .{});
    std.debug.print("  dir.deleteFile(name)      ファイル削除\n", .{});
    std.debug.print("  dir.deleteDir(name)       ディレクトリ削除\n", .{});
    std.debug.print("  dir.openDir(name, .{iterate=true})\n", .{});

    std.debug.print("\n【パス (std.fs.path)】\n", .{});
    std.debug.print("  join(alloc, paths)        結合\n", .{});
    std.debug.print("  dirname(path)             ディレクトリ部分\n", .{});
    std.debug.print("  basename(path)            ファイル名部分\n", .{});
    std.debug.print("  extension(path)           拡張子\n", .{});
    std.debug.print("  stem(path)                拡張子除外名\n", .{});

    std.debug.print("\n【stat】\n", .{});
    std.debug.print("  file.stat()               メタデータ取得\n", .{});
    std.debug.print("    .size, .kind, .inode, .mode\n", .{});
    std.debug.print("    .atime, .mtime, .ctime\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    try demoBasicPatterns();
    try demoDirPatterns();
    try demoBufferedPatterns();
    try demoPathPatterns();
    try demoErrorPatterns();
    demoStdioPatterns();
    try demoStatPatterns();
    demoCheatSheet();

    std.debug.print("=== ベストプラクティス ===\n\n", .{});
    std.debug.print("1. defer file.close() でリソース管理\n", .{});
    std.debug.print("2. エラーは適切に処理（catch, try）\n", .{});
    std.debug.print("3. バッファードI/Oで効率化\n", .{});
    std.debug.print("4. std.fs.path でクロスプラットフォーム対応\n", .{});
    std.debug.print("5. stat() でファイル情報を事前確認\n", .{});
}

// --- テスト ---

test "file create and read" {
    const cwd = fs.cwd();

    {
        const file = try cwd.createFile("test_summary.txt", .{});
        defer file.close();
        _ = try file.write("Test");
    }
    defer cwd.deleteFile("test_summary.txt") catch {};

    const file = try cwd.openFile("test_summary.txt", .{});
    defer file.close();

    var buf: [10]u8 = undefined;
    const n = try file.readAll(&buf);
    try std.testing.expectEqualStrings("Test", buf[0..n]);
}

test "path operations" {
    const allocator = std.testing.allocator;

    const joined = try path.join(allocator, &.{ "a", "b", "c.txt" });
    defer allocator.free(joined);
    try std.testing.expectEqualStrings("a/b/c.txt", joined);

    try std.testing.expectEqualStrings("file", path.stem("file.txt"));
    try std.testing.expectEqualStrings(".txt", path.extension("file.txt"));
}

test "fixedBufferStream" {
    var buf: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    try fbs.writer().print("Value: {d}", .{42});
    try std.testing.expectEqualStrings("Value: 42", fbs.getWritten());
}
