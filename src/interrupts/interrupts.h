#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include <stdint.h>

void create_idt();

#define GATE_PRESENT 1 << 7
#define GATE_DPL_KERNEL 0 << 6
#define GATE_DPL_USER 3 << 6

#define GATE_TYPE_TASK 0x5
#define GATE_TYPE_INTERRUPT 0xE
#define GATE_TYPE_TRAP 0xF

void add_int_handler(uint8_t index, uint32_t offset, uint8_t flags, uint16_t selector);

#endif