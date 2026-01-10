//! # 標準入出力
//!
//! stdin、stdout、stderr を使った入出力。
//! ユーザーとプログラム間のインターフェース。
//!
//! ## 主要な関数
//! - std.fs.File.stdout(): 標準出力
//! - std.fs.File.stderr(): 標準エラー出力
//! - std.fs.File.stdin(): 標準入力
//! - std.debug.print(): デバッグ出力

const std = @import("std");

// ====================
// 標準入出力の概念
// ====================

fn demoConcept() void {
    std.debug.print("--- 標準入出力の概念 ---\n", .{});

    std.debug.print("  3つの標準チャネル:\n", .{});
    std.debug.print("    stdin  : 標準入力 (キーボードなど)\n", .{});
    std.debug.print("    stdout : 標準出力 (画面など)\n", .{});
    std.debug.print("    stderr : 標準エラー (エラーメッセージ)\n", .{});

    std.debug.print("\n  OSの仲介:\n", .{});
    std.debug.print("    プログラム ←→ OS ←→ ユーザー\n", .{});
    std.debug.print("    ファイルディスクリプタとして扱える\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// stdout - 標準出力
// ====================

fn demoStdout() !void {
    std.debug.print("--- stdout (標準出力) ---\n", .{});

    // stdout の File オブジェクトを取得
    const stdout_file = std.fs.File.stdout();

    // 直接書き込み
    _ = try stdout_file.write("  直接書き込み: Hello!\n");

    // writeAll で確実に全部書き込み
    try stdout_file.writeAll("  writeAll: World!\n");

    // フォーマット書き込み用のバッファ
    var buffer: [128]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    try fbs.writer().print("  フォーマット: value={d}, name={s}\n", .{ 42, "Zig" });
    try stdout_file.writeAll(fbs.getWritten());

    std.debug.print("  std.debug.print でも出力可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// stderr - 標準エラー出力
// ====================

fn demoStderr() !void {
    std.debug.print("--- stderr (標準エラー出力) ---\n", .{});

    const stderr_file = std.fs.File.stderr();

    // エラーメッセージを書き込み
    try stderr_file.writeAll("  [ERROR] これはエラーメッセージです\n");
    try stderr_file.writeAll("  [WARN] これは警告メッセージです\n");

    std.debug.print("\n  stdout と stderr の違い:\n", .{});
    std.debug.print("    stdout : 通常の出力\n", .{});
    std.debug.print("    stderr : エラー・警告の出力\n", .{});
    std.debug.print("    リダイレクト時に分離可能:\n", .{});
    std.debug.print("      ./program > out.txt 2> err.txt\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// std.debug.print
// ====================

fn demoDebugPrint() void {
    std.debug.print("--- std.debug.print ---\n", .{});

    // 最も簡単な出力方法
    std.debug.print("  文字列: {s}\n", .{"Hello"});
    std.debug.print("  整数: {d}\n", .{42});
    std.debug.print("  16進: 0x{X}\n", .{255});
    std.debug.print("  浮動小数: {d:.2}\n", .{3.14159});
    std.debug.print("  真偽値: {}\n", .{true});

    // 複数の値
    std.debug.print("  複数: {s} is {d} years old\n", .{ "Alice", 25 });

    std.debug.print("\n  std.debug.print の特徴:\n", .{});
    std.debug.print("    stderr に出力\n", .{});
    std.debug.print("    エラー時は静かに失敗\n", .{});
    std.debug.print("    デバッグ用途向け\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// フォーマット指定子
// ====================

fn demoFormatSpecifiers() void {
    std.debug.print("--- フォーマット指定子 ---\n", .{});

    std.debug.print("  基本:\n", .{});
    std.debug.print("    {{s}} 文字列  : {s}\n", .{"text"});
    std.debug.print("    {{d}} 10進数  : {d}\n", .{42});
    std.debug.print("    {{x}} 16進小  : {x}\n", .{255});
    std.debug.print("    {{X}} 16進大  : {X}\n", .{255});
    std.debug.print("    {{b}} 2進数   : {b}\n", .{10});
    std.debug.print("    {{o}} 8進数   : {o}\n", .{64});
    std.debug.print("    {{c}} 文字    : {c}\n", .{@as(u8, 'A')});

    std.debug.print("\n  幅指定:\n", .{});
    std.debug.print("    幅5右詰: [{d:5}]\n", .{42});
    std.debug.print("    幅5左詰: [{d:<5}]\n", .{42});
    std.debug.print("    0埋め:   [{d:0>5}]\n", .{42});

    std.debug.print("\n  浮動小数:\n", .{});
    std.debug.print("    小数点2桁: {d:.2}\n", .{3.14159});
    std.debug.print("    小数点5桁: {d:.5}\n", .{3.14159});

    std.debug.print("\n", .{});
}

// ====================
// 出力先の選択
// ====================

fn demoOutputSelection() void {
    std.debug.print("--- 出力先の選択 ---\n", .{});

    std.debug.print("  std.debug.print:\n", .{});
    std.debug.print("    用途: デバッグ\n", .{});
    std.debug.print("    出力先: stderr\n", .{});
    std.debug.print("    エラー処理: なし\n", .{});

    std.debug.print("\n  File.stdout()/stderr():\n", .{});
    std.debug.print("    用途: プロダクション\n", .{});
    std.debug.print("    出力先: 指定可能\n", .{});
    std.debug.print("    エラー処理: 必須\n", .{});

    std.debug.print("\n  推奨:\n", .{});
    std.debug.print("    開発中: std.debug.print\n", .{});
    std.debug.print("    本番出力: File.stdout()\n", .{});
    std.debug.print("    エラー出力: File.stderr()\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// stdin - 標準入力（デモのみ）
// ====================

fn demoStdinConcept() void {
    std.debug.print("--- stdin (標準入力) の概念 ---\n", .{});

    std.debug.print("  基本的なパターン:\n", .{});
    std.debug.print("    const stdin = std.fs.File.stdin();\n", .{});
    std.debug.print("    var buf: [256]u8 = undefined;\n", .{});
    std.debug.print("    const len = try stdin.read(&buf);\n", .{});
    std.debug.print("    const input = buf[0..len];\n", .{});

    std.debug.print("\n  注意点:\n", .{});
    std.debug.print("    改行文字も含まれる\n", .{});
    std.debug.print("    std.mem.trimRight で除去可能\n", .{});
    std.debug.print("    ブロッキング操作\n", .{});

    std.debug.print("\n  例（コメントアウト）:\n", .{});
    std.debug.print("    // const stdin = std.fs.File.stdin();\n", .{});
    std.debug.print("    // var buf: [256]u8 = undefined;\n", .{});
    std.debug.print("    // const n = try stdin.read(&buf);\n", .{});
    std.debug.print("    // const line = std.mem.trimRight(u8, buf[0..n], \"\\n\");\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パイプとリダイレクト
// ====================

fn demoPipeAndRedirect() void {
    std.debug.print("--- パイプとリダイレクト ---\n", .{});

    std.debug.print("  リダイレクト:\n", .{});
    std.debug.print("    ./program > out.txt      # stdout → ファイル\n", .{});
    std.debug.print("    ./program 2> err.txt     # stderr → ファイル\n", .{});
    std.debug.print("    ./program < input.txt    # ファイル → stdin\n", .{});
    std.debug.print("    ./program &> all.txt     # 両方 → ファイル\n", .{});

    std.debug.print("\n  パイプ:\n", .{});
    std.debug.print("    cat file.txt | ./program    # パイプ入力\n", .{});
    std.debug.print("    ./program | less           # パイプ出力\n", .{});
    std.debug.print("    ./program 2>&1 | less      # 両方をパイプ\n", .{});

    std.debug.print("\n  Zigプログラムでの活用:\n", .{});
    std.debug.print("    stdin/stdout経由でUNIXツールと連携\n", .{});
    std.debug.print("    フィルタプログラムの作成\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  標準チャネル取得:\n", .{});
    std.debug.print("    std.fs.File.stdout()  # 標準出力\n", .{});
    std.debug.print("    std.fs.File.stderr()  # 標準エラー\n", .{});
    std.debug.print("    std.fs.File.stdin()   # 標準入力\n", .{});

    std.debug.print("\n  出力方法:\n", .{});
    std.debug.print("    file.write()      # 書き込み\n", .{});
    std.debug.print("    file.writeAll()   # 全部書き込み\n", .{});
    std.debug.print("    std.debug.print() # デバッグ用\n", .{});

    std.debug.print("\n  用途:\n", .{});
    std.debug.print("    stdout: 通常の出力結果\n", .{});
    std.debug.print("    stderr: エラー・デバッグ情報\n", .{});
    std.debug.print("    stdin: ユーザー入力\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== 標準入出力 ===\n\n", .{});

    demoConcept();
    try demoStdout();
    try demoStderr();
    demoDebugPrint();
    demoFormatSpecifiers();
    demoOutputSelection();
    demoStdinConcept();
    demoPipeAndRedirect();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・stdout/stderr は File として操作可能\n", .{});
    std.debug.print("・std.debug.print はデバッグに便利\n", .{});
    std.debug.print("・リダイレクトでファイルに出力可能\n", .{});
}

// --- テスト ---

test "stdout write" {
    const stdout = std.fs.File.stdout();
    // stdout への書き込みはテスト環境でも動作する
    try stdout.writeAll("");
}

test "stderr write" {
    const stderr = std.fs.File.stderr();
    try stderr.writeAll("");
}

test "format to buffer" {
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    try fbs.writer().print("Value: {d}", .{42});
    try std.testing.expectEqualStrings("Value: 42", fbs.getWritten());
}

test "format with width" {
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    try fbs.writer().print("[{d:5}]", .{42});
    try std.testing.expectEqualStrings("[   42]", fbs.getWritten());

    fbs.reset();
    try fbs.writer().print("[{d:0>5}]", .{42});
    try std.testing.expectEqualStrings("[00042]", fbs.getWritten());

    fbs.reset();
    try fbs.writer().print("[{d:<5}]", .{42});
    try std.testing.expectEqualStrings("[42   ]", fbs.getWritten());
}

test "format hex" {
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    try fbs.writer().print("0x{X}", .{255});
    try std.testing.expectEqualStrings("0xFF", fbs.getWritten());
}

test "format float" {
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    try fbs.writer().print("{d:.2}", .{3.14159});
    try std.testing.expectEqualStrings("3.14", fbs.getWritten());
}
