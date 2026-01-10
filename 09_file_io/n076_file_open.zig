//! # ファイルを開く
//!
//! std.fsを使ったファイルのオープン操作。
//! 読み取り・書き込みモードとファイルディスクリプタ。
//!
//! ## 主要関数
//! - std.fs.cwd(): 現在の作業ディレクトリ
//! - Dir.openFile(): 既存ファイルを開く
//! - Dir.createFile(): 新規ファイル作成
//! - File.close(): ファイルを閉じる

const std = @import("std");

// ====================
// 現在の作業ディレクトリ
// ====================

fn demoCwd() void {
    std.debug.print("--- 現在の作業ディレクトリ ---\n", .{});

    // std.fs.cwd() で現在の作業ディレクトリを取得
    // 戻り値は std.fs.Dir 型
    const cwd = std.fs.cwd();
    _ = cwd;

    std.debug.print("  std.fs.cwd():\n", .{});
    std.debug.print("    現在のディレクトリを取得\n", .{});
    std.debug.print("    std.fs.Dir 型を返す\n", .{});
    std.debug.print("    ファイル操作の起点\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ファイルを開く（読み取り）
// ====================

fn demoOpenFileRead() !void {
    std.debug.print("--- ファイルを開く（読み取り） ---\n", .{});

    // テスト用ファイルを作成
    const cwd = std.fs.cwd();
    {
        const tmp = try cwd.createFile("test_read.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Hello, Zig!");
    }
    defer cwd.deleteFile("test_read.txt") catch {};

    // ファイルを読み取り専用で開く
    const file = try cwd.openFile("test_read.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    var buffer: [64]u8 = undefined;
    const bytes_read = try file.read(&buffer);
    std.debug.print("  読み取り: {s}\n", .{buffer[0..bytes_read]});

    std.debug.print("  openFile() オプション:\n", .{});
    std.debug.print("    .mode = .read_only - 読み取りのみ\n", .{});
    std.debug.print("    .mode = .write_only - 書き込みのみ\n", .{});
    std.debug.print("    .mode = .read_write - 読み書き両方\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ファイルを開く（書き込み）
// ====================

fn demoOpenFileWrite() !void {
    std.debug.print("--- ファイルを開く（書き込み） ---\n", .{});

    const cwd = std.fs.cwd();

    // テスト用ファイルを作成
    {
        const tmp = try cwd.createFile("test_write.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Original content\n");
    }
    defer cwd.deleteFile("test_write.txt") catch {};

    // 書き込み専用で開く
    {
        const file = try cwd.openFile("test_write.txt", .{
            .mode = .write_only,
        });
        defer file.close();

        // 末尾に移動して追記
        try file.seekFromEnd(0);
        _ = try file.write("Appended content\n");
    }

    // 結果を確認
    {
        const file = try cwd.openFile("test_write.txt", .{
            .mode = .read_only,
        });
        defer file.close();

        var buffer: [128]u8 = undefined;
        const bytes_read = try file.read(&buffer);
        std.debug.print("  結果:\n  {s}", .{buffer[0..bytes_read]});
    }

    std.debug.print("\n", .{});
}

// ====================
// 新規ファイル作成
// ====================

fn demoCreateFile() !void {
    std.debug.print("--- 新規ファイル作成 ---\n", .{});

    const cwd = std.fs.cwd();

    // createFile() で新規ファイル作成
    const file = try cwd.createFile("new_file.txt", .{});
    defer file.close();
    defer cwd.deleteFile("new_file.txt") catch {};

    _ = try file.write("Created by createFile()");
    std.debug.print("  createFile() 成功\n", .{});

    std.debug.print("  createFile() オプション:\n", .{});
    std.debug.print("    .read = true     - 読み取りも許可\n", .{});
    std.debug.print("    .truncate = true - 既存内容を削除（デフォルト）\n", .{});
    std.debug.print("    .exclusive = true - 既存なら失敗\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 読み書き両用
// ====================

fn demoReadWrite() !void {
    std.debug.print("--- 読み書き両用 ---\n", .{});

    const cwd = std.fs.cwd();

    // .read = true で読み取りも可能に
    const file = try cwd.createFile("readwrite.txt", .{
        .read = true,
    });
    defer file.close();
    defer cwd.deleteFile("readwrite.txt") catch {};

    // 書き込み
    _ = try file.write("Hello, World!");

    // 先頭に戻る
    try file.seekTo(0);

    // 読み取り
    var buffer: [64]u8 = undefined;
    const bytes_read = try file.read(&buffer);
    std.debug.print("  書き込み後に読み取り: {s}\n", .{buffer[0..bytes_read]});

    std.debug.print("\n", .{});
}

// ====================
// シーク操作
// ====================

fn demoSeek() !void {
    std.debug.print("--- シーク操作 ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("seek_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("0123456789ABCDEF");
    }
    defer cwd.deleteFile("seek_test.txt") catch {};

    const file = try cwd.openFile("seek_test.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    var buffer: [4]u8 = undefined;

    // 先頭から読む
    _ = try file.read(&buffer);
    std.debug.print("  先頭から: {s}\n", .{buffer});

    // 位置10にシーク
    try file.seekTo(10);
    _ = try file.read(&buffer);
    std.debug.print("  位置10から: {s}\n", .{buffer});

    // 末尾から-4にシーク
    try file.seekFromEnd(-4);
    _ = try file.read(&buffer);
    std.debug.print("  末尾-4から: {s}\n", .{buffer});

    std.debug.print("  シーク関数:\n", .{});
    std.debug.print("    seekTo(pos)        - 絶対位置\n", .{});
    std.debug.print("    seekBy(delta)      - 相対移動\n", .{});
    std.debug.print("    seekFromEnd(delta) - 末尾から\n", .{});
    std.debug.print("    getPos()           - 現在位置取得\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ファイル情報
// ====================

fn demoFileStat() !void {
    std.debug.print("--- ファイル情報 ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("stat_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("This is test content for stat");
    }
    defer cwd.deleteFile("stat_test.txt") catch {};

    const file = try cwd.openFile("stat_test.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // ファイル情報取得
    const stat = try file.stat();
    std.debug.print("  ファイルサイズ: {d} bytes\n", .{stat.size});

    std.debug.print("  stat() で取得可能:\n", .{});
    std.debug.print("    .size      - ファイルサイズ\n", .{});
    std.debug.print("    .atime     - 最終アクセス時刻\n", .{});
    std.debug.print("    .mtime     - 最終更新時刻\n", .{});
    std.debug.print("    .ctime     - 作成時刻\n", .{});
    std.debug.print("    .mode      - パーミッション\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// エラーハンドリング
// ====================

fn demoErrorHandling() void {
    std.debug.print("--- エラーハンドリング ---\n", .{});

    const cwd = std.fs.cwd();

    // 存在しないファイルを開こうとする
    if (cwd.openFile("nonexistent.txt", .{})) |file| {
        file.close();
    } else |err| {
        std.debug.print("  エラー発生: {s}\n", .{@errorName(err)});
    }

    std.debug.print("  一般的なエラー:\n", .{});
    std.debug.print("    FileNotFound     - ファイルが存在しない\n", .{});
    std.debug.print("    AccessDenied     - アクセス権限なし\n", .{});
    std.debug.print("    PathAlreadyExists - パスが既に存在\n", .{});
    std.debug.print("    IsDir            - ディレクトリだった\n", .{});
    std.debug.print("    NotDir           - ディレクトリでない\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  ディレクトリ取得:\n", .{});
    std.debug.print("    std.fs.cwd() - 現在のディレクトリ\n", .{});

    std.debug.print("  ファイルオープン:\n", .{});
    std.debug.print("    openFile()   - 既存ファイル\n", .{});
    std.debug.print("    createFile() - 新規作成\n", .{});

    std.debug.print("  基本パターン:\n", .{});
    std.debug.print("    const file = try dir.openFile(...);\n", .{});
    std.debug.print("    defer file.close();\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ファイルを開く ===\n\n", .{});

    demoCwd();
    try demoOpenFileRead();
    try demoOpenFileWrite();
    try demoCreateFile();
    try demoReadWrite();
    try demoSeek();
    try demoFileStat();
    demoErrorHandling();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・defer file.close() を忘れずに\n", .{});
    std.debug.print("・read_only がデフォルト\n", .{});
    std.debug.print("・createFile は既存を上書き\n", .{});
    std.debug.print("・seekToで任意の位置に移動\n", .{});
}

// --- テスト ---

test "cwd returns valid dir" {
    const cwd = std.fs.cwd();
    // cwdが有効なDirであることを確認
    _ = cwd;
}

test "create and delete file" {
    const cwd = std.fs.cwd();

    // ファイル作成
    const file = try cwd.createFile("test_create_delete.txt", .{});
    file.close();

    // ファイル削除
    try cwd.deleteFile("test_create_delete.txt");

    // 削除後は開けない
    const result = cwd.openFile("test_create_delete.txt", .{});
    try std.testing.expectError(error.FileNotFound, result);
}

test "write and read file" {
    const cwd = std.fs.cwd();

    // 書き込み
    {
        const file = try cwd.createFile("test_write_read.txt", .{});
        defer file.close();
        _ = try file.write("Test content");
    }
    defer cwd.deleteFile("test_write_read.txt") catch {};

    // 読み取り
    {
        const file = try cwd.openFile("test_write_read.txt", .{
            .mode = .read_only,
        });
        defer file.close();

        var buffer: [64]u8 = undefined;
        const bytes_read = try file.read(&buffer);
        try std.testing.expectEqualStrings("Test content", buffer[0..bytes_read]);
    }
}

test "seek operations" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_seek.txt", .{});
        defer file.close();
        _ = try file.write("0123456789");
    }
    defer cwd.deleteFile("test_seek.txt") catch {};

    const file = try cwd.openFile("test_seek.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // seekTo テスト
    try file.seekTo(5);
    var buffer: [5]u8 = undefined;
    _ = try file.read(&buffer);
    try std.testing.expectEqualStrings("56789", &buffer);
}

test "file stat" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_stat.txt", .{});
        defer file.close();
        _ = try file.write("12345678901234567890"); // 20 bytes
    }
    defer cwd.deleteFile("test_stat.txt") catch {};

    const file = try cwd.openFile("test_stat.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    const stat = try file.stat();
    try std.testing.expectEqual(@as(u64, 20), stat.size);
}

test "file not found error" {
    const cwd = std.fs.cwd();
    const result = cwd.openFile("nonexistent_file_12345.txt", .{});
    try std.testing.expectError(error.FileNotFound, result);
}
