__precompile__()

module NBody
  include("body.jl")
  include("nbody.jl")
  include("integrators.jl")

  export EvolveArgs, evolve, read_nbody
end
