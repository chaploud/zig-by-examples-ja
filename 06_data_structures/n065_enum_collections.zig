//! # EnumSet / EnumMap / EnumArray
//!
//! 列挙型をキーとした特殊コレクション。
//! ビットフィールドと配列を使い、高速でメモリ効率が良い。
//!
//! ## 種類
//! - EnumSet: 列挙型の集合（どの値が存在するか）
//! - EnumMap: 列挙型→値のマップ（一部のキーのみ）
//! - EnumArray: 列挙型→値の配列（全キー必須）
//!
//! ## 特徴
//! - 動的メモリ割り当てなし
//! - コピー可能（値型）
//! - O(1)アクセス

const std = @import("std");

// ====================
// EnumSet（列挙型の集合）
// ====================

fn demoEnumSet() void {
    std.debug.print("--- EnumSet ---\n", .{});

    const Permission = enum { read, write, execute, admin };
    const PermissionSet = std.EnumSet(Permission);

    // initEmpty: 空の集合
    var perms = PermissionSet.initEmpty();

    // insert: 要素を追加
    perms.insert(.read);
    perms.insert(.write);

    std.debug.print("  要素数: {d}\n", .{perms.count()});

    // contains: 存在確認
    std.debug.print("  read: {}\n", .{perms.contains(.read)});
    std.debug.print("  admin: {}\n", .{perms.contains(.admin)});

    // remove: 削除
    perms.remove(.write);
    std.debug.print("  remove(write)後: {d}個\n", .{perms.count()});

    std.debug.print("\n", .{});
}

// ====================
// EnumSet 初期化バリエーション
// ====================

fn demoEnumSetInit() void {
    std.debug.print("--- EnumSet 初期化 ---\n", .{});

    const Color = enum { red, green, blue, yellow };
    const ColorSet = std.EnumSet(Color);

    // init: 構造体形式で初期化
    const warm_colors = ColorSet.init(.{
        .red = true,
        .yellow = true,
        .green = false,
        .blue = false,
    });
    std.debug.print("  warm_colors: {d}個\n", .{warm_colors.count()});

    // initFull: 全要素を含む
    const all_colors = ColorSet.initFull();
    std.debug.print("  initFull: {d}個\n", .{all_colors.count()});

    // initMany: スライスから初期化
    const some_colors = ColorSet.initMany(&[_]Color{ .red, .blue });
    std.debug.print("  initMany: {d}個\n", .{some_colors.count()});

    // initOne: 1要素のみ
    const one_color = ColorSet.initOne(.green);
    std.debug.print("  initOne: {d}個\n", .{one_color.count()});

    std.debug.print("\n", .{});
}

// ====================
// EnumSet 集合演算
// ====================

fn demoEnumSetOperations() void {
    std.debug.print("--- EnumSet 集合演算 ---\n", .{});

    const Day = enum { mon, tue, wed, thu, fri, sat, sun };
    const DaySet = std.EnumSet(Day);

    var weekdays = DaySet.init(.{
        .mon = true,
        .tue = true,
        .wed = true,
        .thu = true,
        .fri = true,
        .sat = false,
        .sun = false,
    });

    const weekend = DaySet.init(.{
        .mon = false,
        .tue = false,
        .wed = false,
        .thu = false,
        .fri = false,
        .sat = true,
        .sun = true,
    });

    std.debug.print("  weekdays: {d}個\n", .{weekdays.count()});
    std.debug.print("  weekend: {d}個\n", .{weekend.count()});

    // unionWith: 和集合
    const all_days = weekdays.unionWith(weekend);
    std.debug.print("  union: {d}個\n", .{all_days.count()});

    // intersectWith: 積集合
    const common = weekdays.intersectWith(weekend);
    std.debug.print("  intersection: {d}個\n", .{common.count()});

    // complement: 補集合
    const not_weekdays = weekdays.complement();
    std.debug.print("  complement(weekdays): {d}個\n", .{not_weekdays.count()});

    // toggle: 反転
    weekdays.toggle(.sat);
    std.debug.print("  toggle(sat): sat={}\n", .{weekdays.contains(.sat)});

    std.debug.print("\n", .{});
}

// ====================
// EnumSet イテレーション
// ====================

fn demoEnumSetIteration() void {
    std.debug.print("--- EnumSet イテレーション ---\n", .{});

    const Status = enum { pending, running, completed, failed };
    const StatusSet = std.EnumSet(Status);

    const active = StatusSet.initMany(&[_]Status{ .pending, .running });

    std.debug.print("  アクティブなステータス: ", .{});
    var it = active.iterator();
    while (it.next()) |status| {
        std.debug.print("{s} ", .{@tagName(status)});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// EnumMap（列挙型マップ）
// ====================

fn demoEnumMap() void {
    std.debug.print("--- EnumMap ---\n", .{});

    const Priority = enum { low, medium, high, critical };
    const PriorityMap = std.EnumMap(Priority, u32);

    // init: 一部のキーのみ設定
    var counts = PriorityMap.init(.{
        .low = 5,
        .medium = 3,
        .high = null, // なし
        .critical = 1,
    });

    std.debug.print("  要素数: {d}\n", .{counts.count()});

    // get: 値を取得（ない場合はnull）
    if (counts.get(.low)) |v| {
        std.debug.print("  low: {d}\n", .{v});
    }
    if (counts.get(.high)) |v| {
        std.debug.print("  high: {d}\n", .{v});
    } else {
        std.debug.print("  high: なし\n", .{});
    }

    // put: 追加/更新
    counts.put(.high, 2);
    std.debug.print("  put(high, 2)後: {d}個\n", .{counts.count()});

    // remove: 削除
    counts.remove(.low);
    std.debug.print("  remove(low)後: {d}個\n", .{counts.count()});

    std.debug.print("\n", .{});
}

// ====================
// EnumMap イテレーション
// ====================

fn demoEnumMapIteration() void {
    std.debug.print("--- EnumMap イテレーション ---\n", .{});

    const Level = enum { debug, info, warn, err };
    const LevelMap = std.EnumMap(Level, []const u8);

    var descriptions = LevelMap.init(.{
        .debug = "デバッグ情報",
        .info = "通常情報",
        .warn = null,
        .err = "エラー",
    });

    std.debug.print("  設定済みレベル:\n", .{});
    var it = descriptions.iterator();
    while (it.next()) |entry| {
        std.debug.print("    {s}: {s}\n", .{ @tagName(entry.key), entry.value.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// EnumArray（全キー配列）
// ====================

fn demoEnumArray() void {
    std.debug.print("--- EnumArray ---\n", .{});

    const Direction = enum { north, east, south, west };
    const DirectionArray = std.EnumArray(Direction, i32);

    // init: 全キーに値を設定（必須）
    const dx = DirectionArray.init(.{
        .north = 0,
        .east = 1,
        .south = 0,
        .west = -1,
    });

    const dy = DirectionArray.init(.{
        .north = -1,
        .east = 0,
        .south = 1,
        .west = 0,
    });

    std.debug.print("  北に移動: dx={d}, dy={d}\n", .{ dx.get(.north), dy.get(.north) });
    std.debug.print("  東に移動: dx={d}, dy={d}\n", .{ dx.get(.east), dy.get(.east) });

    // initFill: 同じ値で初期化
    const zeros = DirectionArray.initFill(0);
    std.debug.print("  initFill(0): north={d}\n", .{zeros.get(.north)});

    std.debug.print("\n", .{});
}

// ====================
// EnumArray 更新
// ====================

fn demoEnumArrayUpdate() void {
    std.debug.print("--- EnumArray 更新 ---\n", .{});

    const Size = enum { small, medium, large };
    const SizeArray = std.EnumArray(Size, u32);

    var prices = SizeArray.init(.{
        .small = 100,
        .medium = 200,
        .large = 300,
    });

    std.debug.print("  初期: small={d}\n", .{prices.get(.small)});

    // getPtr: ポインタで更新
    const ptr = prices.getPtr(.small);
    ptr.* = 150;

    std.debug.print("  更新後: small={d}\n", .{prices.get(.small)});

    // set: 直接設定
    prices.set(.large, 350);
    std.debug.print("  set後: large={d}\n", .{prices.get(.large)});

    std.debug.print("\n", .{});
}

// ====================
// 実践: 状態管理
// ====================

fn demoStateManagement() void {
    std.debug.print("--- 実践: 状態管理 ---\n", .{});

    const Feature = enum { dark_mode, notifications, auto_save, analytics };
    const FeatureSet = std.EnumSet(Feature);

    // ユーザー設定
    var user_features = FeatureSet.initEmpty();
    user_features.insert(.dark_mode);
    user_features.insert(.auto_save);

    // デフォルト設定
    const default_features = FeatureSet.init(.{
        .dark_mode = false,
        .notifications = true,
        .auto_save = true,
        .analytics = false,
    });

    std.debug.print("  ユーザー設定: {d}個\n", .{user_features.count()});
    std.debug.print("  デフォルト: {d}個\n", .{default_features.count()});

    // 差分を確認
    const user_only = user_features.differenceWith(default_features);
    std.debug.print("  ユーザーのみ有効: ", .{});
    var it = user_only.iterator();
    while (it.next()) |f| {
        std.debug.print("{s} ", .{@tagName(f)});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  EnumSet:\n", .{});
    std.debug.print("    - 列挙型の集合\n", .{});
    std.debug.print("    - insert/remove/contains\n", .{});
    std.debug.print("    - 集合演算（union/intersect）\n", .{});

    std.debug.print("  EnumMap:\n", .{});
    std.debug.print("    - 一部のキーのみ持つマップ\n", .{});
    std.debug.print("    - get/put/remove\n", .{});
    std.debug.print("    - 値はOptional\n", .{});

    std.debug.print("  EnumArray:\n", .{});
    std.debug.print("    - 全キー必須の配列\n", .{});
    std.debug.print("    - get/set/getPtr\n", .{});
    std.debug.print("    - 値は非Optional\n", .{});

    std.debug.print("  共通:\n", .{});
    std.debug.print("    - 動的メモリなし\n", .{});
    std.debug.print("    - O(1)アクセス\n", .{});
    std.debug.print("    - コピー可能\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== EnumSet / EnumMap / EnumArray ===\n\n", .{});

    demoEnumSet();
    demoEnumSetInit();
    demoEnumSetOperations();
    demoEnumSetIteration();
    demoEnumMap();
    demoEnumMapIteration();
    demoEnumArray();
    demoEnumArrayUpdate();
    demoStateManagement();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・列挙型専用の高効率コレクション\n", .{});
    std.debug.print("・ビットフィールドベースで省メモリ\n", .{});
    std.debug.print("・設定管理や状態管理に最適\n", .{});
    std.debug.print("・コンパイル時に型安全を保証\n", .{});
}

// --- テスト ---

test "enumset insert and contains" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    var set = ColorSet.initEmpty();

    try std.testing.expect(!set.contains(.red));

    set.insert(.red);
    try std.testing.expect(set.contains(.red));
    try std.testing.expect(!set.contains(.green));
}

test "enumset count" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    var set = ColorSet.initEmpty();
    try std.testing.expectEqual(@as(usize, 0), set.count());

    set.insert(.red);
    set.insert(.blue);
    try std.testing.expectEqual(@as(usize, 2), set.count());
}

test "enumset remove" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    var set = ColorSet.initMany(&[_]Color{ .red, .green });
    try std.testing.expect(set.contains(.red));

    set.remove(.red);
    try std.testing.expect(!set.contains(.red));
}

test "enumset initFull" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    const set = ColorSet.initFull();
    try std.testing.expectEqual(@as(usize, 3), set.count());
    try std.testing.expect(set.contains(.red));
    try std.testing.expect(set.contains(.green));
    try std.testing.expect(set.contains(.blue));
}

test "enumset union" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    const setA = ColorSet.initMany(&[_]Color{.red});
    const setB = ColorSet.initMany(&[_]Color{.blue});

    const union_set = setA.unionWith(setB);
    try std.testing.expectEqual(@as(usize, 2), union_set.count());
    try std.testing.expect(union_set.contains(.red));
    try std.testing.expect(union_set.contains(.blue));
}

test "enumset intersection" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    const setA = ColorSet.initMany(&[_]Color{ .red, .green });
    const setB = ColorSet.initMany(&[_]Color{ .green, .blue });

    const intersect = setA.intersectWith(setB);
    try std.testing.expectEqual(@as(usize, 1), intersect.count());
    try std.testing.expect(intersect.contains(.green));
}

test "enumset iterator" {
    const Color = enum { red, green, blue };
    const ColorSet = std.EnumSet(Color);

    const set = ColorSet.initMany(&[_]Color{ .red, .blue });

    var count: usize = 0;
    var it = set.iterator();
    while (it.next()) |_| {
        count += 1;
    }

    try std.testing.expectEqual(@as(usize, 2), count);
}

test "enummap put and get" {
    const Color = enum { red, green, blue };
    const ColorMap = std.EnumMap(Color, u32);

    var map = ColorMap.init(.{
        .red = 10,
        .green = null,
        .blue = 30,
    });

    try std.testing.expectEqual(@as(?u32, 10), map.get(.red));
    try std.testing.expectEqual(@as(?u32, null), map.get(.green));
    try std.testing.expectEqual(@as(?u32, 30), map.get(.blue));

    map.put(.green, 20);
    try std.testing.expectEqual(@as(?u32, 20), map.get(.green));
}

test "enummap count" {
    const Color = enum { red, green, blue };
    const ColorMap = std.EnumMap(Color, u32);

    var map = ColorMap.init(.{
        .red = 1,
        .green = null,
        .blue = 3,
    });

    try std.testing.expectEqual(@as(usize, 2), map.count());

    map.put(.green, 2);
    try std.testing.expectEqual(@as(usize, 3), map.count());
}

test "enummap remove" {
    const Color = enum { red, green, blue };
    const ColorMap = std.EnumMap(Color, u32);

    var map = ColorMap.init(.{
        .red = 1,
        .green = 2,
        .blue = null,
    });

    map.remove(.red);
    try std.testing.expectEqual(@as(?u32, null), map.get(.red));
    try std.testing.expectEqual(@as(usize, 1), map.count());
}

test "enumarray get and set" {
    const Color = enum { red, green, blue };
    const ColorArray = std.EnumArray(Color, u32);

    var arr = ColorArray.init(.{
        .red = 100,
        .green = 200,
        .blue = 300,
    });

    try std.testing.expectEqual(@as(u32, 100), arr.get(.red));
    try std.testing.expectEqual(@as(u32, 200), arr.get(.green));

    arr.set(.red, 150);
    try std.testing.expectEqual(@as(u32, 150), arr.get(.red));
}

test "enumarray initFill" {
    const Color = enum { red, green, blue };
    const ColorArray = std.EnumArray(Color, u32);

    const arr = ColorArray.initFill(42);

    try std.testing.expectEqual(@as(u32, 42), arr.get(.red));
    try std.testing.expectEqual(@as(u32, 42), arr.get(.green));
    try std.testing.expectEqual(@as(u32, 42), arr.get(.blue));
}

test "enumarray getPtr" {
    const Color = enum { red, green, blue };
    const ColorArray = std.EnumArray(Color, u32);

    var arr = ColorArray.initFill(0);

    const ptr = arr.getPtr(.red);
    ptr.* = 999;

    try std.testing.expectEqual(@as(u32, 999), arr.get(.red));
}
