__precompile__()

module NBody
  include("nbody/body.jl")
  include("nbody/nbody.jl")
  include("nbody/integrators.jl")

  export EvolveArgs, evolve, read_nbody
end
