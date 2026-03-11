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

	mov  esp, stack_top-0xC0000000

	extern _kernel_start
	mov edi, page_table_1 - 0xC0000000 ; current page table entry
	mov esi, 0 ; current physical adress

	.get_to_kstart:
		add esi, 0x1000 ; add 4K to physical adress
		add edx, 4 ; move to next page entry

		; stop when reached _kernel_start
		cmp esi, _kernel_start - 0xC0000000
		jle .get_to_kstart
	
	extern _kernel_start
	mov edi, page_table_1 - 0xC0000000 + 0x400
	mov esi, _kernel_start

	extern _multiboot_end
	mov eax, _multiboot_end
	push eax

	call map_pages

	extern _text_end
	mov eax, _text_end-0xC0000000
	push eax

	call map_pages

	extern _rodata_end
	mov eax, _rodata_end-0xC0000000
	push eax

	call map_pages

	extern _data_end
	mov eax, _data_end-0xC0000000
	push eax

	call map_pages

	extern _bss_end
	mov eax, _bss_end-0xC0000000
	push eax

	call map_pages

	;; TODO, this is not a good idea
	;; This should be somewhere else
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

map_pages:
	push ebp
	mov ebp, esp

	mov eax, [ebp+8] ; end addr

	.write_pte:
		mov edx, esi
		or edx, 0x3
		mov dword [edi], edx

		add esi, 0x1000
		add edi, 4

		cmp esi, eax
		jl .write_pte

	pop ebp
	ret

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