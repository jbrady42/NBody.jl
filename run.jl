
include("body.jl")

# b = NB.Body(1, [0.5, 0, 0], [0, 0.7, 0])
function simple_integrator()
	dt = 0.01 	
	num_steps = 100

	body = NB.read_body()

	for i in 1:num_steps
		r1 = mapreduce(x->x^2, +, body.pos)
		r = r1 * sqrt(r1) # we want r^(2/3)
		acc = map(x -> -body.mass * x/r, body.pos)
		body.pos += body.vel * dt
		body.vel += acc * dt
		# println(r)
		# println(acc)
	end
	show(body)
end

function basic_test()
	b = NB.read_body()
	print(b)
end

simple_integrator()
# basic_test()