//! # 文字列
//!
//! Zigの文字列は `[]const u8`（UTF-8バイトのスライス）。
//! C言語の文字列と似ているが、長さ情報を持つため安全。
//!
//! ## 文字列の型
//! - `[]const u8`: 文字列スライス（最も一般的）
//! - `[N]u8`: 固定長バイト配列
//! - `[:0]const u8`: null終端文字列（C互換）
//! - `*const [N:0]u8`: 文字列リテラルの型
//!
//! ## 特徴
//! - UTF-8エンコード前提
//! - 長さは `.len` で取得
//! - 不変（const）が基本

const std = @import("std");

pub fn main() void {
    std.debug.print("=== 文字列 ===\n\n", .{});

    // ====================
    // 文字列リテラル
    // ====================

    const greeting = "Hello, World!";
    std.debug.print("greeting: {s}\n", .{greeting});
    std.debug.print("len: {d}\n", .{greeting.len});

    // 日本語（マルチバイトUTF-8）
    const japanese = "こんにちは";
    std.debug.print("japanese: {s}\n", .{japanese});
    std.debug.print("バイト長: {d}\n", .{japanese.len}); // 15バイト（3バイト×5文字）

    std.debug.print("\n", .{});

    // ====================
    // 文字列の比較
    // ====================

    const str1 = "hello";
    const str2 = "hello";
    const str3 = "world";

    std.debug.print("\"hello\" == \"hello\": {}\n", .{std.mem.eql(u8, str1, str2)});
    std.debug.print("\"hello\" == \"world\": {}\n", .{std.mem.eql(u8, str1, str3)});

    std.debug.print("\n", .{});

    // ====================
    // 文字列操作（std.mem）
    // ====================

    const text = "Hello, World!";

    // startsWith / endsWith
    std.debug.print("starts with 'Hello': {}\n", .{std.mem.startsWith(u8, text, "Hello")});
    std.debug.print("ends with '!': {}\n", .{std.mem.endsWith(u8, text, "!")});

    // indexOf
    if (std.mem.indexOf(u8, text, "World")) |pos| {
        std.debug.print("'World' found at: {d}\n", .{pos});
    }

    std.debug.print("\n", .{});

    // ====================
    // 文字列の反復
    // ====================

    const word = "Zig";

    // バイト単位
    std.debug.print("バイト単位: ", .{});
    for (word) |byte| {
        std.debug.print("{c} ", .{byte});
    }
    std.debug.print("\n", .{});

    // インデックス付き
    std.debug.print("インデックス付き: ", .{});
    for (word, 0..) |byte, i| {
        std.debug.print("[{d}]={c} ", .{ i, byte });
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});

    // ====================
    // 文字列スライス
    // ====================

    const sentence = "The quick brown fox";

    const first_word = sentence[0..3];
    std.debug.print("最初の単語: {s}\n", .{first_word});

    const rest = sentence[4..];
    std.debug.print("残り: {s}\n", .{rest});

    std.debug.print("\n", .{});

    // ====================
    // エスケープシーケンス
    // ====================

    const with_newline = "Line1\nLine2";
    const with_tab = "Col1\tCol2";
    const with_quote = "She said \"Hello\"";

    std.debug.print("改行: {s}\n", .{with_newline});
    std.debug.print("タブ: {s}\n", .{with_tab});
    std.debug.print("引用符: {s}\n", .{with_quote});

    std.debug.print("\n", .{});

    // ====================
    // マルチライン文字列
    // ====================

    const multiline =
        \\Line 1
        \\Line 2
        \\Line 3
    ;
    std.debug.print("マルチライン:\n{s}\n", .{multiline});

    std.debug.print("\n--- 補足 ---\n", .{});
    std.debug.print("・文字列は []const u8 スライス\n", .{});
    std.debug.print("・UTF-8エンコード前提\n", .{});
    std.debug.print("・比較は std.mem.eql を使用\n", .{});
}

// ====================
// 文字列操作関数
// ====================

/// 文字列を大文字に変換（ASCII限定）
fn toUpperAscii(src: []const u8, dest: []u8) []u8 {
    std.debug.assert(src.len <= dest.len);
    for (src, 0..) |c, i| {
        dest[i] = if (c >= 'a' and c <= 'z') c - 32 else c;
    }
    return dest[0..src.len];
}

/// 文字列を小文字に変換（ASCII限定）
fn toLowerAscii(src: []const u8, dest: []u8) []u8 {
    std.debug.assert(src.len <= dest.len);
    for (src, 0..) |c, i| {
        dest[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    return dest[0..src.len];
}

/// 部分文字列の出現回数をカウント
fn countOccurrences(haystack: []const u8, needle: []const u8) usize {
    return std.mem.count(u8, haystack, needle);
}

/// 文字列が数字のみで構成されているか
fn isDigitsOnly(str: []const u8) bool {
    for (str) |c| {
        if (c < '0' or c > '9') return false;
    }
    return str.len > 0;
}

// --- テスト ---

test "string literal" {
    const s = "Hello";
    try std.testing.expectEqual(@as(usize, 5), s.len);
    try std.testing.expectEqual(@as(u8, 'H'), s[0]);
    try std.testing.expectEqual(@as(u8, 'o'), s[4]);
}

test "string comparison" {
    const a = "hello";
    const b = "hello";
    const c = "world";

    try std.testing.expect(std.mem.eql(u8, a, b));
    try std.testing.expect(!std.mem.eql(u8, a, c));
}

test "startsWith and endsWith" {
    const s = "Hello, World!";

    try std.testing.expect(std.mem.startsWith(u8, s, "Hello"));
    try std.testing.expect(!std.mem.startsWith(u8, s, "World"));
    try std.testing.expect(std.mem.endsWith(u8, s, "!"));
    try std.testing.expect(!std.mem.endsWith(u8, s, "Hello"));
}

test "indexOf" {
    const s = "Hello, World!";

    try std.testing.expectEqual(@as(?usize, 7), std.mem.indexOf(u8, s, "World"));
    try std.testing.expect(std.mem.indexOf(u8, s, "xyz") == null);
}

test "string slice" {
    const s = "Hello, World!";

    try std.testing.expect(std.mem.eql(u8, s[0..5], "Hello"));
    try std.testing.expect(std.mem.eql(u8, s[7..], "World!"));
}

test "escape sequences" {
    const with_newline = "a\nb";
    try std.testing.expectEqual(@as(usize, 3), with_newline.len);

    const with_tab = "a\tb";
    try std.testing.expectEqual(@as(usize, 3), with_tab.len);
}

test "multiline string" {
    const s =
        \\Line 1
        \\Line 2
    ;
    try std.testing.expect(std.mem.indexOf(u8, s, "Line 1") != null);
    try std.testing.expect(std.mem.indexOf(u8, s, "Line 2") != null);
}

test "toUpperAscii function" {
    var buf: [20]u8 = undefined;
    const result = toUpperAscii("Hello", &buf);
    try std.testing.expect(std.mem.eql(u8, result, "HELLO"));
}

test "toLowerAscii function" {
    var buf: [20]u8 = undefined;
    const result = toLowerAscii("HELLO", &buf);
    try std.testing.expect(std.mem.eql(u8, result, "hello"));
}

test "countOccurrences function" {
    try std.testing.expectEqual(@as(usize, 2), countOccurrences("abcabc", "a"));
    try std.testing.expectEqual(@as(usize, 2), countOccurrences("abcabc", "bc"));
    try std.testing.expectEqual(@as(usize, 0), countOccurrences("abcabc", "xyz"));
}

test "isDigitsOnly function" {
    try std.testing.expect(isDigitsOnly("12345"));
    try std.testing.expect(!isDigitsOnly("123a5"));
    try std.testing.expect(!isDigitsOnly(""));
    try std.testing.expect(!isDigitsOnly("hello"));
}

test "utf8 string length" {
    // UTF-8マルチバイト文字
    const japanese = "あ"; // ひらがな「あ」は3バイト
    try std.testing.expectEqual(@as(usize, 3), japanese.len);

    // 複数文字
    const hello_ja = "こんにちは"; // 5文字 × 3バイト = 15バイト
    try std.testing.expectEqual(@as(usize, 15), hello_ja.len);
}

test "string concatenation at comptime" {
    const a = "Hello";
    const b = ", ";
    const c = "World!";
    const combined = a ++ b ++ c;

    try std.testing.expect(std.mem.eql(u8, combined, "Hello, World!"));
}

test "string to bytes" {
    const s = "ABC";
    try std.testing.expectEqual(@as(u8, 65), s[0]); // 'A'
    try std.testing.expectEqual(@as(u8, 66), s[1]); // 'B'
    try std.testing.expectEqual(@as(u8, 67), s[2]); // 'C'
}

test "null-terminated string" {
    const s: [:0]const u8 = "hello";
    try std.testing.expectEqual(@as(usize, 5), s.len);
    try std.testing.expectEqual(@as(u8, 0), s[s.len]); // センチネル値
}

test "trim whitespace" {
    const s = "  hello  ";
    const trimmed = std.mem.trim(u8, s, " ");
    try std.testing.expect(std.mem.eql(u8, trimmed, "hello"));
}
