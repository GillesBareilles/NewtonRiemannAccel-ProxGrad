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

function main()
    n1, n2, m, sparsity = 10, 12, 60, 0.8
    pb = get_tracenorm_MLE(n1 = n1, n2 = n2, m = m, sparsity = sparsity)

    pbname = "tracenorm-$(n1)x$(n2)"

    optparams_PG = OptimizerParams(iterations_limit = 1e13, trace_length = 1e3, time_limit = 8)
    optparams_Newton = OptimizerParams(iterations_limit = 1e3, trace_length = 1e3, time_limit = 8)

    ####

    Random.seed!(1234)
    x0 = rand(Normal(), n1, n2)
    optimizer = ProximalGradient(extrapolation=AcceleratedProxGrad())
    trace = optimize!(pb, optimizer, x0, optparams =  OptimizerParams(iterations_limit = 1e3, time_limit = 0.5), optimstate_extensions = osext_point)

    x0 = last(trace).additionalinfo.x
    M0 = last(trace).additionalinfo.M
    println("starting point:" , x0)
    @show M0
    #####


    #
    ### Solving the problem
    #
    # x0 = [1.5741614423780308 -3.503012233257623 -0.12615119699155522; -5.828891835208343 13.745680044592309 0.3735519744285379; 7.844342499238895 -9.304372784510043 -1.613414615310625]
    # x0 = [2.0635970828915253 -3.634815675448217 -0.28102644892387935; -8.000535347628777 14.092126575790118 1.0895353830815027; 6.501372193612408 -11.451503666671803 -0.8853751325056449]
    # x0 = [0.20622541175583128 -0.36324490075752436 -0.028084369018482602; -0.7995328157492636 1.408295009991721 0.1088826757513013; 0.6497142898836532 -1.1444050504743855 -0.0884799584993819]
    # x0 = [0.20622541163127106 -0.3632449010031875 -0.02808436894413518; -0.7995328153575622 1.4082950111048222 0.10888267547547961; 0.6497142887831582 -1.1444050500011604 -0.08847995816872328]
    xprecisesolvestart = [0.212302497857745 -0.07590950565460453 0.04167559745907928 0.21435373668058605 0.3802137166124494 0.032250637803974004 0.10853508104408018 -0.4224892647273791 0.12090022116586663 -0.24968118468375014 0.3078018368938669 -0.4153561464056329; 0.5617975853887945 -0.1303445252884291 0.002204581071099663 0.12291113533244573 0.38222745490223625 -0.14228442380822773 0.12180525209652446 -0.2818783208379729 0.06595269070892541 -0.1467119830949226 0.15180563104581313 -0.6506947308786737; -0.993151625224906 0.013678159523408048 0.43137654767608713 1.0353255475359608 0.20048698446292418 0.9001895831203668 -0.1692105654084363 -1.5338647039798972 0.3602669425246777 -0.27562847562383014 0.7215336059889446 0.35492169924137; -1.3265742877291462 0.2728260547603242 0.22288796436565517 0.19479041516181023 -0.842043020794441 0.5441754186064885 -0.3251965751096127 0.08406830417619984 -0.11264311330055185 0.29217972303087575 -0.15194764721839607 1.3009305308896009; 1.8742391669692995 -0.3263682840332992 -0.34140345287710494 -0.4911992970022772 0.8901667067347079 -0.8835079517427025 0.36870434230282895 0.27769745815803526 0.031234984941079288 -0.2826118049646925 -0.0484093557583046 -1.6914436044580188; 0.44849739713971853 -0.2119150470900752 0.22157836761096789 0.695373167411122 0.7453008200030552 0.21299994442391162 0.07981305186668623 -1.2621042482649234 0.3184185781547522 -0.43411628967504096 0.613711925598169 -0.9377115262090844; 0.5452600705298128 -0.18716323398640086 0.10477444942290572 0.42904019796911574 0.6997249960015662 0.03644835058602679 0.13568377743512838 -0.8753773195438007 0.25241407419774975 -0.41091149787149805 0.4893382294088165 -0.9054247473017338; -1.5072973983577513 0.25619120214904445 0.3199550886469758 0.4696848987022766 -0.7199340370557261 0.7478046869110051 -0.32953071500152115 -0.33277024235899383 -0.005221292303113995 0.2092026641977808 0.05823824692361658 1.3144268329167401; -0.006458506312139825 -0.3175281116881232 0.4104802272943328 1.4297817786080464 1.3296707005971964 0.8087022301421374 0.11952893212945662 -2.563031208804524 0.6914491010259323 -0.7270675813789061 1.3225484694021594 -0.942507084038553; 0.6810093863453547 0.041321731576300647 -0.42648724304348135 -1.1093494740204008 -0.49153579989699453 -0.8256394022447162 0.04666179030670532 1.6991967547146123 -0.3663270808740904 0.47165098121296334 -0.9299622484797992 0.060745723811045385]

    optimizer_APG = ProximalGradient(extrapolation = AcceleratedProxGrad())
    optimizer_PG = ProximalGradient(extrapolation = VanillaProxGrad())
    optimizer_ManTN = PartlySmoothOptimizer(manifold_update = ManTruncatedNewton())

    trace = optimize!(pb, optimizer_APG, xprecisesolvestart, optparams = optparams_PG, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_APG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_APG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_APG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_PG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)

    @show typeof(last(trace).additionalinfo.x)
    optparams = OptimizerParams(iterations_limit = 1e3, trace_length = 1e3, time_limit = 25)
    trace = optimize!(pb, optimizer_ManTN, last(trace).additionalinfo.x, optparams = optparams, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_PG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)
    # trace = optimize!(pb, optimizer_PG, last(trace).additionalinfo.x, optparams = optparams_PG, optimstate_extensions = osext_point)


    M_opt = last(trace).additionalinfo.M
    F_opt = last(trace).f_x + last(trace).g_x
    x_opt = last(trace).additionalinfo.x

    # @show x_opt
    # @assert false

    #
    ### Run numerical experiments, or recover logged data
    #
    # if !isfile(joinpath(NUMEXPS_OUTDIR, "$pbname.jld"))
    optimdata = run_algorithms(pbname, pb, x0, optparams_PG, optparams_Newton, M_opt, F_opt, osext; CG_maxiter=150)
    # end

    println("Opening trace logs file: ", joinpath(NUMEXPS_OUTDIR, "$pbname.jld"))
    @load joinpath(NUMEXPS_OUTDIR, "$pbname.jld") optimdata M_opt F_opt
    # d = load(joinpath(NUMEXPS_OUTDIR, "$pbname.jld"))

    # optimdata = d["optimdata"]
    # M_opt = d["M_opt"]
    # F_opt = d["F_opt"]

    #
    ### Build numerical exps data
    #
    fig = process_expe_data(optimdata, pbname, M_opt, F_opt)

    println("Returning...")
    return fig
end

main()
