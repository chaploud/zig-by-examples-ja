//! # エラーペイロード（追加情報付きエラー）
//!
//! Zigのerror型には追加情報を持たせられないが、
//! 代替パターンで詳細なエラー情報を伝達できる。
//!
//! ## パターン
//! - 構造体を使用した結果型
//! - グローバル/スレッドローカル変数
//! - @errorReturnTrace
//!
//! ## 注意
//! - Zigのerrorには直接データを添付できない
//! - 設計パターンで代替

const std = @import("std");

// ====================
// 問題：errorにはデータを持たせられない
// ====================

fn demoProblem() void {
    std.debug.print("--- 問題：errorにはデータを持たせられない ---\n", .{});

    std.debug.print("  Zigのerror型:\n", .{});
    std.debug.print("    - 単なるタグ（列挙値）\n", .{});
    std.debug.print("    - 追加データなし\n", .{});
    std.debug.print("    - error.FileNotFound だけでは不十分\n", .{});

    std.debug.print("  欲しい情報:\n", .{});
    std.debug.print("    - どのファイル？\n", .{});
    std.debug.print("    - 何行目でエラー？\n", .{});
    std.debug.print("    - エラーコードは？\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パターン1：Result構造体
// ====================

const ParseError = error{
    InvalidSyntax,
    UnexpectedToken,
    EndOfInput,
};

const ParseResult = struct {
    success: bool,
    value: ?i32,
    err: ?ParseError,
    line: usize,
    column: usize,
    message: []const u8,
};

fn parseWithDetails(input: []const u8) ParseResult {
    if (input.len == 0) {
        return .{
            .success = false,
            .value = null,
            .err = error.EndOfInput,
            .line = 1,
            .column = 1,
            .message = "入力が空です",
        };
    }

    // パース成功
    return .{
        .success = true,
        .value = 42,
        .err = null,
        .line = 0,
        .column = 0,
        .message = "",
    };
}

fn demoResultStruct() void {
    std.debug.print("--- パターン1：Result構造体 ---\n", .{});

    // エラーケース
    const result1 = parseWithDetails("");
    if (!result1.success) {
        std.debug.print("  エラー: {s}\n", .{result1.message});
        std.debug.print("  位置: {d}:{d}\n", .{ result1.line, result1.column });
    }

    // 成功ケース
    const result2 = parseWithDetails("valid input");
    if (result2.success) {
        std.debug.print("  成功: value={d}\n", .{result2.value.?});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン2：タプル戻り値
// ====================

const ErrorInfo = struct {
    code: u32,
    message: []const u8,
};

fn processWithInfo(input: []const u8) !struct { value: i32, info: ?ErrorInfo } {
    if (input.len < 3) {
        return error.InputTooShort;
    }
    return .{ .value = 100, .info = null };
}

fn demoTupleReturn() void {
    std.debug.print("--- パターン2：タプル戻り値 ---\n", .{});

    if (processWithInfo("ab")) |result| {
        std.debug.print("  成功: value={d}\n", .{result.value});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
    }

    if (processWithInfo("valid")) |result| {
        std.debug.print("  成功: value={d}\n", .{result.value});
    } else |_| {}

    std.debug.print("\n", .{});
}

// ====================
// パターン3：outパラメータ
// ====================

const DetailedError = struct {
    kind: enum { file_not_found, permission_denied, parse_error },
    line: usize,
    column: usize,
    file_path: []const u8,
    message: []const u8,

    pub fn format(self: DetailedError) void {
        std.debug.print("    詳細: {s}\n", .{self.message});
        std.debug.print("    場所: {s}:{d}:{d}\n", .{ self.file_path, self.line, self.column });
    }
};

fn loadFile(path: []const u8, err_out: *?DetailedError) ![]const u8 {
    if (path.len == 0) {
        err_out.* = .{
            .kind = .file_not_found,
            .line = 0,
            .column = 0,
            .file_path = "(none)",
            .message = "パスが空です",
        };
        return error.FileNotFound;
    }

    err_out.* = null;
    return "file contents";
}

fn demoOutParameter() void {
    std.debug.print("--- パターン3：outパラメータ ---\n", .{});

    var err_info: ?DetailedError = null;

    // エラーケース
    if (loadFile("", &err_info)) |_| {} else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
        if (err_info) |info| {
            info.format();
        }
    }

    // 成功ケース
    if (loadFile("test.txt", &err_info)) |contents| {
        std.debug.print("  成功: {s}\n", .{contents});
    } else |_| {}

    std.debug.print("\n", .{});
}

// ====================
// パターン4：エラー構造体を返す
// ====================

const ValidationError = struct {
    field: []const u8,
    expected: []const u8,
    actual: []const u8,
};

const ValidationResult = union(enum) {
    ok: void,
    invalid_field: ValidationError,
    missing_required: []const u8,

    pub fn isOk(self: @This()) bool {
        return self == .ok;
    }
};

fn validate(data: struct { name: []const u8, age: i32 }) ValidationResult {
    if (data.name.len == 0) {
        return .{ .missing_required = "name" };
    }

    if (data.age < 0) {
        return .{ .invalid_field = .{
            .field = "age",
            .expected = "0以上",
            .actual = "負の値",
        } };
    }

    return .ok;
}

fn demoValidationResult() void {
    std.debug.print("--- パターン4：エラー構造体を返す ---\n", .{});

    // 有効なデータ
    const result1 = validate(.{ .name = "Alice", .age = 25 });
    std.debug.print("  valid data: isOk={}\n", .{result1.isOk()});

    // 無効なデータ（名前なし）
    const result2 = validate(.{ .name = "", .age = 25 });
    switch (result2) {
        .ok => {},
        .missing_required => |field| {
            std.debug.print("  必須フィールドなし: {s}\n", .{field});
        },
        .invalid_field => |err| {
            std.debug.print("  無効: {s}\n", .{err.field});
        },
    }

    // 無効なデータ（年齢）
    const result3 = validate(.{ .name = "Bob", .age = -1 });
    switch (result3) {
        .ok => {},
        .missing_required => {},
        .invalid_field => |err| {
            std.debug.print("  無効: {s} (expected: {s})\n", .{ err.field, err.expected });
        },
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン5：スレッドローカルエラー情報
// ====================

threadlocal var last_error_msg: [256]u8 = undefined;
threadlocal var last_error_len: usize = 0;

fn setLastError(msg: []const u8) void {
    const len = @min(msg.len, last_error_msg.len);
    @memcpy(last_error_msg[0..len], msg[0..len]);
    last_error_len = len;
}

fn getLastError() []const u8 {
    return last_error_msg[0..last_error_len];
}

fn operationWithThreadLocal(fail: bool) !void {
    if (fail) {
        setLastError("詳細なエラー情報: タイムアウト発生");
        return error.OperationFailed;
    }
}

fn demoThreadLocal() void {
    std.debug.print("--- パターン5：スレッドローカルエラー情報 ---\n", .{});

    if (operationWithThreadLocal(true)) |_| {} else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
        std.debug.print("  詳細: {s}\n", .{getLastError()});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン6：エラー + コンテキスト
// ====================

const Context = struct {
    errors: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Context {
        return .{
            .errors = .{},
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Context) void {
        self.errors.deinit(self.allocator);
    }

    pub fn addError(self: *Context, msg: []const u8) !void {
        try self.errors.append(self.allocator, msg);
    }

    pub fn hasErrors(self: *const Context) bool {
        return self.errors.items.len > 0;
    }
};

fn processWithContext(ctx: *Context, input: []const u8) !void {
    if (input.len == 0) {
        try ctx.addError("入力が空です");
        return error.ValidationFailed;
    }

    if (input.len < 3) {
        try ctx.addError("入力が短すぎます");
        try ctx.addError("最低3文字必要です");
        return error.ValidationFailed;
    }
}

fn demoContextPattern() !void {
    std.debug.print("--- パターン6：エラー + コンテキスト ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ctx = Context.init(allocator);
    defer ctx.deinit();

    if (processWithContext(&ctx, "ab")) |_| {
        std.debug.print("  成功\n", .{});
    } else |err| {
        std.debug.print("  エラー: {s}\n", .{@errorName(err)});
        for (ctx.errors.items) |msg| {
            std.debug.print("    - {s}\n", .{msg});
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  Zigのエラーには追加データを持たせられない\n", .{});
    std.debug.print("  代替パターン:\n", .{});
    std.debug.print("    1. Result構造体\n", .{});
    std.debug.print("    2. タプル戻り値\n", .{});
    std.debug.print("    3. outパラメータ\n", .{});
    std.debug.print("    4. union型で複数エラー\n", .{});
    std.debug.print("    5. スレッドローカル変数\n", .{});
    std.debug.print("    6. コンテキスト引き渡し\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== エラーペイロード ===\n\n", .{});

    demoProblem();
    demoResultStruct();
    demoTupleReturn();
    demoOutParameter();
    demoValidationResult();
    demoThreadLocal();
    try demoContextPattern();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・errorに直接データは持たせられない\n", .{});
    std.debug.print("・Result構造体が最も一般的\n", .{});
    std.debug.print("・outパラメータも有効\n", .{});
    std.debug.print("・用途に応じてパターンを選択\n", .{});
}

// --- テスト ---

test "result struct success" {
    const result = parseWithDetails("valid");
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(i32, 42), result.value.?);
}

test "result struct failure" {
    const result = parseWithDetails("");
    try std.testing.expect(!result.success);
    try std.testing.expectEqual(error.EndOfInput, result.err.?);
    try std.testing.expectEqual(@as(usize, 1), result.line);
}

test "out parameter error info" {
    var err_info: ?DetailedError = null;

    const result = loadFile("", &err_info);
    try std.testing.expectError(error.FileNotFound, result);
    try std.testing.expect(err_info != null);
    try std.testing.expectEqualStrings("パスが空です", err_info.?.message);
}

test "out parameter success" {
    var err_info: ?DetailedError = null;

    const result = try loadFile("test.txt", &err_info);
    try std.testing.expectEqualStrings("file contents", result);
    try std.testing.expect(err_info == null);
}

test "validation result ok" {
    const result = validate(.{ .name = "Alice", .age = 25 });
    try std.testing.expect(result.isOk());
}

test "validation result missing field" {
    const result = validate(.{ .name = "", .age = 25 });
    switch (result) {
        .missing_required => |field| {
            try std.testing.expectEqualStrings("name", field);
        },
        else => try std.testing.expect(false),
    }
}

test "validation result invalid field" {
    const result = validate(.{ .name = "Bob", .age = -1 });
    switch (result) {
        .invalid_field => |err| {
            try std.testing.expectEqualStrings("age", err.field);
        },
        else => try std.testing.expect(false),
    }
}

test "thread local error" {
    const result = operationWithThreadLocal(true);
    try std.testing.expectError(error.OperationFailed, result);

    const msg = getLastError();
    try std.testing.expect(msg.len > 0);
}
