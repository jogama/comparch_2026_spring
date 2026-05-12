# File "grade_comparator_by_comparison.jl"
# so named because it grades the five comparator questions
# by comparing them with known reference solutions,
# as opposed to grading by compilation, which would run the autograder from pa6

using DelimitedFiles
akindicsv = readdlm("2026sp-computer-architectur-0119821110 - exam-2 responses.csv", ',')

function grade30_34_comparison(row; compile_correct_bubbles=false)
    # The first five columns are general student information,
    # so question 30 is in column 35, et cetera. 
    q30_34 = row[(30:34) .+ 5]

    # The key currently in akindi is "HCBCC", but is too narrow.
    # Other answers found by compiling and autograding everything, or manually:
    valid_answers = ("HCAGC", "HCBCC", "HCBHC", "HCBED",
                     "GFAGC", "GFBCC", "GFBHC", "GFBED"
         # No one at all used both q30=G xor and q31=F nor.
         # Everyone who did q30=G also also did q31=C,
         # which erases some information. Within the exam, this is not recoverable.
         # Another alternative should be q30=G xor and q31=E or,
         # but that may require more wires and certainly requires DeMorgan's Law.
                     )
    
    score = 0
    wasblank = " " # sentinel marking a blank answer
    for i = 1:5
        answer = q30_34[i]
        if answer == "( )" || answer == "()" || answer == " "
            # If answer space was left blank, homogenize and handle later.
            q30_34[i] = wasblank
        else
            # Strip parentheses. For empty answers (only one student .
            q30_34[i] = strip(answer, ['(', ')'])
        end
    end

    # Two students circled in two bubbles for q33, A and something else.
    # I assume they wanted A, "nothing" to be replaced with zero.
    # Treat these as special cases.
    
    if q30_34 == ["G", "C", "AH", "C", " "]
        # Manually looking into this and setting up a zero in the code, in A's place,
        # it needs two variables changed to work.
        # While it may be possible, I couldn't modify this to work with less.
        # The nearest correct solution assuming A means 0 seems to be
        # q30_34 = ["H", "C", "AH", "C", "C"],
        # which is two away from the given response, and 5-2=3.        
        return 3
    elseif q30_34 == ["C", "C", "AG", " ", "C"]
        # q30 = C AND looses information, so we'll change that to H XNOR straightaway.
        # we interpret q32 = AG as assign x = 0 ^ in_c, which just sets x=in_c.
        # Can the blank q33 recover from that to set y=0? Yes; X^X=0, so q33=G xor.
        # We now have H,C,AG,G,C, which turns out to be correct.
        # We changed two variables, and 5-2=3.
        return 3
    end

    # We've handled the special cases.
    # Now compare to the correct answers and return if full points.
    (join(q30_34) in valid_answers) && (return 5)

    # If all blank, return 0 points.
    all(==(wasblank), q30_34) && (return 0)
    
    
    # Apply partial credit by comparing to the most similar correct answer
    any(str -> length(str) != 1, q30_34) && error(
        "Each element in q30_34 must be a string of length one, yet" *
            "\nq30_34=\n", q30_34)


    lva = length(valid_answers[1]) # length valid answer
    all(va -> length(va) == lva, valid_answers) || error(
        "We currently assume that all valid answers have the same length," *
        "\nyet these are the lengths of all the reference solutions:" *
	string('\n', map(length, valid_answers)))
    
    distance = Inf
    for i in 1:length(valid_answers)
        candidate_answer = valid_answers[i]
        new_distance = sum([candidate_answer[j] != q30_34[j][1] for j=1:lva])
        if new_distance < distance
            closest_valid_answer = candidate_answer
            distance = new_distance
        end
    end
    score = 5 - distance
    
    # A negative score implies a bug in the above logic.
    score < 0 && error("Score=$score is negative for student ", row[1])

    return score
end

println("Total grades for questions 30-34, comparator, on exam two:")
grades_digital = []
for i in 7:size(akindicsv)[1] # The first six rows are basically metadata
    row = akindicsv[i, :]
    score = grade30_34_comparison(row)
    push!(grades_digital, score)
    println(row[1], '\t', score) # print name and score
end
