# StructNewtonExperiments

This project contains all code relevant to running the numerical experiments and producing tables and plots relative to the structured solvers implemented in `StructuredSolvers.jl`, and problems from `CompositeProblems.jl`, `StructuredProximalOperators.jl`.

Each problem is dealt with a dedicated file. Running it will produce the output tables, tex and figures in folder `numexps_output`:
- Logistic-ionosphere: `run_FI_logit.jl`;
- Tracenorm: `run_solvers_tracenorm_nxn.jl`;
- AL's function: `run_solvers_maxquad`.

### Running numerical experiments


### TODOs:

- [x] check time logging in algorithm implementation -> why are there slow downs in the subopt vs time curve for PG?
- [x] work out 2d example
- [x] run solvers a first time to avoid precompilation delays in logs
- [x] save trace from solvers before plotting
- [ ] review packages dependencies
