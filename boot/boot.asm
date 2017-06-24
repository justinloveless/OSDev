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
	
		
;load kernel
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print_string
	
	mov bx, KERNEL_OFFSET
	mov dh, 15
	mov dl, [BOOT_DRIVE]
	call disk_load
	
	ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	; load DH number of sectors to ES:BX from drive DL
disk_load:
	push dx				;Store DX so we can later recall how many sectors we expected
	
	mov ah, 0x02		;BIOS read sector function
	mov al, dh			;Read DH number of sectors
	mov ch, 0x00		;Select Cylinder 0
	mov dh, 0x00		;Select head 0
	mov cl, 0x02		;Start reading from the second sector (after the boot sector)
	int 0x13			;BIOS interrupt for disk read
	
	jc disk_error		;jump if error (carry flag will be set)
	
	pop dx				;Recall DX to get the number of sectors we expected in DH
	cmp dh, al			; if AL (sectors read) != DH
	jne disk_error		;there was an error
	ret
	
disk_error:
	mov si, DISK_ERROR_MSG
	call print_string
	jmp $
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; Switch to protected mode
switch_to_pm:

	cli						;must turn off interrupts until the protected mode
							;interrupt vectors have been set up, otherwise the interrupts 
							;would "run riot"
							
	lgdt [gdt_descriptor]	;load the global descriptor table 
	
	mov eax, cr0			;to switch to protected mode, set the first bit of cr0
	or eax, 0x1
	mov cr0, eax
	
	jmp CODE_SEG:init_pm	;Make a far jump (i.e. to a new segment) to our 32-bit code.
							;This forces the CPU to flush its pipeline because it doesn't
							; have any way of knowing where it will end up



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;						
;assumes that the string to print is in the si register
print_string:
	;pusha				;housekeeping -> save ax
	mov al, [si]		;get first byte from si register
	or al, al			;check if al == 0
	jz exit				;if so, the end of the string has been reached, move on
	inc si				;increment si register for next character
	call print			;else, print character
	jmp print_string	;continue printing
exit:
	;popa				;housekeeping -> return ax to the way it was before
	ret
	
	
	;parameters: assumes that al contains character to be printed
;to use scrolling teletype BIOS routine, you need int 0x10, and ah must equal 0x0e
print:
	push ax				;housekeeping -> make sure whatever was in ah isn't disturbed
	mov ah, 0x0e		;select scrolling teletype BIOS routine
	int 0x10
	pop ax				;return ah to the way it was before
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT (Global Descriptor Table)

gdt_start:

gdt_null:		;the mandatory null descriptor
	dd 0x0
	dd 0x0
	
gdt_code:		;code segment descriptor
	; base = 0x0, limit = 0xfffff,
	; 1st flags: (present)1 (privilege)00 (descriptor type)1 -> 1001b
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
	; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
	dw 0xffff	;Limit (bits 0-15)
	dw 0x0		;Base (bits 0-15)
	db 0x0		;Base (bits 16-23)
	db 10011010b	;1st flags, type flags
	db 11001111b	;2nd flags, Limit (bits 16-19)
	db 0x0			;Base (bits 24-31)
	
gdt_data:		;data segment descriptor
	;only the type flags change for the the data segment
	;type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
	dw 0xffff	;Limit (bits 0-15)
	dw 0x0		;Base (bits 0-15)
	db 0x0		;Base (bits 16-23)
	db 10010010b	;1st flags, type flags
	db 11001111b	;2nd flags, Limit (bits 16-19)
	db 0x0			;Base (bits 24-31)
	
gdt_code_usermode:		;code segment descriptor for usermode privilege
	; base = 0x0, limit = 0xfffff,
	; 1st flags: (present)1 (privilege)11 (descriptor type)1 -> 1111b
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
	; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
	dw 0xffff	;Limit (bits 0-15)
	dw 0x0		;Base (bits 0-15)
	db 0x0		;Base (bits 16-23)
	db 11111010b	;1st flags, type flags
	db 11001111b	;2nd flags, Limit (bits 16-19)
	db 0x0			;Base (bits 24-31)
	
gdt_data_usermode:		;data segment descriptor for usermode privilege
	;only the type flags change for the the data segment
	;type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
	dw 0xffff	;Limit (bits 0-15)
	dw 0x0		;Base (bits 0-15)
	db 0x0		;Base (bits 16-23)
	db 11110010b	;1st flags, type flags
	db 11001111b	;2nd flags, Limit (bits 16-19)
	db 0x0			;Base (bits 24-31)
	
gdt_end:			;this label is used to calculate the size of the GDT


;GDT descriptor
gdt_descriptor:
	dw gdt_end - gdt_start - 1 		;The size of the GDT is always 1 less than the true size
	dd gdt_start					;start address of the gdt
	
	

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
CODE_SEG_USERMODE equ gdt_code_usermode - gdt_start
DATA_SEG_USERMODE equ gdt_data_usermode - gdt_start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
[bits 32]
; Initialize registers and the stack once in protected mode
init_pm:

	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, 0x90000
	mov esp, ebp
	
	call BEGIN_PM
	

; This is where we arrive after switching to and initialising protected mode
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	mov edx, (VIDEO_MEMORY + 80*2)	; print on second line
	call print_string_pm		
	
	call KERNEL_OFFSET				; begin processing C-level code 
									; (which is at an offset equal to KERNEL_OFFSET)
									; This depends on the build process to put the 
									; C-code at the correct offset.
	
	jmp $							; Hang
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	;Global variables
BOOT_DRIVE: db 0
MSG_REAL_MODE	db "Started in 16-bit Real Mode", 13, 10, 0
MSG_PROT_MODE	db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory.", 0
	;variables
DISK_ERROR_MSG: db "Disk read error!", 0

;boot padding and boot signature
times 510 - ($ - $$) db 0	;fill remainder of boot sector with 0'scrolling
dw 0xaa55

