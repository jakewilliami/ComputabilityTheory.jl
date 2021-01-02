#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#

const __increment_identifier = 0
const __decrement_identifier = 1
const __goto_identifier = 2
const __ifzero_goto_identifier = 3
const __halt_identifier = (4, 0)

@doc raw"""
```julia
struct Instruction <: ProgrammeCompoment
```

An instruction is a command spanning a single line in a goto programme.

This struct has the fields:
  - `I::Integer`
  - `first::Integer`
  - `second::Integer`
  - `third::Union{Integer, Nothing}`
  - `instruction::Tuple`
  
---

```julia
Instruction(I::Integer)
```

Given an integer, this constructor function decodes the instruction.  An instruction can be one of five things, defined as follows:
  - The code for "``Rn := Rn + 1``" is ``\left\langle 0, n\right\rangle``;
  - The code for "``Rn := Rn - 1``" is ``\left\langle 1, n\right\rangle``;
  - The code for "``\texttt{goto } k``" is ``\left\langle 2, k\right\rangle``;
  - The code for "``\texttt{if } Rn = 0 \texttt{ goto } k``" is ``\left\langle 3, \left\langle n, k\right\rangle\right\rangle``; and
  - The code for "``\texttt{halt}``" is ``\left\langle 4, 0\right\rangle``.

```julia
Instruction(instruction::Tuple)
Instruction(i::Integer, j::Integer...) = Instruction((i, j...))
```

Given a tuple or a list of values, the value of the instruction is the pair of all inputs.
"""
struct Instruction <: ProgrammeCompoment
	I::Integer
	first::Integer
	second::Integer
	third::Union{Integer, Nothing}
	instruction::Tuple
	
	function Instruction(I::Integer)
		first, second = π(I)
		instruction = nothing
		third = nothing
		
		if isequal(first, 3)
			second, third = π(second)
			instruction = (first, (second, third))
		else
			instruction = (first, second)
		end
		
		new(I, first, second, third, instruction)
	end # end constructor function
	
	function Instruction(instruction::Tuple)
		instruction_error = "Instructions whose coding tuple is more than three is not a valid instruction."
		length(instruction) > 3 && throw(error("$instruction_error"))
		first, second = Base.first(instruction), instruction[2]
		third = I = nothing
		
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

@doc raw"""
```julia
struct Sequence <: ProgrammeCompoment
```

For any ``d \in \mathbb{N}``, the sequence code of a sequence ``(a_0,a_1,\ldots,a_{d-1}) \in \mathbb{N}^d``, denoted by ``[a_0,a_1,\ldots,a_{d-1}]``, is

```math
\left\langle d, \left\langle a a_0,a_1,\ldots,a_{d-1}\right\rangle\right\rangle
```

The struct has the following fields:
  - `q::Integer`
  - `seq_length::Integer`
  - `instructions::Tuple`

```julia
Sequence(q::Integer)
Sequence(t::Tuple)
Sequence(i::Integer, j::Tuple)
Sequence(i::Integer, j::Integer...)
```

The constructor methods for this struct decode the given value(s) into the sequence.
"""
struct Sequence <: ProgrammeCompoment
	q::Integer
	seq_length::Integer
	instructions::Tuple
	
	function Sequence(q::Integer)
		seq_length, instructions = π(q)
		instructions = isone(seq_length) ? (instructions,) : π(instructions, seq_length)
		
		new(q, seq_length, instructions)
	end
	
	function Sequence(t::Tuple)
		q = nothing
		seq_length, instructions = Base.first(t), t[2]

		if eltype(instructions) <: Integer
			q = pair_tuple(t[1], t[2]...)
		end
		
		if eltype(instructions) <: Tuple
			# q = pair_tuple(Base.first(t), pair_tuple(pair_tuple.(t[2])))
			q = pair_tuple(Base.first(t), pair_tuple(t[2]))
		end
		
		sequence_length_error = "The first number in your sequence should match the length of your sequence."
		seq_length ≠ length(instructions) && throw(error("$(sequence_length_error)"))
		
		new(q, seq_length, instructions)
	end
	
	Sequence(i::Integer, j::Tuple) = Sequence(pair_tuple(i, pair_tuple(j...)))
	Sequence(i::Integer, j::Integer...) = Sequence((i, tuple(j...)))
end # end struct

@doc raw"""
```julia
increment(n::Integer)
```

Constructs an `Instruction` object for incrementing the ``n\textsuperscript{th}`` register.

The code for "``Rn := Rn + 1``" is ``\left\langle 0, n\right\rangle``.
"""
increment(n::Integer) = Instruction(__increment_identifier, n)

@doc raw"""
```julia
decrement(n::Integer)
```

Constructs an `Instruction` object for decrementing the ``n\textsuperscript{th}`` register.

The code for "``Rn := Rn - 1``" is ``\left\langle 1, n\right\rangle``.
"""
decrement(n::Integer) = Instruction(__decrement_identifier, n)

@doc raw"""
```julia
goto(n::Integer)
```

Constructs an `Instruction` object for going to line ``k``.

The code for "``\texttt{goto } k``" is ``\left\langle 2, k\right\rangle``.
"""
goto(k::Integer) = Instruction(__goto_identifier, k)

@doc raw"""
```julia
ifzero_goto(t::NTuple{2, Integer})
ifzero_goto(n::Integer, k::Integer)
```

Constructs an `Instruction` object for going to line ``k`` if and only  if the ``n\textsuperscript{th}`` register is zero.

The code for "``\texttt{if } Rn = 0 \texttt{ goto } k``" is ``\left\langle 3, \left\langle n, k\right\rangle\right\rangle``.
"""
ifzero_goto(t::NTuple{2, Integer}) = Instruction(__ifzero_goto_identifier, t...)
ifzero_goto(n::Integer, k::Integer) = Instruction(__ifzero_goto_identifier, (n, k)...)

@doc raw"""
```julia
halt()
```

Constructs an `Instruction` object for the final line of all goto programmes: `halt`.

The code for "``\texttt{halt}``" is ``\left\langle 4, 0\right\rangle``.
"""
halt() = Instruction(__halt_identifier...)

@doc raw"""
```julia
struct GoToProgramme <: Programme
```

This struct has fields:
  - `P::Integer`
  - `programme_length::Integer`
  - `instructions::Vector{<:Tuple}`
  - `max_line::Integer`
  
---

```julia
GoToProgramme(P::Integer)
```

A goto programme can be coded by a single number!  This number in the struct is `P`.

---

For any ``d \in \mathbb{N}``, the sequence code of a sequence ``(a_0,a_1,\ldots,a_{d-1}) \in \mathbb{N}^d``, denoted by ``[a_0,a_1,\ldots,a_{d-1}]``, is

```math
\left\langle d, \left\langle a a_0,a_1,\ldots,a_{d-1}\right\rangle\right\rangle
```

Then, P is ``[a_0,a_1,\ldots,a_{d-1}]``.  So, given ``P``, `π(P, 2, 0)` is the number of lines of the programme, d;
and `π(P, 2, 1)` is the programme itself.  Depairing that ``d`` times, we get a tuple of integers: the
instructions of the programme (one integer codes one line in the programme).
We define each line of the programme as being coded as follows:
  - The code for "``Rn := Rn + 1``" is ``\left\langle 0, n\right\rangle``;
  - The code for "``Rn := Rn - 1``" is ``\left\langle 1, n\right\rangle``;
  - The code for "``\texttt{goto } k``" is ``\left\langle 2, k\right\rangle``;
  - The code for "``\texttt{if } Rn = 0 \texttt{ goto } k``" is ``\left\langle 3, \left\langle n, k\right\rangle\right\rangle``; and
  - The code for "``\texttt{halt}``" is ``\left\langle 4, 0\right\rangle``.
 
It should also be noted that the sequence code for some base cases is defined as follows:
  - if ``d = 0``, the sequence code ``[]`` for the empty sequence is the number 0; and
  - if ``d = 1``, for ``a \in \mathbb{N}``, the sequence code ``[a]`` for the sequence ``(a)`` of length 1, is ``\left\langle 1, a\right\rangle``.

The constructor function for this struct will ensure that the given integer `P` is a valid goto programme.
"""
struct GoToProgramme <: Programme
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
        instructions = iszero(programme_length) ? 0 : Tuple[i.instruction for i in snapshot]
        # check that the programme halts at the end
    	instructions[end] ≠ halt().instruction && throw(error("Goto programmes neccesarily have a halting instruction."))
            
		max_line = programme_length - 1
		lower_bound, upper_bound = extrema(Int[__increment_identifier, __decrement_identifier, __goto_identifier, __ifzero_goto_identifier, __halt_identifier...])
        row_counter = 0
        
        # check that all programme instruction codes are valid instructions
        for instruction in instructions
            primary_identifier, secondary_identifier = instruction
            
			if primary_identifier < lower_bound || primary_identifier > upper_bound || (isequal(primary_identifier, halt().first) && ! isequal(secondary_identifier, halt().second))
                throw(error("No known instruction for code ⟨$(join(instruction, ","))⟩"))
            end
            
            if isequal(primary_identifier, halt().first) && ! isequal(secondary_identifier, halt().second) && ! isequal(max_line, row_counter)
                throw(error("You must have exactly one halting instruction at the end of the programme."))
            end
            
            if isequal(primary_identifier, __goto_identifier) && secondary_identifier > max_line
                throw(error("I cannot go to line $secondary_identifier of a programme which has $max_line instructions."))
            elseif isequal(primary_identifier, __goto_identifier) && isequal(secondary_identifier, row_counter)
                throw(error("I am told to go to my own line (at line $secondary_identifier, goto line $secondary_identifier), and so I am stuck in an infinite loop.  The only way to escape is to tell you.  Please help me."))
            end
			
			row_counter += 1
        end
        
        # construct fields
        new(P, programme_length, instructions, max_line)
    end # end constructor (GoToProgramme) function
end # end struct

"""
```julia
show_programme(io::IO, P::GoToProgramme)
show_programme(P::GoToProgramme)
show_programme(P::Integer)
```

Given a goto programme, this function will decode it into its constituent components.  It will default to `stdout`.
"""
function show_programme(io::IO, P::GoToProgramme)
	# println("\033[1;38mThe number for $(P.P) pertains to the following programme:\033[0;38m\n")
    row_counter = 0
    message = string() # initalise message with empty string
    
    for instruction in P.instructions
        primary_identifier, secondary_identifier = instruction
        
		if isequal(primary_identifier, __increment_identifier)
            n = secondary_identifier
            message = "R$n := R$n + 1"
        elseif isequal(primary_identifier, __decrement_identifier)
            n = secondary_identifier
            message = "R$n := R$n - 1"
        elseif isequal(primary_identifier, __goto_identifier)
            k = secondary_identifier
            message = "goto $k"
        elseif isequal(primary_identifier, __ifzero_goto_identifier)
            n, k = secondary_identifier
            message = "if R$n = 0 goto $k"
        elseif isequal(primary_identifier, halt().first) && isequal(secondary_identifier, halt().second)
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

function Base.rand(::GoToProgramme, d::Integer; upper_bound::Integer = 200)
	return pair_tuple(d, pair_tuple(rand(1:upper_bound), halt().I))
	return Sequence((d, (rand(1:upper_bound), halt().I))).q
end

function Base.rand(::GoToProgramme)
	while true
		try
			return rand(T, rand(2:10))
		catch
		end
	end
end
