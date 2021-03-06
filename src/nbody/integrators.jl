
###### Integrators #####

type EvolveArgs
  integ_method::Function
  soften_len
  dt
  dt_param
  time_end
  dt_output
  dt_stats
  init_out
  x_info
  dynamic_step
  exact_time
  final_snapshot
end

function evolve(nb, arg::EvolveArgs)
  dt = arg.dt
  x_info = arg.x_info
  dt_stats = arg.dt_stats
  dt_output = arg.dt_output
  integ_method = arg.integ_method

  current_time = 0
  step = 0

  t_stats = current_time + dt_stats
  t_checkp = current_time + dt_output
  t_end = current_time + arg.time_end

  if !arg.dynamic_step
    t_stats -= (1//2)*dt
    t_checkp -= (1//2)*dt
    t_end -= (1//2)*dt
  end

  init_energy!(nb)
  write_stats(nb, step, x_info)

  if arg.init_out; write_snapshot(nb); end

  while current_time < t_end
    # Handle dynamic step
    if arg.dynamic_step
      dt = arg.dt_param * collision_time_scale(nb)

      if  arg.exact_time && current_time + dt > t_checkp
        dt = nextfloat(t_checkp - current_time)
      end
    end

    # Call the integration method
    # nb.step = step
    integ_method(nb, dt)

    current_time += dt
    nb.time = current_time
    step += 1
    if current_time >= t_stats
      write_stats(nb, step, x_info)
      t_stats += dt_stats
    end
    if current_time >= t_checkp
      write_snapshot(nb)
      t_checkp += dt_output
    end
  end

  # Write final snapshot and stats
  if arg.final_snapshot
    write_snapshot(nb)
  end
  write_stats(nb, step, x_info)
end

function forward_step(nb::NBodySystem, dt)
  nb_accel(x) = accel(x, nb)
  old_accel = map(nb_accel, nb.bodies)
  for b in nb.bodies
    b.pos += b.vel*dt
  end
  for (i,b) in enumerate(nb.bodies)
    nb.bodies[i].vel += old_accel[i]*dt
  end
end

function leapfrog_step(nb::NBodySystem, dt)
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

function rk2_step(nb::NBodySystem, dt)
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

function rk4_step(nb::NBodySystem, dt)
  # old_pos = Array{Vector{Float64}}(nb.N)
  # for (i, b) in enumerate(nb.bodies); old_pos[i] = b.pos; end;
  old_pos = map(x -> x.pos, nb.bodies)

  nb_accel(x) = accel(x, nb)
  a0 = map(nb_accel, nb.bodies)
  for (i, b) in enumerate(nb.bodies)
    b.pos = old_pos[i] + b.vel*0.5*dt + a0[i]*0.125*dt*dt
  end

  a1 = map(nb_accel, nb.bodies)
  for (i, b) in enumerate(nb.bodies)
    b.pos = old_pos[i] + b.vel*dt + a1[i]*0.5*dt*dt
  end

  a2 = map(nb_accel, nb.bodies)
  for (i, b) in enumerate(nb.bodies)
    b.pos = old_pos[i] + b.vel*dt + (a0[i]+a1[i]*2)*(1//6)*dt*dt
  end

  for (i, b) in enumerate(nb.bodies)
    b.vel += (a0[i]+a1[i]*4+a2[i])*(1//6)*dt
  end
end

function hermite_step(nb::NBodySystem, dt)
  old_pos = map(x -> x.pos, nb.bodies)
  old_vel = map(x -> x.vel, nb.bodies)

  old_acc = map(x -> accel(x, nb), nb.bodies)
  old_jerk = map(x -> jerk(x, nb), nb.bodies)

  for (i, b) in enumerate(nb.bodies)
    b.pos += b.vel*dt + old_acc[i]*0.5*dt*dt + old_jerk[i]*(dt*dt*dt/6)
  end

  for (i, b) in enumerate(nb.bodies)
    b.vel += old_acc[i]*dt + old_jerk[i]*(dt*dt/2)
  end

  for (i, b) in enumerate(nb.bodies)
    b.vel = old_vel[i] + (old_acc[i] + accel(b, nb))*(dt/2) + (old_jerk[i] - jerk(b, nb))*(dt*dt/12)
  end

  for (i, b) in enumerate(nb.bodies)
    b.pos = old_pos[i] + (old_vel[i] + b.vel)*(dt/2) + (old_acc[i] - accel(b, nb))*(dt*dt/12)
  end
end
