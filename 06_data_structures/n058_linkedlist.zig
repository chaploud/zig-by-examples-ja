//! # LinkedList（連結リスト）
//!
//! 連結リストはノードがポインタで連結されたデータ構造。
//! 挿入・削除がO(1)で高速だが、ランダムアクセスは不可。
//!
//! ## 種類
//! - SinglyLinkedList: 単方向連結リスト（nextのみ）
//! - DoublyLinkedList: 双方向連結リスト（prev/next）
//!
//! ## 特徴
//! - メモリは連続しない
//! - 先頭・途中への挿入削除がO(1)
//! - インデックスアクセス不可（走査が必要）

const std = @import("std");

// ====================
// 基本: SinglyLinkedList（単方向）
// ====================

fn demoSinglyLinkedList() void {
    std.debug.print("--- SinglyLinkedList（単方向） ---\n", .{});

    // ノード型を定義（データ + Nodeを含む構造体）
    const NodeU32 = struct {
        data: u32,
        node: std.SinglyLinkedList.Node = .{},
    };

    // 空の連結リストを作成
    var list: std.SinglyLinkedList = .{};

    // ノードを作成（スタック上）
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };
    var three: NodeU32 = .{ .data = 3 };

    // prepend: 先頭に追加
    list.prepend(&two.node); // {2}
    list.prepend(&one.node); // {1, 2}

    // insertAfter: 指定ノードの後に挿入
    two.node.insertAfter(&three.node); // {1, 2, 3}

    std.debug.print("  ノード数: {d}\n", .{list.len()});

    // イテレーション
    std.debug.print("  内容: ", .{});
    var it = list.first;
    while (it) |node| : (it = node.next) {
        // @fieldParentPtr: Nodeから親構造体を取得
        const parent: *NodeU32 = @fieldParentPtr("node", node);
        std.debug.print("{d} ", .{parent.data});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// DoublyLinkedList（双方向）
// ====================

fn demoDoublyLinkedList() void {
    std.debug.print("--- DoublyLinkedList（双方向） ---\n", .{});

    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};

    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };
    var three: NodeU32 = .{ .data = 3 };

    // append: 末尾に追加
    list.append(&one.node); // {1}
    list.append(&two.node); // {1, 2}
    list.append(&three.node); // {1, 2, 3}

    std.debug.print("  ノード数: {d}\n", .{list.len()});

    // 前方イテレーション
    std.debug.print("  前方: ", .{});
    var it = list.first;
    while (it) |node| : (it = node.next) {
        const parent: *NodeU32 = @fieldParentPtr("node", node);
        std.debug.print("{d} ", .{parent.data});
    }
    std.debug.print("\n", .{});

    // 後方イテレーション（双方向の利点）
    std.debug.print("  後方: ", .{});
    var rit = list.last;
    while (rit) |node| : (rit = node.prev) {
        const parent: *NodeU32 = @fieldParentPtr("node", node);
        std.debug.print("{d} ", .{parent.data});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ノードの挿入位置
// ====================

fn demoInsertion() void {
    std.debug.print("--- ノードの挿入位置 ---\n", .{});

    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};

    var a: NodeU32 = .{ .data = 10 };
    var b: NodeU32 = .{ .data = 20 };
    var c: NodeU32 = .{ .data = 30 };
    var d: NodeU32 = .{ .data = 15 };
    var e: NodeU32 = .{ .data = 5 };

    list.append(&a.node); // {10}
    list.append(&b.node); // {10, 20}
    list.append(&c.node); // {10, 20, 30}

    // insertAfter: 指定ノードの後に挿入
    list.insertAfter(&a.node, &d.node); // {10, 15, 20, 30}

    // prepend: 先頭に挿入
    list.prepend(&e.node); // {5, 10, 15, 20, 30}

    std.debug.print("  結果: ", .{});
    var it = list.first;
    while (it) |node| : (it = node.next) {
        const parent: *NodeU32 = @fieldParentPtr("node", node);
        std.debug.print("{d} ", .{parent.data});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// ノードの削除
// ====================

fn demoRemoval() void {
    std.debug.print("--- ノードの削除 ---\n", .{});

    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};

    var a: NodeU32 = .{ .data = 1 };
    var b: NodeU32 = .{ .data = 2 };
    var c: NodeU32 = .{ .data = 3 };
    var d: NodeU32 = .{ .data = 4 };

    list.append(&a.node);
    list.append(&b.node);
    list.append(&c.node);
    list.append(&d.node);

    std.debug.print("  初期: ", .{});
    printDoublyList(&list, NodeU32);

    // remove: 特定ノードを削除
    list.remove(&b.node);
    std.debug.print("  remove(2): ", .{});
    printDoublyList(&list, NodeU32);

    // popFirst: 先頭を削除
    _ = list.popFirst();
    std.debug.print("  popFirst: ", .{});
    printDoublyList(&list, NodeU32);

    // pop: 末尾を削除
    _ = list.pop();
    std.debug.print("  pop: ", .{});
    printDoublyList(&list, NodeU32);

    std.debug.print("\n", .{});
}

fn printDoublyList(list: *std.DoublyLinkedList, comptime NodeType: type) void {
    var it = list.first;
    while (it) |node| : (it = node.next) {
        const parent: *NodeType = @fieldParentPtr("node", node);
        std.debug.print("{d} ", .{parent.data});
    }
    std.debug.print("\n", .{});
}

// ====================
// @fieldParentPtrの仕組み
// ====================

fn demoFieldParentPtr() void {
    std.debug.print("--- @fieldParentPtrの仕組み ---\n", .{});

    const Person = struct {
        name: []const u8,
        age: u8,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};

    var alice: Person = .{ .name = "Alice", .age = 25 };
    var bob: Person = .{ .name = "Bob", .age = 30 };

    list.append(&alice.node);
    list.append(&bob.node);

    // @fieldParentPtr: 子フィールドから親構造体を逆引き
    // LinkedList.NodeからPersonを取得できる
    var it = list.first;
    while (it) |node| : (it = node.next) {
        const person: *Person = @fieldParentPtr("node", node);
        std.debug.print("  {s}: {d}歳\n", .{ person.name, person.age });
    }

    std.debug.print("\n", .{});
}

// ====================
// 文字列データの連結リスト
// ====================

fn demoStringList() void {
    std.debug.print("--- 文字列データの連結リスト ---\n", .{});

    const StringNode = struct {
        text: []const u8,
        node: std.SinglyLinkedList.Node = .{},
    };

    var list: std.SinglyLinkedList = .{};

    var hello: StringNode = .{ .text = "Hello" };
    var world: StringNode = .{ .text = "World" };
    var zig: StringNode = .{ .text = "Zig" };

    list.prepend(&zig.node);
    list.prepend(&world.node);
    list.prepend(&hello.node);

    std.debug.print("  メッセージ: ", .{});
    var it = list.first;
    while (it) |node| : (it = node.next) {
        const parent: *StringNode = @fieldParentPtr("node", node);
        std.debug.print("{s} ", .{parent.text});
    }
    std.debug.print("\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 単方向 vs 双方向
// ====================

fn demoComparison() void {
    std.debug.print("--- 単方向 vs 双方向 ---\n", .{});

    std.debug.print("  SinglyLinkedList（単方向）:\n", .{});
    std.debug.print("    - nextポインタのみ\n", .{});
    std.debug.print("    - メモリ効率が良い\n", .{});
    std.debug.print("    - 前方走査のみ可能\n", .{});
    std.debug.print("    - prepend, insertAfter\n", .{});

    std.debug.print("  DoublyLinkedList（双方向）:\n", .{});
    std.debug.print("    - prev/nextポインタ\n", .{});
    std.debug.print("    - 前後どちらにも走査可能\n", .{});
    std.debug.print("    - 任意位置の削除がO(1)\n", .{});
    std.debug.print("    - append, prepend, insertAfter\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("--- まとめ ---\n", .{});

    std.debug.print("  ノード型の定義:\n", .{});
    std.debug.print("    const Node = struct {{\n", .{});
    std.debug.print("        data: T,\n", .{});
    std.debug.print("        node: std.SinglyLinkedList.Node = .{{}},\n", .{});
    std.debug.print("    }};\n", .{});

    std.debug.print("  リスト作成:\n", .{});
    std.debug.print("    var list: std.SinglyLinkedList = .{{}};\n", .{});

    std.debug.print("  挿入:\n", .{});
    std.debug.print("    list.prepend(&node.node);\n", .{});
    std.debug.print("    node.node.insertAfter(&other.node);\n", .{});

    std.debug.print("  親構造体取得:\n", .{});
    std.debug.print("    @fieldParentPtr(\"node\", linked_node)\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    std.debug.print("=== LinkedList（連結リスト） ===\n\n", .{});

    demoSinglyLinkedList();
    demoDoublyLinkedList();
    demoInsertion();
    demoRemoval();
    demoFieldParentPtr();
    demoStringList();
    demoComparison();
    demoSummary();

    std.debug.print("--- 補足 ---\n", .{});
    std.debug.print("・連結リストはメモリ非連続\n", .{});
    std.debug.print("・挿入削除がO(1)で高速\n", .{});
    std.debug.print("・ランダムアクセスは不可\n", .{});
    std.debug.print("・@fieldParentPtrでデータ取得\n", .{});
}

// --- テスト ---

test "singly linked list prepend" {
    const NodeU32 = struct {
        data: u32,
        node: std.SinglyLinkedList.Node = .{},
    };

    var list: std.SinglyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };

    list.prepend(&two.node);
    list.prepend(&one.node);

    try std.testing.expectEqual(@as(usize, 2), list.len());

    const first: *NodeU32 = @fieldParentPtr("node", list.first.?);
    try std.testing.expectEqual(@as(u32, 1), first.data);
}

test "singly linked list insertAfter" {
    const NodeU32 = struct {
        data: u32,
        node: std.SinglyLinkedList.Node = .{},
    };

    var list: std.SinglyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };
    var three: NodeU32 = .{ .data = 3 };

    list.prepend(&one.node);
    one.node.insertAfter(&three.node);
    one.node.insertAfter(&two.node);

    // Expected: 1 -> 2 -> 3
    try std.testing.expectEqual(@as(usize, 3), list.len());

    var it = list.first;
    const n1: *NodeU32 = @fieldParentPtr("node", it.?);
    try std.testing.expectEqual(@as(u32, 1), n1.data);

    it = it.?.next;
    const n2: *NodeU32 = @fieldParentPtr("node", it.?);
    try std.testing.expectEqual(@as(u32, 2), n2.data);

    it = it.?.next;
    const n3: *NodeU32 = @fieldParentPtr("node", it.?);
    try std.testing.expectEqual(@as(u32, 3), n3.data);
}

test "doubly linked list append" {
    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };

    list.append(&one.node);
    list.append(&two.node);

    try std.testing.expectEqual(@as(usize, 2), list.len());

    const first: *NodeU32 = @fieldParentPtr("node", list.first.?);
    const last: *NodeU32 = @fieldParentPtr("node", list.last.?);

    try std.testing.expectEqual(@as(u32, 1), first.data);
    try std.testing.expectEqual(@as(u32, 2), last.data);
}

test "doubly linked list remove" {
    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };
    var three: NodeU32 = .{ .data = 3 };

    list.append(&one.node);
    list.append(&two.node);
    list.append(&three.node);

    list.remove(&two.node);

    try std.testing.expectEqual(@as(usize, 2), list.len());

    // Verify 1 -> 3
    const first: *NodeU32 = @fieldParentPtr("node", list.first.?);
    const last: *NodeU32 = @fieldParentPtr("node", list.last.?);

    try std.testing.expectEqual(@as(u32, 1), first.data);
    try std.testing.expectEqual(@as(u32, 3), last.data);
}

test "doubly linked list popFirst" {
    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };

    list.append(&one.node);
    list.append(&two.node);

    const popped = list.popFirst();
    try std.testing.expect(popped != null);

    const popped_data: *NodeU32 = @fieldParentPtr("node", popped.?);
    try std.testing.expectEqual(@as(u32, 1), popped_data.data);
    try std.testing.expectEqual(@as(usize, 1), list.len());
}

test "doubly linked list pop" {
    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };

    list.append(&one.node);
    list.append(&two.node);

    const popped = list.pop();
    try std.testing.expect(popped != null);

    const popped_data: *NodeU32 = @fieldParentPtr("node", popped.?);
    try std.testing.expectEqual(@as(u32, 2), popped_data.data);
    try std.testing.expectEqual(@as(usize, 1), list.len());
}

test "doubly linked list reverse iteration" {
    const NodeU32 = struct {
        data: u32,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var one: NodeU32 = .{ .data = 1 };
    var two: NodeU32 = .{ .data = 2 };
    var three: NodeU32 = .{ .data = 3 };

    list.append(&one.node);
    list.append(&two.node);
    list.append(&three.node);

    // Reverse iteration
    var result: [3]u32 = undefined;
    var i: usize = 0;
    var it = list.last;
    while (it) |node| : (it = node.prev) {
        const parent: *NodeU32 = @fieldParentPtr("node", node);
        result[i] = parent.data;
        i += 1;
    }

    try std.testing.expectEqual(@as(u32, 3), result[0]);
    try std.testing.expectEqual(@as(u32, 2), result[1]);
    try std.testing.expectEqual(@as(u32, 1), result[2]);
}

test "empty list" {
    var list: std.SinglyLinkedList = .{};

    try std.testing.expectEqual(@as(usize, 0), list.len());
    try std.testing.expect(list.first == null);
}

test "fieldParentPtr with custom data" {
    const Person = struct {
        name: []const u8,
        age: u8,
        node: std.DoublyLinkedList.Node = .{},
    };

    var list: std.DoublyLinkedList = .{};
    var alice: Person = .{ .name = "Alice", .age = 25 };

    list.append(&alice.node);

    const retrieved: *Person = @fieldParentPtr("node", list.first.?);
    try std.testing.expectEqualStrings("Alice", retrieved.name);
    try std.testing.expectEqual(@as(u8, 25), retrieved.age);
}
