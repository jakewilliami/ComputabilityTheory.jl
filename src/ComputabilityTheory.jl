#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#
    
module ComputabilityTheory

include(joinpath(dirname(@__FILE__), "machines.jl"))
include(joinpath(dirname(@__FILE__), "coding.jl"))
include(joinpath(dirname(@__FILE__), "goto.jl"))

export ∸, pair_tuple, algebraic, π, cℤ, cℤ⁻¹

export Tape, Left, Stay, Right, MachineState, Rule, TMProgramme, turing

export Sequence, Instruction, GoToProgramme
export increment, decrement, goto, ifzero_goto, halt
export show_programme

end # end module
