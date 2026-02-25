import os
import random
import subprocess
# Julia's bitwise operator precedence differs from C
#     (xor and or are have the same precedence in Julia)
# Thus, to get the answer, it is best to simply complile the generated C.
# I don't want students to also need to install gcc or clang onto their computers,
#     so I'll write this such that it works on ilab.

def random_logic_expression(variable_names=("A", "B", "C")):
    l = random.randrange(2, 6) # length of the expression
    expression = ""
    for p in range(l):
        v = random.choice(variable_names)
        n = random.choice(("~", ""))
        op = random.choice(('&', '^', '|'))
        expression += n + v
        if p != l-1:
            expression += ' ' + op + ' '
    return expression

def emit_c_code(infix):
    s = """#include <stdio.h>
int main() {
    unsigned char A = 0x0f;
    unsigned char B = 0x33;
    unsigned char C = 0x55;
    unsigned char F = """
    s += infix + ";\n"
    s += """    printf("0x%02x\\n", F);
    return 0;
}"""
    return s

def run_c(code):
    filename = "./boolean_algebra.c"
    executable_name = filename[0:-2]
    with open(filename, "w") as f:
        f.write(code)
    subprocess.run(['gcc', '-std=c17', '-o', executable_name, filename])
    completed_process = subprocess.run(executable_name,
                                       capture_output=True, text=True)
    os.remove(filename)
    os.remove(executable_name)
    return completed_process.stdout.strip()

def generate_answer_strings(code):
    bubbles = ['ⓐ','ⓑ','ⓒ','ⓓ','ⓔ','ⓕ','ⓖ','ⓗ','ⓘ','ⓙ']
    hexstring = run_c(code)
    bitstring = bin(int(hexstring, base=16))[2:] # strip leading '0b' for now.
    bitstring = '0'*(8-len(bitstring)) + bitstring # pad with leading zeros.
    bubblestring = list(bitstring + '00') # we have ten bubbles
    for i in range(10):
        if bubblestring[i] == '0':
            bubblestring[i] = bubbles[i]
        else:
            bubblestring[i] = '●'
    bubblestring = ' '.join(bubblestring)    
    return (hexstring, "0b"+bitstring, bubblestring)

answers = ""
for question in range(1, 9):
    print(f"Question {question}:")
    print("Express, in binary, the program's output:")
    code = emit_c_code(random_logic_expression())
    print(code)
    print()

    # Assemble and store answer.
    hxs, bs, bbs = generate_answer_strings(code) # hexstring, bitstring, bubblestring.
    answers += f"Answer for question {question}:\n"
    answers += hxs + " in hexadecimal\n"
    answers += bs + " in binary\n"
    answers += bbs + "  in the bubble sheet.\n\n"

answers = answers[0:-1] # remove a trailing newline.
answers_filename = "answers_boolean_algebra.txt"
with open(answers_filename, "w") as f:
    f.write(answers)
print(f"Answers saved to {answers_filename}.")
