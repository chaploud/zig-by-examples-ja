// mathlib.h - 自作C数学ライブラリ
//
// ZigからCを呼び出すサンプル

#ifndef MATHLIB_H
#define MATHLIB_H

#include <stdint.h>
#include <stddef.h>

// 基本的な数学関数
int32_t add(int32_t a, int32_t b);
int32_t multiply(int32_t a, int32_t b);
int32_t factorial(int32_t n);

// 配列操作
int32_t array_sum(const int32_t* arr, size_t len);
void array_double(int32_t* arr, size_t len);

// 文字列操作
size_t count_chars(const char* str, char target);
void reverse_string(char* str);

// 構造体の例
typedef struct {
    int32_t x;
    int32_t y;
} Point;

Point point_add(Point a, Point b);
int32_t point_distance_squared(Point a, Point b);

// コールバック関数の例
typedef int32_t (*BinaryOp)(int32_t, int32_t);
int32_t apply_operation(int32_t a, int32_t b, BinaryOp op);

#endif // MATHLIB_H
