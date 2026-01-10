//! # ファイル読み込み
//!
//! ファイルからデータを読み込む様々な方法。
//! read、readAll、Reader インターフェース。
//!
//! ## 主要メソッド
//! - file.read(): バッファに読み込み
//! - file.readAll(): 可能な限り読み込み
//! - file.reader(): Reader インターフェース取得
//! - readUntilDelimiter(): 区切り文字まで読み込み

const std = @import("std");

// ====================
// 基本的な読み込み
// ====================

fn demoBasicRead() !void {
    std.debug.print("--- 基本的な読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("basic_read.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Hello, Zig!\nSecond line\nThird line");
    }
    defer cwd.deleteFile("basic_read.txt") catch {};

    const file = try cwd.openFile("basic_read.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // read() はバッファを埋めるかEOFまで読む
    var buffer: [16]u8 = undefined;
    const bytes_read = try file.read(&buffer);

    std.debug.print("  read() 結果: \"{s}\"\n", .{buffer[0..bytes_read]});
    std.debug.print("  読み込みバイト数: {d}\n", .{bytes_read});

    std.debug.print("  read() の特徴:\n", .{});
    std.debug.print("    バッファサイズまで読み込む\n", .{});
    std.debug.print("    EOFで0を返す\n", .{});
    std.debug.print("    部分的読み込みの可能性あり\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// readAll
// ====================

fn demoReadAll() !void {
    std.debug.print("--- readAll ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("readall_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Complete content here!");
    }
    defer cwd.deleteFile("readall_test.txt") catch {};

    const file = try cwd.openFile("readall_test.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // readAll() はバッファが埋まるまで繰り返し読む
    var buffer: [64]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);

    std.debug.print("  readAll() 結果: \"{s}\"\n", .{buffer[0..bytes_read]});

    std.debug.print("  readAll() の特徴:\n", .{});
    std.debug.print("    バッファ全体を埋めようとする\n", .{});
    std.debug.print("    複数回のsyscallを内部で実行\n", .{});
    std.debug.print("    EOFまたはバッファ一杯で終了\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// Reader インターフェース
// ====================

fn demoLineByLine() !void {
    std.debug.print("--- 行単位読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("lines_test.txt", .{});
        defer tmp.close();
        _ = try tmp.write("Line1\nLine2\nLine3\n");
    }
    defer cwd.deleteFile("lines_test.txt") catch {};

    const file = try cwd.openFile("lines_test.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // 手動で行を解析
    var buffer: [128]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    var line_count: usize = 0;
    var iter = std.mem.splitScalar(u8, content, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        line_count += 1;
        std.debug.print("  行{d}: {s}\n", .{ line_count, line });
    }

    std.debug.print("  行単位読み込みのパターン:\n", .{});
    std.debug.print("    1. ファイル全体を読む\n", .{});
    std.debug.print("    2. mem.splitScalar で分割\n", .{});
    std.debug.print("    3. イテレータで処理\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 区切り文字での読み込み
// ====================

fn demoDelimiterRead() !void {
    std.debug.print("--- 区切り文字での読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // CSVライクなデータ
    {
        const tmp = try cwd.createFile("csv_data.txt", .{});
        defer tmp.close();
        _ = try tmp.write("apple,banana,cherry,date");
    }
    defer cwd.deleteFile("csv_data.txt") catch {};

    const file = try cwd.openFile("csv_data.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // ファイル全体を読んでから分割
    var buffer: [128]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    std.debug.print("  カンマ区切りで読み込み:\n", .{});
    var count: usize = 0;
    var iter = std.mem.splitScalar(u8, content, ',');
    while (iter.next()) |word| {
        std.debug.print("    [{d}] {s}\n", .{ count, word });
        count += 1;
    }

    std.debug.print("\n", .{});
}

// ====================
// ファイル全体読み込み（アロケータ使用）
// ====================

fn demoReadEntireFile() !void {
    std.debug.print("--- ファイル全体読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // テストファイル作成
    {
        const tmp = try cwd.createFile("entire_file.txt", .{});
        defer tmp.close();
        _ = try tmp.write("This is the entire file content.\nMultiple lines.\nEnd.");
    }
    defer cwd.deleteFile("entire_file.txt") catch {};

    const file = try cwd.openFile("entire_file.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // アロケータを使ってファイル全体を読む
    const allocator = std.testing.allocator;
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    std.debug.print("  ファイル全体 ({d} bytes):\n", .{content.len});
    std.debug.print("  {s}\n", .{content});

    std.debug.print("  readToEndAlloc() の特徴:\n", .{});
    std.debug.print("    アロケータでメモリ確保\n", .{});
    std.debug.print("    最大サイズを指定\n", .{});
    std.debug.print("    呼び出し側でfree必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// バイナリデータ読み込み
// ====================

fn demoBinaryRead() !void {
    std.debug.print("--- バイナリデータ読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // バイナリデータ作成
    {
        const tmp = try cwd.createFile("binary.dat", .{});
        defer tmp.close();
        // リトルエンディアンで数値を書き込み
        _ = try tmp.write(&std.mem.toBytes(@as(u32, 0x12345678)));
        _ = try tmp.write(&std.mem.toBytes(@as(u16, 0xABCD)));
    }
    defer cwd.deleteFile("binary.dat") catch {};

    const file = try cwd.openFile("binary.dat", .{
        .mode = .read_only,
    });
    defer file.close();

    // バイト列を読み込んでからmem.readIntで解析
    var buffer: [6]u8 = undefined;
    _ = try file.readAll(&buffer);

    const val32 = std.mem.readInt(u32, buffer[0..4], .little);
    const val16 = std.mem.readInt(u16, buffer[4..6], .little);

    std.debug.print("  u32: 0x{X:0>8}\n", .{val32});
    std.debug.print("  u16: 0x{X:0>4}\n", .{val16});

    std.debug.print("  std.mem.readInt() の特徴:\n", .{});
    std.debug.print("    エンディアンを指定可能\n", .{});
    std.debug.print("    .little / .big\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 構造体の読み込み
// ====================

const Header = packed struct {
    magic: u32,
    version: u16,
    flags: u16,
};

fn demoStructRead() !void {
    std.debug.print("--- 構造体の読み込み ---\n", .{});

    const cwd = std.fs.cwd();

    // ヘッダーデータ作成
    {
        const tmp = try cwd.createFile("header.bin", .{});
        defer tmp.close();
        const header = Header{
            .magic = 0x5A494700, // "ZIG\0"
            .version = 1,
            .flags = 0x0003,
        };
        _ = try tmp.write(std.mem.asBytes(&header));
    }
    defer cwd.deleteFile("header.bin") catch {};

    const file = try cwd.openFile("header.bin", .{
        .mode = .read_only,
    });
    defer file.close();

    // バイト列を読み込んでから構造体にキャスト
    var buffer: [@sizeOf(Header)]u8 = undefined;
    _ = try file.readAll(&buffer);
    const header: *const Header = @ptrCast(&buffer);

    std.debug.print("  magic:   0x{X:0>8}\n", .{header.magic});
    std.debug.print("  version: {d}\n", .{header.version});
    std.debug.print("  flags:   0x{X:0>4}\n", .{header.flags});

    std.debug.print("  packed struct 読み込みパターン:\n", .{});
    std.debug.print("    1. バッファにreadAll\n", .{});
    std.debug.print("    2. @ptrCast で構造体参照に変換\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  低レベル（File直接）:\n", .{});
    std.debug.print("    read()     - 一度の読み込み\n", .{});
    std.debug.print("    readAll()  - バッファを埋める\n", .{});

    std.debug.print("  ファイル全体:\n", .{});
    std.debug.print("    readToEndAlloc() - アロケータ使用\n", .{});

    std.debug.print("  パース処理:\n", .{});
    std.debug.print("    mem.splitScalar() - 区切り分割\n", .{});
    std.debug.print("    mem.readInt()     - バイナリ整数\n", .{});
    std.debug.print("    @ptrCast          - 構造体変換\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== ファイル読み込み ===\n\n", .{});

    try demoBasicRead();
    try demoReadAll();
    try demoLineByLine();
    try demoDelimiterRead();
    try demoReadEntireFile();
    try demoBinaryRead();
    try demoStructRead();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・read() は部分的読み込みの可能性あり\n", .{});
    std.debug.print("・readAll() は完全読み込みを保証\n", .{});
    std.debug.print("・reader() でストリーム操作\n", .{});
    std.debug.print("・バイナリはエンディアンに注意\n", .{});
}

// --- テスト ---

test "basic read" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_basic_read.txt", .{});
        defer file.close();
        _ = try file.write("Test");
    }
    defer cwd.deleteFile("test_basic_read.txt") catch {};

    const file = try cwd.openFile("test_basic_read.txt", .{});
    defer file.close();

    var buffer: [10]u8 = undefined;
    const n = try file.read(&buffer);
    try std.testing.expectEqual(@as(usize, 4), n);
    try std.testing.expectEqualStrings("Test", buffer[0..n]);
}

test "readAll" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_readall.txt", .{});
        defer file.close();
        _ = try file.write("Complete");
    }
    defer cwd.deleteFile("test_readall.txt") catch {};

    const file = try cwd.openFile("test_readall.txt", .{});
    defer file.close();

    var buffer: [64]u8 = undefined;
    const n = try file.readAll(&buffer);
    try std.testing.expectEqualStrings("Complete", buffer[0..n]);
}

test "multiple reads" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_multi.txt", .{});
        defer file.close();
        _ = try file.write("FirstSecondThird");
    }
    defer cwd.deleteFile("test_multi.txt") catch {};

    const file = try cwd.openFile("test_multi.txt", .{});
    defer file.close();

    var buffer: [5]u8 = undefined;

    // 最初の5バイトを読む
    _ = try file.read(&buffer);
    try std.testing.expectEqualStrings("First", &buffer);

    // 次の6バイトを読む
    var buffer2: [6]u8 = undefined;
    _ = try file.read(&buffer2);
    try std.testing.expectEqualStrings("Second", &buffer2);
}

test "binary read with mem" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_binary.bin", .{});
        defer file.close();
        _ = try file.write(&std.mem.toBytes(@as(u32, 0x04030201)));
    }
    defer cwd.deleteFile("test_binary.bin") catch {};

    const file = try cwd.openFile("test_binary.bin", .{});
    defer file.close();

    var buffer: [4]u8 = undefined;
    _ = try file.read(&buffer);
    const val = std.mem.readInt(u32, &buffer, .little);
    try std.testing.expectEqual(@as(u32, 0x04030201), val);
}

test "readToEndAlloc" {
    const cwd = std.fs.cwd();

    {
        const file = try cwd.createFile("test_toend.txt", .{});
        defer file.close();
        _ = try file.write("Entire content");
    }
    defer cwd.deleteFile("test_toend.txt") catch {};

    const file = try cwd.openFile("test_toend.txt", .{});
    defer file.close();

    const allocator = std.testing.allocator;
    const content = try file.readToEndAlloc(allocator, 1024);
    defer allocator.free(content);

    try std.testing.expectEqualStrings("Entire content", content);
}
