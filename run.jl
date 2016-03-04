
include("body.jl")

function simple_integrator_main(	)
	dt = 0.00001
	dt_stats = 2.5
	dt_output = 2.5
	time_end = 2.5
	
	body = NB.read_body()
	NB.evolve(body, dt, time_end, dt_output, dt_stats)
end

function basic_test()
	b = NB.read_body()
	print(b)
end

simple_integrator_main()
# basic_test()
