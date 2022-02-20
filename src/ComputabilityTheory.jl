module ComputabilityTheory

using Printf: @printf

include("utils.jl")

# Abstract Types
export Machine, TuringMachine, MachineComponent, Programme,
        ProgrammeComponent

export ∸, pair_tuple, algebraic, π, cℤ, cℤ⁻¹

export Tape, Left, Stay, Right, MachineState, Rule, TMProgramme,
        run_turing_machine, RegisterMachine, run_goto_programme

export Sequence, Instruction, GoToProgramme, increment, decrement,
        goto, ifzero_goto, halt, show_programme, rand

include("abstract_types.jl")
include("coding.jl")
include("goto.jl")
include("machines.jl")

end # end module
