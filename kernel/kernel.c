#include "..\drivers\screen.h"

void start(){
	//Create a pointer to char and point it to the first text cell of video memory (top left of screen)
	//char* video_memory = (char*) 0xb8000;

	//At the address pointed to by video_memory, store the character 'X' to display it
	//*video_memory = 'Z';

	print("\nReached D-Land\n\0");
	for (int i = 0; i < 20; i++){
		print ("test\n\0");
	} 


}