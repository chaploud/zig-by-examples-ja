//! # SIMD 実践例
//!
//! SIMDを使った実用的な処理パターン。
//!
//! ## 実行方法
//! ```
//! zig run 12_simd/n109_simd_practical.zig
//! ```
//!
//! ## このファイルで学ぶこと
//! - 配列処理の高速化
//! - ベクトル演算の実践パターン
//! - SIMDが有効なケース

const std = @import("std");

// ====================
// 1. 配列の合計（SIMD版）
// ====================

fn sumScalar(arr: []const i32) i32 {
    var sum: i32 = 0;
    for (arr) |val| {
        sum += val;
    }
    return sum;
}

fn sumSimd(arr: []const i32) i32 {
    const vec_size = 4;
    var sum_vec: @Vector(vec_size, i32) = @splat(0);

    // ベクトル単位で処理
    var i: usize = 0;
    while (i + vec_size <= arr.len) : (i += vec_size) {
        const chunk: @Vector(vec_size, i32) = arr[i..][0..vec_size].*;
        sum_vec += chunk;
    }

    // 残りをスカラーで処理
    var remainder: i32 = 0;
    while (i < arr.len) : (i += 1) {
        remainder += arr[i];
    }

    // ベクトルの要素を集約
    return @reduce(.Add, sum_vec) + remainder;
}

fn demoArraySum() void {
    std.debug.print("=== 1. 配列の合計 ===\n\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    const scalar_sum = sumScalar(&arr);
    const simd_sum = sumSimd(&arr);

    std.debug.print("配列: {any}\n", .{arr});
    std.debug.print("スカラー合計: {d}\n", .{scalar_sum});
    std.debug.print("SIMD合計: {d}\n", .{simd_sum});

    std.debug.print("\n【SIMDアプローチ】\n", .{});
    std.debug.print("  1. 4要素ずつベクトルで処理\n", .{});
    std.debug.print("  2. 残りはスカラーで処理\n", .{});
    std.debug.print("  3. @reduce で最終集約\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 2. ドット積
// ====================

fn dotProductScalar(a: []const f32, b: []const f32) f32 {
    var sum: f32 = 0;
    for (a, b) |va, vb| {
        sum += va * vb;
    }
    return sum;
}

fn dotProductSimd(a: []const f32, b: []const f32) f32 {
    const vec_size = 4;
    var sum_vec: @Vector(vec_size, f32) = @splat(0);

    var i: usize = 0;
    while (i + vec_size <= a.len) : (i += vec_size) {
        const va: @Vector(vec_size, f32) = a[i..][0..vec_size].*;
        const vb: @Vector(vec_size, f32) = b[i..][0..vec_size].*;
        sum_vec += va * vb;
    }

    var remainder: f32 = 0;
    while (i < a.len) : (i += 1) {
        remainder += a[i] * b[i];
    }

    return @reduce(.Add, sum_vec) + remainder;
}

fn demoDotProduct() void {
    std.debug.print("=== 2. ドット積 ===\n\n", .{});

    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const b = [_]f32{ 2.0, 3.0, 4.0, 5.0, 6.0 };

    const scalar_dot = dotProductScalar(&a, &b);
    const simd_dot = dotProductSimd(&a, &b);

    std.debug.print("a = {any}\n", .{a});
    std.debug.print("b = {any}\n", .{b});
    std.debug.print("\nスカラー: {d:.1}\n", .{scalar_dot});
    std.debug.print("SIMD: {d:.1}\n", .{simd_dot});
    std.debug.print("(1*2 + 2*3 + 3*4 + 4*5 + 5*6 = 70)\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 3. 配列のスケーリング
// ====================

fn scaleArraySimd(arr: []f32, scale: f32) void {
    const vec_size = 4;
    const scale_vec: @Vector(vec_size, f32) = @splat(scale);

    var i: usize = 0;
    while (i + vec_size <= arr.len) : (i += vec_size) {
        const chunk: @Vector(vec_size, f32) = arr[i..][0..vec_size].*;
        const scaled = chunk * scale_vec;
        arr[i..][0..vec_size].* = scaled;
    }

    // 残りをスカラーで
    while (i < arr.len) : (i += 1) {
        arr[i] *= scale;
    }
}

fn demoScaleArray() void {
    std.debug.print("=== 3. 配列のスケーリング ===\n\n", .{});

    var arr = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 };

    std.debug.print("元の配列: {any}\n", .{arr});

    scaleArraySimd(&arr, 2.5);

    std.debug.print("x2.5後: {any}\n", .{arr});

    std.debug.print("\n【用途】\n", .{});
    std.debug.print("  - 音声のボリューム調整\n", .{});
    std.debug.print("  - 画像の明るさ調整\n", .{});
    std.debug.print("  - 数値データの正規化\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 4. 最大値・最小値の検索
// ====================

fn findMaxSimd(arr: []const i32) i32 {
    if (arr.len == 0) return 0;

    const vec_size = 4;
    var max_vec: @Vector(vec_size, i32) = @splat(arr[0]);

    var i: usize = 0;
    while (i + vec_size <= arr.len) : (i += vec_size) {
        const chunk: @Vector(vec_size, i32) = arr[i..][0..vec_size].*;
        max_vec = @max(max_vec, chunk);
    }

    var result = @reduce(.Max, max_vec);

    while (i < arr.len) : (i += 1) {
        if (arr[i] > result) result = arr[i];
    }

    return result;
}

fn demoFindMax() void {
    std.debug.print("=== 4. 最大値の検索 ===\n\n", .{});

    const arr = [_]i32{ 3, 7, 2, 9, 5, 1, 8, 4, 6, 10 };

    std.debug.print("配列: {any}\n", .{arr});
    std.debug.print("最大値: {d}\n", .{findMaxSimd(&arr)});

    std.debug.print("\n【アルゴリズム】\n", .{});
    std.debug.print("  1. 4要素ずつ@maxで比較\n", .{});
    std.debug.print("  2. @reduce(.Max)で最終結果\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 5. 閾値処理（クランプ）
// ====================

fn clampArraySimd(arr: []i32, min_val: i32, max_val: i32) void {
    const vec_size = 4;
    const min_vec: @Vector(vec_size, i32) = @splat(min_val);
    const max_vec: @Vector(vec_size, i32) = @splat(max_val);

    var i: usize = 0;
    while (i + vec_size <= arr.len) : (i += vec_size) {
        var chunk: @Vector(vec_size, i32) = arr[i..][0..vec_size].*;
        chunk = @max(chunk, min_vec); // 下限
        chunk = @min(chunk, max_vec); // 上限
        arr[i..][0..vec_size].* = chunk;
    }

    while (i < arr.len) : (i += 1) {
        if (arr[i] < min_val) arr[i] = min_val;
        if (arr[i] > max_val) arr[i] = max_val;
    }
}

fn demoClamp() void {
    std.debug.print("=== 5. 閾値処理（クランプ） ===\n\n", .{});

    var arr = [_]i32{ -5, 0, 50, 100, 150, 200, 255, 300 };

    std.debug.print("元の配列: {any}\n", .{arr});

    clampArraySimd(&arr, 0, 255);

    std.debug.print("クランプ後 [0, 255]: {any}\n", .{arr});

    std.debug.print("\n【用途】\n", .{});
    std.debug.print("  - 画像処理（ピクセル値を0-255に制限）\n", .{});
    std.debug.print("  - 信号処理（飽和防止）\n", .{});

    std.debug.print("\n", .{});
}

// ====================
// 6. 条件カウント
// ====================

fn countAboveThreshold(arr: []const i32, threshold: i32) usize {
    const vec_size = 4;
    const thresh_vec: @Vector(vec_size, i32) = @splat(threshold);
    var count: usize = 0;

    var i: usize = 0;
    while (i + vec_size <= arr.len) : (i += vec_size) {
        const chunk: @Vector(vec_size, i32) = arr[i..][0..vec_size].*;
        const above = chunk > thresh_vec;
        // boolベクトルをカウント
        const ones: @Vector(vec_size, i32) = @splat(1);
        const zeros: @Vector(vec_size, i32) = @splat(0);
        const counts = @select(i32, above, ones, zeros);
        count += @as(usize, @intCast(@reduce(.Add, counts)));
    }

    while (i < arr.len) : (i += 1) {
        if (arr[i] > threshold) count += 1;
    }

    return count;
}

fn demoCountCondition() void {
    std.debug.print("=== 6. 条件カウント ===\n\n", .{});

    const arr = [_]i32{ 10, 25, 5, 30, 15, 40, 8, 20 };
    const threshold = 20;

    std.debug.print("配列: {any}\n", .{arr});
    std.debug.print("閾値: {d}\n", .{threshold});
    std.debug.print("{d}より大きい要素の数: {d}\n", .{ threshold, countAboveThreshold(&arr, threshold) });

    std.debug.print("\n", .{});
}

// ====================
// 7. SIMDが有効なケース
// ====================

fn demoWhenToUseSIMD() void {
    std.debug.print("=== 7. SIMDが有効なケース ===\n\n", .{});

    std.debug.print("【有効なケース】\n", .{});
    std.debug.print("  - 大量のデータに同じ操作を適用\n", .{});
    std.debug.print("  - 画像・音声処理\n", .{});
    std.debug.print("  - 数値シミュレーション\n", .{});
    std.debug.print("  - 行列・ベクトル演算\n", .{});
    std.debug.print("  - 信号処理（フィルタリング等）\n", .{});

    std.debug.print("\n【効果が薄いケース】\n", .{});
    std.debug.print("  - データ量が少ない\n", .{});
    std.debug.print("  - 分岐が多い処理\n", .{});
    std.debug.print("  - メモリアクセスパターンが不規則\n", .{});

    std.debug.print("\n【ポイント】\n", .{});
    std.debug.print("  - アライメントに注意\n", .{});
    std.debug.print("  - 残り要素の処理を忘れずに\n", .{});
    std.debug.print("  - ベクトルサイズはCPUに合わせる\n", .{});
    std.debug.print("    (一般的に4, 8, 16)\n", .{});

    std.debug.print("\n", .{});
}

pub fn main() void {
    demoArraySum();
    demoDotProduct();
    demoScaleArray();
    demoFindMax();
    demoClamp();
    demoCountCondition();
    demoWhenToUseSIMD();

    std.debug.print("=== 次のトピック ===\n", .{});
    std.debug.print("・n110_simd_summary: SIMD総まとめ\n", .{});
}

// ====================
// テスト
// ====================

test "sum array" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const expected: i32 = 55;
    try std.testing.expectEqual(expected, sumSimd(&arr));
    try std.testing.expectEqual(expected, sumScalar(&arr));
}

test "dot product" {
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const b = [_]f32{ 2.0, 3.0, 4.0, 5.0 };
    // 1*2 + 2*3 + 3*4 + 4*5 = 2 + 6 + 12 + 20 = 40
    try std.testing.expectEqual(@as(f32, 40.0), dotProductSimd(&a, &b));
}

test "find max" {
    const arr = [_]i32{ 3, 7, 2, 9, 5, 1, 8, 4, 6, 10 };
    try std.testing.expectEqual(@as(i32, 10), findMaxSimd(&arr));
}

test "clamp array" {
    var arr = [_]i32{ -5, 0, 50, 100, 150, 200, 255, 300 };
    clampArraySimd(&arr, 0, 255);
    try std.testing.expectEqual(@as(i32, 0), arr[0]);
    try std.testing.expectEqual(@as(i32, 255), arr[7]);
}

test "count above threshold" {
    const arr = [_]i32{ 10, 25, 5, 30, 15, 40, 8, 20 };
    // 25, 30, 40 are > 20
    try std.testing.expectEqual(@as(usize, 3), countAboveThreshold(&arr, 20));
}
