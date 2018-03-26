import JSON

type NBodySystem
  N
  time
  bodies::Array{Body}

  initial_energy
  soften_len
end

NBodySystem(n, current_time=0) = NBodySystem(n, current_time, Array{Body}(n), 0, 0)

function NBodySystem(d::Dict{String, Any})
  bodies = map(Body, d["bodies"])
  NBodySystem(length(bodies), d["time"], bodies, get(d, "initial_energy", 0), get(d, "soften_len", 0))
end

function set_ids(nb::NBodySystem)
  id = 0
  for b in nb.bodies
    b.id = id
    id += 1
  end
end

function diff(a::NBodySystem, b::NBodySystem)
  res = NBodySystem(a.N, b.time)
  bodies = filter!(x->!isnull(x), map(a.bodies) do body
    other_body_inds = find(x-> x.id == body.id ,b.bodies)
    if length(other_body_inds) == 0
      return Nullable{Body}()
    end

    other_body = b.bodies[other_body_inds[1]]

    Body(
      mass = body.mass,
      pos = other_body.pos - body.pos,
      vel = other_body.vel - body.vel,
      id = body.id
    )
  end)

  res.bodies = bodies
  res
end

function abs(nb::NBodySystem)
  sqrt(
    mapreduce(
      x -> dot(x.pos, x.pos) + dot(x.vel, x.vel),
      +,
      nb.bodies))
end

function abs_pos(nb::NBodySystem)
  sqrt(
    mapreduce(
      x -> dot(x.pos, x.pos),
      +,
      nb.bodies))
end

####### Energy #########

function kin_energy(nb::NBodySystem)
  return mapreduce(kin_energy, +, nb.bodies)
end

function pot_energy(nb::NBodySystem)
  return mapreduce(x -> pot_energy(x, nb), +, nb.bodies)  / 2
end

function total_energy(nb::NBodySystem)
  return kin_energy(nb) + pot_energy(nb)
end

function init_energy!(nb::NBodySystem)
  nb.initial_energy = total_energy(nb)
end

function collision_time_scale(nb::NBodySystem)
  time_scale = Inf
  for b in nb.bodies
    indv_time_scale = collision_time_scale(b, nb.bodies)
    if indv_time_scale < time_scale
      time_scale = indv_time_scale
    end
  end
  return time_scale
end


function accel(body::Body, nb::NBodySystem)
  return accel(body, nb.bodies, nb.soften_len)
end

function jerk(body::Body, nb::NBodySystem)
  return jerk(body, nb.bodies, nb.soften_len)
end

function pot_energy(body::Body, nb::NBodySystem)
  return pot_energy(body, nb.bodies, nb.soften_len)
end

######## Utils #######

function ordered_radii(nb::NBodySystem)
  sort(
    map(x-> dot(x.pos, x.pos), nb.bodies)
  )
end

function quartiles(nb::NBodySystem)
  sorted = ordered_radii(nb)
  r1 = sqrt(sorted[ceil(Int, nb.N/4)])
  r2 = sqrt(sorted[ceil(Int, nb.N/2)])
  r3 = sqrt(sorted[ceil(Int, nb.N*3/4)])
  r4 = sqrt(sorted[end])
  (r1, r2, r3, r4)
end

function shift_to_center_of_mass!(nb::NBodySystem)
  mass_total = mapreduce(b -> b.mass, +, nb.bodies)
  com_pos = mapreduce(b -> b.pos*b.mass, +, nb.bodies) / mass_total
  com_vel = mapreduce(b -> b.vel*b.mass, +, nb.bodies) / mass_total

  for b in nb.bodies
    b.pos -= com_pos
    b.vel -= com_vel
  end
end

function adjust_units!(nb::NBodySystem)
  alpha = -pot_energy(nb) / 0.5
  beta = kin_energy(nb) / 0.25

  for b in nb.bodies
    b.pos *= alpha
    b.vel /= sqrt(beta)
  end
end

######## IO ##########

read_nbody() = read_nbody_json()

function read_nbody_json(stream::IO = STDIN)
  strs = readlines(stream)
  return read_nbody_json(join(strs))
end

function read_nbody_json(str::String)
  js = JSON.parse(str)
  s = NBody.NBodySystem(js)
  return s
end

function read_nbody_dml()
  n = parse(Int, readline())
  current_time = parse(Float64, readline())

  nb = NBodySystem(n, current_time)
  for i in 1:n
    body = read_body()
    nb.bodies[i] = body
  end
  return nb
end

function write_snapshot(nb::NBodySystem)
  write_snapshot(STDOUT, nb)
end

function write_snapshot(io::IO, nb::NBodySystem)
  println(io, JSON.json(nb))
end

function ppx(nb::NBodySystem, io = STDERR)
  # print(io, "N: ", length(nb.bodies), "\n")
  @printf(io, "time: %24.16e\n", nb.time)
  for a in nb.bodies
    show(io, a)
    acc = accel(a, nb)
    print(io, "accel: ", join(acc, ", "), "\n\n")
  end
end

# import Base.show
# function show(io::IO, nb::NBodySystem)
#   print(io, "N: ", length(nb.bodies), "\n")
#   @printf(io, "time: %24.16e\n", nb.time)
#   for a in nb.bodies
#     pp(io, a, nb)
#   end
# end

# import Base.print
# function print(io::IO, nb::NBodySystem)
#   print(io, length(nb.bodies), "\n")
#   @printf(io, "%24.16e\n", nb.time)
#   for a in nb.bodies
#     print(io, a)
#   end
# end

function write_stats(nb::NBodySystem, steps=0, x_info=false)
  tot_energy = total_energy(nb)

  s = """
        Time  $(@sprintf("%.3g", nb.time))
       Steps  $steps
  ========================
       E_Kin  $(@sprintf("%.3g", kin_energy(nb)))
       E_Pot  $(@sprintf("%.3g", pot_energy(nb)))
       E_Tot  $(@sprintf("%.3g", tot_energy))
       E Err  $(@sprintf("%.3g", (tot_energy - nb.initial_energy)))
    Err/Init  $(@sprintf("%.3g", (tot_energy - nb.initial_energy) / nb.initial_energy))

  """
  write(STDERR, s)

  if x_info
    ppx(nb)
  end
end
