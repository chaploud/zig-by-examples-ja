//! # SIMD シャッフル
//!
//! @shuffle と @select による要素の並べ替え・選択。
//!
//! ## 実行方法
//! ```
//! zig run 12_simd/n108_simd_shuffle.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - @shuffle の基本
//! - マスクの指定方法
//! - @select による条件付き選択
//! - 実用的なシャッフルパターン

const std = @import("std");

// ====================
// 1. @shuffle の基本
// ====================

fn demoShuffleBasics() void {
    std.debug.print("=== 1. @shuffle の基本 ===\n\n", .{});

    std.debug.print("【@shuffle とは】\n", .{});
    std.debug.print("  2つのベクトルから要素を選んで新しいベクトルを作成\n", .{});
    std.debug.print("  @shuffle(型, v1, v2, mask) の形式\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    std.debug.print("\n  v1 = {any}\n", .{v1});
    std.debug.print("  v2 = {any}\n", .{v2});

    std.debug.print("\n【マスクの意味】\n", .{});
    std.debug.print("  正のインデックス: v1 から選択\n", .{});
    std.debug.print("  負のインデックス（ビット反転）: v2 から選択\n", .{});
    std.debug.print("    ~@as(i32, 0) = -1 → v2[0]\n", .{});
    std.debug.print("    ~@as(i32, 1) = -2 → v2[1]\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. 基本的なシャッフル
// ====================

fn demoBasicShuffle() void {
    std.debug.print("=== 2. 基本的なシャッフル ===\n\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    // v1とv2から交互に選択
    // mask: 0=v1[0], ~0=v2[0], 2=v1[2], ~2=v2[2]
    const mask1 = @Vector(4, i32){ 0, ~@as(i32, 0), 2, ~@as(i32, 2) };
    const result1 = @shuffle(i32, v1, v2, mask1);

    std.debug.print("【例1: 混合選択】\n", .{});
    std.debug.print("  v1 = {any}\n", .{v1});
    std.debug.print("  v2 = {any}\n", .{v2});
    std.debug.print("  mask = {{ 0, ~0, 2, ~2 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{result1});
    std.debug.print("  (v1[0], v2[0], v1[2], v2[2])\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 3. 単一ベクトルのシャッフル
// ====================

fn demoSingleVectorShuffle() void {
    std.debug.print("=== 3. 単一ベクトルのシャッフル ===\n\n", .{});

    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    std.debug.print("v = {any}\n\n", .{v});

    // 逆順
    const reverse_mask = @Vector(4, i32){ 3, 2, 1, 0 };
    const reversed = @shuffle(i32, v, undefined, reverse_mask);
    std.debug.print("【逆順】\n", .{});
    std.debug.print("  mask = {{ 3, 2, 1, 0 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{reversed});

    // 回転（左ローテート）
    const rotate_mask = @Vector(4, i32){ 1, 2, 3, 0 };
    const rotated = @shuffle(i32, v, undefined, rotate_mask);
    std.debug.print("\n【左ローテート】\n", .{});
    std.debug.print("  mask = {{ 1, 2, 3, 0 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{rotated});

    // ブロードキャスト（最初の要素を全体に）
    const broadcast_mask = @Vector(4, i32){ 0, 0, 0, 0 };
    const broadcast = @shuffle(i32, v, undefined, broadcast_mask);
    std.debug.print("\n【ブロードキャスト】\n", .{});
    std.debug.print("  mask = {{ 0, 0, 0, 0 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{broadcast});

    // スワップ（隣接要素の交換）
    const swap_mask = @Vector(4, i32){ 1, 0, 3, 2 };
    const swapped = @shuffle(i32, v, undefined, swap_mask);
    std.debug.print("\n【隣接スワップ】\n", .{});
    std.debug.print("  mask = {{ 1, 0, 3, 2 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{swapped});

    std.debug.print("\n", .{});
}

// ====================
// 4. インターリーブ
// ====================

fn demoInterleave() void {
    std.debug.print("=== 4. インターリーブ ===\n\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };

    std.debug.print("v1 = {any}\n", .{v1});
    std.debug.print("v2 = {any}\n", .{v2});

    // 交互に配置（インターリーブ）
    const interleave_mask = @Vector(4, i32){ 0, ~@as(i32, 0), 1, ~@as(i32, 1) };
    const interleaved = @shuffle(i32, v1, v2, interleave_mask);

    std.debug.print("\n【インターリーブ】\n", .{});
    std.debug.print("  mask = {{ 0, ~0, 1, ~1 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{interleaved});
    std.debug.print("  (v1[0], v2[0], v1[1], v2[1])\n", .{});

    // 連結（concatenate）
    const concat_mask = @Vector(4, i32){ 0, 1, ~@as(i32, 0), ~@as(i32, 1) };
    const concatenated = @shuffle(i32, v1, v2, concat_mask);

    std.debug.print("\n【連結（前半+前半）】\n", .{});
    std.debug.print("  mask = {{ 0, 1, ~0, ~1 }}\n", .{});
    std.debug.print("  結果 = {any}\n", .{concatenated});

    std.debug.print("\n", .{});
}

// ====================
// 5. @select
// ====================

fn demoSelect() void {
    std.debug.print("=== 5. @select ===\n\n", .{});

    std.debug.print("【@select とは】\n", .{});
    std.debug.print("  ブールマスクで要素を選択\n", .{});
    std.debug.print("  @select(型, mask, true_vec, false_vec)\n", .{});

    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };
    const selector = @Vector(4, bool){ true, false, true, false };

    std.debug.print("\n  v1 = {any}\n", .{v1});
    std.debug.print("  v2 = {any}\n", .{v2});
    std.debug.print("  selector = {any}\n", .{selector});

    const selected = @select(i32, selector, v1, v2);

    std.debug.print("\n【結果】\n", .{});
    std.debug.print("  @select(i32, selector, v1, v2) = {any}\n", .{selected});
    std.debug.print("  (true→v1, false→v2)\n", .{});

    // 条件での使用例
    const values = @Vector(4, i32){ 5, 15, 25, 35 };
    const threshold: @Vector(4, i32) = @splat(20);
    const above_threshold = values > threshold;
    const clamped = @select(i32, above_threshold, threshold, values);

    std.debug.print("\n【実用例: 閾値クランプ】\n", .{});
    std.debug.print("  values = {any}\n", .{values});
    std.debug.print("  threshold = 20\n", .{});
    std.debug.print("  above = {any}\n", .{above_threshold});
    std.debug.print("  clamped = {any}\n", .{clamped});

    std.debug.print("\n", .{});
}

// ====================
// 6. @select vs @shuffle
// ====================

fn demoSelectVsShuffle() void {
    std.debug.print("=== 6. @select vs @shuffle ===\n\n", .{});

    std.debug.print("【@select】\n", .{});
    std.debug.print("  - ブールマスクを使用\n", .{});
    std.debug.print("  - 同じ位置から選択\n", .{});
    std.debug.print("  - 条件分岐に最適\n", .{});

    std.debug.print("\n【@shuffle】\n", .{});
    std.debug.print("  - インデックスマスクを使用\n", .{});
    std.debug.print("  - 任意の位置から選択可能\n", .{});
    std.debug.print("  - 並べ替え、逆順、インターリーブに最適\n", .{});

    std.debug.print("\n【使い分け】\n", .{});
    std.debug.print("  max(v1, v2) → @select + 比較\n", .{});
    std.debug.print("  reverse(v) → @shuffle\n", .{});
    std.debug.print("  interleave → @shuffle\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 7. 実用パターン
// ====================

fn demoPracticalPatterns() void {
    std.debug.print("=== 7. 実用パターン ===\n\n", .{});

    const v = @Vector(4, i32){ 10, 20, 30, 40 };
    std.debug.print("v = {any}\n\n", .{v});

    // パターン1: 水平和（horizontal sum）の補助
    // (v[0]+v[1], v[2]+v[3], ...) を作る前段階
    const high = @shuffle(i32, v, undefined, @Vector(4, i32){ 2, 3, 0, 1 });
    const partial_sum = v + high;
    std.debug.print("【水平和の補助】\n", .{});
    std.debug.print("  high = shuffle{{ 2, 3, 0, 1 }} = {any}\n", .{high});
    std.debug.print("  v + high = {any}\n", .{partial_sum});

    // パターン2: ペアワイズ最大
    const pair_max_mask = @Vector(4, i32){ 1, 0, 3, 2 };
    const shifted = @shuffle(i32, v, undefined, pair_max_mask);
    const pair_max = @max(v, shifted);
    std.debug.print("\n【ペアワイズ最大】\n", .{});
    std.debug.print("  shifted = {any}\n", .{shifted});
    std.debug.print("  max(v, shifted) = {any}\n", .{pair_max});

    std.debug.print("\n", .{});
}

// ====================
// まとめ
// ====================

fn demoSummary() void {
    std.debug.print("=== シャッフル まとめ ===\n\n", .{});

    std.debug.print("【@shuffle】\n", .{});
    std.debug.print("  @shuffle(型, v1, v2, mask)\n", .{});
    std.debug.print("  正のインデックス → v1 から\n", .{});
    std.debug.print("  負のインデックス（~n） → v2 から\n", .{});

    std.debug.print("\n【@select】\n", .{});
    std.debug.print("  @select(型, bool_mask, true_vec, false_vec)\n", .{});
    std.debug.print("  条件分岐に使用\n", .{});

    std.debug.print("\n【よく使うパターン】\n", .{});
    std.debug.print("  逆順: {{ 3, 2, 1, 0 }}\n", .{});
    std.debug.print("  スワップ: {{ 1, 0, 3, 2 }}\n", .{});
    std.debug.print("  ローテート: {{ 1, 2, 3, 0 }}\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoShuffleBasics();
    demoBasicShuffle();
    demoSingleVectorShuffle();
    demoInterleave();
    demoSelect();
    demoSelectVsShuffle();
    demoPracticalPatterns();
    demoSummary();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n109_simd_practical: 実践的なSIMD活用\n", .{});
}

// ====================
// テスト
// ====================

test "reverse shuffle" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const mask = @Vector(4, i32){ 3, 2, 1, 0 };
    const reversed = @shuffle(i32, v, undefined, mask);
    try std.testing.expectEqual(@as(i32, 4), reversed[0]);
    try std.testing.expectEqual(@as(i32, 1), reversed[3]);
}

test "interleave shuffle" {
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };
    const mask = @Vector(4, i32){ 0, ~@as(i32, 0), 1, ~@as(i32, 1) };
    const result = @shuffle(i32, v1, v2, mask);
    try std.testing.expectEqual(@as(i32, 1), result[0]);
    try std.testing.expectEqual(@as(i32, 10), result[1]);
    try std.testing.expectEqual(@as(i32, 2), result[2]);
    try std.testing.expectEqual(@as(i32, 20), result[3]);
}

test "@select" {
    const v1 = @Vector(4, i32){ 1, 2, 3, 4 };
    const v2 = @Vector(4, i32){ 10, 20, 30, 40 };
    const selector = @Vector(4, bool){ true, false, true, false };
    const result = @select(i32, selector, v1, v2);
    try std.testing.expectEqual(@as(i32, 1), result[0]);
    try std.testing.expectEqual(@as(i32, 20), result[1]);
    try std.testing.expectEqual(@as(i32, 3), result[2]);
    try std.testing.expectEqual(@as(i32, 40), result[3]);
}

test "broadcast" {
    const v = @Vector(4, i32){ 42, 0, 0, 0 };
    const mask = @Vector(4, i32){ 0, 0, 0, 0 };
    const broadcast = @shuffle(i32, v, undefined, mask);
    for (0..4) |i| {
        try std.testing.expectEqual(@as(i32, 42), broadcast[i]);
    }
}

test "swap pairs" {
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const mask = @Vector(4, i32){ 1, 0, 3, 2 };
    const swapped = @shuffle(i32, v, undefined, mask);
    try std.testing.expectEqual(@as(i32, 2), swapped[0]);
    try std.testing.expectEqual(@as(i32, 1), swapped[1]);
    try std.testing.expectEqual(@as(i32, 4), swapped[2]);
    try std.testing.expectEqual(@as(i32, 3), swapped[3]);
}
