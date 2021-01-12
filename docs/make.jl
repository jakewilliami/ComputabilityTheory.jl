include(joinpath(dirname(@__DIR__), "src", "ComputabilityTheory.jl"))
using Documenter, .ComputabilityTheory

Documenter.makedocs(
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

deploydocs(;
    repo  =  "github.com/jakewilliami/ComputabilityTheory.jl.git",
)

# deploydocs(
#     target = "build",
#     repo   = "github.com/jakewilliami/ComputabilityTheory.jl.git",
#     branch = "gh-pages",
#     devbranch = "master",
#     devurl = "dev",
#     versions = ["stable" => "v^", "v#.#.#", "dev" => "dev"],
#     push_preview    = false
# )
