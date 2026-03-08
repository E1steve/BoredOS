#include <stdint.h>

#include "gdt/gdt.h"
#include "vga.h"
#include "multiboot/mboot.h"

void kmain(mboot_tag* mboot_info) {

    create_gdt();
    reload_segments();

    set_term_color(VGA_WHITE, VGA_BLACK);

    print_str("Multiboot headers are: 0x");
    print_byte((uint8_t)(mboot_info->type & 0xFF));
    print_str(" bytes long.\n");

    printf("Multiboot headers are: 0x%x bytes long.\n", (uint8_t)(mboot_info->type & 0xFF));

    // The fist tag is just info about the entire structure
    mboot_info++;
    
    // Parse the mboot structur 
    while(!(mboot_info->type == 0 && mboot_info->size == 8)){

        print_str("Multiboot tag of type: 0x");
        print_byte((uint8_t)(mboot_info->type & 0xFF));
        write_char('\n');

        switch(mboot_info->type){
            case MBOOT_TAG_TYPE_BOOT_LOADER_NAME:
                print_str((char*)(mboot_info+1));
                write_char('\n');
                break;
            default:
                break;
        }

        // Move to next mboot tag
        mboot_info += (mboot_info->size+7)/8;
    }

    for(;;){}
}