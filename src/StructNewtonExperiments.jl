module StructNewtonExperiments

using StructuredProximalOperators
using CompositeProblems
using StructuredSolvers
using Colors
using PGFPlotsX
using LaTeXStrings
using DataStructures
using DelimitedFiles
using JLD2
using Random
using Distributions

using Contour

include("getters.jl")
include("table.jl")

include("plot_base.jl")
include("plot_utils.jl")
include("plot_highlevel.jl")
include("plot_iterates.jl")
include("algorithms.jl")

const osext = [
    # (key = :x, getvalue = s -> s.x),
    (key = :M, getvalue = s -> s.M)
]

# function get_pointrepr(s)
#     # @show s
#     return StructuredSolvers.get_repr(s.x)
# end
get_pointrepr(s) = deepcopy(StructuredSolvers.get_repr(s.x))

const osext_point = [
    (key = :x, getvalue = get_pointrepr),
    (key = :M, getvalue = s -> s.M)
]
const NUMEXPS_OUTDIR_DEFAULT = joinpath(dirname(pathof(StructNewtonExperiments)), "..", "numexps_output")

function __init__()
    !isdir(NUMEXPS_OUTDIR_DEFAULT) && mkdir(NUMEXPS_OUTDIR_DEFAULT)
    return
end


function process_expe_data(optimdata, pbname, M_opt, F_opt, NUMEXPS_OUTDIR)
    println("Building table...")
    build_table(optimdata, pbname, [1e-3, 1e-9], M_opt = M_opt, F_opt = F_opt, NUMEXPS_OUTDIR=NUMEXPS_OUTDIR)

    ### Build TikzAxis and final plotting object
    println("Building figures...")
    fig = TikzDocument()

    # push!(fig, TikzPicture(plot_subopt_time(optimdata)))
    # push!(fig, TikzPicture(plot_tangentres_time(optimdata)))
    # push!(fig, TikzPicture(plot_structure_time(optimdata, M_opt)))

    # push!(fig, TikzPicture(plot_subopt_iteration(optimdata)))
    # push!(fig, TikzPicture(plot_tangentres_iteration(optimdata)))
    # push!(fig, TikzPicture(plot_structure_iteration(optimdata, M_opt)))

    # println("Building output tex $(pbname) ...")
    # PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname).tex"), fig)
    # println("Building output pdf $(pbname) ...")
    # PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname).pdf"), fig)

    ## Build individual figures
    PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-subopt-time.tex"), plot_subopt_time(optimdata, subopt_levels=[1e-3, 1e-9]), include_preamble=false)
    try
        PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-subopt-time.pdf"), plot_subopt_time(optimdata, subopt_levels=[1e-3, 1e-9]), include_preamble=false)
    catch
        @warn "Could not build $(joinpath(NUMEXPS_OUTDIR, "$(pbname)-subopt-time.pdf"))"
    end

    # PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-relsubopt-time.tex"), plot_relsubopt_time(optimdata), include_preamble=false)
    # PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-relsubopt-time.pdf"), plot_relsubopt_time(optimdata), include_preamble=false)

    PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-structure-iteration.tex"), plot_structure_iteration(optimdata, M_opt), include_preamble=false)
    try
        PGFPlotsX.pgfsave(joinpath(NUMEXPS_OUTDIR, "$(pbname)-structure-iteration.pdf"), plot_structure_iteration(optimdata, M_opt), include_preamble=false)
    catch
        @warn "Could not build $(joinpath(NUMEXPS_OUTDIR, "$(pbname)-structure-iteration.pdf"))"
    end
    return fig
end


include("experiments/expe_logistic.jl")
include("experiments/expe_maxquad.jl")
include("experiments/expe_tracenorm.jl")

function run_expes(;NUMEXPS_OUTDIR = NUMEXPS_OUTDIR_DEFAULT)
    run_expe_logistic(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    run_expe_maxquad(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    run_expe_tracenorm(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    return nothing
end

export osext, osext_point
export process_expe_data
export NUMEXPS_OUTDIR
export run_algorithms
export plot_iterates

export run_expe_logistic, run_expe_maxquad, run_expe_tracenorm
export run_expes

end # module
