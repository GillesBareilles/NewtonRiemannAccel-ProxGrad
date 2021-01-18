FROM julia:1.5.3

RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/GillesBareilles/StructuredProximalOperators.jl", rev="v0.1")'
RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/GillesBareilles/CompositeProblems.jl", rev="v0.1")'
RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/GillesBareilles/StructuredSolvers.jl", rev="v0.1")'
RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/GillesBareilles/NewtonRiemannAccel-ProxGrad")'
RUN julia -e 'using StructNewtonExperiments'

RUN mkdir /root/numexps_output
