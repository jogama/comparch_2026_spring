using DelimitedFiles

akindicsv = readdlm("2026sp-computer-architectur-0119821110 - 01198211-10-13-final-exam responses.csv", ',')

"""
Function to provide an overall grade for questions 66 to 72,
given a student's row in the csv.

The response cell for a question has either a capital letter (A..J) if correct or a capital letter in parenthesis if incorrect.
"""

function grade66_72(row)
    # The first five columns are general student information,
    # so question 66 is in column 71, et cetera. 
    q66_72 = row[(66:72) .+ 5]

    # Strip parentheses and reduce strings to characters.
    map!(q66_72) do answer
        answer[1] == '(' ? answer[2] : answer[1]
    end
    q66, q67, q68, q69, q70, q71, q72 = q66_72
    
    # The students saw the following key:
    # (a) 0         (b)  1         (c)  2          (d)  3         (e) "&" AND
    # (f)  "|" OR   (g)  "~|" NOR  (h)  "~&" NAND  (i)   "^" XOR  (j) "~^" XNOR
    # We map it in this dictionary.
    options = Dict(
        'A' => 0,
        'B' => 1,
        'C' => 2,
        'D' => 3,
        'E' => &,
        'F' => |,
        'G' => nor,
        'H' => nand,
        'I' => xor,
        'J' => == # XNOR on two inputs implements logical equality.
         # XNOR on more than two inputs does not necessarily implement equality.
    )
    
    # I'd prefer to grade it by compiling it and giving something out
    #     of 16, based on the 16 test cases. However, I said what I
    #     said and I'll try to grade for those points. I might still grade that afterwards.
    compiles = issubset([q66, q68, q69, q71], 'A':'D') &&  # Confirm that literals are literals
        issubset([q67, q70, q72], 'E':'J') # and confirm that operators are operators.
    if !compiles
        @warn "Does not compile for " * row[1]
        return 0
    end
        
    function student_palindrome_logic(nibble)::Bool
        left, right =        [options[q66], options[q68]] .+ 1 # Julia 1-indexes, but 
        izquierda, derecha = [options[q69], options[q71]] .+ 1 # question is 0-indexed.
        op1, op2, op3 = options[q67], options[q70], options[q72]
        b = op1(nibble[left], nibble[right])
        a = op2(nibble[izquierda], nibble[derecha])
        is_palindrome = op3(a, b)
        return is_palindrome
    end
    # reference by index - 1. 
    reference = [true,  # 00 = 0b0000
                 false, # 01 = 0b0001
                 false, # 02 = 0b0010
                 false, # 03 = 0b0011
                 false, # 04 = 0b0100
                 false, # 05 = 0b0101
                 true,  # 06 = 0b0110
                 false, # 07 = 0b0111
                 false, # 08 = 0b1000
                 true,  # 09 = 0b1001
                 false, # 10 = 0b1010
                 false, # 11 = 0b1011
                 false, # 12 = 0b1100
                 false, # 13 = 0b1101
                 false, # 14 = 0b1110
                 true   # 15 = 0b1111
                 ]
    score = 0
    for i in 0:15
        nibble = [c=='1' for c in bitstring(i)[end-3:end]] # 4 bits
        if student_palindrome_logic(nibble) == reference[i+1]
            score += 1
            end
    end
    return score/2 # only 8 points for this question.
end

grades_digital = []
for i in 7:size(akindicsv)[1] # The first six rows are basically metadata
    row = akindicsv[i, :]
    score = grade66_72(row)
    push!(grades_digital, score)
    println(row[1], '\t', score)
end
