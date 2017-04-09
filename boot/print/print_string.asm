
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
	
%include 'boot/print/print.asm'