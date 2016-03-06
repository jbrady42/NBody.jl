
# include("nb/nb.jl")
push!(LOAD_PATH, pwd())

import NB

function nbody_main()
	dt = 0.0001
	dt_stats  = 10
	dt_output = 10
	time_end  = 10

	# method = NB.forward_step
	# method = NB.rk2_step
	method = NB.rk4_step

	info = """
	dt: $dt
	dt_stats: $dt_stats
	dt_output: $dt_output
	dt_end: $time_end
	method: $method

	"""
	write(STDERR, info)
	
	@time nb = NB.read_nbody()
	# print(nb)
	@time NB.evolve(nb, dt, time_end, dt_output, dt_stats, method)
end

# simple_integrator_main()
# basic_test()
nbody_main()
