

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



# Individual step
function evolve_ind(nb::NBodySystem, arg::EvolveArgs)

end
