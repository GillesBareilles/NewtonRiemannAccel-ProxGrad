function run_expe_maxquad(; NUMEXPS_OUTDIR = NUMEXPS_OUTDIR_DEFAULT)
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
    ### Running algorithms
    #
    optimizer_to_trace = OrderedDict{Optimizer,Any}()

    # Proximal gradient
    optimizer = ProximalGradient(backtracking=false)
    initial_state = ProximalGradientState(optimizer, x0, pb.regularizer; γ = 0.05)

    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext_point) #First precompilation run
    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext_point, state=initial_state)
    optimizer_to_trace[optimizer] = trace

    # Accelerated Proximal Gradient
    optimizer = ProximalGradient(extrapolation = AcceleratedProxGrad(), backtracking=false)
    initial_state = ProximalGradientState(optimizer, x0, pb.regularizer; γ = 0.05)

    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext_point) #First precompilation run
    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext_point, state=initial_state)
    optimizer_to_trace[optimizer] = trace

    ## Alternating Newton
    whPG = WholespaceProximalGradient(backtracking=false, γ_init=0.05)
    optimizer = PartlySmoothOptimizer(wholespace_update = whPG, manifold_update = ManNewton())

    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext_point) #First precompilation run
    trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext_point)
    optimizer_to_trace[optimizer] = trace

    #
    ### Build numerical exps data
    #
    # fig = process_expe_data(optimizer_to_trace, pbname, M_opt, F_opt, NUMEXPS_OUTDIR)
    println("Building table...")
    build_table(optimizer_to_trace, pbname, [1e-3, 1e-9], M_opt = M_opt, F_opt = F_opt, NUMEXPS_OUTDIR=NUMEXPS_OUTDIR)

    # plot iterates
    fig = plot_iterates(pb, optimizer_to_trace)
    PGFPlotsX.savetex(joinpath(NUMEXPS_OUTDIR, "$pbname-iterates.tex"), fig, include_preamble=false)
    try
        pgfsave(joinpath(NUMEXPS_OUTDIR, "$pbname-iterates.pdf"), fig)
    catch
        @warn "Could not build $(joinpath(NUMEXPS_OUTDIR, "$pbname-iterates.pdf"))"
    end

    return nothing
end
