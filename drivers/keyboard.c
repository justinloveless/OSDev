#include "keyboard.h"
#include "..\kernel\low_level.h"

// For reference, keyboard interrupt table: http://www.ctyme.com/intr/int-16.htm

//Int 16/AH=10h - KEYBOARD - GET ENHANCED KEYSTROKE (enhanced kbd support only)

char wait_key(){
	
	
}