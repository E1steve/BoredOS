#ifndef WRAPPERS_H
#define WRAPPERS_H

#include <stdint.h>

uint8_t inb(uint16_t port);
void outb(uint16_t port, uint8_t data);

void io_wait(void);

#endif