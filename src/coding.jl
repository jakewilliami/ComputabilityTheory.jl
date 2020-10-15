#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
    =#
    
# setprecision(100000)

import Base.π # needed in order to redefine it

##############################################################################

# Dot minus (monus):
# i.e., truncated negation
∸(x::Number, y::Number) = x - y ≥ 0 ? x - y : 0

##############################################################################

# The pairing function:
# Takes integers x1 to x_n so that
# <x1, x2, ..., xn> = <<x_1, ..., xn-1>, x_n>
# And returns their pair.
pairntuple_error = "This function is only defined for natural numbers.  Use cℤ."
pair_tuple(x::Integer, y::Integer)::BigInt = x < 0 || y < 0 ? throw(error("$pairntuple_error")) : big(x) + binomial(big(x)+big(y)+1, 2)
pair_tuple(x::Integer, y::Integer, z::Integer...)::BigInt = pair_tuple(pair_tuple(x, y), z...)
pair_tuple(t::Tuple) = pair_tuple(t...)

##############################################################################

# Singleton type with a descriptive name, and use that as the second argument
# In the algebraic unpairing function
struct Algebra end
const algebraic = Algebra()

# The brute-force unpairing function:
# Takes in integer m (that is, a natural number)
# and integer n (that is, m ⟼ <x1, ..., xn>)
# returns x1, ..., xn.
# Alternatively, given
@generated function π(::Val{n}, m::Integer) where {n}
    quote
        iszero(n) && return nothing
        isone(n) && return m
        
        # promote type to BigInt
        # we probably do not need n to be a big int
        m = big(m)
        
        @inbounds @fastmath Base.Cartesian.@nloops $n i d -> 0:m begin
            if isequal(pair_tuple((Base.Cartesian.@ntuple $n i)...), m)
                return Base.Cartesian.@ntuple $n i
            end
        end
    end
end
# Ensuring the function is more readible
# (i.e., switch the inputs) such that
# π(m, n) ⟼ <x1, ..., xn> = m
π(m::Integer, n::Integer) = π(Val(n), m)
# default to n=2
π(m::Integer) = π(m, 2)
# Defining a selection function that obtains
# the kth element in the tuple obtained using π;
# e.g., π(83, 2, 0) = 5 = \pi_2^0(83)
# note: by convention this is indexed from zero,
# which is why we need to offset it by one.
π(m::Integer, n::Integer, k::Integer) = π(m, n)[k+1]

# Algebraic unpairing function:
# Unpairing if n=2 (base case):
function π(m::Integer, ::Algebra)
    m = big(m)
    
    w = (Base.isqrt(8*m + 1) - 1) ÷ 2
    t = (w^2 + w) ÷ 2
    x = m - t
    y = w - x
        
    if ! isequal(pair_tuple(x, y), m)
        throw(error("The provided m = $m is not equal to ⟨ $x, $y ⟩, and so there has been an error in the calculation."))
    end
    
    return BigInt(x), BigInt(y)
end
# Generalised case:
function π(m::Integer, n::Integer, ::Algebra)
    iszero(n) && return nothing
    isone(n) && return m
    
    appended_tuple = π(m, algebraic)
    
    while n != 2
        appended_tuple = (π(appended_tuple[1], algebraic)..., appended_tuple[2:end]...)
        n -= 1
    end
    
    return appended_tuple
end
# Selection function taking input k and outputting the
# kth element in the tuple obtained by the algebraic π
π(m::Integer, n::Integer, k::Integer, ::Algebra) = π(m, n, algebraic)[k+1]

##############################################################################

# coding the cℤ: ℤ ⟶ ℕ
# e.g., with a single input
# z ⟼ cℤ(z)
cℤ(z::Integer)::Integer = z >= 0 ? 2 * big(z) : (2 * abs(big(z))) - 1
# e.g., with multiple inputs
# z, w, ... ⟼ cℤ(z), cℤ(w), ...
cℤ(z::Integer, w::Integer...) = cℤ(z), cℤ(w...)...
cℤ(zs::AbstractArray{<:Integer}) = cℤ.(zs)
# e.g., with a tuple, ℤ^2 ⟼ ℕ (integer pair to nat)
# (z, w) ⟼ cℤ(<z, w>)
cℤ(r::Tuple{Integer,Integer})::Integer = pair_tuple(cℤ.(r)...)

##############################################################################

# Converts natural numbers to integers
# ℕ ∋ cℤ⁻¹(n) ⟼ z ∈ ℤ
cℤ⁻¹_error = "Invalid input. We have only defined this function for natural numbers.  Why are you even using it?"
cℤ⁻¹(n::Integer) = n < 0 ? throw(error("$cℤ⁻¹_error")) : (iseven(n) ? Int(big(n) / 2) : -Int(floor(big(n) / 2) + 1))
cℤ⁻¹(ns::AbstractArray{<:Integer}) = cℤ⁻¹.(ns)
