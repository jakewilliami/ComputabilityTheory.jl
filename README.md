<h1 align="center">
    ComputabilityTheory.jl
</h1>

[![Code Style: Blue][code-style-img]][code-style-url] [![Build Status](https://travis-ci.com/jakewilliami/CodingTheory.jl.svg?branch=master)](https://travis-ci.com/jakewilliami/CodingTheory.jl) ![Project Status](https://img.shields.io/badge/status-maturing-green)


## Description
This is a minimal package for a pure Julia implementation of tools used in [Computability Theory](https://en.wikipedia.org/wiki/Computability_theory).  This is the science involving mathematical models of what it means to compute.  This naturally progresses to the idea of complexity: how much memory is used in computing?  How long will it take?  Does it halt?

## Examples

```julia
julia> pair_tuple(5,7) # code pair of natural numbers as a natural number
83

julia> pair_tuple(5,7,20)
5439

julia> π(83, 2) # code a natural number into a 2-tuple
(5, 7)

julia> π(83)
(5, 7)

julia> π(83, 2, algebraic)
(5, 7)

julia> π(83, 3, algebraic) # code a natural number into a 3-tuple
(2, 0, 7)

julia> π(83, 2, 1) # code a natural number into a 2-tuple and get the the number in the tuple indexed by 1 (index starting from zero)
7

julia> cℤ(-10) # code integer as a natural number
19

julia> cℤ((-1,2))
16

julia> cℤ(-1, 2)
(1, 4)

julia> cℤ⁻¹(19)
-10

julia> Sequence(121).length
1

julia> Sequence(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535).instructions
(328, 4, 531, 4, 5, 0, 14)

julia> Sequence(121).instructions
(14,)

julia>  Instruction(7).instruction
(1, 2)

julia>  Instruction(14).instruction
(4, 0)

julia>  Instruction(58).instruction
(3, (1, 2))

julia> Instruction((3, (1, 2))).I
58

julia> Programme(121).length
1

julia> Programme(121).instructions
1-element Array{Tuple{BigInt,BigInt},1}:
 (4, 0)

julia> show_programme(121)
0    halt

julia> show_programme(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535)
0    if R1 = 0 goto 5
1    R1 := R1 - 1
2    if R1 = 0 goto 6
3    R1 := R1 - 1
4    goto 0
5    R0 := R0 + 1
6    halt
```

[code-style-img]: https://img.shields.io/badge/code%20style-blue-4495d1.svg
[code-style-url]: https://github.com/invenia/BlueStyle
