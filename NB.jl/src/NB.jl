__precompile__()

module NB
	include("body.jl")
	include("nbody.jl")
	include("integrators.jl")

	export evolve , read_nbody
end
