using Random: shuffle, shuffle!

bubbles = ('ⓐ', 'ⓑ', 'ⓒ', 'ⓓ', 'ⓔ', 'ⓕ', 'ⓖ', 'ⓗ', 'ⓘ', 'ⓙ')

function generate_option_string(options, answer; shuffle_ops=false, sort_ops=false)

    ops = collect(options)  # options may be immutable.
    answer in options && deleteat!(ops, findall(==(ops), answer))
    
    shuffle_ops && sort_ops && error("Set either shuffle_ops or sort_ops to true, not both.")
    allunique(ops) || error("All elements options must be unique. Received\n\t$ops")
    length(ops) >= 9 || error("Must have at least nine options.")

    length(ops) > 9 && (ops = shuffle(options)[1:9])    
    push!(ops, answer)
    shuffle_ops && shuffle!(ops)
    sort_ops && sort!(ops)

    s = ""
    for (b, op) in zip(bubbles, ops)
        s *= "   " * b * ' ' * string(op) * '\n'
    end
    return s
end

"""Assumes Int8 or UInt8."""
function generate_answer_string(answer::Integer)
    bubblestring = collect(bitstring(answer) * "00")  # we have ten bubbles
    for i in 1:10
        if bubblestring[i] == '0'
            bubblestring[i] = bubbles[i]
        else
            bubblestring[i] = '●'
        end
    end
    bubblestring = join(bubblestring, ' ')
    s = "The answer $n is expressesd as 0x" *
        string(reinterpret(UInt8, answer), base=16) * # thou shalt be unsigned
        " in hexadecimal," *
        "\n   " * bitstring(answer) * " in binary, and as "*
        "\n   " * bubblestring * " in the bubble sheet.\n"
    return s
end

const CHARACTERS = ['0':'9'; 'a':'z']
for r in (1:12, 13:24, 25:36)
    v = CHARACTERS[r] # set v to a subset of u defined by the indices in the range r.
    println("Char:   " * join(v, "   " ))
    println("ASCII: " * join(string.(Int.(v), pad=3), ' '))
end


answers=""

###### BITS AS BUBBLES #####
n = rand(Int8)
println("\n1. Express $n as an 8-bit two's complement integer.")
println(  "   " * join(bubbles, ' '))
answers *= "1. " * generate_answer_string(n) * '\n'

# Test knowledge of positive octal.
n = abs(rand(Int8))
println("\n2. Express the octal number 0" *
    string(n, base=8) *
    " as an 8-bit two's complement integer.")
println(  "   " * join(bubbles, ' '))
answers *= "2. " * generate_answer_string(n) * '\n'

# Hammer home that characters are numbers.
c1, c2 = rand(CHARACTERS, 2)
println("\n3. Use the ASCII chart to express the sum '$c1' + '$c2' as a byte in binary."*
    "\n   Assume that they are first cast to 8-bit unsigned integers, such as uint8_t.")
println(  "   " * join(bubbles, ' '))
n = UInt8(c1) + UInt8(c2) # Julia will let this overflow.
answers *= "3. " * generate_answer_string(n) * '\n'

# Test bitshift knowledge.
n = rand(Int8)
s = rand(1:7)
println("\n4. Express $n << $s as a byte.")
println(  "   " * join(bubbles, ' '))
n = n << s
answers *= "4. " * generate_answer_string(n) * '\n'

n = rand(Int8)
s = rand(1:7)
println("\n5. Express $n >> $s as a byte, " *
    "\n   assuming >> is arithmetic (sign-preserving) and $n is signed.")
println(  "   " * join(bubbles, ' '))
n = n >> s
answers *= "5. " * generate_answer_string(n) * '\n'

n = rand(Int8)
s = rand(1:7)
println("\n6. Express $n >> $s as a byte, assuming >> is logical (unsigned).")
println(  "   " * join(bubbles, ' '))
n = n >>> s
answers *= "6. " * generate_answer_string(n) * '\n'

###### SELECT ONE ######
widths = [2 4 8 12 16 18 24 32 36 48 64]
n, m = rand(widths, 2)
p = n + m
println("\n7. We multiply two integers. They are $n and $m bits wide. " *
      "\n   From the options below, select the smallest number of bits " *
      "\n   to store the result, such that overflow is prevented.")
options = sort(unique(reduce(hcat,[widths .+ w for w in widths])))
println(generate_option_string(options, p, sort_ops=true))
answers *= "7. The answer is $p.\n\n"

println("8. What is the result from the following program?")
n = rand(Int16)
println(join(["        #include <stdio.h>"
        "int main(){"
          "    int n = $n;"
          "    int m = 0;"
          "    printf(\"%d\\n\", n/m);"
          "    return 0;"
        "}"], "\n        "))
answer = "Floating Point Exception"
options = (n + rand(Int8), n + rand(Int8), n, +0.0, -0.0, -Inf, Inf, NaN, "Compilation Error")
println(generate_option_string(options, answer))
answers *= "8. The answer is $answer.\n"

answers_filename = "answers_integers.txt"
write(answers_filename, answers)
println("Saved answers to $(answers_filename).")
