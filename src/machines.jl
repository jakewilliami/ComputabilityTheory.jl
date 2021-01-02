#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
    =#

#---Turing Machine-------------------------------------------------------------------------
# Adapted form https://rosettacode.org/wiki/Universal_Turing_machine#Julia

# define moving
"""
```julia
@enum Move Left=1 Stay Right
```

An enumerated type `Move`.
"""
@enum Move Left=1 Stay Right

"""
```julia
mutable struct MachineState <: MachineComponent
```
    
A snapshot of a state of a Turing machine.

Fields:
  - `state::String`: The name of the state of the Turing machine at the current machine state.
  - `tape::Dict{Int, String}``: The current state of the tape of the machine.  The head will be at `Int` value, and the contents at `String` value.
  - `headpos::Int`: The position of the head at the current state of the Turing Machine.
"""
mutable struct MachineState <: MachineComponent
    state::String
    tape::Dict{Int, String}
    headpos::Int
end

"""
```julia
struct Rule <: MachineComponent
```
    
Fields:
  - `instate::String`: The state name (`String`) where the rule starts.
  - `outstate::String`: The state name (`String`) where the rule ends.
  - `s1::String`: What the Turing machine will read.
  - `s2::String`: What the Turing machine will write.
  - `move::String`: How the Turing machine will move (see `Move`).
  
Note: `instate` and `outstate` are connected nodes in the Turing Machine.
"""
struct Rule <: MachineComponent
    instate::String
    outstate::String
    s1::String
    s2::String
    move::Move
end

"""
```julia
struct TMProgramme <: TuringMachine
```
    
Fields:
  - `title::String`: A descriptive name for your programme.
  - `initial::String`: The state name where the Turing machine begins.
  - `final::String`: The state name where the Turing machine halts.
  - `blank::String`: The symbol used to denote a blank cell.
  - `Rules::Vector{Rule}``: A list of rules of the programme.
"""
struct TMProgramme <: TuringMachine
    title::String
    initial::String
    final::String
    blank::String
    rules::Vector{Rule}
end

"""
```julia
Base.show(io::IO, mstate::MachineState)
```

Prints the current state of a Turing machine.
"""
function Base.show(io::IO, mstate::MachineState)
    ibracket(i, curpos, val) = isequal(i, curpos) ? "[$val]" : " $val "
    print(io, rpad("($(mstate.state))", 12))
    for i in sort(collect(keys(mstate.tape)))
        print(io, "   $(ibracket(i, mstate.headpos, mstate.tape[i]))")
    end
end

"""
```julia
run_turing_machine(TMProgramme, tape, verbose)
```

Run a specified Turing programme on a specified tape.  `verbose` is a boolean.
"""
function run_turing_machine(TMProgramme, tape, verbose)
    println("\u001b[1;38m$(TMProgramme.title)\u001b[0;38m")
    verbose && println(" State\t\t\tTape [head]\n", "-"^displaysize(stdout)[2])
    
    mstate = MachineState(TMProgramme.initial, tape, 1)
    stepcount = 0
    while true
        if ! haskey(mstate.tape, mstate.headpos)
            mstate.tape[mstate.headpos] = TMProgramme.blank
        end
        
        verbose && println(mstate)
        
        for rule in TMProgramme.rules
            if isequal(rule.instate, mstate.state) && isequal(rule.s1, mstate.tape[mstate.headpos])
                mstate.tape[mstate.headpos] = rule.s2
                if isequal(rule.move, Left)
                    mstate.headpos -= 1
                elseif isequal(rule.move, Right)
                    mstate.headpos += 1
                end
                
                mstate.state = rule.outstate
                break
            end
        end
        
        stepcount += 1
        
        if isequal(mstate.state, TMProgramme.final)
            break
        end
    end
    
    verbose && println(mstate)
    println("Total number of steps taken: $stepcount")
end

#--Register Machines--------------------------------------------------------------------------

"""
```julia
mutable struct RegisterMachine <: Machine
```

A register machine.  That is, a machine with finitely many registers, whose registers contain a natural number n ∈ ℕ ∪ {0}.

Fields:
  - `contents::AbastractArray`: The contents of the registers.

---
```julia
RegisterMachine(contents::AbstractArray)
```

A constructor function for the `struct` `RegisterMachine`.  Ensures the contents of the machine are indeed all natural numbers

---

```julia
RegisterMachine(T::Union{Tuple, UnitRange})
RegisterMachine(a::Integer, b::Integer...)
```

Constructor functions for the `struct` `RegisterMachine`.  Your contents are allowed to be tuples, ranges, or a series of integers.
"""
mutable struct RegisterMachine <: Machine
    contents::AbstractArray#Vector{<:Integer}
    
    function RegisterMachine(contents::AbstractArray)
        anylessthan(0, contents) && throw(error("Registers must contain non-negative numbers."))
        
        new(contents)
    end
    
    RegisterMachine(T::Union{Tuple, UnitRange}) = RegisterMachine([T...])
    RegisterMachine(a::Integer...) = RegisterMachine([a...])
end

"""
```julia
run_goto_programme(P::GoToProgramme, R::RegisterMachine) -> RegisterMachine.contents
run_goto_programme(P::GoToProgramme, T::Tuple) -> RegisterMachine.contents
run_goto_programme(P::Integer, T::Tuple) -> RegisterMachine.contents
run_goto_programme(P::Integer, R::RegisterMachine) -> RegisterMachine.contents
```

Takes in a *coded* programme `P` (for coding a programme, see notes), and runs the programme using register machine R.  It a tuple is given, will convert to a register machine whose contents is the tuple.  If an integer is given, will convert to a goto programme.

Notes: There are five possible instructions for a GoTo programme:
  - Increment Rᵢ  ⟵ `pair_tuple(0, i)`
  - Decrement Rᵢ  ⟵ `pair_tuple(1, i)`
  - Goto line k  ⟵ `pair_tuple(2, k)`
  - If Rᵢ is zero, goto line k  ⟵ `pair_tuple(3, (i, k))`
  - Halt  ⟵ `pair_tuple(4, 0)`
  
Then, the programme P, consisting of instructions I₁, I₂, ..., Iᵢ, is coded by
    
```julia
pair_tuple(i, pair_tuple(I₁, I₂, ..., Iᵢ))
```

For utilities regarding these instructions, see `pair_tuple`, `Sequence`, `Instruction`, `increment`, `decrement`, `goto`, `ifzero_goto`, `halt`, and `GoToProgramme`.
"""
function run_goto_programme(P::GoToProgramme, R::RegisterMachine)
    line_number = 0
    
    for instruction in P.instructions
        primary_identifier, secondary_identifier = instruction
    
        if isequal(primary_identifier, __increment_identifier)
            n = secondary_identifier
            R.contents[n + 1] += 1
        elseif isequal(primary_identifier, __decrement_identifier)
            n = secondary_identifier
            R.contents[n + 1] = R.contents[n + 1] ∸ 1
        elseif isequal(primary_identifier, __goto_identifier)
            k = secondary_identifier
            line_number = k
            continue
        elseif isequal(primary_identifier, __ifzero_goto_identifier)
            n, k = secondary_identifier
            if iszero(R.contents[n + 1])
                line_number = k
                continue
            end
        elseif isequal(primary_identifier, halt().first) && isequal(secondary_identifier, halt().second)
            break
        end
        
        line_number += 1
    end
    
    return tuple(R.contents...)
end
function run_goto_programme(P::GoToProgramme)
    max_register = extrema_tuple(P.instructions)[2][2] # the maximum value in the list of instructions in the second position
    R = RegisterMachine(zeros(Integer, max_register+1)) # fill register with zeros
    
    return run_goto_programme(P, R)
end
run_goto_programme(P::GoToProgramme, T::Tuple) = run_goto_programme(P, RegisterMachine(T))
run_goto_programme(P::Integer, T::Tuple) = run_goto_programme(GoToProgramme(P), RegisterMachine(T))
run_goto_programme(P::Integer, R::RegisterMachine) = run_goto_programme(GoToProgramme(P), R)
run_goto_programme(P::Integer) = run_goto_programme(GoToProgramme(P))
