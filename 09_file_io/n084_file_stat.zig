//! # ファイル情報取得 (stat)
//!
//! ファイルのメタデータ（サイズ、種類、時刻など）を取得。
//!
//! ## 主要な情報
//! - size: ファイルサイズ（バイト）
//! - kind: ファイル種別（file, directory, sym_link...）
//! - atime: 最終アクセス時刻
//! - mtime: 最終変更時刻
//! - ctime: メタデータ変更時刻
//! - inode: i-node番号
//! - mode: パーミッション（POSIX）

const std = @import("std");

// ====================
// 基本的な stat 取得
// ====================

fn demoBasicStat() !void {
    std.debug.print("--- 基本的な stat 取得 ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const file = try cwd.createFile("stat_test.txt", .{});
        defer file.close();
        _ = try file.write("Hello, World! This is test content.");
    }
    defer cwd.deleteFile("stat_test.txt") catch {};

    // ファイルを開いて stat 取得
    const file = try cwd.openFile("stat_test.txt", .{});
    defer file.close();

    const st = try file.stat();

    std.debug.print("  ファイルサイズ: {d} bytes\n", .{st.size});
    std.debug.print("  ファイル種別: {}\n", .{st.kind});
    std.debug.print("  i-node: {d}\n", .{st.inode});

    std.debug.print("\n", .{});
}

// ====================
// ファイル種別 (Kind)
// ====================

fn demoFileKind() !void {
    std.debug.print("--- ファイル種別 (Kind) ---\n", .{});

    const cwd = std.fs.cwd();

    // 通常ファイル
    {
        const file = try cwd.createFile("kind_test.txt", .{});
        defer file.close();
        _ = try file.write("test");
    }
    defer cwd.deleteFile("kind_test.txt") catch {};

    // ディレクトリ
    cwd.makeDir("kind_test_dir") catch {};
    defer cwd.deleteDir("kind_test_dir") catch {};

    // 種別を確認
    const file = try cwd.openFile("kind_test.txt", .{});
    defer file.close();
    const file_st = try file.stat();

    const dir = try cwd.openDir("kind_test_dir", .{});
    defer dir.close();
    const dir_stat = try dir.stat();

    std.debug.print("  通常ファイル: {}\n", .{file_st.kind});
    std.debug.print("  ディレクトリ: {}\n", .{dir_stat.kind});

    std.debug.print("\n  Kind の種類:\n", .{});
    std.debug.print("    .file              - 通常ファイル\n", .{});
    std.debug.print("    .directory         - ディレクトリ\n", .{});
    std.debug.print("    .sym_link          - シンボリックリンク\n", .{});
    std.debug.print("    .block_device      - ブロックデバイス\n", .{});
    std.debug.print("    .character_device  - キャラクタデバイス\n", .{});
    std.debug.print("    .named_pipe        - 名前付きパイプ\n", .{});
    std.debug.print("    .unix_domain_socket- UNIXソケット\n", .{});
    std.debug.print("    .unknown           - 不明\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// タイムスタンプ
// ====================

fn demoTimestamps() !void {
    std.debug.print("--- タイムスタンプ ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("time_test.txt", .{});
        defer file.close();
        _ = try file.write("Content");
    }
    defer cwd.deleteFile("time_test.txt") catch {};

    const file = try cwd.openFile("time_test.txt", .{});
    defer file.close();
    const st = try file.stat();

    // ナノ秒から秒に変換
    const ns_per_s = std.time.ns_per_s;

    const atime_s = @divFloor(st.atime, ns_per_s);
    const mtime_s = @divFloor(st.mtime, ns_per_s);
    const ctime_s = @divFloor(st.ctime, ns_per_s);

    std.debug.print("  atime (最終アクセス): {d} 秒 (Unix epoch)\n", .{atime_s});
    std.debug.print("  mtime (最終変更):     {d} 秒 (Unix epoch)\n", .{mtime_s});
    std.debug.print("  ctime (メタデータ):   {d} 秒 (Unix epoch)\n", .{ctime_s});

    std.debug.print("\n  時刻の意味:\n", .{});
    std.debug.print("    atime: 最後にファイルを読んだ時刻\n", .{});
    std.debug.print("    mtime: 最後にファイル内容を変更した時刻\n", .{});
    std.debug.print("    ctime: 最後にメタデータを変更した時刻\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// サイズの取得方法
// ====================

fn demoGetSize() !void {
    std.debug.print("--- サイズの取得方法 ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("size_test.txt", .{});
        defer file.close();
        _ = try file.write("1234567890"); // 10バイト
    }
    defer cwd.deleteFile("size_test.txt") catch {};

    const file = try cwd.openFile("size_test.txt", .{});
    defer file.close();

    // 方法1: stat() から取得
    const st = try file.stat();
    std.debug.print("  stat().size: {d} bytes\n", .{st.size});

    // 方法2: getEndPos() を使用
    const end_pos = try file.getEndPos();
    std.debug.print("  getEndPos(): {d} bytes\n", .{end_pos});

    std.debug.print("\n  使い分け:\n", .{});
    std.debug.print("    stat(): メタデータ全体が必要な場合\n", .{});
    std.debug.print("    getEndPos(): サイズだけ必要な場合\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パーミッション (mode)
// ====================

fn demoMode() !void {
    std.debug.print("--- パーミッション (mode) ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("mode_test.txt", .{});
        defer file.close();
        _ = try file.write("test");
    }
    defer cwd.deleteFile("mode_test.txt") catch {};

    const file = try cwd.openFile("mode_test.txt", .{});
    defer file.close();
    const st = try file.stat();

    // mode は POSIX のパーミッションビット
    std.debug.print("  mode: 0o{o}\n", .{st.mode});

    // 各ビットの確認
    const user_r = (st.mode & 0o400) != 0;
    const user_w = (st.mode & 0o200) != 0;
    const user_x = (st.mode & 0o100) != 0;

    std.debug.print("  ユーザー権限:\n", .{});
    std.debug.print("    読み取り: {}\n", .{user_r});
    std.debug.print("    書き込み: {}\n", .{user_w});
    std.debug.print("    実行:     {}\n", .{user_x});

    std.debug.print("\n  パーミッションビット:\n", .{});
    std.debug.print("    0o400 - ユーザー読み取り\n", .{});
    std.debug.print("    0o200 - ユーザー書き込み\n", .{});
    std.debug.print("    0o100 - ユーザー実行\n", .{});
    std.debug.print("    0o040 - グループ読み取り\n", .{});
    std.debug.print("    0o020 - グループ書き込み\n", .{});
    std.debug.print("    0o010 - グループ実行\n", .{});
    std.debug.print("    0o004 - その他読み取り\n", .{});
    std.debug.print("    0o002 - その他書き込み\n", .{});
    std.debug.print("    0o001 - その他実行\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ディレクトリの stat
// ====================

fn demoDirStat() !void {
    std.debug.print("--- ディレクトリの stat ---\n", .{});

    const cwd = std.fs.cwd();

    cwd.makeDir("stat_dir") catch {};
    defer cwd.deleteDir("stat_dir") catch {};

    // ディレクトリの stat
    const dir = try cwd.openDir("stat_dir", .{});
    defer dir.close();
    const st = try dir.stat();

    std.debug.print("  種別: {}\n", .{st.kind});
    std.debug.print("  inode: {d}\n", .{st.inode});
    std.debug.print("  mode: 0o{o}\n", .{st.mode});

    std.debug.print("\n  注意:\n", .{});
    std.debug.print("    ディレクトリの size は実装依存\n", .{});
    std.debug.print("    中身のサイズ合計ではない\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実用例: ファイル情報表示
// ====================

fn demoPractical() !void {
    std.debug.print("--- 実用例: ファイル情報表示 ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("info_test.txt", .{});
        defer file.close();
        _ = try file.write("Sample file content for demonstration.");
    }
    defer cwd.deleteFile("info_test.txt") catch {};

    const file = try cwd.openFile("info_test.txt", .{});
    defer file.close();
    const st = try file.stat();

    std.debug.print("  info_test.txt の情報:\n", .{});
    std.debug.print("    サイズ:   {d} bytes\n", .{st.size});
    std.debug.print("    種別:     {}\n", .{st.kind});
    std.debug.print("    inode:    {d}\n", .{st.inode});
    std.debug.print("    mode:     0o{o}\n", .{st.mode});

    // 人間が読める形式で権限表示
    const mode = st.mode;
    var perms: [9]u8 = undefined;
    perms[0] = if (mode & 0o400 != 0) 'r' else '-';
    perms[1] = if (mode & 0o200 != 0) 'w' else '-';
    perms[2] = if (mode & 0o100 != 0) 'x' else '-';
    perms[3] = if (mode & 0o040 != 0) 'r' else '-';
    perms[4] = if (mode & 0o020 != 0) 'w' else '-';
    perms[5] = if (mode & 0o010 != 0) 'x' else '-';
    perms[6] = if (mode & 0o004 != 0) 'r' else '-';
    perms[7] = if (mode & 0o002 != 0) 'w' else '-';
    perms[8] = if (mode & 0o001 != 0) 'x' else '-';
    std.debug.print("    権限:     {s}\n", .{&perms});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  stat() で取得できる情報:\n", .{});
    std.debug.print("    .size  : ファイルサイズ（バイト）\n", .{});
    std.debug.print("    .kind  : ファイル種別\n", .{});
    std.debug.print("    .inode : i-node番号\n", .{});
    std.debug.print("    .mode  : パーミッション\n", .{});
    std.debug.print("    .atime : 最終アクセス時刻\n", .{});
    std.debug.print("    .mtime : 最終変更時刻\n", .{});
    std.debug.print("    .ctime : メタデータ変更時刻\n", .{});

    std.debug.print("\n  使用方法:\n", .{});
    std.debug.print("    const st = try file.stat();\n", .{});
    std.debug.print("    // または\n", .{});
    std.debug.print("    const st = try dir.stat();\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ファイル情報取得 (stat) ===\n\n", .{});

    try demoBasicStat();
    try demoFileKind();
    try demoTimestamps();
    try demoGetSize();
    try demoMode();
    try demoDirStat();
    try demoPractical();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・stat() でファイルのメタデータを取得\n", .{});
    std.debug.print("・時刻はナノ秒単位（Unix epoch起点）\n", .{});
    std.debug.print("・mode は POSIX パーミッション\n", .{});
}

// --- テスト ---

test "basic stat" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_stat.txt", .{});
        defer file.close();
        _ = try file.write("Test content");
    }
    defer cwd.deleteFile("test_stat.txt") catch {};

    const file = try cwd.openFile("test_stat.txt", .{});
    defer file.close();

    const st = try file.stat();
    try std.testing.expectEqual(std.fs.File.Kind.file, st.kind);
    try std.testing.expectEqual(@as(u64, 12), st.size);
}

test "directory stat" {
    const cwd = std.fs.cwd();

    cwd.makeDir("test_stat_dir") catch {};
    defer cwd.deleteDir("test_stat_dir") catch {};

    var dir = try cwd.openDir("test_stat_dir", .{});
    defer dir.close();

    const st = try dir.stat();
    try std.testing.expectEqual(std.fs.File.Kind.directory, st.kind);
}

test "getEndPos equals stat size" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_endpos.txt", .{});
        defer file.close();
        _ = try file.write("0123456789"); // 10 bytes
    }
    defer cwd.deleteFile("test_endpos.txt") catch {};

    const file = try cwd.openFile("test_endpos.txt", .{});
    defer file.close();

    const st = try file.stat();
    const end_pos = try file.getEndPos();

    try std.testing.expectEqual(st.size, end_pos);
    try std.testing.expectEqual(@as(u64, 10), st.size);
}

test "permission bits" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_perms.txt", .{});
        defer file.close();
        _ = try file.write("test");
    }
    defer cwd.deleteFile("test_perms.txt") catch {};

    const file = try cwd.openFile("test_perms.txt", .{});
    defer file.close();

    const st = try file.stat();

    // ユーザー読み取り権限は通常存在する
    const user_readable = (st.mode & 0o400) != 0;
    try std.testing.expect(user_readable);
}
