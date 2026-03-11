ENTRY(_start)

SECTIONS
{
    . = 1M;
    _kernel_start = .;
    
    .multiboot.data : {
        *(.multiboot.data);
    }

    .multiboot.text : {
        *(.multiboot.text);
    }

    . += 0xC0000000;
    
    _text_start = .;
    .text ALIGN (4K) : AT (ADDR (.text) - 0xC0000000) {
        *(.text);
    }
    _text_end = .;

    _rodata_start = .;
    .rodata ALIGN(4K) : AT (ADDR (.rodata) - 0xC0000000) {
        *(.rodata);
    }
    _rodata_end = .;

    _data_start = .;
    .data ALIGN (4K) : AT (ADDR (.data) - 0xC0000000) {
        *(.data);
    }
    _data_end = .;

    _bss_start = .; 
    .bss ALIGN (4K) : AT (ADDR (.bss) - 0xC0000000) {
        *(.bss);
    }
    _bss_end = .;

    _kernel_end = .;
}