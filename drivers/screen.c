#include "screen.h"
#include "..\kernel\low_level.h"




 void scroll(){
	unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
	unsigned char attribute_byte = WHITE_ON_BLACK;
	unsigned char blank = 0x20;
	int pos = get_cursor();
	if (get_row(pos) >= MAX_ROWS) {
		//shift every line up one
		int i;
		for (i = 0; i < ((MAX_COLS * 2)*(MAX_ROWS-1)); i++){
			vidmem[i] = vidmem[i + MAX_COLS*2];
		}
		
		//now make the last line blank
		for (i = (MAX_ROWS - 1)*(MAX_COLS * 2); i < (MAX_ROWS)*(MAX_COLS*2); i+= 2){
			vidmem[i] = blank;
			vidmem[i+1] = attribute_byte;
		}
		
		set_cursor(pos - 2*(MAX_COLS)); // Place cursor one line up
	}
	
} 

int get_cursor(){
	//return the offset from the beginning of video memory based on the current cursor position
	//the device uses its control register as an index to select its internal registers
	//we're interested in:
	//		reg 14: high byte of cursor's offset
	//		reg 15: low byte of cursor's offset
	//After selecting the internal register, we may read or write a byte on the data register
	port_byte_out(REG_SCREEN_CTRL, 14);
	int offset = port_byte_in(REG_SCREEN_DATA) << 8;
	port_byte_out (REG_SCREEN_CTRL, 15);
	offset += port_byte_in(REG_SCREEN_DATA);
	// Note: the cursor offset reported by the VGA hardware is the number of characters,
	// so we have to multiply it by 2 to convert it to a character cell offset
	return offset*2;
}

void set_cursor(int offset){
	offset /= 2; //convert character cell offset to VGA hardware offset
	//write value to data registers
	port_byte_out(REG_SCREEN_CTRL, 14);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8)); // output the high byte
	port_byte_out (REG_SCREEN_CTRL, 15);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset)); // truncate to low byte and output it
	
}

int get_row(int offset){
	return (offset / (2 * MAX_COLS));
}

int get_col(int offset){
	return (offset / 2) % MAX_COLS;
}

int get_screen_offset(int col, int row){
	//return the offset from the beginning of video memory based on the desired row and column
	//2 bytes per character, and each row is worth 1 MAX_COLS
	return (2*(row * MAX_COLS + col));
}

/* Print a character on the screen at col, row, or at cursor position */
void print_char(char character, int col, int row, char attribute_byte) {
	/* Create a byte (char) pointer to the start of video memory */
	unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
	
	if (!attribute_byte){
		attribute_byte = WHITE_ON_BLACK;
	}
	
	int offset;
	
	// if col and row are non-negative, use them for offset.
	if (col >= 0 && row >= 0) {
		offset = get_screen_offset(col, row);
	} else {
		offset = get_cursor();
	}
	
	
	//if we see a newline character, set offset to end of current row, so it will advance to the 
	//first col of the next row
	if (character == '\n') {
		//find current row
		int current_row = get_row(offset);
		//calculate new offset
		offset = get_screen_offset(79, current_row);
	} 
	// handle the bakcspace character
	else if (character == '\b' && col) {
		// move the offset back by 2
		offset = get_screen_offset(col - 1, row);
	}
	//handle the tab character
	else if (character == 0x9) {
		//increase col to next number divisible by 8
		int new_col = (col + 0x8) & ~(0x7);
		offset += new_col * 2;
		vidmem[offset] = 'x';
		vidmem[offset + 1] = attribute_byte;
		offset += 2;
	}
	else { // otherwise, write the character and its attribute byte to vidmem at the offset
		vidmem[offset] = character;
		vidmem[offset + 1] = attribute_byte;
	}
	
	//update the offset to the next character cell
	offset += 2;
	//update the cursor position on the screen
	set_cursor(offset);
	scroll();
	
}

void print_hex(char hexcode, char attribute_byte){
	/* Create a byte (char) pointer to the start of video memory */
	unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
	
	if (!attribute_byte){
		attribute_byte = WHITE_ON_BLACK;
	}
	
	int offset = get_cursor();
	
	print("0x\0");
	
	
	vidmem[offset] = hexcode;
	vidmem[offset + 1] = attribute_byte;
	
	
	//update the offset to the next character cell
	offset += 2;
	//update the cursor position on the screen
	set_cursor(offset);
	scroll();
}

void print_at(char* message, int col, int row){
	// place cursor at row and column if not negative
	if (col >= 0 && row >= 0) {
		set_cursor(get_screen_offset(col, row));
	}
	// loop through each character and print it
	int i = 0;
	while (message[i]){
		print_char(message[i++], col, row, WHITE_ON_BLACK);
	}
}

void print(char* message){
	//print wherever the cursor is
	print_at(message, -1, -1);
}


void clear_screen() {
	int row = 0;
	int col = 0;
	
	//loop through video memory and write blank characters
	for (row = 0; row < MAX_ROWS; row++){
		for (col=0; col < MAX_COLS; col++){
			print_char(' ', col, row, WHITE_ON_BLACK);
		}
	}
	
	// Move the cursor back to the top left
	set_cursor(get_screen_offset(0,0));
}