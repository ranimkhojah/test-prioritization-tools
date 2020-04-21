#!/usr/bin/env julia
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

#######################################################################3

# A Diversity sequencer is used to select a sequence of objects with high diversity.
abstract type DiversitySequencer end

# A div sequencer can either be updateable or not
isupdateable(ds::DiversitySequencer) = false # Default is to not be updateable

abstract type UpdateableDiversitySequencer <: DiversitySequencer end
isupdateable(ds::UpdateableDiversitySequencer) = true

struct DiversitySequence{A}
    maxsize::Int
    objects::Array{String} # Objects in the sequence, unordered
    strings::Vector{String} # Strings for each object, unordered
    order::Vector{Int}   # Permutation vector, i.e. the order in which objects come in the sequence
end

function ranks(ds::Array{Int})
    rankvec = zeros(Int, length(ds))
    for i in ds
        rankvec[ds[i]] = i
    end
    rankvec
end

# Given a distance matrix, calculate the maxi-min diversity sequence, i.e. add the object
# with the largest (maxi) minimum (min) distance to the objects already in the sequence.
# This means we start from the two objects that have the largest distance between them
# and then grow greedily from there.
function find_maximin_sequence(dm::Array{Float64,2})
    # Setup
    N = size(dm, 1)
    @assert N >= 2
    selected = Int[]
    unselected = Set(1:N)

    # Add the two elements with largest distance
    maxdist, idx = findmax(dm)
    println("max distance is: ", maxdist, "and index is : " ,idx)
    push!(selected, idx[1])
    push!(selected, idx[2])
    pop!(unselected, idx[1])
    pop!(unselected, idx[2])


    mindistances = vec(minimum(view(dm, :, selected), dims=2))
    while length(selected) < min(1000000000, N)
        # Find the unselected one with maximum min distance to selected ones
        distval, idx = findmax(mindistances) # maxi-min
        push!(selected, idx)
        @isdefined unselected
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
using DataFrames
using DelimitedFiles
function MaxiMinDiversitySequence()
    # strings = String[string(o) for o in objects]
    # df = CSV.read("d2v_dm.csv")
    # dm = Matrix{Float64}(df)
    dm = readdlm("d2v_dm.csv",';', Float64)
    selectionorder = find_maximin_sequence(dm)
    selectionorder
end

# function MaxiMinDiversitySequence(distance, objects::Vector{O}, strings::Vector{String}, dm::Array{Float64,2}) where O
#     selectionorder = find_maximin_sequence(dm)
#     DiversitySequence(length(objects), objects, strings, selectionorder)
# end

##########################################################################

function main(pargs)


    if pargs["%COMMAND%"] == "divseq"
        orderarg = lowercase(pargs["divseq"]["order"])
        if in(orderarg, ["maximin", "maxi-min"])
            seq = MaxiMinDiversitySequence()
        end
        # Save rank order info to a csv file
        rankvec = ranks(seq)
        ma = zeros(Float64, length(rankvec), 1)
        ma[:, 1] = rankvec
        println(ma)
    end

    exit(0)
end

main(pargs)