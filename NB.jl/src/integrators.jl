
###### Integrators #####

function evolve(nb, dt, time_end, dt_output, dt_stats, integ_method::Function)
	current_time = 0
	step = 0

	t_stats = dt_stats - 0.5*dt
	t_checkp = dt_output - 0.5*dt
	t_end = time_end - 0.5*dt

	init_energy!(nb)
	write_stats(nb, step)

	while current_time < t_end
		# Call the integration method
		# nb.step = step
		integ_method(nb, dt)

		current_time += dt
		step += 1
		if current_time > t_stats
			write_stats(nb, step)
			t_stats += dt_stats
		end
		if current_time > t_checkp
			print(nb)
			t_checkp += dt_output
		end

	end
end

function forward_step(nb::NBody, dt)
	old_accel = map(accel, nb.bodies)
	for b in nb.bodies
		b.pos += b.vel*dt
	end
	for (i,b) in enumerate(nb.bodies)
		nb.bodies[i].vel += old_accel[i]*dt
	end
end

function leapfrog_step(nb::NBody, dt)
	for b in nb.bodies
		b.vel += accel(b, nb) * 0.5 * dt
	end
	for b in nb.bodies
		b.pos += b.vel * dt
	end
	for b in nb.bodies
		b.vel += accel(b, nb) * 0.5 * dt
	end
end

function rk2_step(nb::NBody, dt)
	old_pos = Array{Vector{Float64}}(nb.N)
	for (i, b) in enumerate(nb.bodies); old_pos[i] = b.pos; end

	half_vel = Array{Vector{Float64}}(nb.N)
	for (i, b) in enumerate(nb.bodies)
		half_vel[i] = b.vel + accel(b, nb) * 0.5 * dt
	end
	for b in nb.bodies
		b.pos += b.vel * 0.5 * dt
	end
	for b in nb.bodies
		b.vel += accel(b, nb) * dt
	end
	for (i, b) in enumerate(nb.bodies)
		b.pos = old_pos[i] + half_vel[i] * 0.5 * dt
	end
end

function rk4_step(nb::NBody, dt)
	# old_pos = Array{Vector{Float64}}(nb.N)
	# for (i, b) in enumerate(nb.bodies); old_pos[i] = b.pos; end;
	old_pos = map(x -> x.pos, nb.bodies)

	a0 = map(x-> accel(x, nb), nb.bodies)
	for (i, b) in enumerate(nb.bodies)	
		b.pos = old_pos[i] + b.vel*0.5*dt + a0[i]*0.125*dt*dt
	end

	a1 = map(x-> accel(x, nb), nb.bodies)
	for (i, b) in enumerate(nb.bodies)
		b.pos = old_pos[i] + b.vel*dt + a1[i]*0.5*dt*dt
	end

	a2 = map(x-> accel(x, nb), nb.bodies)
	for (i, b) in enumerate(nb.bodies)
		b.pos = old_pos[i] + b.vel*dt + (a0[i]+a1[i]*2)*(1/6.0)*dt*dt
	end

	for (i, b) in enumerate(nb.bodies)
		b.vel += (a0[i]+a1[i]*4+a2[i])*(1/6.0)*dt
	end
end
