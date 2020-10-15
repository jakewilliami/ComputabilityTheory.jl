#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $(dirname $0)))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#

#=
Check that all elements in a list are less than a given x.
=#
@inline function __arelessthan(x::Number, A::AbstractArray)::Bool
    @inbounds for a in A
        a < x && return true
    end
    
    return false
end

@inline function __arelessthan(x::Number, T::Tuple)::Bool
    A = [T...]
    return __arelessthan(x, A)
end

@inline function __arelessthan(x::Number, a::Number)::Bool
    A = [a]
    return __arelessthan(x, A)
end

@inline function __arelessthan(x::Number, a::Number, b::Number...)::Bool
    A = [a, b...]
    return __arelessthan(x, A)
end
