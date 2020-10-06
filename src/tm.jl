#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
    =#
    
# Adapted form https://rosettacode.org/wiki/Universal_Turing_machine#Julia

Blank = " " # "□"
# Tape = 11111111111
# Tape = "101010" * Blank * "1"

global programme_counter = 0
programme_description(description::AbstractString) = (global programme_counter; programme_counter += 1; println("\t$programme_counter) $description"))

println("The following are the list of programmes to choose from:")

programme_description("Remove last character from string")
programme_description("Duplicate input string")
programme_description("Calculate the tally-code successor")
programme_description("Calculate the binary successor")
programme_description("Calculate the binary predecessor")
programme_description("Calculates the sum of two binary numbers (blank delimited)")
programme_description("x → x mod 3, where x is in tally-code")

println("\n")
println("Please choose a number as defined above.")

ChosenProgramme = parse(Int, readline())

println("\n")
println("Now please enter a tape.")
Tape = readline()
println("\n")

if Tape == ""
    throw(error("Don't mess with me.  The answer is probably a blank string, unless you want to compute the successor function in which case the answer is one."))
end

println("Do you want to show the process of the Turing Machine?")
Show = nothing
verbosity_input = readline()
if occursin(r"y"i, verbosity_input)
    Show = true
elseif occursin(r"n"i, verbosity_input)
    Show = false
else
    throw(error("You need to tell the programme whether or not you want to show the process of the Turing Machine."))
end
println("\n")





#----------------------------------------------------------------------------
import Base.show

# parse tape into tuple of strings.
# you can apply the string. function to this if you want to
# ensure that the elements are strings and not substrings
Tape = tuple(split(string(Tape), "")...)

# define moving
@enum Move Left=1 Stay Right

# defing structs
mutable struct MachineState
    state::String
    tape::Dict{Int, String}
    headpos::Int
end
 
struct Rule
    instate::String
    outstate::String
    s1::String
    s2::String
    move::Move
end
 
struct Programme
    title::String
    initial::String
    final::String
    blank::String
    rules::Vector{Rule}
end

# define programmes
const programmes = [
    (Programme("Turing Machine to Truncate String", "q0", "halt", Blank,
        [
            Rule("q0", "q0", "0", "0", Right),
            Rule("q0", "q0", "1", "1", Right),
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q1", "0", "0", Right),
            Rule("q1", "q1", "1", "1", Right),
            Rule("q1", "q2", Blank, Blank, Left),
            Rule("q2", "q3", "0", Blank, Left),
            Rule("q2", "q3", "1", Blank, Left),
            Rule("q3", "q3", "0", "0", Left),
            Rule("q3", "q3", "1", "1", Left),
            Rule("q3", "q4", Blank, Blank, Left),
            Rule("q4", "q4", "0", "0", Left),
            Rule("q4", "q4", "1", "1", Left),
            Rule("q4", "halt", Blank, Blank, Right)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Duplicate Input", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q2", "1", "A", Right),
            Rule("q2", "q2", "1", "1", Right),
            Rule("q2", "q2", "0", "0", Right),
            Rule("q2", "q2", "A", "A", Right),
            Rule("q2", "q2", "B", "B", Right),
            Rule("q2", "q3", Blank, "A", Left),
            Rule("q3", "q3", "A", "A", Left),
            Rule("q3", "q3", "B", "B", Left),
            Rule("q3", "q6", "1", "1", Left),
            Rule("q3", "q6", "0", "0", Left),
            Rule("q3", "q7", Blank, Blank, Right),
            Rule("q6", "q6", "1", "1", Left),
            Rule("q6", "q6", "0", "0", Left),
            Rule("q6", "q1", "A", "A", Right),
            Rule("q6", "q1", "B", "B", Right),
            Rule("q1", "q4", "0", "B", Left),
            Rule("q4", "q4", "1", "1", Right),
            Rule("q4", "q4", "0", "0", Right),
            Rule("q4", "q4", "A", "A", Right),
            Rule("q4", "q4", "B", "B", Right),
            Rule("q4", "q5", Blank, "B", Left),
            Rule("q5", "q5", "A", "A", Left),
            Rule("q5", "q5", "B", "B", Left),
            Rule("q5", "q6", "1", "1", Left),
            Rule("q5", "q6", "0", "0", Left),
            Rule("q5", "q7", Blank, Blank, Right),
            Rule("q7", "q7", "A", "1", Right),
            Rule("q7", "q7", "B", "0", Right),
            Rule("q7", "q8", Blank, Blank, Left),
            Rule("q8", "q8", "1", "1", Left),
            Rule("q8", "q8", "0", "0", Left),
            Rule("q8", "halt", Blank, Blank, Right)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Calculate the Tally-code Successor", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q1", "1", "1", Right),
            Rule("q1", "halt", Blank, "1", Stay)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Calculate the Binary Successor", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q1", "0", "0", Right),
            Rule("q1", "q1", "1", "1", Right),
            Rule("q1", "q2", Blank, Blank, Left),
            Rule("q2", "q2", "1", "0", Left),
            Rule("q2", "halt", "0", "1", Stay),
            Rule("q2", "halt", Blank, "1", Stay)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Calculate the Binary Predecessor", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q1", "0", "0", Right),
            Rule("q1", "q1", "1", "1", Right),
            Rule("q1", "q2", Blank, Blank, Left),
            Rule("q2", "q2", "0", "1", Left),
            Rule("q2", "halt", "1", "0", Stay)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Add Two Binary Numbers", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q1", "0", "0", Right),
            Rule("q1", "q1", "1", "1", Right),
            Rule("q1", "q1", "A", "A", Right),
            Rule("q1", "q1", "B", "B", Right),
            Rule("q2", "q1", "0", "A", Right),
            Rule("q2", "q1", "1", "B", Right),
            Rule("q2", "q2", "A", "A", Left),
            Rule("q2", "q2", "B", "B", Left),
            Rule("q3", "q2", Blank, Blank, Left),
            Rule("q3", "q3", "1", "1", Left),
            Rule("q3", "q3", "0", "0", Left),
            Rule("q1", "q4", Blank, Blank, Right),
            Rule("q4", "q4", "1", "1", Right),
            Rule("q4", "q4", "0", "0", Right),
            Rule("q4", "q5", Blank, Blank, Left),
            Rule("q5", "q8", "1", Blank, Left),
            Rule("q8", "q8", "1", "1", Left),
            Rule("q8", "q8", "0", "0", Left),
            Rule("q8", "q7", Blank, Blank, Left),
            Rule("q7", "q7", "A", "A", Left),
            Rule("q7", "q7", "B", "B", Left),
            Rule("q7", "q6", "1", "A", Left),
            Rule("q7", "q1", "0", "B", Right),
            Rule("q6", "q6", "1", "0", Left),
            Rule("q6", "q1", Blank, "1", Right),
            Rule("q6", "q1", "0", "1", Right),
            Rule("q5", "q3", "0", Blank, Left),
            Rule("q5", "q9", Blank, Blank, Left),
            Rule("q9", "q9", "B", "1", Left),
            Rule("q9", "q9", "A", "0", Left),
            Rule("q9", "halt", "0", "0", Stay),
            Rule("q9", "halt", "1", "1", Stay),
            Rule("q9", "halt", Blank, Blank, Stay)
        ]),
        Tape, Show
    ),
    (Programme("Turing Machine to Calculate x mod 3, where x is in tallycode", "q0", "halt", Blank,
        [
            Rule("q0", "q1", Blank, Blank, Right),
            Rule("q1", "q2", "1", Blank, Right),
            Rule("q2", "q3", "1", Blank, Right),
            Rule("q3", "q4", Blank, "1", Left),
            Rule("q4", "halt", Blank, "1", Stay),
            Rule("q2", "halt", Blank, "1", Stay),
            Rule("q3", "q1", "1", Blank, Right),
            Rule("q1", "halt", Blank, Blank, Stay)
        ]),
        Tape, Show
    ),
]
 
function show(io::IO, mstate::MachineState)
    ibracket(i, curpos, val) = isequal(i, curpos) ? "[$val]" : " $val "
    print(io, rpad("($(mstate.state))", 12))
    for i in sort(collect(keys(mstate.tape)))
        print(io, "   $(ibracket(i, mstate.headpos, mstate.tape[i]))")
    end
end
 
function turing(programme, tape, verbose)
    println("\u001b[1;38m$(programme.title)\u001b[0;38m")
    verbose && println(" State\t\t\tTape [head]\n", "-"^displaysize(stdout)[2])
    
    mstate = MachineState(programme.initial, tape, 1)
    stepcount = 0
    while true
        if ! haskey(mstate.tape, mstate.headpos)
            mstate.tape[mstate.headpos] = programme.blank
        end
        
        verbose && println(mstate)
        
        for rule in programme.rules
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
        
        if isequal(mstate.state, programme.final)
            break
        end
    end
    
    verbose && println(mstate)
    println("Total number of steps taken: $stepcount")
end

function main()
    (prog, tape_tuple, verbose) = programmes[ChosenProgramme]
    
    # pad tape with blanks
    tape_tuple = (Blank, tape_tuple..., Blank)
    
    # construct dictionary from tape
    tape = Dict{Int,String}()
    entry_count = 0
    
    for i in tape_tuple
        entry_count += 1
        push!(tape, entry_count => string(i))
    end
    

    turing(prog, tape, verbose)
    print("\n")
end

@time main()
