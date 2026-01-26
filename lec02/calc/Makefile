OUTPUT=calc
CFLAGS=-g -Wall -Werror -fsanitize=address -std=c17
LFLAGS=-lm
TESTFILES=$(wildcard tests/test*.txt)
ANSWERFILES=$(wildcard answers/answer*.txt)
TESTANSWER_PAIRS=$(join $(TESTFILES), $(ANSWERFILES)))

%: %.c %.h
	gcc $(CFLAGS) -o $@ $< $(LFLAGS)

%: %.c
	gcc $(CFLAGS) -o $@ $< $(LFLAGS)

all: $(OUTPUT)

clean:
	rm -f *.o $(OUTPUT)
	rm -f test_output*.txt

test0: $(OUTPUT)
	./$(OUTPUT) tests/test0.txt > test_output0.txt
	diff test_output0.txt answers/answer0.txt
test1: $(OUTPUT)
	./$(OUTPUT) tests/test1.txt > test_output1.txt
	diff test_output1.txt answers/answer1.txt
test2: $(OUTPUT)
	./$(OUTPUT) tests/test2.txt > test_output2.txt
	diff test_output2.txt answers/answer2.txt


test: test0 test1 test2
