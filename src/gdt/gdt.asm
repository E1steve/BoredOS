section .data
gdtr:
    dw gdt_end-gdt-1
    dq gdt
gdt:
    ; null descriptor
    dq 0
    ; All descriptors are base 0x0 and limit 0xFFFFFF
    ; they are also protected mode with page granulatrity
    dq 0x00CF9A000000FFFF ; Kernel mode code, access 0x9A
    dq 0x00CF92000000FFFF ; Kernel mode data, access 0x92
    dq 0x00CFFA000000FFFF ; User mode code, access 0xFA
    dq 0x00CFF2000000FFFF ; User mode data, access 0xF2
gdt_end:

section .text
global create_gdt
create_gdt:
    push ebp
    mov ebp, esp

    lgdt [gdtr]

    pop ebp
    ret

global reload_segments
reload_segments:
    push ebp
    mov ebp, esp

    jmp 0x08:.reload
.reload:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    pop ebp
    ret