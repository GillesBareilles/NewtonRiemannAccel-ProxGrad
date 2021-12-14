function simplify_trace(trace)
    return map(os -> (;
                      :time => os.time,
                      :it => os.it,
                      :F_x => os.f_x + os.g_x,
                      :M => os.additionalinfo.M,
                      ),
               trace)
end


function run_tracenorm_perfprof(; NUMEXPS_OUTDIR = NUMEXPS_OUTDIR_DEFAULT)
    perfprof_data = OrderedDict{Tuple{String, String}, Float64}()
    npb = 20
    CG_maxiter = 150

    runalgs = true

    filename = "tracenorm-perfprof"

    if runalgs || !isfile(joinpath(NUMEXPS_OUTDIR, filename*"jld"))
        optimizer_APG = ProximalGradient(extrapolation = AcceleratedProxGrad())
        optimizer_ManTN = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton())
        optparams_PG = OptimizerParams(iterations_limit = 1e13, trace_length = 1e3, time_limit = 8)
        optparams_Newton = OptimizerParams(iterations_limit = 1e3, trace_length = 1e3, time_limit = 8)

        pb_to_optimdata = OrderedDict()
        for i in 1:npb
            println("** Problem $i")

            # Generate problem
            Random.seed!(1649 + i)
            n1, n2, m, sparsity = 10, 12, 60, 0.8
            pb = get_tracenorm_MLE(n1 = n1, n2 = n2, m = m, sparsity = sparsity)
            pbname = "tracenorm-$(n1)x$(n2)-$i"

            # Generate staring point
            Random.seed!(1234 + i)
            x0 = rand(Normal(), n1, n2)
            optimizer = ProximalGradient(extrapolation=AcceleratedProxGrad())
            trace = optimize!(pb, optimizer, x0, optparams =  OptimizerParams(iterations_limit = 3e3, time_limit = Inf), optimstate_extensions = osext_point)

            x0 = last(trace).additionalinfo.x
            M0 = last(trace).additionalinfo.M
            println("starting point:" , x0)

            # Find minimizer
            trace = optimize!(pb, optimizer_APG, x0, optparams = optparams_PG, optimstate_extensions = osext_point)
            optparams = OptimizerParams(iterations_limit = 1e3, trace_length = 1e3, time_limit = 25)
            trace = optimize!(pb, optimizer_ManTN, last(trace).additionalinfo.x, optparams = optparams, optimstate_extensions = osext_point)

            M_opt = last(trace).additionalinfo.M
            F_opt = last(trace).f_x + last(trace).g_x

            #
            ### Running algorithms
            #
            optparams_precomp = OptimizerParams(iterations_limit = 4, time_limit = 1, show_trace=false)

            optimdata = OrderedDict{Optimizer,Any}()

            optimizer = ProximalGradient()
            trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
            trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
            optimdata[optimizer] = simplify_trace(trace)

            optimizer = ProximalGradient(extrapolation = AcceleratedProxGrad())
            trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
            trace = optimize!(pb, optimizer, x0, optparams = optparams_PG, optimstate_extensions = osext)
            optimdata[optimizer] = simplify_trace(trace)

            optimizer = PartlySmoothOptimizer(manifold_update = ManNewton(CG_maxiter=CG_maxiter, linesearch=Armijo()))
            trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
            trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
            optimdata[optimizer] = simplify_trace(trace)

            optimizer = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton(CG_maxiter=CG_maxiter, linesearch=Armijo()))
            trace = optimize!(pb, optimizer, x0, optparams = optparams_precomp, optimstate_extensions = osext)
            trace = optimize!(pb, optimizer, x0, optparams = optparams_Newton, optimstate_extensions = osext)
            optimdata[optimizer] = simplify_trace(trace)


            pb_to_optimdata[pbname] = (;
                                       optimdata,
                                       F_opt,
                                       M_opt
                                       )
        end

        println("Writing data...")
        @save joinpath(NUMEXPS_OUTDIR, filename*".jld") pb_to_optimdata
        println("Done.")
    end

    @load joinpath(NUMEXPS_OUTDIR, filename*".jld") pb_to_optimdata

    perfplotdata = OrderedDict{Tuple{String, String}, Float64}()

    for (pb, data) in pb_to_optimdata
        F_opt = data.F_opt
        M_opt = data.M_opt
        optimdata = data.optimdata

        for (optimizer, trace) in optimdata
            relit = findfirst(os -> os.F_x - F_opt < 1e-9, trace)

            # perfplotdata[(pb, get_legendname(optimizer))] = isnothing(relit) ? Inf : trace[relit].time
            perfplotdata[(get_legendname(optimizer), pb)] = isnothing(relit) ? Inf : trace[relit].time
        end
    end

    fig = plot_perfprofile(perfplotdata)
    savefig(TikzDocument(fig), joinpath(NUMEXPS_OUTDIR, filename))
    return nothing
end
