#ifndef MBOOT_H
#define MBOOT_H

#define MBOOT_TAG_TYPE_ALIGNMENT 8

#define MBOOT_TAG_TYPE_END 0
#define MBOOT_TAG_TYPE_CMDLINE 1
#define MBOOT_TAG_TYPE_BOOT_LOADER_NAME 2
#define MBOOT_TAG_TYPE_MODULE 3
#define MBOOT_TAG_TYPE_BASIC_MEMINFO 4
#define MBOOT_TAG_TYPE_BOOTDEV 5
#define MBOOT_TAG_TYPE_MMAP 6
#define MBOOT_TAG_TYPE_VBE 7
#define MBOOT_TAG_TYPE_FRAMEBUFFER 8
#define MBOOT_TAG_TYPE_ELF_SECTIONS 9
#define MBOOT_TAG_TYPE_APM 10
#define MBOOT_TAG_TYPE_EFI32 11
#define MBOOT_TAG_TYPE_EFI64 12
#define MBOOT_TAG_TYPE_SMBIOS 13
#define MBOOT_TAG_TYPE_ACPI_OLD 14
#define MBOOT_TAG_TYPE_ACPI 15
#define MBOOT_TAG_TYPE_NETOWORK 16
#define MBOOT_TAG_TYPE_EFI_MEMMAP 17
#define MBOOT_TAG_TYPE_EFI_BS 18
#define MBOOT_TAG_TYPE_EFI32_IH 19
#define MBOOT_TAG_TYPE_EFI64_IH 20
#define MBOOT_TAG_TYPE_LOAD_BASE_ADDR 21


typedef struct {
    uint32_t type;
    uint32_t size;
} __attribute__((packed)) mboot_tag;

typedef struct {
    uint32_t type;
    uint32_t size;
    uint32_t lower_mem;
    uint32_t upper_mem;
} mboot_tag_basic_meminfo;

#define FRAMEBUFFER_TYPE_INDEXED 0
#define FRAMEBUFFER_TYPE_RGB 1
#define FRAMEBUFFER_TYPE_EGA 2

typedef struct {
    uint32_t type;
    uint32_t size;
    uint64_t address;
    uint32_t width;
    uint32_t height;
    uint8_t bpp;
    uint8_t buffer_type;
    uint8_t reserved;
    // color_info is here
} __attribute__((packed)) mboot_frame_buffer_info;

typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} __attribute__((packed)) mboot_color;

typedef struct {
    uint32_t num_colors;
    mboot_color* colors;
} __attribute__((packed)) mboot_color_info_indexed;

typedef struct {
    uint8_t red_field_position;
    uint8_t red_mask;
    uint8_t green_field_position;
    uint8_t green_mask;
    uint8_t blue_field_position;
    uint8_t blue_mask;
} __attribute__((packed)) mboot_color_info_rgb;

#endif