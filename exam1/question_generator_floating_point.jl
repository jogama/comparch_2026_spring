
# The following four functions receive an unsigned integer
# and return a potentially narrower integer alongside with
# that integer's bytes interpreted as a floating point number.
function interpret_f8(i::UInt8)
   i = UInt16(i) << 8
   return interpret_f8(i)
end
function interpret_f8(i::UInt16)
    i = i & 0xff00
    f = reinterpret(Float16, i)
    i = UInt8(i >> 8)
    return (i, f)
end
function interpret_bf16(i::UInt16)
    i = UInt32(i) << 16
    return interpret_bf16(i)
end
function interpret_bf16(i::UInt32)
    i = i & 0xffff0000
    f = reinterpret(Float32, i)
    i = UInt16(i >> 16)
    return (i, f)
end
function random_inf(t::AbstractString)
    if t == "IEEE binary16" || t == "F8 E5M2"
        f = rand([-Inf16 +Inf16])
        i = reinterpret(UInt16, f)
        t == "F8 E5M2" && (i = UInt8(i >> 8))
        return (i, f)
    elseif t == "Google Brain Float16"
        f = rand([-Inf32 +Inf32])
        i = UInt16(reinterpret(UInt32, f) >> 16)
        return (i, f)
    else
        error("Received unsupported type: $t")
    end
end


"""
Reinterprets an unsigned integer as the requested float.

Returns a new integer that is exactly as wide as the requested float, by truncating the lower bits if necessary.

bf16 and E5M2 are the same as truncating a Float32 and Float16, respectively.

At all points in the process, the only rounding that might be done should be truncation.
"""
function interpret_int_as_float(i::Unsigned, t::AbstractString)
    if t == "IEEE binary16"
        typeof(i) == UInt16 || error(
            "Only UInt16 can be interpreted as IEEE binary16." *
            "\nReceived a $(typeof(i)).")
        f = reinterpret(Float16, i)
        return (i, f)        
    elseif t == "Google Brain Float16"
        return interpret_bf16(i)
    elseif t == "F8 E5M2"
        return interpret_f8(i)
    else
        error("Did not recognize float type $t.")
    end
end

const BUBBLES = ['ⓐ','ⓑ','ⓒ','ⓓ','ⓔ','ⓕ','ⓖ','ⓗ','ⓘ','ⓙ']
const BUBBLE_STRING = join(BUBBLES, ' ')
function hex_to_bubbles(i::Unsigned, t::AbstractString)
    bs = bitstring(i) # Somewhere, there is a better way.
    if t == "F8 E5M2"
        bubbles = BUBBLES
        typeof(i) == UInt8 || error("Need UInt8 for $t. Received $(typeof(i)).")
        bs = bitstring(i) * "00" # Ten bubbles, so pad bitstring with zeros.
        bubbles = [bit=='1' ? '●' : BUBBLES[j] for (j, bit) in enumerate(bs)]
        return join(bubbles, ' ')
    elseif typeof(i) == UInt16
        s = if t == "IEEE binary16"
            7  # significand starts at the 7th bit
        elseif t == "Google Brain Float16"
            10 # significand starts at the 10th bit
        else
            error("Did not recognize $t as 16-bit float.")
        end
        # First, split the 16 bits into two 10-char bitstrings.
        bs_a = bitstring(i)[1:(s-1)]
        bs_b = bitstring(i)[s:end]
        bs_a *= '0'^(10-length(bs_a))
        bs_b *= '0'^(10-length(bs_b))

        # Then, translate the bits into bubbles and filled bubbles.
        a = [bit=='1' ? '●' : BUBBLES[j] for (j, bit) in enumerate(bs_a)]
        b = [bit=='1' ? '●' : BUBBLES[j] for (j, bit) in enumerate(bs_b)]
        a = join(a, ' ')
        b = join(b, ' ')
        return (a, b)
    end
    error("Could not parse i=$i and t=$t.")
end

# todo: constrain magnitude by drawing random from correct type.
function generate_decimal_bubble_options(f, t)::String
    p = if t == "IEEE binary16";        precision(Float16) # = 11
    elseif t == "Google Brain Float16"; 8
    elseif t == "F8 E5M2";              3
    end
    if isinf(f) || isnan(f) || iszero(f)
        f = round((rand() * 10 - 5), base=2, sigdigits=p)
    end
    scale = 10 # ceil(abs(f))
    v = round.((rand(5) * scale .- 5), base=2, sigdigits=p)
    for i in 1:5
        while v[i] == f
            v[i] = round((rand() * scale - 5), base=2, sigdigits=p)
        end
    end

    v[rand(1:5)] = f
    push!(v, -0.0)
    push!(v, 0.0)
    push!(v, -Inf)
    push!(v, Inf)
    push!(v, NaN)
    options = ""
    for i in 1:10
        options *= BUBBLES[i] * ' ' * string(v[i]) * '\n'
    end
    return options
end



#########################
println("PROVIDED CHARTS")
for i in (1:-1:-10)
    i >= 0 && print(" ") # Indent nonnegative numbers with a space
    print("$i   ")
    abs(i) < 10 && print(" ")
    println("$(2.0^i)")
end
println()

# https://cloud.google.com/blog/products/ai-machine-learning/bfloat16-the-secret-to-high-performance-on-cloud-tpus
# https://developer.nvidia.com/blog/floating-point-8-an-introduction-to-efficient-lower-precision-ai-training/
println("""
All the below representations conform to the IEEE behaviors for NaN
and Inf that we have been studying.  Each one is as wide as its name
implies.

Name            |Exponent Width|Bias
FP8 E5M2 (8-bit)|      5       |  15
Google BFloat16 |      8       | 127
IEEE binary16   |      5       |  15
IEEE binary32   |      8       | 127
IEEE binary64   |     11       |1023
""")


answers = ""
const REPRESENTATION_NAMES =  [
    "IEEE binary16"
    "Google Brain Float16"
    "F8 E5M2"]

############################
print("DECIMAL TO BINARY. ")
println("For the following questions, round towards zero (truncate).")
question_number = 0
for t in REPRESENTATION_NAMES
    global question_number += 1
    i, f = 0x0, NaN
    while isnan(f) || isinf(f) || 'e' ∈ string(f)
        # Prevent NaN. It has many spellings.
        # I think Inf is better reserved for binary to decimal.
        # Also prevent any float that Julia would print in
        #     decimal scientific notation.
        i = rand(UInt16)
        i, f = interpret_int_as_float(i, t)
    end
    hex = "0x" * string(i, base=16) # hex string
    println(question_number, ". Convert $f into $t. ")
    if typeof(i) == UInt8
        println(BUBBLE_STRING)
        global answers *=
"""Answer for question $(question_number):
$f as $t is $hex in hex, expressed as
$(bitstring(i)) in binary and
$(hex_to_bubbles(i, t))
in the bubble sheet.

"""
    elseif typeof(i) == UInt16
        # Assumes that the only 16-bit floats are IEEE and bf16.
        a, b = t == "IEEE binary16" ? ("six", "ten") : ("nine", "seven")
        println(question_number, "a. Provide the first $a bits. \n",
                BUBBLE_STRING)
        println(question_number, "b. Provide the last $b bits. \n",
                BUBBLE_STRING)

        bubble_a, bubble_b = hex_to_bubbles(i, t)
        global answers *=
"""Answer for question $(question_number):
$f as $t is $hex in hex, expressed as
$(bitstring(i)) in binary and
$(question_number)a. $(bubble_a)
$(question_number)b. $(bubble_b)
in the bubble sheet.

"""
    else
        error("Can currently only produce questions" *
            "\nfor 8-bit or 16-bit wide types.")
    end
    println()
end

############################
println("BINARY TO DECIMAL")
have_had_nan = false
have_had_inf = false
have_had_subnormal = false
j = 1
while true
    # First pick a representation
    global question_number += 1
    t = if j <= length(REPRESENTATION_NAMES)
        REPRESENTATION_NAMES[j]
    else
        rand(REPRESENTATION_NAMES)
    end
    global j += 1

    # Then pick a number...
    i = rand(UInt16)
    i, f = interpret_int_as_float(i, t)
    while 'e' ∈ string(f)
        i = rand(UInt16)
        i, f = interpret_int_as_float(i, t)
    end

    # ...while also ensuring we've picked the right numbers.
    global have_had_nan |= isnan(f)
    global have_had_inf |= isinf(f)
    global have_had_subnormal |= issubnormal(f)
    if j > length(REPRESENTATION_NAMES)
        if have_had_nan && have_had_inf #&& have_had_subnormal
            break
        elseif !have_had_inf
            i, f = random_inf(t)
            global have_had_inf |= isinf(f)
        # The following is quite inefficient, but will eventually work.
        # elseif !have_had_nan && !have_had_subnormal
        #     while !(isnan(f) || issubnormal(f))
        #         i = rand(UInt16)
        #         i, f = interpret_int_as_float(i, t)
        #     end
        #     global have_had_nan |= isnan(f)
        #     global have_had_subnormal |= issubnormal(f)
        # elseif !have_had_subnormal
        #     while !issubnormal(f)
        #         i = rand(UInt16)
        #         i, f = interpret_int_as_float(i, t)
        #     end
        #     global have_had_subnormal |= issubnormal(f)
        elseif !have_had_nan
            while !isnan(f)
                i = rand(UInt16)
                i, f = interpret_int_as_float(i, t)
            end
            global have_had_nan |= isnan(f)
        end
    end

    hex = "0x" * string(i, base=16) # hex string

    # Finally, generate questions and answers
    println(question_number, ". Select the decimal number corresponding to the $t number $hex:")
    println(generate_decimal_bubble_options(f, t))
    global answers *=
        """Answer for question $(question_number):
$f as $t is $hex in hex, expressed as
$(bitstring(i)) in binary.
"""
    if isnan(f)
        global answers *= "(Note that NaN has many representations)\n\n"
    else
        global answers *= "\n"
    end
end
answers_filename = "answers_floating_point.txt"
write(answers_filename, answers)
println("Saved answers to $(answers_filename).")
