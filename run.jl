
# include("nb/nb.jl")
push!(LOAD_PATH, pwd())

import NB

function nbody_main()
	dt = 0.00005				# Time step
	dt_stats  = 2			# Output states every
	dt_output = 10		# Output data every 
	time_end  = 2			# Duration
	init_out = false	# Output initial conditions
	x_info = false			# Output extra debug info

	# method = NB.forward_step
	# method = NB.leapfrog_step
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
	
	nb = NB.read_nbody()
	# print(nb)
	NB.evolve(nb, method, dt, time_end, dt_output, dt_stats, init_out, x_info)
end

# simple_integrator_main()
# basic_test()
nbody_main()
