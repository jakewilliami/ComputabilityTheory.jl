#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#
    
module ComputabilityTheory

include(joinpath(dirname(@__FILE__), "coding.jl"))
include(joinpath(dirname(@__FILE__), "goto.jl"))

export ∸, pair_tuple, algebraic, π, cℤ, cℤ⁻¹

export Sequence, Instruction, Programme
export show_programme

end # end module
