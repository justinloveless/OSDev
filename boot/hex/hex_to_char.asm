	
;parameters: dl -> hex byte to convert (into two characters)
;returns: bx -> address of (two character) string
hex_to_char:
	push ax					;housekeeping -> save ax
	mov ax, dx				;copy dx into ax
							;Note: we're only interested in dl, and it needs to be split into two nybbles
	
	
	mov ah, al				;copy al over, so that we can get the high nybble in ah, and the low nybble in al
	shr ah, 4				;ah should now equal the high nybble
	and al, 0x0f			;al should now equal the low nybble
	
	lea bx, [LOOKUP_TABLE]	;this is used as the base for the xlat lookup
	xlat					;set al equal to whatever is at ds:[bx + al], i.e. a character in the lookup table
	
	xchg ah, al				;swap ah and al, because xlat only works on al
							;now al is the high nybble
	xlat					;set al equal a character from the table -> this time it's the high nybble
	xchg ah, al				;swap back ah and al, so they're in the right order again
	
	;lea bx, [STRING]		;get address of the string that we're going to store the characters in
	;mov [bx], ax			;put both characters into the string
	
	mov bx, ax				;transfer ax to bx for proper return format
	pop ax					;housekeeping -> return ax
	ret						;ax holds the characters

LOOKUP_TABLE:
	db "0123456789ABCDEF",0	;a table to determine how far to offset
	
;STRING:
	;resb	2				;reserver 2 bytes for the string. 
							;This should be enough, but if there's an issue, try increasing it