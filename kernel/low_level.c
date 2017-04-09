#include "low_level.h"

unsigned char port_byte_in (unsigned short port) {
	// reads a byte from the specified port
	// "=a" (result) means: put AL register in variable RESULT when finished
	// "d" (port) means: load EDX with PORT
	unsigned char result;
	__asm__ ("in %%dx, %%al" : "=a" (result) : "d" (port));
	return result;
}

void port_byte_out (unsigned short port, unsigned char data){
	// "a" (data) means: load EAX with DATA
	// "d" (port) means: load EDX with PORT
	__asm__ ("out %%al, %%dx" : :"a" (data), "d" (port));
}

unsigned short port_word_in (unsigned short port){
	unsigned short result;
	__asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
	return result;
}

void port_word_out (unsigned short port, unsigned short data) {
	__asm__("out %%ax, %%dx" : :"a" (data), "d" (port));
}
/*
void load_idt (unsigned long *idt_ptr){
	
	__asm__("lidt %%edx" : : "d" (idt_ptr));	// load idt pointer
	__asm__("sti");							// start interrupts
	
}*/