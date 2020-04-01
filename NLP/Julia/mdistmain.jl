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
        "--distance", "-d"
            help = "distance function(s) to use"
            default = "levenshtein"
        "-q"
            help = "q-gram length"
            arg_type = Int
            required = false
            default = 2
        "--compression-level", "-l"
            help = "compression level"
            required = false
        "--modifier"
            help = "Distance modifier"
            arg_type = String
            required = false
        "--verbose"
            help = "verbose during processing"
            action = :store_true
        "--recurse", "-r"
            help = "recurse into sub directories when selecting files"
            action = :store_true
        "--file-extensions"
            help = "file extensions to include when selecting files"
            default = ".txt"
            required = false
        "distfuncs"
            help = "list all available distance functions"
            action = :command
        "distances"
            help = "calculate distances of a set of files in a dir"
            action = :command
        "dist"
            help = "calculate distance between two files"
            action = :command
        "query"
            help = "find the most similar and distant files given a query file"
            action = :command
        "divseq"
            help = "order files in a sequence by diversity"
            action = :command
        "license"
            help = "print the license"
            action = :command
        "version"
            help = "print the version info"
            action = :command
    end

    @add_arg_table s["distances"] begin
       "--precalc"
            help = "precalculate to speed up distance calculations (default: false)"
            action = :store_true
       "dir"
            help = "directory with files to calculate distances of"
            required = true
    end

    @add_arg_table s["dist"] begin
        "file1"
            help = "first file"
            required = true
        "file2"
            help = "second file"
            required = true
    end

    @add_arg_table s["divseq"] begin
       "--order"
            help = "diversity ordering method (default: maximin)"
    end

    @add_arg_table s["query"] begin
        "-n"
            help = "How many most similar/distant files to list"
            arg_type = Int
            required = false
            default = 7
        "file"
            help = "file to compare"
            required = true
        "dir"
            help = "set of files to compare to"
            required = true
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

# Given a q-gram length q return the string distance to use. Note that
# many of them don't care about q.
DistancesFn = Dict(
    # Edit dist funcs don't care about q or level (l)
    "levenshtein" => (a) -> Levenshtein(),
    "jaro" => (a) -> Jaro(),

    "ratcliffobershelp" => (a) -> RatcliffObershelp(),
    "ratcliff-obershelp" => (a) -> RatcliffObershelp(),

    # Qgram dist funcs only care about q but not level (l)
    "qgram" => (a) -> QGram(q(a)),
    "cosine" => (a) -> Cosine(q(a)),
    "jaccard" => (a) -> Jaccard(q(a)),
    "overlap" => (a) -> Overlap(q(a)),
    "sorensendice" => (a) -> SorensenDice(q(a)),

    # NCD dist funcs. Some care about level (l) but none about q.
    # Note that NCD compressors cannot be modified with Winkler, Partial et al.
    "ncd-zlib" => (a) -> NCD(ZlibCompressor),
    "ncd-gzip" => (a) -> NCD(GzipCompressor),
    "ncd-deflate" => (a) -> NCD(DeflateCompressor),
    "ncd-xz" => (a) -> NCD(XzCompressor(; level = lvl(a, 1, 6, 9))),
    "ncd-lz4" => (a) -> NCD(LZ4Compressor(; compressionlevel = lvl(a, -1, 2, 12))),
    "ncd-zstd" => (a) -> NCD(ZstdCompressor(; level = lvl(a, 1, 3, 19))),
    "ncd-bzip2" => (a) -> NCD(Bzip2Compressor(; workfactor = lvl(a, 0, 30, 250))),
    "ncd" => (a) -> NCD(Bzip2Compressor), # We use bzip2 as the default since it seems to handle shorter strings better
)

QgramDistances = String["qgram", "cosine", "jaccard", "overlap", "sorensendice"]

function can_be_modified(d)
    typeof(d) != NCD
end

DistanceModifierFn = Dict(
    "winkler" => (d) -> Winkler(d),
    "partial" => (d) -> Partial(d),
    "tokensort" => (d) -> TokenSort(d),
    "tokenset" => (d) -> TokenSet(d),
    "tokenmax" => (d) -> TokenMax(d),
)


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

function MaxiMinDiversitySequence()
    # strings = String[string(o) for o in objects]
    dm = [[0.0,0.037164927137295245,0.06436646608913388,0.11827519920645646,0.0230950127605295,0.05654347067387411,0.04834697778216679,0.06329613496789532,0.04800363648458372]  [0.037164927137295245,0.0,0.07476942100418138,0.13790057335349792,0.05541111213820493,0.06766722528298785,0.06586571537695796,0.06997387298300806,0.05299042988408298] [0.06436646608913388,0.07476942100418138,0.0,0.10888755709527442,0.07007123141767413,0.05097689359263424,0.04825717214099068,0.028360892583500608,0.10409321097372792]  [0.11827519920645646,0.13790057335349792,0.10888755709527442,0.0,0.11066580153994188,0.06172960764889979,0.1209207433331072,0.06914035275640729,0.08757077519288736] [0.0230950127605295,0.05541111213820493,0.07007123141767413,0.11066580153994188,0.0,0.06838751351220984,0.05791685050480688,0.061138111338976064,0.05743408209109735] [0.05654347067387411,0.06766722528298785,0.05097689359263424,0.06172960764889979,0.06838751351220984,0.0,0.07931201493484485,0.03915309478666751,0.04262418018805081]  [0.04834697778216679,0.06586571537695796,0.04825717214099068,0.1209207433331072,0.05791685050480688,0.07931201493484485,0.0,0.057927031918735605,0.10014381885590573]  [0.06329613496789532,0.06997387298300806,0.028360892583500608,0.06914035275640729,0.061138111338976064,0.03915309478666751,0.057927031918735605,0.0,0.07278611356784026]  [0.04800363648458372,0.05299042988408298,0.10409321097372792,0.08757077519288736,0.05743408209109735,0.04262418018805081,0.10014381885590573,0.07278611356784026,0.0]]
    selectionorder = find_maximin_sequence(dm)
    selectionorder
end

# function MaxiMinDiversitySequence(distance, objects::Vector{O}, strings::Vector{String}, dm::Array{Float64,2}) where O
#     selectionorder = find_maximin_sequence(dm)
#     DiversitySequence(length(objects), objects, strings, selectionorder)
# end

##########################################################################
function write_float_matrix_to_csv(csvfile::String, m::Matrix{Float64}, rownames::Vector{String}; cols = String[])
    open(csvfile, "w") do fh
        if length(cols) > 0
            println(fh, join(cols, ","))
        else
            println(fh, "File," * join(rownames, ","))
        end
        for i in 1:size(m, 1)
            print(fh, rownames[i])
            for j in 1:size(m, 2)
                print(fh, "," * string(m[i, j]))
            end
            if i < size(m, 1)
                print(fh, "\n")
            end
        end
    end
end

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
        # write_float_matrix_to_csv("ranking", ma; 
        #     cols = ["File", "Rank_" * pargs["divseq"]["order"]])
    end

    exit(0)
end

main(pargs)