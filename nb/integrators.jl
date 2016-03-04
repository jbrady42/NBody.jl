
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
		body.current_step = current_step
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


############

function ms2_step(body::Body, dt)
	if body.current_step == 0
		body.prev_accel = accel(body)
		rk2_step(body, dt)
	else
		old_acc = accel(body)
		jdt = old_acc - body.prev_accel
		body.pos += body.vel*dt + 0.5*old_acc*dt*dt
		body.vel += old_acc*dt + 0.5*jdt*dt
		body.prev_accel = old_acc
	end
end
