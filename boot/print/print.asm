
;parameters: assumes that al contains character to be printed

;to use scrolling teletype BIOS routine, you need int 0x10, and ah must equal 0x0e
print:
	push ax				;housekeeping -> make sure whatever was in ah isn't disturbed
	mov ah, 0x0e		;select scrolling teletype BIOS routine
	int 0x10
	pop ax				;return ah to the way it was before
	ret
	