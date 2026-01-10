//! # ファイル書き込み
//!
//! ファイルへのデータ書き込み方法。
//! write、writeAll、フォーマット出力。
//!
//! ## 主要メソッド
//! - file.write(): バイト列を書き込み
//! - file.writeAll(): 全バイトを書き込み
//! - file.writer(): Writer インターフェース取得
//! - std.fmt.format(): フォーマット文字列

const std = @import("std");

// ====================
// 基本的な書き込み
// ====================

fn demoBasicWrite() !void {
    std.debug.print("--- 基本的な書き込み ---\n", .{});

    const cwd = std.fs.cwd();

    // createFile で新規ファイル作成
    const file = try cwd.createFile("basic_write.txt", .{});
    defer file.close();
    defer cwd.deleteFile("basic_write.txt") catch {};

    // write() でバイト列を書き込み
    const bytes_written = try file.write("Hello, Zig!");
    std.debug.print("  書き込みバイト数: {d}\n", .{bytes_written});

    std.debug.print("  write() の特徴:\n", .{});
    std.debug.print("    書き込んだバイト数を返す\n", .{});
    std.debug.print("    部分書き込みの可能性あり\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// writeAll
// ====================

fn demoWriteAll() !void {
    std.debug.print("--- writeAll ---\n", .{});

    const cwd = std.fs.cwd();

    const file = try cwd.createFile("writeall_test.txt", .{});
    defer file.close();
    defer cwd.deleteFile("writeall_test.txt") catch {};

    // writeAll() は全バイト書き込みを保証
    try file.writeAll("Complete data written!\n");
    try file.writeAll("Second line.\n");

    std.debug.print("  writeAll() 完了\n", .{});

    std.debug.print("  writeAll() の特徴:\n", .{});
    std.debug.print("    全バイト書き込みを保証\n", .{});
    std.debug.print("    内部で繰り返し書き込み\n", .{});
    std.debug.print("    戻り値なし（成功/エラーのみ）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 追記モード
// ====================

fn demoAppendMode() !void {
    std.debug.print("--- 追記モード ---\n", .{});

    const cwd = std.fs.cwd();

    // 最初のファイル作成
    {
        const file = try cwd.createFile("append_test.txt", .{});
        defer file.close();
        try file.writeAll("First line\n");
    }

    // 追記: openFile + seekFromEnd
    {
        const file = try cwd.openFile("append_test.txt", .{
            .mode = .write_only,
        });
        defer file.close();
        try file.seekFromEnd(0);
        try file.writeAll("Appended line\n");
    }
    defer cwd.deleteFile("append_test.txt") catch {};

    // 結果確認
    {
        const file = try cwd.openFile("append_test.txt", .{
            .mode = .read_only,
        });
        defer file.close();
        var buffer: [128]u8 = undefined;
        const n = try file.readAll(&buffer);
        std.debug.print("  結果:\n  {s}", .{buffer[0..n]});
    }

    std.debug.print("  追記の手順:\n", .{});
    std.debug.print("    1. openFile(.write_only)\n", .{});
    std.debug.print("    2. seekFromEnd(0)\n", .{});
    std.debug.print("    3. write/writeAll\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// フォーマット書き込み
// ====================

fn demoFormatWrite() !void {
    std.debug.print("--- フォーマット書き込み ---\n", .{});

    const cwd = std.fs.cwd();

    const file = try cwd.createFile("format_test.txt", .{});
    defer file.close();
    defer cwd.deleteFile("format_test.txt") catch {};

    // バッファを使ってフォーマット
    var buffer: [256]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&buffer, "Name: {s}, Age: {d}, Score: {d:.2}\n", .{
        "Alice",
        @as(u32, 25),
        @as(f64, 95.5),
    });
    try file.writeAll(formatted);

    // 複数行のフォーマット書き込み
    for (0..3) |i| {
        const line = try std.fmt.bufPrint(&buffer, "Item {d}: value_{d}\n", .{ i, i * 10 });
        try file.writeAll(line);
    }

    std.debug.print("  フォーマット書き込み完了\n", .{});

    // 結果確認
    try file.seekTo(0);
    {
        const read_file = try cwd.openFile("format_test.txt", .{});
        defer read_file.close();
        var read_buf: [256]u8 = undefined;
        const n = try read_file.readAll(&read_buf);
        std.debug.print("  内容:\n  {s}", .{read_buf[0..n]});
    }

    std.debug.print("\n", .{});
}

// ====================
// バイナリ書き込み
// ====================

fn demoBinaryWrite() !void {
    std.debug.print("--- バイナリ書き込み ---\n", .{});

    const cwd = std.fs.cwd();

    const file = try cwd.createFile("binary_write.dat", .{});
    defer file.close();
    defer cwd.deleteFile("binary_write.dat") catch {};

    // 整数をバイト列として書き込み
    const num32: u32 = 0x12345678;
    try file.writeAll(&std.mem.toBytes(num32));

    const num16: u16 = 0xABCD;
    try file.writeAll(&std.mem.toBytes(num16));

    // 配列も書き込み可能
    const data = [_]u8{ 0x00, 0x11, 0x22, 0x33 };
    try file.writeAll(&data);

    std.debug.print("  バイナリ書き込み完了\n", .{});
    std.debug.print("  書き込み: u32(0x12345678), u16(0xABCD), [4]u8\n", .{});

    std.debug.print("  std.mem.toBytes() の用途:\n", .{});
    std.debug.print("    任意の型をバイト配列に変換\n", .{});
    std.debug.print("    エンディアンはネイティブ\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体の書き込み
// ====================

const Record = packed struct {
    id: u32,
    value: i16,
    flags: u16,
};

fn demoStructWrite() !void {
    std.debug.print("--- 構造体の書き込み ---\n", .{});

    const cwd = std.fs.cwd();

    const file = try cwd.createFile("struct_write.dat", .{});
    defer file.close();
    defer cwd.deleteFile("struct_write.dat") catch {};

    // 構造体をバイト列として書き込み
    const records = [_]Record{
        .{ .id = 1, .value = 100, .flags = 0x0001 },
        .{ .id = 2, .value = -50, .flags = 0x0002 },
        .{ .id = 3, .value = 200, .flags = 0x0003 },
    };

    for (records) |rec| {
        try file.writeAll(std.mem.asBytes(&rec));
    }

    std.debug.print("  {d}レコード書き込み完了\n", .{records.len});
    std.debug.print("  各レコード: {d} bytes\n", .{@sizeOf(Record)});

    std.debug.print("  std.mem.asBytes() の用途:\n", .{});
    std.debug.print("    packed structをバイト列に変換\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 上書きと切り詰め
// ====================

fn demoTruncate() !void {
    std.debug.print("--- 上書きと切り詰め ---\n", .{});

    const cwd = std.fs.cwd();

    // 長いファイル作成
    {
        const file = try cwd.createFile("truncate_test.txt", .{});
        defer file.close();
        try file.writeAll("This is a very long content that will be truncated.");
    }

    // createFile のデフォルトは truncate=true
    // 既存ファイルを上書き
    {
        const file = try cwd.createFile("truncate_test.txt", .{
            // .truncate = true はデフォルト
        });
        defer file.close();
        try file.writeAll("Short");
    }
    defer cwd.deleteFile("truncate_test.txt") catch {};

    // 結果確認
    {
        const file = try cwd.openFile("truncate_test.txt", .{});
        defer file.close();
        var buffer: [128]u8 = undefined;
        const n = try file.readAll(&buffer);
        std.debug.print("  上書き後: \"{s}\"\n", .{buffer[0..n]});
    }

    std.debug.print("  createFile オプション:\n", .{});
    std.debug.print("    .truncate = true (デフォルト)\n", .{});
    std.debug.print("    既存内容は削除される\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// エラーハンドリング
// ====================

fn demoWriteErrors() void {
    std.debug.print("--- 書き込みエラー ---\n", .{});

    std.debug.print("  一般的なエラー:\n", .{});
    std.debug.print("    AccessDenied      - 書き込み権限なし\n", .{});
    std.debug.print("    NoSpaceLeft       - ディスク容量不足\n", .{});
    std.debug.print("    InputOutput       - I/Oエラー\n", .{});
    std.debug.print("    BrokenPipe        - パイプ切断\n", .{});

    std.debug.print("  エラー処理パターン:\n", .{});
    std.debug.print("    try file.writeAll(data);\n", .{});
    std.debug.print("    または catch |err| { ... }\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  基本書き込み:\n", .{});
    std.debug.print("    write()     - 部分書き込み可\n", .{});
    std.debug.print("    writeAll()  - 全書き込み保証\n", .{});

    std.debug.print("  フォーマット:\n", .{});
    std.debug.print("    std.fmt.bufPrint() + writeAll()\n", .{});

    std.debug.print("  バイナリ:\n", .{});
    std.debug.print("    std.mem.toBytes()  - 型→バイト列\n", .{});
    std.debug.print("    std.mem.asBytes()  - 構造体参照\n", .{});

    std.debug.print("  追記:\n", .{});
    std.debug.print("    openFile + seekFromEnd(0)\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ファイル書き込み ===\n\n", .{});

    try demoBasicWrite();
    try demoWriteAll();
    try demoAppendMode();
    try demoFormatWrite();
    try demoBinaryWrite();
    try demoStructWrite();
    try demoTruncate();
    demoWriteErrors();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・writeAll() を基本的に使う\n", .{});
    std.debug.print("・createFile のデフォルトは切り詰め\n", .{});
    std.debug.print("・追記は seekFromEnd(0) で\n", .{});
    std.debug.print("・バイナリは std.mem 関数を活用\n", .{});
}

// --- テスト ---

test "basic write" {
    const cwd = std.fs.cwd();

    const file = try cwd.createFile("test_write.txt", .{});
    defer file.close();
    defer cwd.deleteFile("test_write.txt") catch {};

    const n = try file.write("Test");
    try std.testing.expectEqual(@as(usize, 4), n);
}

test "writeAll" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_writeall.txt", .{});
        defer file.close();
        try file.writeAll("Complete");
    }
    defer cwd.deleteFile("test_writeall.txt") catch {};

    // 読み取りで検証
    const file = try cwd.openFile("test_writeall.txt", .{});
    defer file.close();
    var buffer: [32]u8 = undefined;
    const n = try file.readAll(&buffer);
    try std.testing.expectEqualStrings("Complete", buffer[0..n]);
}

test "append mode" {
    const cwd = std.fs.cwd();

    // 作成
    {
        const file = try cwd.createFile("test_append.txt", .{});
        defer file.close();
        try file.writeAll("First");
    }
    defer cwd.deleteFile("test_append.txt") catch {};

    // 追記
    {
        const file = try cwd.openFile("test_append.txt", .{ .mode = .write_only });
        defer file.close();
        try file.seekFromEnd(0);
        try file.writeAll("Second");
    }

    // 確認
    const file = try cwd.openFile("test_append.txt", .{});
    defer file.close();
    var buffer: [32]u8 = undefined;
    const n = try file.readAll(&buffer);
    try std.testing.expectEqualStrings("FirstSecond", buffer[0..n]);
}

test "binary write" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_binary_write.dat", .{});
        defer file.close();
        const val: u32 = 0x12345678;
        try file.writeAll(&std.mem.toBytes(val));
    }
    defer cwd.deleteFile("test_binary_write.dat") catch {};

    // 検証
    const file = try cwd.openFile("test_binary_write.dat", .{});
    defer file.close();
    var buffer: [4]u8 = undefined;
    _ = try file.readAll(&buffer);
    const read_val = std.mem.readInt(u32, &buffer, .little);
    try std.testing.expectEqual(@as(u32, 0x12345678), read_val);
}

test "format write" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_format.txt", .{});
        defer file.close();
        var buffer: [64]u8 = undefined;
        const formatted = try std.fmt.bufPrint(&buffer, "Value: {d}", .{@as(i32, 42)});
        try file.writeAll(formatted);
    }
    defer cwd.deleteFile("test_format.txt") catch {};

    // 検証
    const file = try cwd.openFile("test_format.txt", .{});
    defer file.close();
    var buffer: [64]u8 = undefined;
    const n = try file.readAll(&buffer);
    try std.testing.expectEqualStrings("Value: 42", buffer[0..n]);
}

test "truncate on create" {
    const cwd = std.fs.cwd();

    // 長いコンテンツ
    {
        const file = try cwd.createFile("test_truncate.txt", .{});
        defer file.close();
        try file.writeAll("Long content here");
    }
    defer cwd.deleteFile("test_truncate.txt") catch {};

    // 短いコンテンツで上書き
    {
        const file = try cwd.createFile("test_truncate.txt", .{});
        defer file.close();
        try file.writeAll("Short");
    }

    // 検証
    const file = try cwd.openFile("test_truncate.txt", .{});
    defer file.close();
    var buffer: [64]u8 = undefined;
    const n = try file.readAll(&buffer);
    try std.testing.expectEqualStrings("Short", buffer[0..n]);
}
