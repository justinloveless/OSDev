#ifndef SCREEN_H
#define SCREEN_H

#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define WHITE_ON_BLACK 0x0f

// Screen device I/O ports
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA	0x3D5

void scroll();
int get_cursor();
void set_cursor(int offset);
int get_row(int offset);
int get_col(int offset);
int get_screen_offset(int col, int row);
void print_char(char character, int col, int row, char attribute_byte);
void print_at(char* message, int col, int row);
void print(char* message);
void clear_screen();

#endif