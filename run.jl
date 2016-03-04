
include("body.jl")

function simple_integrator_main(	)
	dt = 0.00001
	dt_stats = 10
	dt_output = 10
	time_end = 10

	# method = NB.forward_step
	method = NB.leapfrog_step

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
