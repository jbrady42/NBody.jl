
module NB

type Body
	mass::Float64
	pos::Vector{Float64}
	vel::Vector{Float64}
	e0

	Body(mass=0.0, pos=Vector{Float64}(3), vel=Vector{Float64}(3)) = new(mass, pos, vel, 0)	
end

######## IO ###########

import Base.show
function show(io::IO, a::Body)
	print(io, "mass: ", a.mass, "\n")
	print(io, "pos: ", join(a.pos, ", "), "\n")
	print(io, "vel: ", join(a.vel, ", "), "\n")
end

import Base.print
function print(io::IO, a::Body)
	@printf io "%24.16e\n" a.mass

	map(Array[a.pos, a.vel]) do b
		map(x-> @printf(io,"%24.16e",x), b)
		print(io, "\n")
	end
end

function read_body()
	mass = parse(Float64, readline())
	pos = map(x -> parse(Float64, x), split(readline()))
	vel = map(x -> parse(Float64, x), split(readline()))
	return Body(mass, pos, vel)
end

function write_stats(body::Body, steps, time)
	tot_energy = total_energy(body)
	s = """
	Time: $(@sprintf("%.3g", time)) , steps: $steps
	E_Kin: $(@sprintf("%.3g", kin_energy(body)))
	E_Pot: $(@sprintf("%.3g", pot_energy(body)))
	E_Tot: $(@sprintf("%.3g", total_energy(body)))
	E_Tot - E_init: $(@sprintf("%.3g", (tot_energy - body.e0)))
	(E_tot - E_init) / E_init: $(@sprintf("%.3g", (tot_energy - body.e0) / body.e0))

	"""
	write(STDERR, s)
end

#######################

function accel(body::Body)
	r2 = dot(body.pos, body.pos)
	r3 = r2 * sqrt(r2) # we want r^(2/3)
	acc = body.pos * (-body.mass / r3)
	return acc
end

####### Energy #########

function kin_energy(body::Body)
	return 0.5 * dot(body.vel, body.vel)
end

function pot_energy(body::Body)
	return -body.mass / sqrt(dot(body.pos, body.pos))
end

function total_energy(body::Body)
	return kin_energy(body) + pot_energy(body)
end

function init_energy!(body::Body)
	body.e0 = total_energy(body)
end

###### Integrators #####

function evolve(body::Body, dt, time_end, dt_output, dt_stats, integ_method::Function)
	current_time = 0
	current_step = 0
	# num_steps = round(Int, time_units / dt)

	t_stats = dt_stats - 0.5*dt
	t_checkp = dt_output - 0.5*dt
	t_end = time_end - 0.5*dt

	init_energy!(body)
	write_stats(body, current_step, current_time)

	while current_time < t_end
		# Call the integration method
		integ_method(body, dt)

		current_time += dt
		current_step += 1
		if current_time > t_stats
			write_stats(body, current_step, current_time)
			t_stats += dt_stats
		end
		if current_time > t_checkp
			print(body)
			t_checkp += dt_output
		end

	end

	# show(body)
end

function forward_step(body::Body, dt)
	acc = accel(body)
	body.pos += body.vel * dt
	body.vel += acc * dt
end

function leapfrog_step(body::Body, dt)
	body.vel += accel(body) * 0.5 * dt
	body.pos += body.vel * dt
	body.vel += accel(body) * 0.5 * dt
end

function rk2_step(body::Body, dt)
	old_pos = body.pos
	half_vel = body.vel + accel(body)*0.5*dt
	body.pos += body.vel * 0.5 * dt
	body.vel += accel(body) * dt
	body.pos = old_pos + half_vel*dt
end

function rk4_step(body::Body, dt)
	old_pos = body.pos
	a0 = accel(body)
	body.pos = old_pos + body.vel*0.5*dt + a0*0.125*dt*dt
	a1 = accel(body)
	body.pos = old_pos + body.vel*dt + a1*0.5*dt*dt
	a2 = accel(body)
	body.pos = old_pos + body.vel*dt + (a0 + a1*2)*(1/6.0)*dt*dt
	body.vel += (a0 + a1*4 + a2) * (1/6.0) * dt
end

function yo6_step(body::Body, dt)
	d = [0.784513610477560e0, 0.235573213359357e0, 
				-1.17767998417887e0, 1.31518632068391e0 ]

	for i in 1:3; leapfrog_step(body, dt*d[i]); end;
	leapfrog_step(body, dt*d[4])
	for i in 0:2; leapfrog_step(body, dt*d[3-i]); end;
end

function yo8_step(body::Body, dt)
	d = [0.104242620869991e1, 0.182020630970714e1, 0.157739928123617e0,
				0.244002732616735e1, -0.716989419708120e-2, -0.244699182370524e1,
				-0.161582374150097e1, -0.17808286265894516e1]

	for i in 1:7; leapfrog_step(body, dt*d[i]); end;
	leapfrog_step(body, dt*d[8])
	for i in 0:6; leapfrog_step(body, dt*d[7-i]); end;
end

end
