#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
    =#
    
abstract type Machine end
abstract type TuringMachine <: Machine end
abstract type MachineComponent end
abstract type Programme end
abstract type ProgrammeCompoment end
