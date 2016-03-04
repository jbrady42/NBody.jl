
include("nb/nb.jl")

function simple_integrator_main(	)
	dt = 0.01
	dt_stats  = 0.1
	dt_output = 0.1
	time_end  = 0.1

	# method = NB.forward_step
	# method = NB.leapfrog_step
	# method = NB.rk2_step
	# method = NB.rk4_step
	# method = NB.yo6_step
	# method = NB.yo8_step

	# method = NB.ms2_step
	# method = NB.ms4_step
	# method = NB.ms4pc_step

	method = NB.hermite_step

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
	# show(body)
end

function basic_test()
	b = NB.read_body()
	print(b)
end

simple_integrator_main()
# basic_test()
