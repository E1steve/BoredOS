
global inb
; void inb(uint16_t port)
inb:
    push ebp
    mov esp, ebp
    
    mov dx, word [ebp+8]
    in al, dx

    pop esp
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