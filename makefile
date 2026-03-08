
CC := i686-elf-gcc
C_FLAGS := -O2 -nostdlib -Wall -ffreestanding -Wextra -I ./src

ASMC := nasm
ASM_FLAGS := -f elf32

LD_FLAGS := -nostdlib

SRC_C := $(shell find ./src/ -name "*.c")
SRC_ASM := $(shell find ./src/ -name "*.asm")

OBJ_C := $(patsubst ./src/%.c,./obj/%.o,$(SRC_C))
OBJ_ASM := $(patsubst ./src/%.asm,./obj/%.o,$(SRC_ASM))

OBJ := $(OBJ_C) $(OBJ_ASM)

all: $(OBJ)

	mkdir -p bin
	mkdir -p obj
	mkdir -p iso
	mkdir -p iso/boot
	mkdir -p iso/boot/grub

	i686-elf-ld -T linker.ld -o bin/bored_os $(LD_FLAGS) $(OBJ)
	
	cp grub.cfg iso/boot/grub/grub.cfg
	cp bin/bored_os iso/boot/bored_os
	
	grub-mkrescue -o bored_os.iso iso

$(OBJ_ASM) : obj/%.o : src/%.asm
	mkdir -p $(dir $@)
	$(ASMC) $(ASM_FLAGS) $< -o $@

$(OBJ_C): obj/%.o : src/%.c
	mkdir -p $(dir $@)
	$(CC) $(C_FLAGS) -c $< -o $@

.PHONY clean:
	rm -f $(OBJ) bin/bored_os bored_os.iso
	rm -rf iso