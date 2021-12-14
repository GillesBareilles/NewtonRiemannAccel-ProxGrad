function run_algorithms(pbname, pb, x0, optparams_PG, optparams_Newton, M_opt, F_opt, osext, NUMEXPS_OUTDIR; CG_maxiter=100)
    optparams_precomp = OptimizerParams(iterations_limit = 4, time_limit = 1, show_trace=false)

    #
    ### Running algorithms
    #
    optimdata = OrderedDict{Optimizer,Any}()

    optimizer = ProximalGradient()
    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
    optimdata[optimizer] = trace

    optimizer = ProximalGradient(extrapolation = AcceleratedProxGrad())
    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
    optimdata[optimizer] = trace

    # optimizer = ProximalGradient(extrapolation = MFISTA(AcceleratedProxGrad()))
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
    # optimdata[optimizer] = trace

    # Alternating
    # optimizer = PartlySmoothOptimizer(manifold_update = ManifoldGradient())
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
    # optimdata[optimizer] = trace

    optimizer = PartlySmoothOptimizer(manifold_update = ManNewton(CG_maxiter=CG_maxiter, linesearch=Armijo()))
    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
    optimdata[optimizer] = trace

    optimizer = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton(CG_maxiter=CG_maxiter, linesearch=Armijo()))
    trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
    optimdata[optimizer] = trace

    # optimizer = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton(CG_maxiter=CG_maxiter), update_selector=TwoPhaseTargetSelector(M_opt))
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
    # optimdata[optimizer] = trace

    # optimizer = PartlySmoothOptimizer(
    #     manifold_update = ManTruncatedNewton(truncationstrat = StructuredSolvers.Newton(
    #         ε_CGres = 1e-16,
    #         ν_CGreductionfactor = 1e-13
    #     )),
    #     update_selector=TwoPhaseTargetSelector(M_opt)
    # )
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
    # trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
    # optimdata[optimizer] = trace

    # ## Adaptive manifold
    # optimizer = PartlySmoothOptimizer(manifold_update = ManifoldGradient(), update_selector=ManifoldFollowingSelector())
    # trace = optimize!(pb, optimizer, x0, optparams=optparams_Newton, optimstate_extensions=osext)
    # optimdata[optimizer] = trace

    # optimizer = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton(), update_selector=ManifoldFollowingSelector())
    # trace = optimize!(pb, optimizer, x0, optparams=optparams_Newton, optimstate_extensions=osext)
    # optimdata[optimizer] = trace



    # Constant manifold
    # x0 = project(M_opt, x0)
    # optimizer = PartlySmoothOptimizer(
    #     manifold_update = ManTruncatedNewton(),
    #     update_selector = ConstantManifoldSelector(M_opt),
    # )
    # trace = optimize!(
    #     pb,
    #     optimizer,
    #     x0,
    #     manifold = M_opt,
    #     optparams = optparams_Newton,
    #     optimstate_extensions = osext,
    # )
    # optimdata[optimizer] = trace

    println("Writing data...")
    @save joinpath(NUMEXPS_OUTDIR, "$pbname.jld") optimdata M_opt F_opt
    println("Done.")
    return optimdata, M_opt, F_opt
end
