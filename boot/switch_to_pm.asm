[bits 16]
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