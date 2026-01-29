# --- Configuration ---
TARGET   := calc
SRC      := $(wildcard *.c)
CC       := gcc
CFLAGS   := -g -Wall -Werror -fsanitize=address -std=c17
LFLAGS   := -lm

# --- Directories ---
TEST_DIR   := tests
ANSWER_DIR := answers
TEST_RESULT_DIR  := output_from_tests

# --- Automatic Discovery ---
# 1. Find all input files (e.g., test/1.txt, test/2.txt)
TEST_INPUTS := $(wildcard $(TEST_DIR)/*.txt)

# 2. Generate a list of "success marker" files we want to create
#    If test/1.txt exists, we want to create build/1.ok
TEST_RESULTS := $(patsubst $(TEST_DIR)/%.txt, $(TEST_RESULT_DIR)/%.ok, $(TEST_INPUTS))

# --- Top Level Targets ---

# Default: compile the executable
all: $(TARGET)

# The 'test' target depends on all the .ok files being created
.PHONY: test
test: $(TARGET) $(TEST_RESULTS)
	@echo "All $(words $(TEST_RESULTS)) tests passed successfully!"

# --- Compilation Rules ---

# Compile the single C file into the target executable
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $< $(LFLAGS)

# --- Test Execution Rules ---

# This pattern rule tells Make how to create an .ok file from a .txt file
# It depends on:
#   1. The input file (TEST_DIR/%.txt)
#   2. The answer file (ANSWER_DIR/%.txt)
#   3. The executable itself (so we rebuild if code changes)
# It assumes that the input files and output files have the same filename.
# This recipe does the following:
#   0. Make the directory
#   1. Run the executable, pipe input file in, capture output to temp file
#   2. Compare output (.out) with the expected answer
#      'diff' returns 0 on match, 1 on difference. 
#      If diff fails, Make stops and prints the difference.
#   3. If diff passed, create the .ok file and print Pass.
$(TEST_RESULT_DIR)/%.ok: $(TEST_DIR)/%.txt $(ANSWER_DIR)/%.txt $(TARGET)
	@mkdir -p $(TEST_RESULT_DIR)
	@./$(TARGET) $< > $@.out
	@diff $@.out $(word 2,$^) > /dev/null || \
		(echo "[FAIL] $* " && \
		 echo "Expected vs Actual:" && \
		 diff -u $(word 2,$^) $@.out && \
		 exit 1)
	@touch $@
	@echo "[PASS] $*"

# --- Cleanup ---
.PHONY: clean
clean:
	rm -f *.o
	rm -f $(TARGET)
	rm -rf $(TEST_RESULT_DIR)
