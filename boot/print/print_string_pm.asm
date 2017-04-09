[bits 32]
;Constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

;prints a small null-terminated string pointed to by EBX, at location pointed to by EDX
print_string_pm:
	pusha
	;mov edx, VIDEO_MEMORY		; set edx to the start of vid mem (not needed anymore)
	
print_string_pm_loop:
	mov al, [ebx]
	mov ah, WHITE_ON_BLACK
	
	cmp al, 0 
	je print_string_pm_done
	
	mov [edx], ax
	
	add ebx, 1
	add edx, 2
	
	jmp print_string_pm_loop
	
print_string_pm_done:
	popa
	ret