#!/usr/bin/env julia
# run the script via julia mdistmain.jl divseq --order maximin from the command line
using Pkg
const LibDir = joinpath(dirname(@__FILE__), "..")
Pkg.activate(LibDir); # So that we use right versions of packages below...
using ArgParse

function exiterror(str)
    printstyled(str, color = :red)
    exit(-1)
end

function parse_args(args)

    # initialize the settings (the description is for the help screen)
    s = ArgParseSettings(description = "mdist - multi (string) distance calculator")

    @add_arg_table s begin
        "divseq"
            help = "order files in a sequence by diversity"
            action = :command
    end

    @add_arg_table s["divseq"] begin
       "--order"
            help = "diversity ordering method (default: maximin)"
    end

    ArgParse.parse_args(args, s) # the result is a Dict{String,Any}
end

pargs = parse_args(ARGS)

using StringDistances

q(args) = get(args, "q", 2)
intval(v::AbstractString) = parse(Int, v)
intval(v::Integer) = v
function safeget(dict, k, default)
    if !haskey(dict, k) || dict[k] == nothing
        return default
    else
        return intval(dict[k])
    end
end
lvl(args, lo, default, hi) = clamp(safeget(args, "compression-level", default), lo, hi)

######################## diversity_sequence.jl #############################3

function ranks(ds::Array{Int})
    rankvec = zeros(Int, length(ds))
    for i in ds
        rankvec[ds[i]] = i
    end
    rankvec
end

function find_maximin_sequence(dm::Array{Float64,2})
    # Setup
    N = size(dm, 1)
    @assert N >= 2
    selected = Int[]
    unselected = Set(1:N)

    # Add the two elements with largest distance
    maxdist, idx = findmax(dm)
    push!(selected, idx[1])
    push!(selected, idx[2])
    pop!(unselected, idx[1])
    pop!(unselected, idx[2])

    mindistances = vec(minimum(view(dm, :, selected), dims=2))

    while length(selected) < min(1000000, N)
        # Find the unselected one with maximum min distance to selected ones
        distval, idx = findmax(mindistances) # maxi-min
        push!(selected, idx)
        pop!(unselected, idx)

        # Now we need to update mindistances since we have a new selected one
        mindistances[idx] = 0.0 # Distance to itself is 0.0 so...
        for i in unselected
            if dm[i, idx] < mindistances[i]
                mindistances[i] = dm[i, idx]
            end
        end
    end

    selected # Return the order in which we selected them
end

using CSV
function MaxiMinDiversitySequence()
    dm = CSV.read("dm.csv"; header=false, delim=' ', types=fill(Float64,7))
    selectionorder = find_maximin_sequence(dm)
    selectionorder
end

##########################################################################

function main(pargs)

    if pargs["%COMMAND%"] == "divseq"
        orderarg = lowercase(pargs["divseq"]["order"])
        if in(orderarg, ["maximin", "maxi-min"])
            seq = MaxiMinDiversitySequence()
        end
        rankvec = ranks(seq)
        ma = zeros(Float64, length(rankvec), 1)
        ma[:, 1] = rankvec
        println(ma)
    end

    exit(0)
end

main(pargs)