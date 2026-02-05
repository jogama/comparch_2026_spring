#include <stdlib.h>
#include <stdio.h>


int main() {

    while(1) {
	int number = 32;
	int* pointer = &number;
	int** ptrptr = &pointer;

	printf("number  = %d\n", number);
	printf("pointer = %p\n", pointer);
	printf("ptrptr =  %p\n", ptrptr);
    }
    
    return EXIT_SUCCESS;
}
