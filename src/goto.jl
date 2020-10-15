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

struct Sequence
	q::Integer
	seq_length::Integer
	instructions::Tuple
	
	function Sequence(q::Integer)
		seq_length, instructions = π(q, algebraic)
		instructions = isone(seq_length) ? (instructions,) : π(instructions, seq_length, algebraic)
		
		new(q, seq_length, instructions)
	end
	
	function Sequence(t::Tuple)
		q = nothing
		seq_length, instructions = t[1], t[2]
		
		sequence_length_error = "The first number in your sequence should match the length of your sequence."
		seq_length ≠ length(instructions) && throw(error("$(sequence_length_error)"))

		if eltype(instructions) <: Integer
			q = pair_tuple(t[1], t[2]...)
		end
		
		if eltype(instructions) <: Tuple
			q = pair_tuple(t[1], pair_tuple(pair_tuple.(t[2])))
		end
			
			
			
		# if isone(length(t[2]))
		# 	q = pair_tuple(t[1], t[2]...)
		# else
		# 	q = pair_tuple(t[1], pair_tuple(t[2]))
		# end
		
		new(q, seq_length, instructions)
	end
	
	Sequence(i::Integer, j::Tuple) = Sequence((i, j))
	Sequence(i::Integer, j::Integer...) = Sequence((i, tuple(j...)))
end # end struct

increment(n::Integer) = Instruction(0, n)
decrement(n::Integer) = Instruction(1, n)
goto(k::Integer) = Instruction(2, k)
ifzero_goto(t::Tuple) = Instruction(3, (t[1], t[2]))
ifzero_goto(n::Integer, k::Integer) = Instruction(3, (n, k))
halt() = Instruction(4, 0)

struct GoToProgramme
    P::Integer
    programme_length::Integer
    instructions::Vector{<:Tuple}
    max_line::Integer
    
    # declare constructor function
    function GoToProgramme(P::Integer) # P is the code for a sequence of a programme
        # Ensure the programme P is at least the nothing programme
		smallest_programme = Sequence(1, halt().I).q
        P < smallest_programme && throw(error("The smallest possible programme is coded by $(smallest_programme)."))
        
        # generate the snapshot of programme P
		sequence_dump = Sequence(P)
		snapshot = Instruction.(sequence_dump.instructions)
        programme_length = sequence_dump.seq_length
        
        # construct list of codes for each instruction
        if iszero(programme_length)  instructions = 0  end
        instructions = [i.instruction for i in snapshot]
        
        # check that the programme halts at the end
    	instructions[end] ≠ halt().instruction && throw(error("Goto programmes neccesarily have a halting instruction."))
            
		max_line = programme_length - 1
        row_counter = 0
        
        # check that all programme instruction codes are valid instructions
        for instruction in instructions
            primary_identifier, secondary_identifier = instruction
            
			if primary_identifier < 0 || primary_identifier > 4 || (isequal(primary_identifier, 4) && ! iszero(secondary_identifier))
                throw(error("No known instruction for code ⟨$(join(instruction, ","))⟩"))
            end
            
            if isequal(primary_identifier, 4) && iszero(secondary_identifier) && ! isequal(max_line, row_counter)
                throw(error("You must have exactly one halting instruction at the end of the programme."))
            end
            
            if isequal(primary_identifier, 2) && secondary_identifier > max_line
                throw(error("I cannot go to line $secondary_identifier of a programme which has $max_line instructions."))
            elseif isequal(primary_identifier, 2) && isequal(secondary_identifier, row_counter)
                throw(error("I am told to go to my own line (at line $secondary_identifier, goto line $secondary_identifier), and so I am stuck in an infinite loop.  The only way to escape is to tell you.  Please help me."))
            end
			
			row_counter += 1
        end
        
        # construct fields
        new(P, programme_length, instructions, max_line)
    end # end constructor (GoToProgramme) function
end # end struct

function show_programme(io::IO, P::GoToProgramme)
	# println("\033[1;38mThe number for $(P.P) pertains to the following programme:\033[0;38m\n")
    instructions = P.instructions
    max_line = P.max_line
    row_counter = 0
    message = string() # initalise message with empty string
    
    for instruction in instructions
        primary_identifier, secondary_identifier = instruction
        
        if iszero(primary_identifier)
            n = secondary_identifier
            message = "R$n := R$n + 1"
        elseif isone(primary_identifier)
            n = secondary_identifier
            message = "R$n := R$n - 1"
        elseif isequal(primary_identifier, 2)
            k = secondary_identifier
            message = "goto $k"
        elseif isequal(primary_identifier, 3)
            n, k = secondary_identifier
            message = "if R$n = 0 goto $k"
        elseif isequal(primary_identifier, 4) && iszero(secondary_identifier)
            message = "halt"
        else
            message = "No known instruction for code ⟨$(join(instruction, ","))⟩"
        end
        
        @printf(io, "%-3.3s  %-60.60s\n", "$row_counter", "$message")
		row_counter += 1
    end
    
    return nothing
end # end show_programme function

# Given an integer, show_programme assumes it is a programme
show_programme(io::IO, P::Integer) = show_programme(io::IO, GoToProgramme(P))

# Fall back to standard output
show_programme(P::GoToProgramme) = show_programme(stdout, P)
show_programme(P::Integer) = show_programme(stdout, GoToProgramme(P))
