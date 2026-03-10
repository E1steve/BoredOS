#include "interrupts.h"
#include "../io.h"
#include "../vga.h"

#include <stdint.h>

typedef struct {
    uint16_t size;
    uint32_t offset;
} __attribute__((packed)) idtr;


typedef struct {
    uint16_t offset_low;
    uint16_t segment_selector;
    uint8_t reserved;
    uint8_t flags;
    uint16_t offset_high;
} __attribute__((packed)) gate_descriptor;

static idtr idt_reg;
static gate_descriptor idt[255];

void load_idt(idtr* reg);

void add_int_handler(uint8_t index, uint32_t offset, uint8_t flags, uint16_t selector){
    gate_descriptor* descriptor = idt+index;
    
    descriptor->offset_low = offset & 0xffff;
    descriptor->offset_high = (offset >> 16) & 0xffff;
    
    descriptor->flags = flags;
    descriptor->segment_selector = selector;
}

void program_pic(){
    outb(0x20, 0x11);
    io_wait();

    outb(0xA1, 0x11);
    io_wait();

    outb(0x21, 0x20);
    io_wait();

    outb(0xA1, 0x28);
    io_wait();

    outb(0x21, 1 << 2);
    io_wait();

    outb(0xA1, 2);
    io_wait();

    outb(0x21, 0b10111111);
    outb(0xa1, 0xFF);
}

__attribute__((interrupt))
void test(void* the_stack){
    outb(0x20, 0x20);
    return;
}

void create_idt(){
    program_pic();

    add_int_handler(0x20, (uint32_t)&test, GATE_TYPE_INTERRUPT | GATE_PRESENT | GATE_DPL_KERNEL, 0x8);

    idt_reg.size = sizeof(gate_descriptor)*256;
    idt_reg.offset = (uint32_t)idt;
    load_idt(&idt_reg);
}