__precompile__(true)

module NBody
  include("nbody/body.jl")
  include("nbody/nbody.jl")
  include("nbody/evolve.jl")
  include("nbody/integrators.jl")

  export EvolveArgs,
          evolve,
          read_nbody
end
