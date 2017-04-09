	
;parameters: dx -> hex to convert
;assumes that SI register is where the string should be built
;Requires that hex to char be included!!!
hex_to_string:
	pusha				;housekeeping -> save all
	
	xchg dh, dl			;swap dh and dl so we can convert what used to be dh first
	call hex_to_char	;convert dl to hex, result goes to bx
	mov [si], bh		;put value of bh to where si is pointing
	inc si				;increment where si is pointing by one
	mov [si], bl		;then put value of bl to where si is pointing
	inc si				;increment where si is pointing by one
	xchg dh, dl			;swap dh and dl back so we can convert dl
	call hex_to_char	;convert dl to hex, result goes to bx
	mov [si], bh		;put value of bx to where si is pointing
	inc si				;increment where si is pointing by one
	mov [si], bl		;put value of bx to where si is pointing
	inc si				;increment where si is pointing by one
	
	popa				;housekeeping -> return all
	ret
	
