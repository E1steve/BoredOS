#include "vga.h"

#include <stdint.h>
#include <stddef.h>

static size_t cursor_row;
static size_t cursor_col;
static uint8_t color;

term_char* video_mem = (term_char*)0xb8000;
uint32_t buffer_width = 80;
uint32_t buffer_height = 25;


static uint8_t hex_lookup[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

void set_term_color(vga_color fg_col, vga_color bg_col){
    color = fg_col | bg_col << 4;

    for(size_t i=0; i<buffer_width; i++){
        for(size_t j=0; j<buffer_height; j++){
            video_mem[i+j*buffer_width].color = color;
        }
    }
}

void write_char(char character) {
    if(character == '\n'){
        cursor_row += 1;
        cursor_col = 0;

        return;
    }

    video_mem[cursor_col + cursor_row*buffer_width].character = character;
    cursor_col += 1;

    if(cursor_col > buffer_width){
        cursor_row += 1;
        cursor_col = 0;

        if(cursor_row > buffer_height){
            cursor_row = 0;
        }
    }
}

void printf(char* str, ...) {
    char current;

    // this is probably the worst code ive written

    void* args = (uint8_t*)&str+4;

    while((current = *str) != '\0'){

        if(current == '%'){
            str++;
            current = *str;
            if(current == '\0'){return;}

            switch(current){
                case 'x':
                    print_byte(*((uint8_t*)args));
                    break;
                case 's':
                    print_str(*((char**)args));
                    break;
                default:
                    goto wchar;
                    break;
            }
            
            args+=4;            
            goto loop_end;
        }
        
        wchar:
            write_char(current);
        loop_end:
            str++;
    }

    // while ((current = *str) != '\0'){
    //     if(current == '%'){
    //         str++;
    //         current = *str;

    //         switch(current){
    //             case 's':
    //                 print_str(*((char**)arg));
    //                 break;
    //             case 'x':
    //                 print_byte(*((uint8_t*)arg));
    //                 break;
    //             default:
    //                 write_char(current);
    //                 break;
    //         }

    //         arg += 4;
    //         str++;
    //         continue;
    //     }
        
    //     write_char(current);
    //     str++;
    // }
}

void print_byte(uint8_t byte){
    char string[] = "00";

    string[1] = hex_lookup[byte & 0b1111];
    string[0] = hex_lookup[byte >> 4];

    print_str(string);
}

void print_str(char* str){
    while(*str != '\0'){
        write_char(*str);
        str++;
    }
}