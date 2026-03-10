#include "interrupts/interrupts.h"
#include "io.h"
#include "vga.h"

#include <stdbool.h>
#include <stdint.h>

static uint8_t scancode[256] = {
    0x0,
    0x0,
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    '-',
    '=',
    0x0,
    0x0,
    'Q',
    'W',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
    '[',
    ']',
    0x0,
    0x0,
    'A',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    ';',
    '\'',
    '`',
    '\\',
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
    ',',
    '.',
    '/',
};

static bool extend_code = false;

void handle_scancode(uint8_t code){
    if(code == 0xE0){
        extend_code = true;
    }

    if(extend_code){ extend_code = false; return; }

    char letter = scancode[code];
    if(letter != 0x0){ write_char(letter); }
}

__attribute__((interrupt)) 
void keyboard(void* something){
    uint8_t scancode = inb(0x60);
    io_wait();
    handle_scancode(scancode);

    outb(0x20, 0x20);
    io_wait();
}

void kbd_init(){
    add_int_handler(0x21, (uint32_t)&keyboard, GATE_TYPE_INTERRUPT | GATE_PRESENT | GATE_DPL_KERNEL, 0x8);
}