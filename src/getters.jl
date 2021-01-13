#
### Algorithm names
#

dispname(o::ProximalGradient{StructuredSolvers.VanillaProxGrad}) = "Proximal Gradient"
dispname(o::ProximalGradient{StructuredSolvers.AcceleratedProxGrad}) = "Accel. Proximal Gradient"
dispname(o::ProximalGradient{StructuredSolvers.MFISTA}) = "MAPG"
function dispname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManNewtonCG,
    },
)
    return "Alt. - Newton (CG)"
end
function dispname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManTruncatedNewton{StructuredSolvers.TruncatedNewton},
    },
)
    return "Alt. Truncated Newton"
end
function dispname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManTruncatedNewton{StructuredSolvers.Newton},
    },
)
    return "Alt. Newton"
end
function dispname(
    ::PartlySmoothOptimizer{
        AlternatingUpdateSelector,
        WholespaceProximalGradient,
        ManifoldGradient,
    },
) where {T}
    return "Alt. - Grad descent"
end
function dispname(
    ::PartlySmoothOptimizer{
        ConstantManifoldSelector{T},
        WholespaceProximalGradient,
        ManTruncatedNewton{StructuredSolvers.TruncatedNewton},
    },
) where {T}
    return "Cst. - Newton (tn)"
end
function dispname(
    ::PartlySmoothOptimizer{
        ConstantManifoldSelector{T},
        WholespaceProximalGradient,
        ManNewtonCG,
    },
) where {T}
    return "Cst - NewtonCG"
end

dispname(::PartlySmoothOptimizer{TwoPhaseTargetSelector,WholespaceProximalGradient,ManTruncatedNewton{Newton}}) = "TwoPhase - Newton"
dispname(::PartlySmoothOptimizer{TwoPhaseTargetSelector,WholespaceProximalGradient,ManTruncatedNewton{TruncatedNewton}}) = "TwoPhase - TN"



function dispname(optimizer)
    @show typeof(optimizer)
    @show optimizer
    @assert false
    return
end


#
### Getters from trace
#
get_algname(o, data, ind; kwargs...) = dispname(o)

get_relsubopt(o, data, ::Nothing; kwargs...) = ""
function get_relsubopt(o, data, ind; kwargs...)
    Flim = kwargs[:F_opt]
    Finit = first(data).f_x + first(data).g_x
    return (data[ind].f_x + data[ind].g_x - Flim) / (Finit - Flim)
end

get_subopt(o, data, ::Nothing; kwargs...) = ""
function get_subopt(o, data, ind; kwargs...)
    Flim = kwargs[:F_opt]
    return data[ind].f_x + data[ind].g_x - Flim
end

get_time(o, data, ::Nothing; kwargs...) = ""
get_time(o, data, ind; kwargs...) = data[ind].time

get_tangentres(o, data, ::Nothing; kwargs...) = ""
get_tangentres(o, data, ind; kwargs...) = data[ind].norm_minsubgradient_tangent

get_normcomp(o, data, ::Nothing; kwargs...) = ""
get_normcomp(o, data, ind; kwargs...) = data[ind].norm_minsubgradient_normal

get_ncalls_f(o, data, ::Nothing; kwargs...) = ""
get_ncalls_f(o, data, ind; kwargs...) = data[ind].ncalls_f

get_ncalls_g(o, data, ::Nothing; kwargs...) = ""
get_ncalls_g(o, data, ind; kwargs...) = data[ind].ncalls_g

get_ncalls_∇f(o, data, ::Nothing; kwargs...) = ""
get_ncalls_∇f(o, data, ind; kwargs...) = data[ind].ncalls_∇f

get_ncalls_proxg(o, data, ::Nothing; kwargs...) = ""
get_ncalls_proxg(o, data, ind; kwargs...) = data[ind].ncalls_proxg


## Manifold update values
get_ncalls_gradₘF(o, data, ::Nothing; kwargs...) = ""
get_ncalls_gradₘF(::ProximalGradient, data, ind; kwargs...) = ""
get_ncalls_gradₘF(::ProximalGradient, data, ::Nothing; kwargs...) = ""
get_ncalls_gradₘF(o, data, ind; kwargs...) = data[ind].ncalls_gradₘF

get_ncalls_HessₘF(o, data, ::Nothing; kwargs...) = ""
get_ncalls_HessₘF(::ProximalGradient, data, ind; kwargs...) = ""
get_ncalls_HessₘF(::ProximalGradient, data, ::Nothing; kwargs...) = ""
get_ncalls_HessₘF(o, data, ind; kwargs...) = data[ind].ncalls_HessₘF

# get_ncalls_retr(o, data, ::Nothing; kwargs...) = ""
# get_ncalls_retr(o, data, ind; kwargs...) = data[ind].ncalls_retr
# get_ncalls_retr(::ProximalGradient, data, ind) = ""

# get_nit_CG(o, data, ::Nothing; kwargs...) = ""
# get_nit_CG(o, data, ind; kwargs...) = data[ind].niter_CG
# get_nit_CG(::ProximalGradient, data, ind) = ""

# get_nit_manls(o, data, ::Nothing; kwargs...) = ""
# get_nit_manls(o, data, ind; kwargs...) = -1
# get_nit_manls(::ProximalGradient, data, ind) = ""

get_it(o, data, ::Nothing; kwargs...) = ""
get_it(o, data, ind; kwargs...) = data[ind].it
