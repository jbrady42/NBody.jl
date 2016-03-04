
include("nb/nb.jl")

function simple_integrator_main(	)
	dt = 0.01
	dt_stats  = 0.2
	dt_output = 0.2
	time_end  = 0.2

	# method = NB.forward_step
	# method = NB.leapfrog_step
	# method = NB.rk2_step
	# method = NB.rk4_step
	# method = NB.yo6_step
	method = NB.yo8_step

	info = """
	dt: $dt
	dt_stats: $dt_stats
	dt_output: $dt_output
	dt_end: $time_end
	method: $method

	"""

	write(STDERR, info)
	
	body = NB.read_body()
	NB.evolve(body, dt, time_end, dt_output, dt_stats, method)
end

function basic_test()
	b = NB.read_body()
	print(b)
end

simple_integrator_main()
# basic_test()
