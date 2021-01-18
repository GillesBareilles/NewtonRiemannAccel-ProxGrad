# StructNewtonExperiments

This project contains the code used to produce the numerical result of the paper [Newton Acceleration on Manifolds identified by Proximal-Gradient Methods](https://arxiv.org/abs/2012.12936). It has three main package dependencies:
- [`StructuredProximalOperators.jl`](https://github.com/GillesBareilles/StructuredProximalOperators.jl) implements some nonsmooth functions, their proximity operator, and Riemannian gradients and Hessians;
- [`CompositeProblems.jl`](https://github.com/GillesBareilles/CompositeProblems.jl) implements some additive composite problems, and provide oracles for the smooth and nonsmooth part;
- [`StructuredSover.jl`](https://github.com/GillesBareilles/StructuredSolvers.jl) implements solvers designed to tackle composite problems, such as the (Accelerated) Proximal Gradient, or the methods of the above mentioned paper.

### Running numerical experiments

The numerical experiments may be run as follows:
- first add the three above packages by running
```julia
using Pkg
Pkg.add(url="https://github.com/GillesBareilles/StructuredProximalOperators.jl", rev="v0.1")
Pkg.add(url="https://github.com/GillesBareilles/CompositeProblems.jl", rev="v0.1")
Pkg.add(url="https://github.com/GillesBareilles/StructuredSolvers.jl", rev="v0.1")
Pkg.add(url="https://github.com/GillesBareilles/NewtonRiemannAccel-ProxGrad", rev="v0.1")
```

- then by running the following commands:
```julia
using StructNewtonExperiments

# running each problem separately
run_expe_maxquad(NUMEXPS_OUTDIR = ".");
run_expe_logistic(NUMEXPS_OUTDIR = ".");
run_expe_tracenorm(NUMEXPS_OUTDIR = ".");

# running all problems
run_expes(NUMEXPS_OUTDIR = ".");
```


Alternatively, the numerical experiments may be run using docker as follows:
1. First, build the julia image and install packages: run from a folder containing the `Dockerfile`
```bash
sudo docker build -t julia_structnewton .
```
2. Then run the docker image by executing the following command, where /ABSOLUTE/PATH/TO/OUTDIR is the absolute path to the directory where the numerical experiments files will be written:
```bash
docker run --mount type=bind,source=/ABSOLUTE/PATH/TO/OUTDIR,target=/root/numexps_output -it julia_structnewton
```
3. In the opened julia REPL, run the following
```julia
using StructNewtonExperiments
run_expes(NUMEXPS_OUTDIR="/root/numexps_output/")
```
