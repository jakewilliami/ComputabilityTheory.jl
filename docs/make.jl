include(joinpath(dirname(@__DIR__), "src", "ComputabilityTheory.jl"))
using Documenter, .ComputabilityTheory

Documenter.makedocs(
    root = ".",
    source = "src",
    build = "build",
    clean = true,
    doctest = true,
    modules = Module[ComputabilityTheory],
    repo = "",
    highlightsig = true,
    sitename = "ComputabilityTheory Documentation",
    expandfirst = [],
    pages = [
        "Index" => "index.md",
    ]
)
