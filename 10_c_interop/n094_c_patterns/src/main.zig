//! # C連携 実践パターン
//!
//! よく使うC連携のパターンとイディオム集。
//!
//! ## このファイルで学ぶこと
//! - 初期化/終了処理パターン
//! - エラーコード変換
//! - 配列/バッファの受け渡し
//! - コールバックパターン
//! - リソース管理

const std = @import("std");

// ====================
// パターン1: 初期化/終了処理
// ====================

// Cライブラリでよくある init/deinit パターン
// int lib_init(void);
// void lib_deinit(void);

const LibState = struct {
    initialized: bool = false,
    ref_count: u32 = 0,
};

var lib_state = LibState{};

fn libInit() c_int {
    if (lib_state.initialized) {
        lib_state.ref_count += 1;
        return 0;
    }
    lib_state.initialized = true;
    lib_state.ref_count = 1;
    return 0;
}

fn libDeinit() void {
    if (lib_state.ref_count > 0) {
        lib_state.ref_count -= 1;
    }
    if (lib_state.ref_count == 0) {
        lib_state.initialized = false;
    }
}

fn demoInitDeinit() void {
    std.debug.print("=== 初期化/終了パターン ===\n\n", .{});

    std.debug.print("【Cのパターン】\n", .{});
    std.debug.print("  int lib_init(void);   // 0=成功, -1=失敗\n", .{});
    std.debug.print("  void lib_deinit(void);\n", .{});

    std.debug.print("\n【Zigラッパー例】\n", .{});
    std.debug.print("  pub const Library = struct {{\n", .{});
    std.debug.print("      pub fn init() !void {{\n", .{});
    std.debug.print("          if (c.lib_init() != 0) return error.InitFailed;\n", .{});
    std.debug.print("      }}\n", .{});
    std.debug.print("      pub fn deinit() void {{ c.lib_deinit(); }}\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【defer で確実に解放】\n", .{});
    _ = libInit();
    defer libDeinit();
    std.debug.print("  lib_init() 呼び出し (ref_count={d})\n", .{lib_state.ref_count});
    std.debug.print("  -- スコープ終了時に自動で lib_deinit() --\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パターン2: エラーコード変換
// ====================

// Cのエラーコード
const CError = enum(c_int) {
    success = 0,
    invalid_arg = -1,
    out_of_memory = -2,
    io_error = -3,
    not_found = -4,
    permission_denied = -5,
    _,
};

// Zigのエラーに変換
const ZigError = error{
    InvalidArg,
    OutOfMemory,
    IoError,
    NotFound,
    PermissionDenied,
    Unknown,
};

fn convertError(code: c_int) ZigError!void {
    const err: CError = @enumFromInt(code);
    return switch (err) {
        .success => {},
        .invalid_arg => error.InvalidArg,
        .out_of_memory => error.OutOfMemory,
        .io_error => error.IoError,
        .not_found => error.NotFound,
        .permission_denied => error.PermissionDenied,
        _ => error.Unknown,
    };
}

fn demoErrorConversion() void {
    std.debug.print("=== エラーコード変換 ===\n\n", .{});

    std.debug.print("【Cのエラーコード】\n", .{});
    std.debug.print("  #define SUCCESS 0\n", .{});
    std.debug.print("  #define ERR_INVALID -1\n", .{});
    std.debug.print("  int do_something(void);  // 戻り値でエラー\n", .{});

    std.debug.print("\n【Zigのエラーに変換】\n", .{});
    std.debug.print("  fn doSomething() ZigError!void {{\n", .{});
    std.debug.print("      const ret = c.do_something();\n", .{});
    std.debug.print("      try convertError(ret);\n", .{});
    std.debug.print("  }}\n", .{});

    std.debug.print("\n【変換例】\n", .{});
    const test_codes = [_]c_int{ 0, -1, -2, -3, -100 };
    for (test_codes) |code| {
        if (convertError(code)) {
            std.debug.print("  code {d} → success\n", .{code});
        } else |err| {
            std.debug.print("  code {d} → error.{s}\n", .{ code, @errorName(err) });
        }
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン3: 配列/バッファの受け渡し
// ====================

// Cでよくある出力バッファパターン
// size_t get_data(void* buf, size_t buf_size);

fn getData(buf: [*]u8, buf_size: usize) usize {
    const data = "Hello, Zig!";
    const copy_len = @min(data.len, buf_size);
    @memcpy(buf[0..copy_len], data[0..copy_len]);
    return copy_len;
}

// 長さ取得 → バッファ確保 → データ取得
fn getDataLength() usize {
    return "Hello, Zig!".len;
}

fn demoBufferPattern() void {
    std.debug.print("=== バッファパターン ===\n\n", .{});

    std.debug.print("【Cのパターン】\n", .{});
    std.debug.print("  // 長さ取得 (buf=NULL)\n", .{});
    std.debug.print("  size_t len = get_data(NULL, 0);\n", .{});
    std.debug.print("  // バッファ確保して取得\n", .{});
    std.debug.print("  char* buf = malloc(len);\n", .{});
    std.debug.print("  get_data(buf, len);\n", .{});

    std.debug.print("\n【Zigでの実装】\n", .{});
    std.debug.print("  // 固定サイズバッファ\n", .{});
    var buf: [256]u8 = undefined;
    const len = getData(&buf, buf.len);
    std.debug.print("  結果: \"{s}\"\n", .{buf[0..len]});

    std.debug.print("\n【アロケータ使用パターン】\n", .{});
    std.debug.print("  const len = c.get_data_length();\n", .{});
    std.debug.print("  const buf = try allocator.alloc(u8, len);\n", .{});
    std.debug.print("  defer allocator.free(buf);\n", .{});
    std.debug.print("  _ = c.get_data(buf.ptr, buf.len);\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パターン4: コールバック登録
// ====================

const EventCallback = *const fn (event_type: c_int, data: ?*anyopaque) callconv(.c) void;

var registered_callbacks: [8]?EventCallback = [_]?EventCallback{null} ** 8;
var callback_user_data: [8]?*anyopaque = [_]?*anyopaque{null} ** 8;

fn registerEventCallback(event_type: c_int, callback: EventCallback, user_data: ?*anyopaque) c_int {
    if (event_type < 0 or event_type >= 8) return -1;
    const idx: usize = @intCast(event_type);
    registered_callbacks[idx] = callback;
    callback_user_data[idx] = user_data;
    return 0;
}

fn triggerEvent(event_type: c_int) void {
    if (event_type < 0 or event_type >= 8) return;
    const idx: usize = @intCast(event_type);
    if (registered_callbacks[idx]) |cb| {
        cb(event_type, callback_user_data[idx]);
    }
}

fn demoCallbackPattern() void {
    std.debug.print("=== コールバックパターン ===\n\n", .{});

    std.debug.print("【Cのパターン】\n", .{});
    std.debug.print("  typedef void (*callback_fn)(int event, void* data);\n", .{});
    std.debug.print("  int register_callback(int type, callback_fn, void* data);\n", .{});

    std.debug.print("\n【Zigからの登録】\n", .{});

    const Counter = struct { count: i32 };
    var counter = Counter{ .count = 0 };

    const myCallback = struct {
        fn callback(event_type: c_int, data: ?*anyopaque) callconv(.c) void {
            _ = event_type;
            if (data) |ptr| {
                const c: *Counter = @ptrCast(@alignCast(ptr));
                c.count += 1;
            }
        }
    }.callback;

    _ = registerEventCallback(0, myCallback, &counter);
    std.debug.print("  コールバック登録完了\n", .{});

    triggerEvent(0);
    triggerEvent(0);
    triggerEvent(0);
    std.debug.print("  3回イベント発生後: count={d}\n", .{counter.count});

    std.debug.print("\n【ポイント】\n", .{});
    std.debug.print("  - callconv(.c) を指定\n", .{});
    std.debug.print("  - user_dataの生存期間に注意\n", .{});
    std.debug.print("  - コンテキストをuser_dataで渡す\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// パターン5: リソース管理ラッパー
// ====================

// CライブラリのHandleをZigでラップ
const CHandle = opaque {};

// 擬似的なCライブラリ関数
var handle_counter: u32 = 0;
var handle_storage: [10]u32 = undefined;

fn cCreateHandle() ?*CHandle {
    if (handle_counter >= 10) return null;
    handle_storage[handle_counter] = handle_counter;
    const ptr = &handle_storage[handle_counter];
    handle_counter += 1;
    return @ptrCast(ptr);
}

fn cDestroyHandle(h: *CHandle) void {
    _ = h;
    if (handle_counter > 0) handle_counter -= 1;
}

fn cUseHandle(h: *CHandle) c_int {
    const ptr: *u32 = @ptrCast(@alignCast(h));
    return @intCast(ptr.*);
}

// Zigのラッパー
const Handle = struct {
    raw: *CHandle,

    pub fn create() !Handle {
        const raw = cCreateHandle() orelse return error.CreateFailed;
        return Handle{ .raw = raw };
    }

    pub fn destroy(self: Handle) void {
        cDestroyHandle(self.raw);
    }

    pub fn use(self: Handle) i32 {
        return cUseHandle(self.raw);
    }
};

fn demoResourceWrapper() void {
    std.debug.print("=== リソース管理ラッパー ===\n\n", .{});

    std.debug.print("【Cのリソース管理】\n", .{});
    std.debug.print("  Handle* h = create_handle();\n", .{});
    std.debug.print("  use_handle(h);\n", .{});
    std.debug.print("  destroy_handle(h);  // 忘れがち！\n", .{});

    std.debug.print("\n【Zigのラッパー】\n", .{});
    std.debug.print("  const Handle = struct {{\n", .{});
    std.debug.print("      raw: *c.Handle,\n", .{});
    std.debug.print("      pub fn create() !Handle {{ ... }}\n", .{});
    std.debug.print("      pub fn destroy(self: Handle) void {{ ... }}\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【defer で確実に解放】\n", .{});
    if (Handle.create()) |h| {
        defer h.destroy();
        std.debug.print("  Handle created, value={d}\n", .{h.use()});
        std.debug.print("  -- defer で自動解放 --\n", .{});
    } else |_| {
        std.debug.print("  Handle creation failed\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// パターン6: 構造体の初期化
// ====================

const CConfig = extern struct {
    version: u32 = 0,
    flags: u32 = 0,
    timeout_ms: u32 = 0,
    buffer_size: usize = 0,
    callback: ?*const fn () callconv(.c) void = null,
};

fn demoStructInit() void {
    std.debug.print("=== 構造体の初期化 ===\n\n", .{});

    std.debug.print("【Cのパターン】\n", .{});
    std.debug.print("  struct config cfg;\n", .{});
    std.debug.print("  memset(&cfg, 0, sizeof(cfg));  // ゼロ初期化\n", .{});
    std.debug.print("  cfg.version = 1;\n", .{});

    std.debug.print("\n【Zigでの初期化】\n", .{});

    // 方法1: デフォルト値で初期化
    const cfg1 = CConfig{
        .version = 1,
        .timeout_ms = 5000,
    };
    std.debug.print("  デフォルト値: version={d}, flags={d}\n", .{ cfg1.version, cfg1.flags });

    // 方法2: ゼロ初期化
    const cfg2 = std.mem.zeroes(CConfig);
    std.debug.print("  std.mem.zeroes: version={d}, flags={d}\n", .{ cfg2.version, cfg2.flags });

    // 方法3: 部分的に設定
    var cfg3 = std.mem.zeroes(CConfig);
    cfg3.version = 2;
    cfg3.buffer_size = 4096;
    std.debug.print("  部分設定: version={d}, buffer_size={d}\n", .{ cfg3.version, cfg3.buffer_size });

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== C連携パターン まとめ ===\n\n", .{});

    std.debug.print("【初期化/終了】\n", .{});
    std.debug.print("  defer で確実に解放\n", .{});

    std.debug.print("\n【エラー処理】\n", .{});
    std.debug.print("  Cエラーコード → Zigエラー変換\n", .{});

    std.debug.print("\n【バッファ】\n", .{});
    std.debug.print("  固定バッファ or アロケータで確保\n", .{});

    std.debug.print("\n【コールバック】\n", .{});
    std.debug.print("  callconv(.c) + user_dataパターン\n", .{});

    std.debug.print("\n【リソース管理】\n", .{});
    std.debug.print("  structでラップしてdeferで解放\n", .{});

    std.debug.print("\n【構造体初期化】\n", .{});
    std.debug.print("  デフォルト値 or std.mem.zeroes()\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoInitDeinit();
    demoErrorConversion();
    demoBufferPattern();
    demoCallbackPattern();
    demoResourceWrapper();
    demoStructInit();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・C連携総まとめ\n", .{});
}

// ====================
// テスト
// ====================

test "init/deinit" {
    lib_state = .{};
    try std.testing.expectEqual(@as(c_int, 0), libInit());
    try std.testing.expect(lib_state.initialized);
    try std.testing.expectEqual(@as(u32, 1), lib_state.ref_count);

    libDeinit();
    try std.testing.expect(!lib_state.initialized);
}

test "error conversion" {
    try std.testing.expectEqual({}, convertError(0) catch unreachable);
    try std.testing.expectError(ZigError.InvalidArg, convertError(-1));
    try std.testing.expectError(ZigError.OutOfMemory, convertError(-2));
    try std.testing.expectError(ZigError.Unknown, convertError(-100));
}

test "buffer pattern" {
    var buf: [32]u8 = undefined;
    const len = getData(&buf, buf.len);
    try std.testing.expectEqualStrings("Hello, Zig!", buf[0..len]);
}

test "callback pattern" {
    registered_callbacks = [_]?EventCallback{null} ** 8;

    var counter: i32 = 0;
    const Counter = struct { count: *i32 };
    var ctx = Counter{ .count = &counter };

    const cb = struct {
        fn callback(_: c_int, data: ?*anyopaque) callconv(.c) void {
            if (data) |ptr| {
                const c: *Counter = @ptrCast(@alignCast(ptr));
                c.count.* += 1;
            }
        }
    }.callback;

    try std.testing.expectEqual(@as(c_int, 0), registerEventCallback(0, cb, &ctx));
    triggerEvent(0);
    try std.testing.expectEqual(@as(i32, 1), counter);
}

test "handle wrapper" {
    handle_counter = 0;

    const h = try Handle.create();
    defer h.destroy();

    try std.testing.expectEqual(@as(i32, 0), h.use());
}

test "struct zeroes" {
    const cfg = std.mem.zeroes(CConfig);
    try std.testing.expectEqual(@as(u32, 0), cfg.version);
    try std.testing.expectEqual(@as(u32, 0), cfg.flags);
    try std.testing.expectEqual(@as(?*const fn () callconv(.c) void, null), cfg.callback);
}
