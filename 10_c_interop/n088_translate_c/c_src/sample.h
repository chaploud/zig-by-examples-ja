// sample.h - translate-c デモ用Cヘッダー
//
// このヘッダーを zig translate-c でZigコードに変換する

#ifndef SAMPLE_H
#define SAMPLE_H

#include <stdint.h>
#include <stddef.h>

// ====================
// 定数・マクロ
// ====================

#define MAX_SIZE 256
#define VERSION "1.0.0"
#define SQUARE(x) ((x) * (x))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

// ====================
// 列挙型
// ====================

typedef enum {
    COLOR_RED = 0,
    COLOR_GREEN = 1,
    COLOR_BLUE = 2,
    COLOR_COUNT
} Color;

typedef enum {
    STATUS_OK = 0,
    STATUS_ERROR = -1,
    STATUS_NOT_FOUND = -2
} Status;

// ====================
// 構造体
// ====================

typedef struct {
    int32_t x;
    int32_t y;
} Vec2;

typedef struct {
    char name[64];
    int32_t age;
    double score;
} Person;

// ネストした構造体
typedef struct {
    Vec2 position;
    Vec2 velocity;
    Color color;
} Entity;

// ====================
// 関数宣言
// ====================

// 基本関数
int32_t add_numbers(int32_t a, int32_t b);
int32_t multiply_numbers(int32_t a, int32_t b);

// 配列操作
int32_t sum_array(const int32_t* arr, size_t len);
void double_array(int32_t* arr, size_t len);

// 構造体操作
Vec2 vec2_add(Vec2 a, Vec2 b);
Vec2 vec2_scale(Vec2 v, int32_t factor);
int32_t vec2_dot(Vec2 a, Vec2 b);

// 文字列操作
size_t string_length(const char* str);
void string_copy(char* dest, const char* src, size_t max_len);

// コールバック
typedef int32_t (*BinaryOp)(int32_t, int32_t);
int32_t apply_op(int32_t a, int32_t b, BinaryOp op);

#endif // SAMPLE_H
