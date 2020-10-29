<h1 align="center">
    ComputabilityTheory.jl
</h1>

[![Code Style: Blue][code-style-img]][code-style-url] [![Build Status](https://travis-ci.com/jakewilliami/ComputabilityTheory.jl.svg?branch=master)](https://travis-ci.com/jakewilliami/ComputabilityTheory.jl) ![Project Status](https://img.shields.io/badge/status-maturing-green)


This is a minimal package for a pure Julia implementation of tools used in [Computability Theory](https://en.wikipedia.org/wiki/Computability_theory).  This is the science involving mathematical models of what it means to compute.  This naturally progresses to the idea of complexity: how much memory is used in computing?  How long will it take?  Does it halt?

## Examples

```julia
julia> using ComputabilityTheory

julia> pair_tuple(5,7) # code pair of natural numbers as a natural number
83

julia> π(83) # code a natural number into a 2-tuple
(5, 7)

julia> π(83, 2, algebraic) # use algebraic method of depairing rather than search (much faster)
(5, 7)

julia> π(83, 2, 1) # code a natural number into a 2-tuple and get the the number in the tuple indexed by 1 (index starting from zero)
7

julia> cℤ(-10) # code integer as a natural number
19

julia> cℤ((-1,2)) # cℤ pairs the code of each
16

julia> cℤ⁻¹(19)
-10

julia> Sequence(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535).instructions
(328, 4, 531, 4, 5, 0, 14)

julia> Instruction((3, (1, 2))).I
58

julia> Programme(121).length
1

julia> Programme(121).instructions
1-element Array{Tuple{BigInt,BigInt},1}:
 (4, 0)

julia> show_programme(121)
0    halt

julia> run_goto_programme(363183787614755732766753446033240)
(1, 0)

julia> run_goto_programme(363183787614755732766753446033240, Register(0, 0, 0 ,0))
(1, 0, 0, 0)

julia> show_programme(rand(GoToProgramme), 3) # a reasonably small random programme with 3 lines
0    R3 := R3 + 1
1    if R0 = 0 goto 1
2    halt
```

[code-style-img]: https://img.shields.io/badge/code%20style-blue-4495d1.svg
[code-style-url]: https://github.com/invenia/BlueStyle
