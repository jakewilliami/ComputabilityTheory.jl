#=
Check that all elements in a list are less than a given x.
=#
@inline function anylessthan(x::Number, A::AbstractArray)::Bool
    @inbounds for a in A
        a < x && return true
    end
    
    return false
end

@inline function anylessthan(x::Number, T::Tuple)::Bool
    A = [T...]
    return arelessthan(x, A)
end

@inline function anylessthan(x::Number, a::Number...)::Bool
    A = [a...]
    return arelessthan(x, A)
end

#=
Get extrema values from a list of tuples

e.g.
julia> extrema((4,0), (1,2), (3,2), (5,2))
((1, 5), (0, 2))

WARNING: This function is entirely for machines.jl, and should not be used elsewhere
See also extrema from MultidimensionalTools.jl
=#
function extrema_tuple(A::AbstractArray{T}) where T <: Tuple
    min_i, min_j = A[1][1], A[1][2][1]
    max_i, max_j = A[1][1], A[1][2][1]
    
    for t in A
        i, j = t
        isequal(i, 2) && continue # ignore goto instructions, as they don't give us register information
        
        if j isa Tuple
            # we only care about one level of nested Tuple
            # and we only care about the first element in it
            min_i = min_i > i ? i : min_i
            min_j = min_j > j[1] ? j[1] : min_j
            max_i = max_i < i ? i : max_i
            max_j = max_j < j[1] ? j[1] : max_j
        else
            min_i = min_i > i ? i : min_i
            min_j = min_j > j ? j : min_j
            max_i = max_i < i ? i : max_i
            max_j = max_j < j ? j : max_j
        end
    end
    
    return (min_i, max_i), (min_j, max_j)
end

extrema_tuple(T::Tuple...) = extrema_tuple([T...])
