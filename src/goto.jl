#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#

#=
A goto programme can be coded by a single number!
For any d ∈ ℕ, the sequence code of a sequence (a0,a1,...,ad-1) ∈ ℕ^d, denoted by [a0,a1,...,ad-1], is
    ⟨d,⟨a0,a1,...,ad-1⟩⟩
Then, P is [a0,a1,...,ad-1].  So, given P, π(P, 2, 0, algebraic) is the number of lines of the programme, d;
and π(P, 2, 1, algebraic) is the programme itself.  Depairing that d times, we get a tuple of integers: the
instructions of the programme (one integer codes one line in the programme).
We define each line of the programme as being coded as follows:
 - The code for "Rn := Rn + 1" is ⟨0, n⟩;
 - The code for "Rn := Rn - 1" is ⟨1, n⟩;
 - The code for "goto k" is ⟨2, k⟩;
 - The code for "if Rn = 0 goto k" is ⟨3, ⟨n, k⟩⟩; and
 - The code for "halt" is ⟨4, 0⟩.
 
It should also be noted that the sequence code for some base cases is defined as follows:
 - if d = 0, the sequence code [] for the empty sequence is the number 0; and
 - if d = 1, for a ∈ ℕ, the sequence code [a] for the sequence (a) of length 1, is <1, a>.
=#

include(joinpath(dirname(@__FILE__), "coding.jl"))

using Printf: @printf

struct Sequence
	q::Integer
	length::Integer
	instructions::Tuple
	
	function Sequence(q::Integer)
		length, instructions = π(q, algebraic)
		instructions = isone(length) ? (instructions,) : π(instructions, length, algebraic)
		
		new(q, length, instructions)
	end
end # end struct

struct Instruction
	I::Integer
	first::Integer
	second::Integer
	third::Union{Integer, Nothing}
	instruction::Tuple
	
	function Instruction(I::Integer)
		first, second = π(I, algebraic)
		instruction = nothing
		third = nothing
		
		if isequal(first, 3)
			second, third = π(second, algebraic)
			instruction = (first, (second, third))
		else
			instruction = (first, second)
		end
		
		new(I, first, second, third, instruction)
	end # end constructor function
	
	function Instruction(instruction::Tuple)
		instruction_error = "Instructions whose coding tuple is more than three is not a valid instruction."
		length(instruction) > 3 && throw(error("$instruction_error"))
		first, second = instruction[1], instruction[2]
		third = nothing
		I = nothing
		
		if isequal(length(instruction), 3)
			third = instruction[3]
			I = pair_tuple(first, pair_tuple(second, third))
		else
			if instruction[2] isa Tuple
				second_tuple = second
				second = second_tuple[1]
				third = second_tuple[2]
				I = pair_tuple(first, pair_tuple(second, third))
			else
				I = pair_tuple(first, second)
			end
		end
			
		new(I, first, second, third, instruction)
	end # end constructor function
	
	Instruction(i::Integer, j::Integer...) = Instruction((i, j...))
end # end struct

increment(n::Integer) = Instruction(0, n)
decrement(n::Integer) = Instruction(1, n)
goto(k::Integer) = Instruction(2, k)
ifzero_goto(n::Integer, k::Integer) = Instruction(3, (n, k))
halt() = Instruction(4, 0)

struct Programme
    P::Integer
    length::Integer
    instructions::Vector{<:Tuple}
    max_line::Integer
    
    # declare constructor function
    function Programme(P::Integer)
        # Ensure the programme P is at least the nothing programme
		smallest_programme = pair_tuple(1, pair_tuple(4, 0))
        P < smallest_programme && throw(error("The smallest possible programme is coded by $(smallest_programme)."))
        
        # generate the snapshot of programme P
		sequence_dump = Sequence(P)
		snapshot = Instruction.(sequence_dump.instructions)
        length = sequence_dump.length
        
        # construct list of codes for each instruction
        if iszero(length)  instructions = 0  end
        instructions = [i.instruction for i in snapshot]
        
        # check that the programme halts at the end
    	instructions[end] != (4, 0) && throw(error("Goto programmes neccesarily have a halting instruction."))
            
		max_line = length - 1
        row_counter = -1 # need offset as we start counting from zero
        
        # check that all programme instruction codes are valid instructions
        for instruction in instructions
            primary_identifier = instruction[1]
            row_counter += 1
            
            if primary_identifier ∉ 0:4 || (isequal(primary_identifier, 4) && ! iszero(instruction[2]))
                throw(error("No known instruction for code ⟨$(join(instruction, ","))⟩"))
            end
            
            if isequal(primary_identifier, 4) && iszero(instruction[2]) && ! isequal(max_line, row_counter)
                throw(error("You must have exactly one halting instruction at the end of the programme."))
            end
            
            k = instruction[2]
            if isequal(primary_identifier, 2) && k > max_line
                throw(error("I cannot go to line $k of a programme which has $max_line instructions."))
            elseif isequal(primary_identifier, 2) && isequal(k, row_counter)
                throw(error("I am told to go to my own line (at line $k, goto line $k), and so I am stuck in an infinite loop.  The only way to escape is to tell you.  Please help me."))
            end
        end
        
        # construct fields
        new(P, length, instructions, max_line)
    end # end constructor (Programme) function
end # end struct

function show_programme(io::IO, P::Programme)
	# println("\033[1;38mThe number for $(P.P) pertains to the following programme:\033[0;38m\n")

    instructions = P.instructions
    max_line = P.max_line
    row_counter = -1
    message = ""
    
    for instruction in instructions
        primary_identifier = instruction[1]
        row_counter += 1
        
        if iszero(primary_identifier)
            n = instruction[2]
            message = "R$n := R$n + 1"
        elseif isone(primary_identifier)
            n = instruction[2]
            message = "R$n := R$n - 1"
        elseif isequal(primary_identifier, 2)
            k = instruction[2]
            message = "goto $k"
        elseif isequal(primary_identifier, 3)
            snapshot = instruction[2]
            n = snapshot[1]
            k = snapshot[2]
            message = "if R$n = 0 goto $k"
        elseif isequal(primary_identifier, 4) && iszero(instruction[2])
            message = "halt"
        else
            message = "No known instruction for code ⟨$(join(instruction, ","))⟩"
        end
        
        @printf(io, "%-3.3s  %-60.60s\n", "$row_counter", "$message")
    end
    
    return nothing
end # end show_programme function

# Given an integer, show_programme assumes it is a programme
show_programme(io::IO, P::Integer) = show_programme(io::IO, Programme(P))

# Fall back to standard output
show_programme(P::Programme) = show_programme(stdout, P)
show_programme(P::Integer) = show_programme(stdout, Programme(P))
