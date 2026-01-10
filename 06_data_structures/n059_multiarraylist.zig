//! # MultiArrayList
//!
//! MultiArrayListは構造体の各フィールドを別々の配列で管理する。
//! Struct of Arrays (SoA) パターンを実現する。
//!
//! ## 利点
//! - キャッシュ効率が良い（特定フィールドのみアクセス時）
//! - SIMDに適した連続メモリレイアウト
//! - 大量データの特定フィールド処理が高速
//!
//! ## 通常のArrayListとの違い
//! - ArrayList(Person): [Person, Person, Person, ...]
//! - MultiArrayList(Person): names[], ages[], heights[] （分離）

const std = @import("std");

// ====================
// 基本的な使い方
// ====================

fn demoBasicUsage() !void {
    std.debug.print("--- 基本的な使い方 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 構造体を定義
    const Person = struct {
        name: []const u8,
        age: u8,
        height: f32,
    };

    // MultiArrayListを作成
    var people: std.MultiArrayList(Person) = .{};
    defer people.deinit(allocator);

    // append: 構造体を追加
    try people.append(allocator, .{ .name = "Alice", .age = 25, .height = 1.65 });
    try people.append(allocator, .{ .name = "Bob", .age = 30, .height = 1.78 });
    try people.append(allocator, .{ .name = "Charlie", .age = 35, .height = 1.72 });

    std.debug.print("  要素数: {d}\n", .{people.len});

    // items: 特定フィールドの配列を取得
    std.debug.print("  年齢一覧: ", .{});
    for (people.items(.age)) |age| {
        std.debug.print("{d} ", .{age});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// sliceでの高効率アクセス
// ====================

fn demoSliceAccess() !void {
    std.debug.print("--- sliceでの高効率アクセス ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Point = struct {
        x: f32,
        y: f32,
        z: f32,
    };

    var points: std.MultiArrayList(Point) = .{};
    defer points.deinit(allocator);

    try points.append(allocator, .{ .x = 1.0, .y = 2.0, .z = 3.0 });
    try points.append(allocator, .{ .x = 4.0, .y = 5.0, .z = 6.0 });
    try points.append(allocator, .{ .x = 7.0, .y = 8.0, .z = 9.0 });

    // slice: 複数フィールドへの効率的なアクセス
    const slice = points.slice();
    const xs = slice.items(.x);
    const ys = slice.items(.y);
    const zs = slice.items(.z);

    std.debug.print("  各座標:\n", .{});
    for (xs, ys, zs, 0..) |x, y, z, i| {
        std.debug.print("    点{d}: ({d:.1}, {d:.1}, {d:.1})\n", .{ i, x, y, z });
    }

    std.debug.print("\n", .{});
}

// ====================
// フィールドの変更
// ====================

fn demoModification() !void {
    std.debug.print("--- フィールドの変更 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Score = struct {
        name: []const u8,
        points: u32,
    };

    var scores: std.MultiArrayList(Score) = .{};
    defer scores.deinit(allocator);

    try scores.append(allocator, .{ .name = "Player1", .points = 100 });
    try scores.append(allocator, .{ .name = "Player2", .points = 200 });
    try scores.append(allocator, .{ .name = "Player3", .points = 150 });

    std.debug.print("  変更前: ", .{});
    for (scores.items(.points)) |p| {
        std.debug.print("{d} ", .{p});
    }
    std.debug.print("\n", .{});

    // items経由でポインタを取得して変更
    const slice = scores.slice();
    for (slice.items(.points)) |*p| {
        p.* += 50; // 全員にボーナス
    }

    std.debug.print("  変更後: ", .{});
    for (scores.items(.points)) |p| {
        std.debug.print("{d} ", .{p});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// get/setでの個別アクセス
// ====================

fn demoGetSet() !void {
    std.debug.print("--- get/setでの個別アクセス ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Item = struct {
        id: u32,
        value: i32,
    };

    var items: std.MultiArrayList(Item) = .{};
    defer items.deinit(allocator);

    try items.append(allocator, .{ .id = 1, .value = 10 });
    try items.append(allocator, .{ .id = 2, .value = 20 });
    try items.append(allocator, .{ .id = 3, .value = 30 });

    // get: 指定インデックスの構造体を取得
    const second = items.get(1);
    std.debug.print("  items[1]: id={d}, value={d}\n", .{ second.id, second.value });

    // set: 指定インデックスの構造体を設定
    items.set(1, .{ .id = 2, .value = 200 });

    const updated = items.get(1);
    std.debug.print("  更新後: id={d}, value={d}\n", .{ updated.id, updated.value });

    std.debug.print("\n", .{});
}

// ====================
// Array of Structs vs Struct of Arrays
// ====================

fn demoAoSvsSoA() void {
    std.debug.print("--- Array of Structs vs Struct of Arrays ---\n", .{});

    std.debug.print("  Array of Structs (AoS):\n", .{});
    std.debug.print("    メモリ: [name,age,h][name,age,h][name,age,h]\n", .{});
    std.debug.print("    利点: 1つの要素全体へのアクセスが高速\n", .{});
    std.debug.print("    用途: 要素単位の処理が多い場合\n", .{});

    std.debug.print("  Struct of Arrays (SoA):\n", .{});
    std.debug.print("    メモリ: [name,name,name][age,age,age][h,h,h]\n", .{});
    std.debug.print("    利点: 特定フィールドのみのアクセスが高速\n", .{});
    std.debug.print("    用途: 特定フィールドの一括処理が多い場合\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// キャッシュ効率の例
// ====================

fn demoCacheEfficiency() !void {
    std.debug.print("--- キャッシュ効率の例 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Entity = struct {
        x: f32,
        y: f32,
        velocity_x: f32,
        velocity_y: f32,
        name: []const u8,
        id: u64,
    };

    var entities: std.MultiArrayList(Entity) = .{};
    defer entities.deinit(allocator);

    // 大量のエンティティを追加（例として3つ）
    try entities.append(allocator, .{
        .x = 0, .y = 0, .velocity_x = 1, .velocity_y = 1,
        .name = "A", .id = 1,
    });
    try entities.append(allocator, .{
        .x = 10, .y = 10, .velocity_x = -1, .velocity_y = 0,
        .name = "B", .id = 2,
    });
    try entities.append(allocator, .{
        .x = 5, .y = 5, .velocity_x = 0, .velocity_y = 2,
        .name = "C", .id = 3,
    });

    // 位置の更新（x, y, velocity_x, velocity_y のみ使用）
    // → name, id は読み込まれない（キャッシュ効率↑）
    const slice = entities.slice();
    const xs = slice.items(.x);
    const ys = slice.items(.y);
    const vxs = slice.items(.velocity_x);
    const vys = slice.items(.velocity_y);

    std.debug.print("  位置更新:\n", .{});
    for (xs, ys, vxs, vys, 0..) |*x, *y, vx, vy, i| {
        std.debug.print("    Entity{d}: ({d:.1},{d:.1})", .{ i, x.*, y.* });
        x.* += vx;
        y.* += vy;
        std.debug.print(" -> ({d:.1},{d:.1})\n", .{ x.*, y.* });
    }

    std.debug.print("\n", .{});
}

// ====================
// 複数要素の追加
// ====================

fn demoMultipleAppend() !void {
    std.debug.print("--- 複数要素の追加 ---\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Vec2 = struct {
        x: i32,
        y: i32,
    };

    var vectors: std.MultiArrayList(Vec2) = .{};
    defer vectors.deinit(allocator);

    // 配列から複数要素を追加
    const initial = [_]Vec2{
        .{ .x = 1, .y = 2 },
        .{ .x = 3, .y = 4 },
        .{ .x = 5, .y = 6 },
    };
    for (initial) |item| {
        try vectors.append(allocator, item);
    }

    std.debug.print("  追加後: {d}個\n", .{vectors.len});
    for (vectors.items(.x), vectors.items(.y), 0..) |x, y, i| {
        std.debug.print("    [{d}]: ({d}, {d})\n", .{ i, x, y });
    }

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  作成:\n", .{});
    std.debug.print("    var list: std.MultiArrayList(T) = .{{}};\n", .{});

    std.debug.print("  追加:\n", .{});
    std.debug.print("    append(allocator, value)\n", .{});

    std.debug.print("  アクセス:\n", .{});
    std.debug.print("    items(.field)   - フィールドの配列\n", .{});
    std.debug.print("    slice()         - 効率的なアクセス\n", .{});
    std.debug.print("    get(index)      - 構造体を取得\n", .{});
    std.debug.print("    set(index, val) - 構造体を設定\n", .{});

    std.debug.print("  用途:\n", .{});
    std.debug.print("    - 大量データの特定フィールド処理\n", .{});
    std.debug.print("    - SIMD最適化が必要な場合\n", .{});
    std.debug.print("    - ゲームのECSなど\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() !void {
    std.debug.print("=== MultiArrayList ===\n\n", .{});

    try demoBasicUsage();
    try demoSliceAccess();
    try demoModification();
    try demoGetSet();
    demoAoSvsSoA();
    try demoCacheEfficiency();
    try demoMultipleAppend();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・MultiArrayListはSoAパターン\n", .{});
    std.debug.print("・特定フィールドの一括処理が高速\n", .{});
    std.debug.print("・items(.field)でフィールド配列取得\n", .{});
    std.debug.print("・大量データ処理に最適\n", .{});
}

// --- テスト ---

test "multiarraylist basic append" {
    const allocator = std.testing.allocator;

    const Item = struct {
        id: u32,
        value: i32,
    };

    var list: std.MultiArrayList(Item) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .id = 1, .value = 100 });
    try list.append(allocator, .{ .id = 2, .value = 200 });

    try std.testing.expectEqual(@as(usize, 2), list.len);
}

test "multiarraylist items" {
    const allocator = std.testing.allocator;

    const Item = struct {
        id: u32,
        value: i32,
    };

    var list: std.MultiArrayList(Item) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .id = 1, .value = 100 });
    try list.append(allocator, .{ .id = 2, .value = 200 });

    const ids = list.items(.id);
    const values = list.items(.value);

    try std.testing.expectEqual(@as(u32, 1), ids[0]);
    try std.testing.expectEqual(@as(u32, 2), ids[1]);
    try std.testing.expectEqual(@as(i32, 100), values[0]);
    try std.testing.expectEqual(@as(i32, 200), values[1]);
}

test "multiarraylist slice" {
    const allocator = std.testing.allocator;

    const Point = struct {
        x: f32,
        y: f32,
    };

    var list: std.MultiArrayList(Point) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .x = 1.0, .y = 2.0 });
    try list.append(allocator, .{ .x = 3.0, .y = 4.0 });

    const slice = list.slice();
    const xs = slice.items(.x);
    const ys = slice.items(.y);

    try std.testing.expectEqual(@as(f32, 1.0), xs[0]);
    try std.testing.expectEqual(@as(f32, 3.0), xs[1]);
    try std.testing.expectEqual(@as(f32, 2.0), ys[0]);
    try std.testing.expectEqual(@as(f32, 4.0), ys[1]);
}

test "multiarraylist modification" {
    const allocator = std.testing.allocator;

    const Counter = struct {
        count: u32,
    };

    var list: std.MultiArrayList(Counter) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .count = 10 });
    try list.append(allocator, .{ .count = 20 });

    // Modify via slice
    const slice = list.slice();
    for (slice.items(.count)) |*c| {
        c.* += 5;
    }

    try std.testing.expectEqual(@as(u32, 15), list.items(.count)[0]);
    try std.testing.expectEqual(@as(u32, 25), list.items(.count)[1]);
}

test "multiarraylist get and set" {
    const allocator = std.testing.allocator;

    const Data = struct {
        a: u8,
        b: u16,
    };

    var list: std.MultiArrayList(Data) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .a = 1, .b = 100 });
    try list.append(allocator, .{ .a = 2, .b = 200 });

    // get
    const first = list.get(0);
    try std.testing.expectEqual(@as(u8, 1), first.a);
    try std.testing.expectEqual(@as(u16, 100), first.b);

    // set
    list.set(0, .{ .a = 10, .b = 1000 });

    const updated = list.get(0);
    try std.testing.expectEqual(@as(u8, 10), updated.a);
    try std.testing.expectEqual(@as(u16, 1000), updated.b);
}

test "multiarraylist multiple append" {
    const allocator = std.testing.allocator;

    const Vec = struct {
        x: i32,
        y: i32,
    };

    var list: std.MultiArrayList(Vec) = .{};
    defer list.deinit(allocator);

    const data = [_]Vec{
        .{ .x = 1, .y = 2 },
        .{ .x = 3, .y = 4 },
        .{ .x = 5, .y = 6 },
    };

    for (data) |item| {
        try list.append(allocator, item);
    }

    try std.testing.expectEqual(@as(usize, 3), list.len);
    try std.testing.expectEqual(@as(i32, 1), list.items(.x)[0]);
    try std.testing.expectEqual(@as(i32, 5), list.items(.x)[2]);
}

test "multiarraylist empty" {
    const allocator = std.testing.allocator;

    const Item = struct {
        value: u32,
    };

    var list: std.MultiArrayList(Item) = .{};
    defer list.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 0), list.len);
}

test "multiarraylist multiple field types" {
    const allocator = std.testing.allocator;

    const Complex = struct {
        name: []const u8,
        score: f64,
        active: bool,
        count: usize,
    };

    var list: std.MultiArrayList(Complex) = .{};
    defer list.deinit(allocator);

    try list.append(allocator, .{
        .name = "test",
        .score = 3.14,
        .active = true,
        .count = 42,
    });

    try std.testing.expectEqualStrings("test", list.items(.name)[0]);
    try std.testing.expectEqual(@as(f64, 3.14), list.items(.score)[0]);
    try std.testing.expect(list.items(.active)[0]);
    try std.testing.expectEqual(@as(usize, 42), list.items(.count)[0]);
}
