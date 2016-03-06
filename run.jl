
# include("nb/nb.jl")
push!(LOAD_PATH, pwd())

using NB

function nbody_main()
	soften_len = 0.1
	dt = 0.001				# Time step
	dt_stats  = 2			# Output states every
	dt_output = 2		# Output data every 
	time_end  = 2			# Duration
	init_out = false	# Output initial conditions
	x_info = false			# Output extra debug info

	# method = NB.forward_step
	# method = NB.leapfrog_step
	# method = NB.rk2_step
	method = NB.rk4_step

	info = """
	soft_len: $soften_len
	dt: $dt
	dt_stats: $dt_stats
	dt_output: $dt_output
	dt_end: $time_end
	method: $method

	"""
	write(STDERR, info)
	
	nb = read_nbody()
	nb.soften_len = soften_len
	# print(nb)
	evolve(nb, method, soften_len, dt, time_end, dt_output, dt_stats, init_out, x_info)
end

# simple_integrator_main()
# basic_test()
nbody_main()
