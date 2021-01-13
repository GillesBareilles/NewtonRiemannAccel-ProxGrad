# StructNewtonExperiments

This project contains the code used to produce the numerical result of the paper [Newton Acceleration on Manifolds identified by Proximal-Gradient Methods](https://arxiv.org/abs/2012.12936). It has three main package dependencies:
- [`StructuredProximalOperators.jl`](https://github.com/GillesBareilles/StructuredProximalOperators.jl) implements some nonsmooth functions, their proximity operator, and Riemannian gradients and Hessians;
- [`CompositeProblems.jl`](https://github.com/GillesBareilles/CompositeProblems.jl) implements some additive composite problems, and provide oracles for the smooth and nonsmooth part;
- [`StructuredSover.jl`](https://github.com/GillesBareilles/StructuredSolvers.jl) implements solvers designed to tackle composite problems, such as the (Accelerated) Proximal Gradient, or the methods of the above mentioned paper.

### Running numerical experiments

The numerical experiments may be run as follows:
- first add the three above packages by running
```julia
pkg> add https://github.com/GillesBareilles/StructuredProximalOperators.jl
pkg> add https://github.com/GillesBareilles/CompositeProblems.jl
pkg> add https://github.com/GillesBareilles/StructuredSolvers.jl
pkg> add https://github.com/GillesBareilles/NewtonRiemannAccel-ProxGrad
```

- then by running the following commands:
```julia
using StructNewtonExperiments

# running each problem separately
run_expe_maxquad(NUMEXPS_OUTDIR = ".");
run_expe_logistic(NUMEXPS_OUTDIR = ".");
run_expe_tracenorm(NUMEXPS_OUTDIR = ".");

# running all problems
```


<!-- Alternatively, the numerical experiments may be run near automatically using docker as follows: -->

