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

using PlotsOptim
import PlotsOptim.get_legendname

include("getters.jl")
include("table.jl")

# include("plot_base.jl")
# include("plot_utils.jl")
# include("plot_highlevel.jl")
include("plot_iterates.jl")
include("algorithms.jl")

const osext = [
    (key = :M, getvalue = s -> s.M)
]

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



get_legendname(o::ProximalGradient{StructuredSolvers.VanillaProxGrad}) = "Proximal Gradient"
get_legendname(o::ProximalGradient{StructuredSolvers.AcceleratedProxGrad}) = "Accel. Proximal Gradient"
function get_legendname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManTruncatedNewton{StructuredSolvers.TruncatedNewton},
    },
    )
    return "Alt. Truncated Newton"
end
function get_legendname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManTruncatedNewton{StructuredSolvers.Newton},
    },
    )
    return "Alt. Newton"
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
    optimizer_to_trace = optimdata

    # Time to suboptimality
    get_time(obj, trace) = [os.time for os in trace]
    get_subopt(obj, trace) = [os.f_x + os.g_x - F_opt for os in trace]

    # fig = plot_curves(optimdata,
    #                   get_time,
    #                   get_subopt,
    #                   horizontallines = [1e-3, 1e-9],
    #                   xlabel = "time (s)",
    #                   ylabel = L"$F(x_k)-F(x^\star)$",
    #                   nmarks = 20,
    #                   simplifylines = false
    #                   )
    # savefig(TikzDocument(fig), joinpath(NUMEXPS_OUTDIR, "$(pbname)-subopt-time-extensive"))

    fig = plot_curves(optimdata,
                      get_time,
                      get_subopt,
                      horizontallines = [1e-3, 1e-9],
                      xlabel = "time (s)",
                      ylabel = L"$F(x_k)-F(x^\star)$",
                      nmarks = 0,
                      simplifylines = true,
                      simplificationfactor = 1e-2,
                      includelegend = false
                      )
    savefig(TikzDocument(fig), joinpath(NUMEXPS_OUTDIR, "$(pbname)-subopt-time"))

    ## Iteration to manifold dimension
    get_iteration(obj, trace) = [Float64(os.it) for os in trace]
    get_mandim(obj, trace) = [manifold_dimension(os.additionalinfo.M) for os in trace]

    # fig = plot_curves(optimdata,
    #                   get_iteration,
    #                   get_mandim,
    #                   xlabel = "iterations",
    #                   ylabel = latexstring("dim(\$M_k\$)"),
    #                   xmode = "log",
    #                   ymode = "normal",
    #                   nmarks = 0,
    #                   simplifylines = false
    #                   )
    # savefig(TikzDocument(fig), joinpath(NUMEXPS_OUTDIR, "$(pbname)-structure-iteration-extensive"))

    fig = plot_curves(optimdata,
                      get_iteration,
                      get_mandim,
                      xlabel = "iterations",
                      ylabel = latexstring("dim(\$M_k\$)"),
                      xmode = "log",
                      ymode = "normal",
                      nmarks = 0,
                      simplifylines = true,
                      simplificationfactor = 1e-2,
                      includelegend = false
                      )

    savefig(TikzDocument(fig), joinpath(NUMEXPS_OUTDIR, "$(pbname)-structure-iteration"))
    return fig
end


include("experiments/expe_logistic.jl")
include("experiments/expe_maxquad.jl")
include("experiments/expe_tracenorm.jl")
include("experiments/expe_tracenorm_perfprofile.jl")

function run_expes(;NUMEXPS_OUTDIR = NUMEXPS_OUTDIR_DEFAULT)
    run_expe_logistic(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    run_expe_maxquad(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    run_expe_tracenorm(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    run_tracenorm_perfprof(NUMEXPS_OUTDIR = NUMEXPS_OUTDIR);
    return nothing
end

export osext, osext_point
export process_expe_data
export NUMEXPS_OUTDIR
export run_algorithms
export plot_iterates

export run_expe_logistic, run_expe_maxquad, run_expe_tracenorm, run_tracenorm_perfprof
export run_expes

end # module
