# --- Configuration ---
TARGET   := demo
SRC      := $(wildcard *.c)
CC       := gcc
CFLAGS   := -g -Wall -Werror -fsanitize=address -std=c17
LFLAGS   := -lm


# Compile the C files into the target executable
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $< $(LFLAGS)

# Default: compile the executable
all: $(TARGET)

# --- Cleanup ---
.PHONY: clean
clean:
	rm -f *.o
	rm -f $(TARGET)
	rm -rf $(TEST_RESULT_DIR)
