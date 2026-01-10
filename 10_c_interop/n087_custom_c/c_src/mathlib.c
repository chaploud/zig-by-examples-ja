// mathlib.c - 自作C数学ライブラリ実装

#include "mathlib.h"
#include <string.h>

// 基本的な数学関数
int32_t add(int32_t a, int32_t b) {
    return a + b;
}

int32_t multiply(int32_t a, int32_t b) {
    return a * b;
}

int32_t factorial(int32_t n) {
    if (n <= 1) return 1;
    int32_t result = 1;
    for (int32_t i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// 配列操作
int32_t array_sum(const int32_t* arr, size_t len) {
    int32_t sum = 0;
    for (size_t i = 0; i < len; i++) {
        sum += arr[i];
    }
    return sum;
}

void array_double(int32_t* arr, size_t len) {
    for (size_t i = 0; i < len; i++) {
        arr[i] *= 2;
    }
}

// 文字列操作
size_t count_chars(const char* str, char target) {
    size_t count = 0;
    while (*str) {
        if (*str == target) count++;
        str++;
    }
    return count;
}

void reverse_string(char* str) {
    size_t len = strlen(str);
    for (size_t i = 0; i < len / 2; i++) {
        char tmp = str[i];
        str[i] = str[len - 1 - i];
        str[len - 1 - i] = tmp;
    }
}

// 構造体操作
Point point_add(Point a, Point b) {
    Point result = { a.x + b.x, a.y + b.y };
    return result;
}

int32_t point_distance_squared(Point a, Point b) {
    int32_t dx = b.x - a.x;
    int32_t dy = b.y - a.y;
    return dx * dx + dy * dy;
}

// コールバック関数
int32_t apply_operation(int32_t a, int32_t b, BinaryOp op) {
    return op(a, b);
}
