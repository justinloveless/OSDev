#include "keyboard.h"
#include "..\kernel\low_level.h"

// For reference, keyboard interrupt table: http://www.ctyme.com/intr/int-16.htm

//Int 16/AH=10h - KEYBOARD - GET ENHANCED KEYSTROKE (enhanced kbd support only)

char wait_key(){
	int result;
	// set AH registry to 10h, then call interupt 16h to tell the BIOS to wait for keyboard input
	char ah = 0x1;
	int ax = 0x0;
	asm (
		"mov %%ax, %3\n\t"
		"mov %%ah, %1\n\t" 
		"int $2\n\t"
		"mov %0, %%ax"
		: "=m"(result): "g" (ah) , "i" (0x16), "g" (ax) : "ax", "ah"
	);
	// the resulting keypress will be stored in AX

	return result;	
}

/*
char check_key(){
	
	int zero = 0x0;
	char interruptKey = 0x1;
	int result;
	asm (
		"mov %%ax, %1\n\t"
		"mov %%ah, %2\n\t"
		"int $3\n\t"
		"jz .noKey"
		"mov %%ax, %1\n\t"
		"int $3\n\t"
		"mov %0, %%ax\n\t"
		"ret\n\t"
		".noKey:\n\t"
		"mov %0, $1\n\t"
		: "=m" (result): "g" (zero), "g" (interruptKey), "i" (0x16) : "ax", "ah"
	);
	
	return result;
} */
