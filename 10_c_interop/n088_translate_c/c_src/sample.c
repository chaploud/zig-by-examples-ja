// sample.c - translate-c デモ用Cソース

#include "sample.h"
#include <string.h>

// 基本関数
int32_t add_numbers(int32_t a, int32_t b) {
    return a + b;
}

int32_t multiply_numbers(int32_t a, int32_t b) {
    return a * b;
}

// 配列操作
int32_t sum_array(const int32_t* arr, size_t len) {
    int32_t sum = 0;
    for (size_t i = 0; i < len; i++) {
        sum += arr[i];
    }
    return sum;
}

void double_array(int32_t* arr, size_t len) {
    for (size_t i = 0; i < len; i++) {
        arr[i] *= 2;
    }
}

// 構造体操作
Vec2 vec2_add(Vec2 a, Vec2 b) {
    return (Vec2){ .x = a.x + b.x, .y = a.y + b.y };
}

Vec2 vec2_scale(Vec2 v, int32_t factor) {
    return (Vec2){ .x = v.x * factor, .y = v.y * factor };
}

int32_t vec2_dot(Vec2 a, Vec2 b) {
    return a.x * b.x + a.y * b.y;
}

// 文字列操作
size_t string_length(const char* str) {
    if (!str) return 0;
    size_t len = 0;
    while (str[len]) len++;
    return len;
}

void string_copy(char* dest, const char* src, size_t max_len) {
    if (!dest || !src || max_len == 0) return;
    size_t i;
    for (i = 0; i < max_len - 1 && src[i]; i++) {
        dest[i] = src[i];
    }
    dest[i] = '\0';
}

// コールバック
int32_t apply_op(int32_t a, int32_t b, BinaryOp op) {
    if (!op) return 0;
    return op(a, b);
}
