#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#define BUFFER_SIZE 256
#define BASE 0 // Guess base from context

int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Enter exactly one command-line argument.\n");
	return EXIT_FAILURE;
    }

    FILE* fp = fopen(argv[1], "r");
    if (fp == NULL){
	perror("fopen() failed to open the file.\n");
	return EXIT_FAILURE;
    }


    // Declare a character array array of size BUFFER_SIZE.
    char string_buffer[BUFFER_SIZE];
    char * end_pointer_for_string_to_num; // "endptr" in documentation

    // Initialize the operator to an arbitrary value.
    char op = '\0';
  
    // Now apply the operator and store the result.
    long result;

    // Loop until we reach EOF, while keeping track of lines read.
    for (int lines_read = 0; !feof(fp); lines_read++) {
	// fgets() stops reading after an EOF or a newline.
	// Read one line into string_buffer of length at most BUFFER_SIZE.
	// Question for students: what is missing in this fgets() check?
	if (fgets(string_buffer, BUFFER_SIZE, fp) == NULL && !feof(fp)) {
	    perror("fgets() failed to read a line.\n");
	    return EXIT_FAILURE;
	}
	// If we have not yet set the operator,
	if (lines_read == 0) {
	    op = string_buffer[0];
	    continue;
	}
      
	// Attempt to convert the line to a number
	// Clear errno of any previous errors
	errno = 0; 
	long next_number = strtol(string_buffer, &end_pointer_for_string_to_num, BASE);
	if (errno == ERANGE) {
	    perror("strtol() suffered underflow or overflow with the string\n");
	    return EXIT_FAILURE;
	} else if (errno == EINVAL) {
	    perror("strtol() received an unsupported base\n");
	    return EXIT_FAILURE;
	}
	if (next_number == 0 && string_buffer == end_pointer_for_string_to_num){
	    // The documentations states that if the conversion function does not find digits,
	    // it will return 0 and set end_pointer ("endptr") to string_buffer ("nptr").
	    // It did not find digits. Continue.
	    continue;
	}
	
	// The conversion was successful. Now parse the line.
	if (lines_read == 1) {
	    // Initialize result if this is the first argument to the operator.
	    result = next_number;
	} else {
	    // let result = op(result, next_number)
	    // Question for students: what happens if I remove the break statements?
	    switch(op) {
	    case '+': result = result + next_number; break; // Summation
	    case '*': result = result * next_number; break; // Multiplication
	    default:
		// Question for students: What could be improved about this print statement?
		printf("Received unsupported operator: %c\n", op);
		return EXIT_FAILURE;
	    }
	}

	// Set string_buffer to a zero-length string to prevent re-reading.
	string_buffer[1] = '\0';
    } // for (int lines_read...

    // Finally, print the result.
    printf("%ld\n", result);

    // Question for students: must we close the file?
    // If fp is not at EOF and yet fclose returned EOF,
    if (!feof(fp) && (fclose(fp) == EOF)) {
	perror("Failed to close the file.\n");
	return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
} // int main(...)
