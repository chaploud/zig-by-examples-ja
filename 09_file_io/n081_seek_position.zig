//! # シーク位置
//!
//! ファイル内の読み書き位置を制御する。
//! ランダムアクセスや位置の取得・設定。
//!
//! ## 主要メソッド
//! - seekTo(): 先頭からの絶対位置にシーク
//! - seekBy(): 現在位置からの相対移動
//! - seekFromEnd(): 終端からの相対位置にシーク
//! - getPos(): 現在位置を取得
//! - getEndPos(): ファイル終端位置を取得

const std = @import("std");

// ====================
// 位置インジケータの概念
// ====================

fn demoConcept() void {
    std.debug.print("--- 位置インジケータの概念 ---\n", .{});

    std.debug.print("  ファイルディスクリプタの内部状態:\n", .{});
    std.debug.print("    現在の読み書き位置を保持\n", .{});
    std.debug.print("    read/write のたびに自動的に進む\n", .{});

    std.debug.print("\n  シークメソッド:\n", .{});
    std.debug.print("    seekTo(n)      : 先頭から n バイト目へ\n", .{});
    std.debug.print("    seekBy(n)      : 現在位置から n バイト移動\n", .{});
    std.debug.print("    seekFromEnd(n) : 終端から n バイト前へ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// seekTo - 絶対位置シーク
// ====================

fn demoSeekTo() !void {
    std.debug.print("--- seekTo (絶対位置シーク) ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成 (0123456789)
    {
        const tmp = try cwd.createFile("seek_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("0123456789ABCDEFGHIJ");
    }
    defer cwd.deleteFile("seek_test.txt") catch {};

    const file = try cwd.openFile("seek_test.txt", .{});
    defer file.close();

    var buffer: [5]u8 = undefined;

    // 先頭から読む
    _ = try file.readAll(&buffer);
    std.debug.print("  最初の5文字: \"{s}\"\n", .{&buffer});

    // seekTo で先頭に戻る
    try file.seekTo(0);
    _ = try file.readAll(&buffer);
    std.debug.print("  seekTo(0)後: \"{s}\"\n", .{&buffer});

    // seekTo で特定位置へ
    try file.seekTo(10);
    _ = try file.readAll(&buffer);
    std.debug.print("  seekTo(10)後: \"{s}\"\n", .{&buffer});

    // 現在位置を確認
    const pos = try file.getPos();
    std.debug.print("  現在位置: {d}\n", .{pos});

    std.debug.print("\n", .{});
}

// ====================
// seekBy - 相対位置シーク
// ====================

fn demoSeekBy() !void {
    std.debug.print("--- seekBy (相対位置シーク) ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const tmp = try cwd.createFile("seekby_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("ABCDEFGHIJKLMNOPQRST");
    }
    defer cwd.deleteFile("seekby_test.txt") catch {};

    const file = try cwd.openFile("seekby_test.txt", .{});
    defer file.close();

    var buffer: [3]u8 = undefined;

    // 最初の読み込み
    _ = try file.readAll(&buffer);
    std.debug.print("  最初: \"{s}\" (pos={d})\n", .{ &buffer, try file.getPos() });

    // 2バイト進む
    try file.seekBy(2);
    _ = try file.readAll(&buffer);
    std.debug.print("  seekBy(2)後: \"{s}\" (pos={d})\n", .{ &buffer, try file.getPos() });

    // 5バイト戻る
    try file.seekBy(-5);
    _ = try file.readAll(&buffer);
    std.debug.print("  seekBy(-5)後: \"{s}\" (pos={d})\n", .{ &buffer, try file.getPos() });

    std.debug.print("\n  seekBy の用途:\n", .{});
    std.debug.print("    データのスキップ\n", .{});
    std.debug.print("    前のレコードに戻る\n", .{});
    std.debug.print("    相対的なナビゲーション\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// seekFromEnd - 終端からのシーク
// ====================

fn demoSeekFromEnd() !void {
    std.debug.print("--- seekFromEnd (終端からのシーク) ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const tmp = try cwd.createFile("seekend_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Hello, World!");
    }
    defer cwd.deleteFile("seekend_test.txt") catch {};

    const file = try cwd.openFile("seekend_test.txt", .{});
    defer file.close();

    var buffer: [6]u8 = undefined;

    // 終端から6バイト前
    try file.seekFromEnd(-6);
    _ = try file.readAll(&buffer);
    std.debug.print("  seekFromEnd(-6): \"{s}\"\n", .{&buffer});

    // 終端に移動 (0)
    try file.seekFromEnd(0);
    const end_pos = try file.getPos();
    std.debug.print("  seekFromEnd(0): pos={d} (終端)\n", .{end_pos});

    std.debug.print("\n  seekFromEnd の用途:\n", .{});
    std.debug.print("    ファイル末尾のデータ読み取り\n", .{});
    std.debug.print("    追記位置の確認\n", .{});
    std.debug.print("    ファイルサイズの取得\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// getPos / getEndPos
// ====================

fn demoGetPositions() !void {
    std.debug.print("--- getPos / getEndPos ---\n", .{});

    const cwd = std.fs.cwd();

    {
        const tmp = try cwd.createFile("pos_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("0123456789"); // 10バイト
    }
    defer cwd.deleteFile("pos_test.txt") catch {};

    const file = try cwd.openFile("pos_test.txt", .{});
    defer file.close();

    // ファイルサイズを取得
    const end_pos = try file.getEndPos();
    std.debug.print("  ファイルサイズ: {d} bytes\n", .{end_pos});

    // 現在位置を確認
    std.debug.print("  初期位置: {d}\n", .{try file.getPos()});

    // 読み込んで位置変化を確認
    var buffer: [4]u8 = undefined;
    _ = try file.readAll(&buffer);
    std.debug.print("  4バイト読み込み後: {d}\n", .{try file.getPos()});

    // 残りバイト数を計算
    const current = try file.getPos();
    const remaining = end_pos - current;
    std.debug.print("  残りバイト数: {d}\n", .{remaining});

    std.debug.print("\n", .{});
}

// ====================
// ランダムアクセスパターン
// ====================

fn demoRandomAccess() !void {
    std.debug.print("--- ランダムアクセスパターン ---\n", .{});

    const cwd = std.fs.cwd();

    // 固定長レコードファイル作成
    {
        const tmp = try cwd.createFile("records.dat", .{});
        defer tmp.close();
        // 各レコード10バイト
        _ = try tmp.write("Record-00-");
        _ = try tmp.write("Record-01-");
        _ = try tmp.write("Record-02-");
        _ = try tmp.write("Record-03-");
        _ = try tmp.write("Record-04-");
    }
    defer cwd.deleteFile("records.dat") catch {};

    const file = try cwd.openFile("records.dat", .{});
    defer file.close();

    const record_size: u64 = 10;

    // レコードを直接読む関数
    const readRecord = struct {
        fn f(f_inner: std.fs.File, index: u64) ![10]u8 {
            try f_inner.seekTo(index * record_size);
            var buffer: [10]u8 = undefined;
            _ = try f_inner.readAll(&buffer);
            return buffer;
        }
    }.f;

    // 任意の順序でレコードにアクセス
    std.debug.print("  レコード3: \"{s}\"\n", .{try readRecord(file, 3)});
    std.debug.print("  レコード1: \"{s}\"\n", .{try readRecord(file, 1)});
    std.debug.print("  レコード4: \"{s}\"\n", .{try readRecord(file, 4)});
    std.debug.print("  レコード0: \"{s}\"\n", .{try readRecord(file, 0)});

    std.debug.print("\n  固定長レコードの利点:\n", .{});
    std.debug.print("    seekTo(index * record_size) で直接アクセス\n", .{});
    std.debug.print("    O(1) でランダムアクセス可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ファイル編集パターン
// ====================

fn demoFileEdit() !void {
    std.debug.print("--- ファイル編集パターン ---\n", .{});

    const cwd = std.fs.cwd();

    // ファイル作成
    {
        const tmp = try cwd.createFile("edit_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Hello, World!");
    }
    defer cwd.deleteFile("edit_test.txt") catch {};

    // read_write モードで開く
    const file = try cwd.openFile("edit_test.txt", .{
        .mode = .read_write,
    });
    defer file.close();

    // 7バイト目に移動して "World" を "Zig!!" に置換
    try file.seekTo(7);
    _ = try file.write("Zig!!");

    // 先頭に戻って結果を確認
    try file.seekTo(0);
    var buffer: [20]u8 = undefined;
    const n = try file.readAll(&buffer);
    std.debug.print("  編集後: \"{s}\"\n", .{buffer[0..n]});

    std.debug.print("\n  注意点:\n", .{});
    std.debug.print("    上書きは同じバイト数が必要\n", .{});
    std.debug.print("    挿入・削除は別の方法が必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  絶対位置シーク:\n", .{});
    std.debug.print("    seekTo(offset)    : 先頭から\n", .{});
    std.debug.print("    seekFromEnd(-n)   : 終端から n バイト前\n", .{});

    std.debug.print("\n  相対位置シーク:\n", .{});
    std.debug.print("    seekBy(n)         : 前方に n バイト\n", .{});
    std.debug.print("    seekBy(-n)        : 後方に n バイト\n", .{});

    std.debug.print("\n  位置取得:\n", .{});
    std.debug.print("    getPos()          : 現在位置\n", .{});
    std.debug.print("    getEndPos()       : ファイルサイズ\n", .{});

    std.debug.print("\n  用途:\n", .{});
    std.debug.print("    ランダムアクセスファイル\n", .{});
    std.debug.print("    固定長レコードの読み書き\n", .{});
    std.debug.print("    ファイルの一部編集\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== シーク位置 ===\n\n", .{});

    demoConcept();
    try demoSeekTo();
    try demoSeekBy();
    try demoSeekFromEnd();
    try demoGetPositions();
    try demoRandomAccess();
    try demoFileEdit();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・シークでファイル内を自由に移動\n", .{});
    std.debug.print("・固定長レコードならO(1)アクセス\n", .{});
    std.debug.print("・getPos/getEndPos で位置・サイズ確認\n", .{});
}

// --- テスト ---

test "seekTo" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_seekto.txt", .{});
        defer file.close();
        _ = try file.write("ABCDEFGHIJ");
    }
    defer cwd.deleteFile("test_seekto.txt") catch {};

    const file = try cwd.openFile("test_seekto.txt", .{});
    defer file.close();

    // 位置5にシーク
    try file.seekTo(5);
    var buf: [3]u8 = undefined;
    _ = try file.readAll(&buf);
    try std.testing.expectEqualStrings("FGH", &buf);
}

test "seekBy" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_seekby.txt", .{});
        defer file.close();
        _ = try file.write("0123456789");
    }
    defer cwd.deleteFile("test_seekby.txt") catch {};

    const file = try cwd.openFile("test_seekby.txt", .{});
    defer file.close();

    // 3バイト読む (位置0->3)
    var buf: [3]u8 = undefined;
    _ = try file.readAll(&buf);

    // 2バイト進む (位置3->5)
    try file.seekBy(2);
    _ = try file.readAll(&buf);
    try std.testing.expectEqualStrings("567", &buf);

    // 4バイト戻る (位置8->4)
    try file.seekBy(-4);
    try std.testing.expectEqual(@as(u64, 4), try file.getPos());
}

test "seekFromEnd" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_seekfromend.txt", .{});
        defer file.close();
        _ = try file.write("Hello, World!");
    }
    defer cwd.deleteFile("test_seekfromend.txt") catch {};

    const file = try cwd.openFile("test_seekfromend.txt", .{});
    defer file.close();

    // 終端から6バイト前
    try file.seekFromEnd(-6);
    var buf: [6]u8 = undefined;
    _ = try file.readAll(&buf);
    try std.testing.expectEqualStrings("World!", &buf);
}

test "getPos and getEndPos" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_getpos.txt", .{});
        defer file.close();
        _ = try file.write("1234567890");
    }
    defer cwd.deleteFile("test_getpos.txt") catch {};

    const file = try cwd.openFile("test_getpos.txt", .{});
    defer file.close();

    try std.testing.expectEqual(@as(u64, 0), try file.getPos());
    try std.testing.expectEqual(@as(u64, 10), try file.getEndPos());

    var buf: [5]u8 = undefined;
    _ = try file.readAll(&buf);
    try std.testing.expectEqual(@as(u64, 5), try file.getPos());
}

test "random access records" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_records.dat", .{});
        defer file.close();
        _ = try file.write("AAA");
        _ = try file.write("BBB");
        _ = try file.write("CCC");
    }
    defer cwd.deleteFile("test_records.dat") catch {};

    const file = try cwd.openFile("test_records.dat", .{});
    defer file.close();

    // レコード2 (位置6) を直接読む
    try file.seekTo(6);
    var buf: [3]u8 = undefined;
    _ = try file.readAll(&buf);
    try std.testing.expectEqualStrings("CCC", &buf);

    // レコード0 (位置0) を読む
    try file.seekTo(0);
    _ = try file.readAll(&buf);
    try std.testing.expectEqualStrings("AAA", &buf);
}
