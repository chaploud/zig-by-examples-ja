//! # opaque型とC連携
//!
//! Cライブラリのハンドル型をZigで安全に扱う方法。
//!
//! ## このファイルで学ぶこと
//! - opaque 型の定義と使い方
//! - Cのハンドル型との対応
//! - anyopaque の使い方
//! - 型安全なラッパーの作成
//!
//! ## opaque とは
//! 内部構造が不明な型。Cの前方宣言された構造体に対応。

const std = @import("std");

// ====================
// opaque 型の基本
// ====================

// Cでよくあるパターン:
// typedef struct File FILE;  // 内部構造は非公開
// FILE* fopen(const char*, const char*);

// Zigでの表現
const OpaqueFile = opaque {};

fn demoOpaqueBasics() void {
    std.debug.print("=== opaque 型の基本 ===\n\n", .{});

    std.debug.print("【Cでのパターン】\n", .{});
    std.debug.print("  typedef struct Handle Handle;  // 前方宣言\n", .{});
    std.debug.print("  Handle* create_handle(void);   // ポインタで返す\n", .{});
    std.debug.print("  void use_handle(Handle* h);    // ポインタで受け取る\n", .{});
    std.debug.print("  void destroy_handle(Handle* h);\n", .{});

    std.debug.print("\n【Zigでの表現】\n", .{});
    std.debug.print("  const Handle = opaque {{}};\n", .{});
    std.debug.print("  extern fn create_handle() ?*Handle;\n", .{});
    std.debug.print("  extern fn use_handle(h: *Handle) void;\n", .{});
    std.debug.print("  extern fn destroy_handle(h: *Handle) void;\n", .{});

    std.debug.print("\n【特徴】\n", .{});
    std.debug.print("  - 値を直接作成できない\n", .{});
    std.debug.print("  - ポインタでのみ扱う\n", .{});
    std.debug.print("  - 型安全性を維持\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// anyopaque (void*)
// ====================

fn demoAnyOpaque() void {
    std.debug.print("=== anyopaque (void*) ===\n\n", .{});

    std.debug.print("【Cのvoid*】\n", .{});
    std.debug.print("  void* ptr;  // 任意の型へのポインタ\n", .{});

    std.debug.print("\n【Zigでの対応】\n", .{});
    std.debug.print("  *anyopaque      → void* (非NULL)\n", .{});
    std.debug.print("  ?*anyopaque     → void* (NULL許容)\n", .{});
    std.debug.print("  *const anyopaque → const void*\n", .{});

    std.debug.print("\n【キャスト例】\n", .{});
    var x: i32 = 42;
    const ptr: *anyopaque = &x;
    const back: *i32 = @ptrCast(@alignCast(ptr));
    std.debug.print("  i32 → *anyopaque → *i32\n", .{});
    std.debug.print("  値: {d}\n", .{back.*});

    std.debug.print("\n【注意】\n", .{});
    std.debug.print("  anyopaqueへのキャストは安全ではない\n", .{});
    std.debug.print("  @ptrCast + @alignCast が必要\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 実践: ハンドルラッパー
// ====================

// 内部で使用するリソース（実際にはCライブラリのもの）
const ResourceData = struct {
    id: u32,
    name: []const u8,
    ref_count: u32,
};

// opaque型として外部に公開
pub const Resource = opaque {
    // opaque内にメソッドを定義可能
    pub fn getId(self: *const @This()) u32 {
        const data = @as(*const ResourceData, @ptrCast(@alignCast(self)));
        return data.id;
    }

    pub fn getName(self: *const @This()) []const u8 {
        const data = @as(*const ResourceData, @ptrCast(@alignCast(self)));
        return data.name;
    }

    pub fn incrementRef(self: *@This()) void {
        const data = @as(*ResourceData, @ptrCast(@alignCast(self)));
        data.ref_count += 1;
    }
};

// グローバルストレージ（実際にはCライブラリが管理）
var resource_storage: [10]ResourceData = undefined;
var next_resource: usize = 0;

// 外部向けAPI
pub fn createResource(id: u32, name: []const u8) ?*Resource {
    if (next_resource >= resource_storage.len) return null;

    resource_storage[next_resource] = .{
        .id = id,
        .name = name,
        .ref_count = 1,
    };
    const ptr = &resource_storage[next_resource];
    next_resource += 1;

    return @ptrCast(ptr);
}

fn demoHandleWrapper() void {
    std.debug.print("=== ハンドルラッパー ===\n\n", .{});

    std.debug.print("【opaque型のメソッド】\n", .{});
    std.debug.print("  pub const Handle = opaque {{\n", .{});
    std.debug.print("      pub fn method(self: *@This()) void {{ ... }}\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【使用例】\n", .{});

    if (createResource(100, "MyResource")) |res| {
        std.debug.print("  ID: {d}\n", .{res.getId()});
        std.debug.print("  Name: {s}\n", .{res.getName()});

        res.incrementRef();
        std.debug.print("  RefCount incremented\n", .{});
    } else {
        std.debug.print("  Resource creation failed\n", .{});
    }

    std.debug.print("\n", .{});
}

// ====================
// Cライブラリとの対応例
// ====================

fn demoCLibraryExamples() void {
    std.debug.print("=== Cライブラリとの対応 ===\n\n", .{});

    std.debug.print("【FILE* (stdio.h)】\n", .{});
    std.debug.print("  C:   FILE* fp = fopen(\"file.txt\", \"r\");\n", .{});
    std.debug.print("  Zig: const c = @cImport(@cInclude(\"stdio.h\"));\n", .{});
    std.debug.print("       const fp = c.fopen(\"file.txt\", \"r\");\n", .{});
    std.debug.print("       // fpの型は ?*c.FILE\n", .{});

    std.debug.print("\n【pthread_t】\n", .{});
    std.debug.print("  C:   pthread_t thread;\n", .{});
    std.debug.print("  Zig: const pthread = opaque {{}};\n", .{});
    std.debug.print("       var thread: pthread = ...;\n", .{});

    std.debug.print("\n【SQLite3】\n", .{});
    std.debug.print("  C:   sqlite3* db;\n", .{});
    std.debug.print("       sqlite3_open(\"test.db\", &db);\n", .{});
    std.debug.print("  Zig: const c = @cImport(@cInclude(\"sqlite3.h\"));\n", .{});
    std.debug.print("       var db: ?*c.sqlite3 = null;\n", .{});
    std.debug.print("       _ = c.sqlite3_open(\"test.db\", &db);\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// コールバックとユーザーデータ
// ====================

// Cライブラリでよくあるパターン
// void register_callback(void (*callback)(void* user_data), void* user_data);

const CallbackFn = *const fn (user_data: ?*anyopaque) void;

var registered_callback: ?CallbackFn = null;
var registered_user_data: ?*anyopaque = null;

fn registerCallback(callback: CallbackFn, user_data: ?*anyopaque) void {
    registered_callback = callback;
    registered_user_data = user_data;
}

fn triggerCallback() void {
    if (registered_callback) |cb| {
        cb(registered_user_data);
    }
}

const MyData = struct {
    value: i32,
    name: []const u8,
};

fn myCallback(user_data: ?*anyopaque) void {
    if (user_data) |ptr| {
        const data: *MyData = @ptrCast(@alignCast(ptr));
        std.debug.print("  Callback: value={d}, name={s}\n", .{ data.value, data.name });
    }
}

fn demoCallbackUserData() void {
    std.debug.print("=== コールバックとユーザーデータ ===\n\n", .{});

    std.debug.print("【Cのパターン】\n", .{});
    std.debug.print("  void set_callback(void (*fn)(void*), void* data);\n", .{});

    std.debug.print("\n【Zigでの実装】\n", .{});
    std.debug.print("  const CallbackFn = *const fn(?*anyopaque) void;\n", .{});
    std.debug.print("  fn set_callback(cb: CallbackFn, data: ?*anyopaque) void\n", .{});

    std.debug.print("\n【使用例】\n", .{});
    var data = MyData{ .value = 42, .name = "Test" };
    registerCallback(myCallback, &data);
    triggerCallback();

    std.debug.print("\n【注意点】\n", .{});
    std.debug.print("  user_dataの生存期間を管理すること\n", .{});
    std.debug.print("  コールバック内でのキャストは慎重に\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 型安全なラッパー
// ====================

fn demoTypeSafeWrapper() void {
    std.debug.print("=== 型安全なラッパー ===\n\n", .{});

    std.debug.print("【問題】\n", .{});
    std.debug.print("  Cのvoid*は型安全ではない\n", .{});
    std.debug.print("  間違った型にキャストしてもコンパイル通る\n", .{});

    std.debug.print("\n【解決策: Zig wrapper】\n", .{});
    std.debug.print("  pub const Handle = struct {{\n", .{});
    std.debug.print("      raw: *anyopaque,\n", .{});
    std.debug.print("      \n", .{});
    std.debug.print("      pub fn init(ptr: *anyopaque) Handle {{\n", .{});
    std.debug.print("          return .{{ .raw = ptr }};\n", .{});
    std.debug.print("      }}\n", .{});
    std.debug.print("      \n", .{});
    std.debug.print("      pub fn getData(self: Handle, T: type) *T {{\n", .{});
    std.debug.print("          return @ptrCast(@alignCast(self.raw));\n", .{});
    std.debug.print("      }}\n", .{});
    std.debug.print("  }};\n", .{});

    std.debug.print("\n【利点】\n", .{});
    std.debug.print("  - 型パラメータで安全にキャスト\n", .{});
    std.debug.print("  - メソッドでカプセル化\n", .{});
    std.debug.print("  - Zig側で追加の安全性チェック可能\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== opaque型 まとめ ===\n\n", .{});

    std.debug.print("【opaque の用途】\n", .{});
    std.debug.print("  - Cライブラリのハンドル型\n", .{});
    std.debug.print("  - 内部構造を隠蔽したい型\n", .{});
    std.debug.print("  - 前方宣言された構造体\n", .{});

    std.debug.print("\n【定義方法】\n", .{});
    std.debug.print("  const Handle = opaque {{}};\n", .{});
    std.debug.print("  const Handle = opaque {{ pub fn method() void {{}} }};\n", .{});

    std.debug.print("\n【ポインタ型】\n", .{});
    std.debug.print("  *Handle       非NULLポインタ\n", .{});
    std.debug.print("  ?*Handle      NULL許容ポインタ\n", .{});
    std.debug.print("  *anyopaque    void*相当\n", .{});

    std.debug.print("\n【キャスト】\n", .{});
    std.debug.print("  @ptrCast + @alignCast で変換\n", .{});
    std.debug.print("  型安全性は自己責任\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoOpaqueBasics();
    demoAnyOpaque();
    demoHandleWrapper();
    demoCLibraryExamples();
    demoCallbackUserData();
    demoTypeSafeWrapper();
    demoSummary();

    std.debug.print("=== 次のステップ ===\n", .{});
    std.debug.print("・C連携実践パターン\n", .{});
    std.debug.print("・C連携総まとめ\n", .{});
}

// ====================
// テスト
// ====================

test "anyopaque cast" {
    var x: i32 = 42;
    const ptr: *anyopaque = &x;
    const back: *i32 = @ptrCast(@alignCast(ptr));
    try std.testing.expectEqual(@as(i32, 42), back.*);
}

test "opaque resource" {
    if (createResource(1, "Test")) |res| {
        try std.testing.expectEqual(@as(u32, 1), res.getId());
        try std.testing.expectEqualStrings("Test", res.getName());
    } else {
        return error.TestFailed;
    }
}

test "callback with user data" {
    var called = false;
    const TestData = struct {
        flag: *bool,
    };
    var data = TestData{ .flag = &called };

    const testCallback = struct {
        fn callback(user_data: ?*anyopaque) void {
            if (user_data) |ptr| {
                const d: *TestData = @ptrCast(@alignCast(ptr));
                d.flag.* = true;
            }
        }
    }.callback;

    registerCallback(testCallback, &data);
    triggerCallback();

    try std.testing.expect(called);
}
