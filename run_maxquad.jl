using StructuredProximalOperators
using CompositeProblems
using StructuredSolvers
using DataStructures
using PGFPlotsX
using Random
using LinearAlgebra
using Distributions

using StructNewtonExperiments
using JLD2
using SparseArrays


function main()
    pb = quadmaxquadAL()
    n = problem_dimension(pb)
    pbname = "maxquadAL"

    x0 = Float64[2, 3]
    xstar = Float64[0, 0]
    F_opt = 0.0
    M_opt = PlaneParabola()


    optparams = OptimizerParams(iterations_limit = 100, time_limit = 5, trace_length = 100)

    optparams_PG = optparams
    optparams_Newton = optparams
    optparams_precomp = OptimizerParams(iterations_limit = 5, time_limit = 1, show_trace=false)

    #
    ### First exact solve
    #
    # optimizer = PartlySmoothOptimizer(manifold_update = ManNewton())
    # optimizer = ProximalGradient()
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext_point)

    M_opt = PlaneParabola()
    F_opt = 0.0

    #
    ### Running algorithms
    #
    optimizer_to_trace = OrderedDict{Optimizer,Any}()

    optimizer = ProximalGradient(backtracking=false)
    initial_state = ProximalGradientState(optimizer, x0, pb.regularizer; γ = 0.05)

    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext_point, state=initial_state)
    optimizer_to_trace[optimizer] = trace

    optimizer = ProximalGradient(extrapolation = AcceleratedProxGrad(), backtracking=false)
    initial_state = ProximalGradientState(optimizer, x0, pb.regularizer; γ = 0.05)

    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext_point, state=initial_state)
    optimizer_to_trace[optimizer] = trace


    ## Alternating
    whPG = WholespaceProximalGradient(backtracking=false, γ_init=0.05)
    # optimizer = PartlySmoothOptimizer(wholespace_update = whPG, manifold_update = ManTruncatedNewton())
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext_point)
    # optimizer_to_trace[optimizer] = trace

    optimizer = PartlySmoothOptimizer(wholespace_update = whPG, manifold_update = ManNewton())
    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext_point)
    optimizer_to_trace[optimizer] = trace

    # ## Two Phase

    # optimizer = PartlySmoothOptimizer(wholespace_update = whPG, manifold_update = ManTruncatedNewton(), update_selector=TwoPhaseTargetSelector(M_opt))
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext_point)
    # optimizer_to_trace[optimizer] = trace

    # optimizer = PartlySmoothOptimizer(wholespace_update = whPG,
    #     manifold_update = ManTruncatedNewton(truncationstrat = StructuredSolvers.Newton(
    #         ε_CGres = 1e-16,
    #         ν_CGreductionfactor = 1e-13
    #     )),
    #     update_selector=TwoPhaseTargetSelector(M_opt)
    # )
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext_point)
    # optimizer_to_trace[optimizer] = trace

    #
    ### Build numerical exps data
    #
    # fig = process_expe_data(optimdata, pbname, M_opt, F_opt)

    fig = process_expe_data(optimizer_to_trace, pbname, M_opt, F_opt)

    fig = plot_iterates(pb, optimizer_to_trace)

    pgfsave("numexps_output/$pbname-iterates.tex", fig, include_preamble=false)
    pgfsave("numexps_output/$pbname-iterates.pdf", fig)

    println("Returning...")
    return fig
end

main()
