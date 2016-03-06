__precompile__()

module NB
	include("body.jl")
	include("nbody.jl")
	include("integrators.jl")
	# include("2_body_int.jl")
end
