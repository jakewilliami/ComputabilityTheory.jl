#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
    =#

include(joinpath(dirname(@__FILE__), "abstract_types.jl"))
include(joinpath(dirname(@__FILE__), "coding.jl"))
include(joinpath(dirname(@__FILE__), "goto.jl"))
include(joinpath(dirname(@__FILE__), "utils.jl"))

#---Turing Machine-------------------------------------------------------------------------
# Adapted form https://rosettacode.org/wiki/Universal_Turing_machine#Julia

# define moving
@enum Move Left=1 Stay Right

# defing structs
mutable struct MachineState <: MachineComponent
    state::String
    tape::Dict{Int, String}
    headpos::Int
end
 
struct Rule <: MachineComponent
    instate::String
    outstate::String
    s1::String
    s2::String
    move::Move
end

struct TMProgramme <: TuringMachine
    title::String
    initial::String
    final::String
    blank::String
    rules::Vector{Rule}
end
 
function Base.show(io::IO, mstate::MachineState)
    ibracket(i, curpos, val) = isequal(i, curpos) ? "[$val]" : " $val "
    print(io, rpad("($(mstate.state))", 12))
    for i in sort(collect(keys(mstate.tape)))
        print(io, "   $(ibracket(i, mstate.headpos, mstate.tape[i]))")
    end
end
 
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

mutable struct RegisterMachine <: Machine
    contents::AbstractArray#Vector{<:Integer}
    
    function RegisterMachine(contents::AbstractArray)
        arelessthan(0, contents) && throw(error("Registers must contain non-negative numbers."))
        
        new(contents)
    end
    
    RegisterMachine(T::Union{Tuple, UnitRange}) = RegisterMachine([T...])
    RegisterMachine(a::Integer...) = RegisterMachine([a...])
end

function run_goto_programme(P::GoToProgramme, R::RegisterMachine)::Tuple
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

function run_goto_programme(P::GoToProgramme)::Tuple
    max_register = extrema_tuple(P.instructions)[2][2] # the maximum value in the list of instructions in the second position
    R = RegisterMachine(zeros(Integer, max_register+1)) # fill register with zeros
    
    return run_goto_programme(P, R)
end

run_goto_programme(P::GoToProgramme, T::Tuple) = run_goto_programme(P, RegisterMachine(T))
run_goto_programme(P::Integer, T::Tuple) = run_goto_programme(GoToProgramme(P), RegisterMachine(T))
run_goto_programme(P::Integer, R::RegisterMachine) = run_goto_programme(GoToProgramme(P), R)
run_goto_programme(P::Integer) = run_goto_programme(GoToProgramme(P))
