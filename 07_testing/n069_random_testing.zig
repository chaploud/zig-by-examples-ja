//! # ランダムテスト
//!
//! 乱数を使ったテストで、予期しないエッジケースを発見。
//! std.testing.random_seedで再現性を確保。
//!
//! ## 主要テクニック
//! - 決定論的シード: テスト結果の再現性
//! - プロパティベーステスト: 不変条件の検証
//! - ストレステスト: 大量データでの検証

const std = @import("std");

// ====================
// std.testing.random_seed
// ====================

// テスト用のシード値（起動時に設定される）
// これにより同じシードで同じテスト結果を再現可能

test "random seed: deterministic randomness" {
    // std.testing.random_seedはテスト実行時に初期化される
    const seed = std.testing.random_seed;

    // シードから乱数生成器を作成
    var rng = std.Random.DefaultPrng.init(seed);
    const random = rng.random();

    // 同じシードなら同じ値が生成される
    const value1 = random.int(u32);
    _ = value1;

    // テストでは乱数値の「範囲」や「性質」を検証
    try std.testing.expect(true);
}

// ====================
// 被テスト関数
// ====================

fn sortArray(arr: []i32) void {
    std.mem.sort(i32, arr, {}, std.sort.asc(i32));
}

fn binarySearch(arr: []const i32, target: i32) ?usize {
    var left: usize = 0;
    var right: usize = arr.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return null;
}

fn reverseArray(arr: []i32) void {
    if (arr.len == 0) return;
    var i: usize = 0;
    var j: usize = arr.len - 1;
    while (i < j) {
        const tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
        i += 1;
        j -= 1;
    }
}

// ====================
// ソートの性質テスト
// ====================

test "random: sort produces sorted output" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    // ランダムな配列を生成
    var arr: [100]i32 = undefined;
    for (&arr) |*v| {
        v.* = random.intRangeAtMost(i32, -1000, 1000);
    }

    // ソート実行
    sortArray(&arr);

    // 性質1: 結果は昇順になっている
    for (arr[0 .. arr.len - 1], arr[1..]) |a, b| {
        try std.testing.expect(a <= b);
    }
}

test "random: sort preserves length" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    var arr: [50]i32 = undefined;
    for (&arr) |*v| {
        v.* = random.int(i32);
    }

    const len_before = arr.len;
    sortArray(&arr);

    // 性質2: 長さは変わらない
    try std.testing.expectEqual(len_before, arr.len);
}

test "random: sort preserves elements" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    var arr: [20]i32 = undefined;
    for (&arr) |*v| {
        v.* = random.intRangeAtMost(i32, 0, 100);
    }

    // ソート前の合計
    var sum_before: i64 = 0;
    for (arr) |v| {
        sum_before += v;
    }

    sortArray(&arr);

    // ソート後の合計（要素が保存されていれば同じはず）
    var sum_after: i64 = 0;
    for (arr) |v| {
        sum_after += v;
    }

    try std.testing.expectEqual(sum_before, sum_after);
}

// ====================
// 二分探索のテスト
// ====================

test "random: binary search finds existing elements" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    // ソート済み配列を作成
    var arr: [50]i32 = undefined;
    arr[0] = random.intRangeAtMost(i32, -100, -50);
    for (1..50) |i| {
        arr[i] = arr[i - 1] + random.intRangeAtMost(i32, 1, 10);
    }

    // 配列内の要素は必ず見つかる
    for (arr, 0..) |v, i| {
        const result = binarySearch(&arr, v);
        try std.testing.expect(result != null);
        try std.testing.expectEqual(v, arr[result.?]);
        _ = i;
    }
}

test "random: binary search returns null for missing" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    // 偶数のみの配列を作成
    var arr: [20]i32 = undefined;
    for (0..20) |i| {
        arr[i] = @as(i32, @intCast(i * 2));
    }

    // 奇数は見つからない
    for (0..10) |_| {
        const odd = random.intRangeAtMost(i32, 0, 20) * 2 + 1;
        const result = binarySearch(&arr, odd);
        try std.testing.expect(result == null);
    }
}

// ====================
// reverseの性質テスト
// ====================

test "random: reverse twice is identity" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    var original: [30]i32 = undefined;
    for (&original) |*v| {
        v.* = random.int(i32);
    }

    // オリジナルをコピー
    var arr = original;

    // 2回reverseすると元に戻る
    reverseArray(&arr);
    reverseArray(&arr);

    try std.testing.expectEqualSlices(i32, &original, &arr);
}

test "random: reverse preserves elements" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    var arr: [25]i32 = undefined;
    for (&arr) |*v| {
        v.* = random.intRangeAtMost(i32, 0, 1000);
    }

    var sum_before: i64 = 0;
    for (arr) |v| {
        sum_before += v;
    }

    reverseArray(&arr);

    var sum_after: i64 = 0;
    for (arr) |v| {
        sum_after += v;
    }

    try std.testing.expectEqual(sum_before, sum_after);
}

// ====================
// 複数回テスト（ストレス）
// ====================

test "stress: multiple random iterations" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    // 100回のランダムテスト
    for (0..100) |_| {
        const size = random.intRangeAtMost(usize, 1, 50);
        var arr: [50]i32 = undefined;
        const slice = arr[0..size];

        // ランダムデータ生成
        for (slice) |*v| {
            v.* = random.int(i32);
        }

        // ソートして検証
        sortArray(slice);

        // ソート結果の検証
        if (slice.len > 1) {
            for (slice[0 .. slice.len - 1], slice[1..]) |a, b| {
                try std.testing.expect(a <= b);
            }
        }
    }
}

// ====================
// 境界値のランダムテスト
// ====================

test "random: edge values handling" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    // 極端な値を含む配列
    var arr: [10]i32 = undefined;
    arr[0] = std.math.minInt(i32);
    arr[1] = std.math.maxInt(i32);
    arr[2] = 0;
    arr[3] = -1;
    arr[4] = 1;

    for (5..10) |i| {
        arr[i] = random.int(i32);
    }

    // 極端な値を含んでもソートは正常動作
    sortArray(&arr);

    for (arr[0..9], arr[1..]) |a, b| {
        try std.testing.expect(a <= b);
    }
}

// ====================
// カスタム乱数生成
// ====================

fn generateRandomString(allocator: std.mem.Allocator, random: std.Random, max_len: usize) ![]u8 {
    const len = random.intRangeAtMost(usize, 0, max_len);
    const buffer = try allocator.alloc(u8, len);

    for (buffer) |*c| {
        c.* = random.intRangeAtMost(u8, 'a', 'z');
    }

    return buffer;
}

test "random: string generation" {
    const allocator = std.testing.allocator;
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = rng.random();

    for (0..10) |_| {
        const s = try generateRandomString(allocator, random, 20);
        defer allocator.free(s);

        // 生成された文字列は全て小文字アルファベット
        for (s) |c| {
            try std.testing.expect(c >= 'a' and c <= 'z');
        }
    }
}

// ====================
// まとめ
// ====================

// ランダムテストのポイント:
// 1. std.testing.random_seedで再現性確保
// 2. 具体的な値ではなく「性質」をテスト
// 3. 複数回実行でカバレッジ向上
// 4. 境界値も含める
// 5. 失敗時はシード値で再現

pub fn main() void {
    std.debug.print("=== ランダムテスト ===\n\n", .{});
    std.debug.print("テスト実行: zig test 07_testing/n069_random_testing.zig\n\n", .{});

    std.debug.print("--- ランダムテストの利点 ---\n", .{});
    std.debug.print("  広いカバレッジ - 手動では考えつかないケース\n", .{});
    std.debug.print("  再現性       - シード値で結果再現\n", .{});
    std.debug.print("  性質ベース   - 具体値より不変条件\n", .{});

    std.debug.print("\n--- 使い方 ---\n", .{});
    std.debug.print("  const seed = std.testing.random_seed;\n", .{});
    std.debug.print("  var rng = std.Random.DefaultPrng.init(seed);\n", .{});
    std.debug.print("  const random = rng.random();\n", .{});
}
