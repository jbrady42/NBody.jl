
###### Integrators #####

function evolve(nb, dt, time_end, dt_output, dt_stats, integ_method::Function)
	current_time = 0
	step = 0
	# num_steps = round(Int, time_units / dt)

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
		b.vel += accel(b) * 0.5 * dt
	end
	for b in nb.bodies
		b.pos += b.vel * dt
	end
	for b in nb.bodies
		b.vel += accel(b) * 0.5 * dt
	end
end

function rk2_step(nb::NBody, dt)
	for b in nb.bodies
		b.vel += accel(b) * 0.5 * dt
	end
	for b in nb.bodies
		b.pos += b.vel * dt
	end
	for b in nb.bodies
		b.vel += accel(b) * 0.5 * dt
	end
end
