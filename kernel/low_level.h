#ifndef LOW_LEVEL_C
#define LOW_LEVEL_C
// #include "low_level.c"

unsigned char port_byte_in (unsigned short port);
void port_byte_out (unsigned short port, unsigned char data);
unsigned short port_word_in (unsigned short port);
void port_word_out (unsigned short port, unsigned short data);

#endif