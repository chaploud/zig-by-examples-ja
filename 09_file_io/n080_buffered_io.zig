//! # バッファードI/O
//!
//! システムコールを減らし効率的なI/Oを実現する。
//! バッファを使って読み書きをまとめて行う。
//!
//! ## 主要な型
//! - std.io.fixedBufferStream: メモリバッファをストリーム化
//! - std.io.Writer.Allocating: 動的バッファ書き込み
//!
//! ## バッファードI/Oの利点
//! - システムコール回数の削減
//! - パフォーマンス向上
//! - 小さな読み書きの効率化

const std = @import("std");

// ====================
// バッファードI/Oの仕組み
// ====================

fn demoConcept() void {
    std.debug.print("--- バッファードI/Oの概念 ---\n", .{});

    std.debug.print("  通常のI/O:\n", .{});
    std.debug.print("    1バイト読む → 1回のsyscall\n", .{});
    std.debug.print("    100バイト読む → 100回のsyscall（最悪）\n", .{});

    std.debug.print("\n  バッファードI/O:\n", .{});
    std.debug.print("    バッファサイズ分まとめて読む → 1回のsyscall\n", .{});
    std.debug.print("    後続の読み込みはバッファから取得\n", .{});

    std.debug.print("\n  典型的なバッファサイズ:\n", .{});
    std.debug.print("    4096 (4KB) - ページサイズ\n", .{});
    std.debug.print("    8192 (8KB) - 一般的\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// fixedBufferStream - メモリバッファのストリーム化
// ====================

fn demoFixedBufferStream() !void {
    std.debug.print("--- fixedBufferStream ---\n", .{});

    // メモリバッファをストリームとして扱う
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    // Writer として使用
    const writer = fbs.writer();
    try writer.print("Hello, {s}!", .{"World"});
    try writer.print(" Value={d}", .{42});

    // 書き込んだ内容を取得
    const written = fbs.getWritten();
    std.debug.print("  書き込み結果: \"{s}\"\n", .{written});
    std.debug.print("  書き込みバイト数: {d}\n", .{written.len});

    // 位置を確認
    const pos = try fbs.getPos();
    std.debug.print("  現在位置: {d}\n", .{pos});

    // 位置をリセット
    fbs.reset();
    std.debug.print("  reset() 後の位置: {d}\n", .{try fbs.getPos()});

    std.debug.print("\n", .{});
}

// ====================
// fixedBufferStream - Reader として使用
// ====================

fn demoFixedBufferReader() !void {
    std.debug.print("--- fixedBufferStream (Reader) ---\n", .{});

    // 読み込み元データ
    const data = "ABCDEFGHIJ1234567890";
    var fbs = std.io.fixedBufferStream(data);
    const reader = fbs.reader();

    // 複数回に分けて読み込み
    var buf: [5]u8 = undefined;

    const n1 = try reader.read(&buf);
    std.debug.print("  1回目: \"{s}\" ({d} bytes)\n", .{ buf[0..n1], n1 });

    const n2 = try reader.read(&buf);
    std.debug.print("  2回目: \"{s}\" ({d} bytes)\n", .{ buf[0..n2], n2 });

    // seekTo で位置を変更
    try fbs.seekTo(0);
    const n3 = try reader.read(&buf);
    std.debug.print("  seekTo(0)後: \"{s}\" ({d} bytes)\n", .{ buf[0..n3], n3 });

    std.debug.print("\n", .{});
}

// ====================
// バッファリングによるファイル書き込み
// ====================

fn demoBufferedFileWrite() !void {
    std.debug.print("--- バッファリングによるファイル書き込み ---\n", .{});

    const cwd = std.fs.cwd();

    // まずメモリバッファに書き込む
    var buffer: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const writer = fbs.writer();

    // 複数回の書き込み（メモリ内で完結、syscall なし）
    try writer.print("Line 1: Hello\n", .{});
    try writer.print("Line 2: World\n", .{});
    try writer.print("Line 3: Zig!\n", .{});

    // まとめてファイルに書き込む（1回のsyscall）
    const file = try cwd.createFile("buffered_output.txt", .{});
    defer file.close();
    defer cwd.deleteFile("buffered_output.txt") catch {};

    _ = try file.write(fbs.getWritten());
    std.debug.print("  {d} bytes を1回で書き込み\n", .{fbs.getWritten().len});

    // 確認
    const read_file = try cwd.openFile("buffered_output.txt", .{});
    defer read_file.close();
    var read_buf: [256]u8 = undefined;
    const len = try read_file.readAll(&read_buf);
    std.debug.print("  ファイル内容:\n{s}", .{read_buf[0..len]});

    std.debug.print("\n", .{});
}

// ====================
// バッファリングによるファイル読み込み
// ====================

fn demoBufferedFileRead() !void {
    std.debug.print("--- バッファリングによるファイル読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("buffered_input.txt", .{});
        defer tmp.close();
        _ = try tmp.write("First,Second,Third,Fourth,Fifth");
    }
    defer cwd.deleteFile("buffered_input.txt") catch {};

    // ファイル全体を一度に読み込む
    const file = try cwd.openFile("buffered_input.txt", .{});
    defer file.close();

    var buffer: [256]u8 = undefined;
    const len = try file.readAll(&buffer);
    const content = buffer[0..len];

    std.debug.print("  {d} bytes を1回で読み込み\n", .{len});

    // fixedBufferStream で処理することも可能
    // var fbs = std.io.fixedBufferStream(content);
    // const reader = fbs.reader();

    // または直接 splitScalar で処理
    std.debug.print("  カンマ区切りで分割:\n", .{});
    var iter = std.mem.splitScalar(u8, content, ',');
    var i: usize = 0;
    while (iter.next()) |item| {
        std.debug.print("    [{d}] {s}\n", .{ i, item });
        i += 1;
    }

    std.debug.print("\n", .{});
}

// ====================
// Writer.Allocating - 動的バッファ
// ====================

fn demoAllocatingWriter() !void {
    std.debug.print("--- Writer.Allocating ---\n", .{});

    const allocator = std.testing.allocator;

    // 動的に拡張するバッファを持つWriter
    var aw: std.io.Writer.Allocating = .init(allocator);
    defer aw.deinit();

    // サイズを気にせず書き込み
    try aw.writer.print("This is a ", .{});
    try aw.writer.print("dynamically ", .{});
    try aw.writer.print("growing buffer!", .{});

    // 結果を取得
    const result = aw.writer.buffered();
    std.debug.print("  結果: \"{s}\"\n", .{result});
    std.debug.print("  バッファ長: {d} bytes\n", .{aw.writer.buffer.len});

    std.debug.print("\n  Writer.Allocating の特徴:\n", .{});
    std.debug.print("    サイズ不明な出力に対応\n", .{});
    std.debug.print("    必要に応じて自動拡張\n", .{});
    std.debug.print("    deinit() で解放必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// バッファサイズの選択
// ====================

fn demoBufferSizes() void {
    std.debug.print("--- バッファサイズの選択 ---\n", .{});

    std.debug.print("  推奨サイズ:\n", .{});
    std.debug.print("    小さなファイル: 1KB - 4KB\n", .{});
    std.debug.print("    一般的な用途:   4KB - 8KB\n", .{});
    std.debug.print("    大きなファイル: 64KB - 256KB\n", .{});

    std.debug.print("\n  考慮事項:\n", .{});
    std.debug.print("    大きすぎ → メモリ無駄遣い\n", .{});
    std.debug.print("    小さすぎ → syscall増加\n", .{});
    std.debug.print("    ページサイズ(4KB)の倍数が効率的\n", .{});

    std.debug.print("\n  スタック vs ヒープ:\n", .{});
    std.debug.print("    小さいバッファ → スタック (var buf: [4096]u8)\n", .{});
    std.debug.print("    大きいバッファ → アロケータで確保\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 用途別パターン
// ====================

fn demoUsagePatterns() void {
    std.debug.print("--- 用途別パターン ---\n", .{});

    std.debug.print("  文字列フォーマット:\n", .{});
    std.debug.print("    var buf: [256]u8 = undefined;\n", .{});
    std.debug.print("    var fbs = fixedBufferStream(&buf);\n", .{});
    std.debug.print("    try fbs.writer().print(...);\n", .{});
    std.debug.print("    fbs.getWritten(); // 結果取得\n", .{});

    std.debug.print("\n  ファイル全体読み込み:\n", .{});
    std.debug.print("    readAll() または readToEndAlloc()\n", .{});
    std.debug.print("    → まとめて処理\n", .{});

    std.debug.print("\n  大きなファイル:\n", .{});
    std.debug.print("    チャンク単位で read() を繰り返し\n", .{});
    std.debug.print("    各チャンクを処理\n", .{});

    std.debug.print("\n  テスト:\n", .{});
    std.debug.print("    fixedBufferStream でモックI/O\n", .{});
    std.debug.print("    ファイル不要でI/Oテスト可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  fixedBufferStream:\n", .{});
    std.debug.print("    メモリバッファをストリーム化\n", .{});
    std.debug.print("    .writer() / .reader() で読み書き\n", .{});
    std.debug.print("    .getWritten() で結果取得\n", .{});

    std.debug.print("\n  Writer.Allocating:\n", .{});
    std.debug.print("    動的に拡張するバッファ\n", .{});
    std.debug.print("    サイズ不明な出力に便利\n", .{});

    std.debug.print("\n  バッファリング戦略:\n", .{});
    std.debug.print("    メモリにまとめてからファイルに書く\n", .{});
    std.debug.print("    ファイルを一度に読んでメモリで処理\n", .{});
    std.debug.print("    syscall回数を最小化\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== バッファードI/O ===\n\n", .{});

    demoConcept();
    try demoFixedBufferStream();
    try demoFixedBufferReader();
    try demoBufferedFileWrite();
    try demoBufferedFileRead();
    try demoAllocatingWriter();
    demoBufferSizes();
    demoUsagePatterns();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・バッファードI/Oで効率的なファイル操作\n", .{});
    std.debug.print("・syscall回数を減らしてパフォーマンス向上\n", .{});
    std.debug.print("・fixedBufferStream はテストにも便利\n", .{});
}

// --- テスト ---

test "fixedBufferStream write" {
    var buffer: [32]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    try fbs.writer().print("Hello {d}", .{42});
    try std.testing.expectEqualStrings("Hello 42", fbs.getWritten());
}

test "fixedBufferStream read" {
    const data = "TestInput";
    var fbs = std.io.fixedBufferStream(data);

    var buf: [4]u8 = undefined;
    const n = try fbs.reader().read(&buf);
    try std.testing.expectEqual(@as(usize, 4), n);
    try std.testing.expectEqualStrings("Test", &buf);
}

test "fixedBufferStream seek" {
    const data = "ABCDEFGH";
    var fbs = std.io.fixedBufferStream(data);

    // 最初に読む
    var buf: [2]u8 = undefined;
    _ = try fbs.reader().read(&buf);
    try std.testing.expectEqualStrings("AB", &buf);

    // seekTo で戻る
    try fbs.seekTo(0);
    _ = try fbs.reader().read(&buf);
    try std.testing.expectEqualStrings("AB", &buf);

    // 途中からシーク
    try fbs.seekTo(4);
    _ = try fbs.reader().read(&buf);
    try std.testing.expectEqualStrings("EF", &buf);
}

test "fixedBufferStream getPos" {
    var buffer: [32]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    try std.testing.expectEqual(@as(u64, 0), try fbs.getPos());

    try fbs.writer().writeAll("Hello");
    try std.testing.expectEqual(@as(u64, 5), try fbs.getPos());

    fbs.reset();
    try std.testing.expectEqual(@as(u64, 0), try fbs.getPos());
}

test "Writer.Allocating" {
    const allocator = std.testing.allocator;

    var aw: std.io.Writer.Allocating = .init(allocator);
    defer aw.deinit();

    try aw.writer.print("Test: {d}", .{123});
    try std.testing.expectEqualStrings("Test: 123", aw.writer.buffered());
}

test "buffered file write pattern" {
    const cwd = std.fs.cwd();

    // バッファに書き込み
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    try fbs.writer().print("Line1\nLine2\n", .{});

    // ファイルに書き込み
    const file = try cwd.createFile("test_buffered_pattern.txt", .{});
    defer file.close();
    defer cwd.deleteFile("test_buffered_pattern.txt") catch {};

    _ = try file.write(fbs.getWritten());

    // 読み込んで確認
    const read_file = try cwd.openFile("test_buffered_pattern.txt", .{});
    defer read_file.close();
    var read_buf: [64]u8 = undefined;
    const len = try read_file.readAll(&read_buf);
    try std.testing.expectEqualStrings("Line1\nLine2\n", read_buf[0..len]);
}
