
global inb
; void inb(uint16_t port)
inb:
    push ebp
    mov ebp, esp
    
    xor eax, eax

    mov dx, word [ebp+8]
    in al, dx

    pop ebp
    ret

global outb
; void outb(uint16_t port, uint8_t data)
outb:
    push ebp
    mov ebp, esp
    
    mov dx, word [ebp+8]
    mov al, byte [ebp+12]
    out dx, al

    pop ebp
    ret

global io_wait
; void io_wait(void);
io_wait:
    push ebp
    mov ebp, esp

    xor al, al
    out 0x80, al

    pop ebp
    ret