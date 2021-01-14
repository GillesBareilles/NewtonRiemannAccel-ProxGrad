
function build_table(optimdata, pbname, subopt_levels; M_opt = nothing, F_opt = nothing)
    #
    ### Indicators
    #
    get_linetolerance(o, data, ind; kwargs...) = kwargs[:tol]

    # :it, :time, :f_x, :g_x, :norm_step, :norm_minsubgradient_tangent, :norm_minsubgradient_normal,
    # :ncalls_f, :ncalls_g, :ncalls_∇f, :ncalls_proxg, :ncalls_∇²fh,
    indname_to_getter = OrderedDict(
        "algo" => get_algname,
        "tol" => get_linetolerance,
        # "F_k-F*/(F_1-F*)" => get_relsubopt,
        "F-F*" => get_subopt,
        # "time" => get_time,
        # "tangent res" => get_tangentres,
        # "normal comp" => get_normcomp,
        # "gradf" => get_ncalls_∇f,
        "proxgrad" => get_ncalls_proxg,
        "gradF" => get_ncalls_gradₘF,
        "HessF" => get_ncalls_HessₘF,
        "f" => get_ncalls_f,
        "g" => get_ncalls_g,
        # "retr" => get_ncalls_retr,
        # "nit CG" => get_nit_CG,
        # "nit man ls" => get_nit_manls,
        # "it." => get_it,
    )
    # "time", "tangent res", "normal res", "ncalls prox", L"ncalls $\nabla f$", "nit prox ls", "nit man ls", "nit CG"


    ### Build table from optim data
    table_lines = []
    # criterion(optimizer, states) = [ get_relsubopt(optimizer, states, i, F_opt=F_opt) for i in 1:length(states)]
    criterion(optimizer, states) = [ get_subopt(optimizer, states, i, F_opt=F_opt) for i in 1:length(states)]

    push!(table_lines, [indname for indname in keys(indname_to_getter)])

    for (optimizer, data) in optimdata
        for subotp_level in subopt_levels
            ind = findfirst(elt -> elt < subotp_level, criterion(optimizer, data))
            push!(
                table_lines,
                [
                    get_ind(optimizer, data, ind; F_opt = F_opt, tol=subotp_level) for get_ind in values(indname_to_getter)
                ],
            )
        end
    end

    ### Write table to file
    open(joinpath(NUMEXPS_OUTDIR, "$(pbname).csv"), "w") do io
        return writedlm(io, table_lines, "&")
    end

    return
end
