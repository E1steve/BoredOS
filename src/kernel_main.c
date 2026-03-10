#include <stdint.h>

#include "gdt/gdt.h"
#include "interrupts/interrupts.h"

#include "io.h"
#include "vga.h"
#include "ps2/kbd/kbd.h"
#include "multiboot/mboot.h"

void kmain(mboot_tag* mboot_info) {

    create_gdt();
    reload_segments();

    create_idt();
    kbd_init();
    set_ints();

    set_term_color(VGA_WHITE, VGA_BLACK);
    toggle_cursor();

    // The fist tag is just info about the entire structure
    printf("Multiboot headers are: 0x%x bytes long.\n", (uint8_t)(mboot_info->type & 0xFF));
    mboot_info++;
    
    // Parse the mboot structure
    while(!(mboot_info->type == 0 && mboot_info->size == 8)){

        printf("Multiboot tag of type: 0x%x\n");

        switch(mboot_info->type){
            case MBOOT_TAG_TYPE_BOOT_LOADER_NAME:
                printf("Loaded by:  \n%s\n", (char*)(mboot_info+1));
                break;
            default:
                break;
        }

        // Move to next mboot tag
        mboot_info += (mboot_info->size+7)/8;
    }

    for(;;){}
}