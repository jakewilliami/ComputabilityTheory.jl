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
@doc raw"""
Truncated negation: an operator that acts like subtraction without going to negatives.

This can be written in the REPL as `\dotminus<tab>`.

Examples:
```julia
julia> 6 ∸ 3
3

julia> 3 ∸ 1
2

julia> 10 ∸ 12
0

julia> 1 ∸ 2
0
```
"""
∸(x::Number, y::Number) = x - y ≥ 0 ? x - y : 0

##############################################################################

pairntuple_error = "This function is only defined for natural numbers.  Use cℤ."

@doc raw"""
```julia
pair_tuple(x::Integer, y::Integer)
pair_tuple(x::Integer, y::Integer, z::Integer...)
pair_tuple(t::Tuple)
```

The pairing function is a function that uniquely maps any number of integer inputs to a single integer:

```math
\left(k_1,k_2\right) \mapsto \frac{1}{2}\left(k_1+k_2\right)\left(k_1+k_2+1\right)+k_1\\
\mathbb{N}^2 \to \mathbb{N}
```

This concept can also be generalised to take integers ``x_0`` to ``x_{n-1}`` so that

```math
(x_0, x_1, \ldots, x_{n - 1}) \mapsto \left\langle\left\langle x_0, \ldots, x_{n - 2}\right\rangle, x_{n - 1}\right\rangle\\
\mathbb{N}^n \to \mathbb{N}
```

and returns their "pair".

As this maps every combination of integers to a single output, this number gets massive very fast.  As such, `pair_tuple` will return a `BigInt`.

To depair the tuple, see ``\pi``.

For more information, see [https://en.m.wikipedia.org/wiki/Pairing_function](https://en.m.wikipedia.org/wiki/Pairing_function).

!!! note

    There are two variations to this process **which will change the output**:
      - As per the visualisation in the link above, the first number given is found along the ``x`` axis, and the second along the ``y`` axis.  **In this implementation, it is the other way around.**  This can easily by modified, however, by adding ``k_1`` at the end instead of ``k_2``.
      - The other variation is which direction of nesting we decide on for more than 2 inputs.  The alternative (which **we do not use in this implementation**) is
        ```math
        \left(x_0, x_1, \ldots, x_{n - 1}\right) \mapsto \left\langle x_0, \left\langle x_1, \ldots, x_{n - 1}\right\rangle\right\rangle
        ```

---

### Examples

```julia
julia> pair_tuple(5,7) # code pair of natural numbers as a natural number
83
```
"""
pair_tuple(x::Integer, y::Integer) = x < 0 || y < 0 ? throw(error("$pairntuple_error")) : big(x) + binomial(big(x)+big(y)+1, 2)
pair_tuple(x::Integer, y::Integer, z::Integer...) = pair_tuple(pair_tuple(x, y), z...)
pair_tuple(t::Tuple) = pair_tuple(t...)

##############################################################################

# Singleton type with a descriptive name, and use that as the second argument
# In the algebraic unpairing function
# struct Algebra end
# const algebraic = Algebra()

# The brute-force unpairing function:
# Takes in integer m (that is, a natural number)
# and integer n (that is, m ⟼ <x1, ..., xn>)
# returns x1, ..., xn.
# Alternatively, given
@generated function _π_brute_force(::Val{n}, m::Integer) where {n}
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
_π_brute_force(m::Integer, n::Integer) = _π_brute_force(Val(n), m)
# default to n=2
_π_brute_force(m::Integer) = _π_brute_force(m, 2)
# Defining a selection function that obtains
# the kth element in the tuple obtained using π;
# e.g., π(83, 2, 0) = 5 = \pi_2^0(83)
# note: by convention this is indexed from zero,
# which is why we need to offset it by one.
_π_brute_force(m::Integer, n::Integer, k::Integer) = _π_brute_force(m, n)[k+1]

# Algebraic unpairing function:
# Unpairing if n=2 (base case):
function _π(m::Integer)
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
function _π(m::Integer, n::Integer)
    iszero(n) && return nothing
    isone(n) && return m
    
    appended_tuple = _π(m)
    
    while n != 2
        appended_tuple = (_π(appended_tuple[1])..., appended_tuple[2:end]...)
        n -= 1
    end
    
    return appended_tuple
end
# Selection function taking input k and outputting the
# kth element in the tuple obtained by the algebraic π
_π(m::Integer, n::Integer, k::Integer) = _π(m, n)[k+1]

@doc raw"""
```julia
π(m::Integer..., algebraic::Bool = true)
```

The depairing function.  Takes in an integer and find its unique pair of integers such that those integers paired is exactly the function input:
    
```math
\pi(m) \mapsto \left\langle m_0, m_1\right\rangle\\
\mathbb{N} \to \mathbb{N}^2
```

Setting boolean `algebraic` flag to `false` calls a brute force search method which is extremely slow for large ``n`` (see the `n` parameter below) but exists for completeness.  That is,

```math
\pi(m) := \left(\mu x\leq m\right)\left(\exists y\leq m\right)m=\left\langle x,y\right\rangle\\
\pi_0\left(\left\langle x_0,x_1\right\rangle\right) = x_0\\
\pi_1\left(\left\langle x_0,x_1\right\rangle\right) = x_1
```
    
This function also takes in a parameter ``n``:
    
```math
\pi(m, n) \mapsto \left\langle m_1, \ldots, m_n\right\rangle\\
\mathbb{N} \to \mathbb{N}^n
```

This function may also take in a third parameter ``k`` so that
    
```math
\pi(m, n, k) \equiv \pi_k^n \mapsto \left\langle m_1, \ldots, m_n\right\rangle \mapsto m_k\quad\text{where }1\leq k\leq n
```
    
!!! note
    
    See the note from documentation on `pair_tuple`.  This function may not do exactly what you expect.

---

### Examples

```julia
julia> π(83, algebraic = false) # code a natural number into a 2-tuple
(5, 7)

julia> π(83, 2, algebraic = true) # use algebraic method of depairing rather than search (much faster)
(5, 7)

julia> π(83, 2, 1, algebraic = false) # code a natural number into a 2-tuple and get the the number in the tuple indexed by 1 (index starting from zero)
7
```
"""
π(m::Integer...; algebraic::Bool = true) =
    algebraic ? _π(m...) : _π_brute_force(m...)
depair(m::Integer...; algebraic::Bool = true) = π(m..., algebraic = algebraic)

##############################################################################

@doc raw"""
```julia
cℤ(z::Integer)
cℤ(z::Integer, w::Integer...)
```

This function uniquely maps an integer to a natural number.  The output is a BigInt.  This function can be written in the REPL by `c\bbZ<tab>`.
    
```math
z \mapsto c\mathbb{Z}(z)\\
z, w, \ldots \mapsto c\mathbb{Z}(z), c\mathbb{Z}(w), \ldots\\
\mathbb{Z} \to \mathbb{N}
```

---

```julia
cℤ(zs::AbstractArray{<:Integer})
```

Given an array of integers, `cℤ` will convert every element of the array into natrual numbers.

---

```julia
cℤ(r::NTuple{N, Integer})
```

Given a tuple, `cℤ` will convert ever element of the tuple into natural numbers, and pair the result:

```math
\left(z, w\right) \mapsto c\mathbb{Z}\left(\left\langle z, w\right\rangle\right)\\
\mathbb{Z}^2 \to \mathbb{N}
```
```math
\left(z_1, \ldots, z_n\right) \mapsto c\mathbb{Z}\left(\left\langle z_1\right\rangle\right), \ldots, c\mathbb{Z}\left(\left\langle z_n\right\rangle\right)\\
\mathbb{Z}^n \to \mathbb{N}
```

---

### Examples

```julia
julia> cℤ(-10) # code integer as a natural number
19

julia> cℤ((-1,2)) # cℤ pairs the code of each
16
```
"""
cℤ(z::Integer) = z >= 0 ? 2 * big(z) : (2 * abs(big(z))) - 1
cℤ(z::Integer, w::Integer...) = cℤ(z), cℤ(w...)...
cℤ(zs::AbstractArray{<:Integer}) = cℤ.(zs)
cℤ(r::NTuple{N, Integer}) where {N} = pair_tuple(cℤ.(r)...)

##############################################################################

cℤ⁻¹_error = "Invalid input. We have only defined this function for natural numbers.  Why are you even using it?"

@doc raw"""
```julia
cℤ⁻¹(n::Integer)
```

The inverse of `cℤ⁻¹`.  Uniquely maps natural numbers to integers.  This function can be written in the REPL by `c\bbZ<tab>\^1<tab>`.

---

```julia
cℤ⁻¹(zs::AbstractArray{<:Integer})
```

Given an array of integers, `cℤ⁻¹` will convert every element of the array into integers.

---

### Examples

```julia
julia> cℤ⁻¹(19)
-10
```
"""
cℤ⁻¹(n::Integer) = n < 0 ? throw(error("$cℤ⁻¹_error")) : (iseven(n) ? Int(big(n) / 2) : -Int(floor(big(n) / 2) + 1))
cℤ⁻¹(ns::AbstractArray{<:Integer}) = cℤ⁻¹.(ns)
