#include "..\drivers\screen.h"
#include "..\drivers\keyboard.h"
#include "..\drivers\descriptor_tables.h"

void start(){
	//Create a pointer to char and point it to the first text cell of video memory (top left of screen)
	//char* video_memory = (char*) 0xb8000;

	//At the address pointed to by video_memory, store the character 'X' to display it
	//*video_memory = 'Z';
	init_descriptor_tables();
	print("\nReached O-Land\n\n\0");
	print ("This is a test branch for developing keyboard functionality\n\0");
	print ("\t 1\n\0");
	char temp[] = "test2: x\n\0";
	//temp[7] = (char) wait_key();
	print (temp);
	for (int i = 0; i < 2; i++){
		for (int j = 0; j <= i; j++){
			print (">");
		}
		print ("test\n\0");
	}


}