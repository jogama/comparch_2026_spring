#include <stdlib.h>
#include <stdio.h>


int sum(int length, int* array) {
  int result = 0;
  for (int i = 0; i < length; i++) {
    result += array[i];
  }
  printf("sum:array = %p\n", array);
  return result;
}

int main(int argc, char* argv[]) {
  int arr[] = {1, 2, 3, 4, 5, 6};
  int number = 300;
  short lilnum = (short)number;
  int* pointer = &number;
  
  char exercise = argv[1][0];
  printf("exercise = %c\n", exercise);
  switch (exercise) {
  case 'a':
    // Pointer chasing
    int** ptrptr = &pointer;
    printf("number  = %d\n", number);
    printf("pointer = %p\n", pointer);
    printf("ptrptr =  %p\n", ptrptr);
  case 'b':
    // Passing array to functions
    int sum_result = sum(6, arr);
    printf("main:arr           = %p\n", arr); 
    printf("main:sum_result    = %d\n", sum_result);
    printf("sizeof(arr)        = %ld\n", sizeof(arr));
    printf("sizeof(sum_result) = %ld\n", sizeof(sum_result));
    break;
  case 'c':
    // Different bases
    printf("main:arr  = %p\n", arr);
    printf("main:arr  = %ld\n", (long unsigned) arr);
    printf("main:arr  = 0%lo\n", (long unsigned) arr);
    break;
  case 'd':
    // Sizes of basic types
    printf("sizeof(number)    = %ld\n", sizeof(number));
    printf("sizeof(lilnum)    = %ld\n", sizeof(lilnum));
    printf("sizeof(exercise)  = %ld\n", sizeof(exercise));
    printf("sizeof(&number)   = %ld\n", sizeof(&number));
    printf("sizeof(&lilnum)   = %ld\n", sizeof(&lilnum));
    printf("sizeof(&exercise) = %ld\n", sizeof(&exercise));
    break;
  case 'e':
    // The '+' operator
    printf("&number   = %p\n", &number);
    printf("&lilnum   = %p\n", &lilnum);
    printf("&exercise = %p\n", &exercise);
    printf("1 + &number   = %p\n", 1 + &number);
    printf("1 + &lilnum   = %p\n", 1 + &lilnum);
    printf("1 + &exercise = %p\n", 1 + &exercise);
    printf("&number     = %ld\n", (long unsigned) &number);
    printf("1 + &number = %ld\n", (long unsigned) (1 + &number));
    printf("&lilnum     = %ld\n", (long unsigned) &lilnum);
    printf("1 + &lilnum = %ld\n", (long unsigned) (1 + &lilnum));
    printf("&exercise     = %ld\n", (long unsigned) &exercise);
    printf("1 + &exercise = %ld\n", (long unsigned) (1 + &exercise));
    /* printf("\n^^^ Add before cast ^^^vvv Add after cast vvv\n\n"); */
    /* printf("&number     = %ld\n", (long unsigned) &number); */
    /* printf("1 + &number = %ld\n", 1 + (long unsigned) &number); */
    /* printf("&lilnum     = %ld\n", (long unsigned) &lilnum); */
    /* printf("1 + &lilnum = %ld\n", 1 + (long unsigned) &lilnum); */
    /* printf("&exercise     = %ld\n", (long unsigned) &exercise); */
    /* printf("1 + &exercise = %ld\n", 1 + (long unsigned) &exercise); */
    break;
  case 'f':
    // Bytes in an integer
    printf("number   = %d\n", number);
    printf("*pointer = %d\n", *pointer);
    printf("&number  = %p\n", &number);
    printf("pointer  = %p\n", pointer);    
    printf("(unsigned char*) pointer     = %p\n", (unsigned char*) pointer);
    printf("(unsigned char*) pointer + 1 = %p\n", (unsigned char*) pointer + 1);
    printf("(unsigned char*) pointer + 2 = %p\n", (unsigned char*) pointer + 2);
    printf("(unsigned char*) pointer + 3 = %p\n", (unsigned char*) pointer + 3);
    printf("* (unsigned char*) pointer     = %d\n", * (unsigned char*) pointer);
    printf("*((unsigned char*) pointer + 1)= %d\n", * ((unsigned char*) pointer + 1));
    printf("*((unsigned char*) pointer + 2)= %d\n", * ((unsigned char*) pointer + 2));
    printf("*((unsigned char*) pointer + 3)= %d\n", * ((unsigned char*) pointer + 3));
    printf("5th byte? w/o asan? endianness?\n"); // https://en.wikipedia.org/wiki/Endianness
    break;
  case 'g':
    // Integers and shorts and chars and pointers
    printf("number        = %d\n", number);
    printf("lilnum        = %d\n", lilnum);
    printf("(char) number = %d\n", (char) number);
    break;
  default:
    printf("Received unsupported argument: %s\n", argv[1]);
    return EXIT_FAILURE;
  } 
      
  return EXIT_SUCCESS;
}
