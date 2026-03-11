bits 32

SECTION .multiboot.data
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

section .bss
;;; reserve space for the stack
align 16
resb 0x4000 ; 16 KiB
stack_top:

align 0x1000
page_directory:
resb 0x1000
page_table_1:
resb 0x1000

section .multiboot.text
global _start
extern kmain

_start:
	cli

	; eax must contain the magic number
	; for multiboot2 compliant loaders
	cmp eax, 0x36d76289
	jne $
	
	extern _kernel_start
	extern _kernel_end

	mov edi, page_table_1-0xC0000000
	mov esi, 0
	mov ecx, 1023

	entry:
		cmp esi, _kernel_start
		jl next
		cmp esi, _kernel_end-0xC0000000
		jge end

		mov edx, esi
		or edx, 0x3
		mov [edi], edx
	next:

		add esi, 4096
		add edi, 4
		loop entry
	end:
		mov dword [page_table_1 - 0xC0000000 + 1023*4], 0x000B8000 | 0x003

		mov dword [page_directory - 0xC0000000 + 0], page_table_1 - 0xC0000000 + 0x003
		mov dword [page_directory - 0xC0000000 + 768*4], page_table_1 - 0xC0000000 + 0x003

		mov ecx, page_directory-0xC0000000
		mov cr3, ecx

		mov ecx, cr0
		or ecx, 0x80010000
		mov cr0, ecx

		lea ecx, higher_half
		jmp ecx

section .text
higher_half:

	;;; un-identity map 1M
	mov dword [page_directory + 0], 0

	mov ecx, cr3
	mov cr3, ecx

	;;; load the gdt
	lgdt [gdtr]

	jmp 0x08:reload
	reload:
    	mov ax, 0x10
    	mov ds, ax
    	mov es, ax
    	mov fs, ax
    	mov gs, ax
    	mov ss, ax

	mov esp, stack_top

	add ebx, 0xC0000000
	push ebx
	call kmain