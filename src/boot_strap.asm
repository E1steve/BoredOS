bits 32

SECTION .multiboot
MAGIC equ 0xE85250D6 ; magic number for mboot2
ARCH equ 0 ; i386 protected
MBOOT_HEADER_SIZE equ mboot_header_end-mboot_header

mboot_header:
	;;; mboot2 magic fields
    dd MAGIC
	dd ARCH
	dd MBOOT_HEADER_SIZE
	dd 0x100000000 - (MAGIC+ARCH+MBOOT_HEADER_SIZE) ; checksum

    ;;; mboot2 tags

    ;;; general tag format is
    ;;; dw type
    ;;; dw flags
    ;;; dd size
    ;;; extra data

    ; ; framebuffer tag
    ; dw 5
    ; dw 0
    ; dd 20
    ; ; 640x480 with 8 bit depth
    ; dw 640
    ; dw 480
    ; dw 8 
	
    ; end tags tag
	dw 0
	dw 0
	dd 8

    mboot_header_end:

section .bss
;;; reserve space for the stack
align 16
stack_bottom:
resb 0x4000 ; 16 KiB
stack_top:

section .text
global _start
extern kmain

_start:
	cli

	; eax must contain the magic number
	; for multiboot2 compliant loaders
	cmp eax, 0x36d76289
	jne no_mboot

	; yippee a stack
	mov esp, stack_top
	
	; pass ebx(multiboot info struct)
	; to kernel main function
	push ebx
	call kmain

	no_mboot:
		jmp $