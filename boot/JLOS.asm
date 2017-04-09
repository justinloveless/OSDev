[bits 16]
[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl		;BIOS stores our boot drive in DL, so remember it for later

;;;;; A boot sector that enters 32-bit protected mode

mov bp, 0x9000				;set the stack
mov sp, bp

mov si, MSG_REAL_MODE
call print_string

call load_kernel

call switch_to_pm			;Note: we never return from here

jmp $						;jump here forever
	
;%include 'boot/hex/hex_to_char.asm'
%include 'boot/print/print_string.asm'
%include 'boot/disk_load.asm'
;%include 'boot/hex/hex_to_string.asm'
%include 'boot/gdt.asm'
%include 'boot/switch_to_pm.asm'
%include 'boot/print/print_string_pm.asm'

[bits 16]

;load kernel
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print_string
	
	mov bx, KERNEL_OFFSET
	mov dh, 15
	mov dl, [BOOT_DRIVE]
	call disk_load
	
	ret

[bits 32]

; This is where we arrive after switching to and initialising protected mode
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	mov edx, (VIDEO_MEMORY + 80*2)	; print on second line
	call print_string_pm		
	
	call KERNEL_OFFSET
	
	jmp $						; Hang


;Global variables
BOOT_DRIVE: db 0
MSG_REAL_MODE	db "Started in 16-bit Real Mode", 13, 10, 0
MSG_PROT_MODE	db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory.", 0

;boot padding and boot signature
times 510 - ($ - $$) db 0	;fill remainder of boot sector with 0'scrolling
dw 0xaa55
