;Requires the print_string method!!!


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
	
;variables
DISK_ERROR_MSG: db "Disk read error!", 0