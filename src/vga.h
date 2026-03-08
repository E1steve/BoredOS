#ifndef VGA_H
#define VGA_H

#include <stdint.h>

// Just something to cut down on magic bit math
typedef struct{
    char character;
    uint8_t color;
} __attribute__((packed)) term_char;

typedef enum {
	VGA_BLACK = 0,
	VGA_BLUE = 1,
	VGA_GREEN = 2,
	VGA_CYAN = 3,
	VGA_RED = 4,
	VGA_MAGENTA = 5,
	VGA_BROWN = 6,
	VGA_LIGHT_GREY = 7,
	VGA_DARK_GREY = 8,
	VGA_LIGHT_BLUE = 9,
	VGA_LIGHT_GREEN = 10,
	VGA_LIGHT_CYAN = 11,
	VGA_LIGHT_RED = 12,
	VGA_LIGHT_MAGENTA = 13,
	VGA_LIGHT_BROWN = 14,
	VGA_WHITE = 15,
} vga_color;

void set_term_color(vga_color fg_col, vga_color bg_col);
void write_char(char character);
void print_str(char* str);
void print_byte(uint8_t byte);
void printf(char* str, ...);

#endif