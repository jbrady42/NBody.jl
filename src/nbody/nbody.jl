import JSON

type NBodySystem
  N
  time
  bodies::Array{Body}

  initial_energy
  soften_len
end

NBodySystem(n, current_time) = NBodySystem(n, current_time, Array{Body}(n), 0, 0)

function NBodySystem(d::Dict{String, Any})
  bodies = map(Body, d["bodies"])
  NBodySystem(length(bodies), d["time"], bodies, get(d, "initial_energy", 0), get(d, "soften_len", 0))
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


function accel(body::Body, nb::NBodySystem)
  return accel(body, nb.bodies, nb.soften_len)
end

function pot_energy(body::Body, nb::NBodySystem)
  return pot_energy(body, nb.bodies, nb.soften_len)
end

######## IO ##########

read_nbody() = read_nbody_json()

function read_nbody_json(stream::IOStream = STDIN)
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

function write_stats(nb::NBodySystem, steps, x_info)
  tot_energy = total_energy(nb)

  s = """
  Time:      $(@sprintf("%.3g", nb.time))
  Steps:     $steps
  E_Kin:     $(@sprintf("%.3g", kin_energy(nb)))
  E_Pot:     $(@sprintf("%.3g", pot_energy(nb)))
  E_Tot:     $(@sprintf("%.3g", tot_energy))
  E Error:   $(@sprintf("%.3g", (tot_energy - nb.initial_energy)))
  E % Error: $(@sprintf("%.3g", ((tot_energy - nb.initial_energy) / nb.initial_energy) * 100))

  """
  write(STDERR, s)

  if x_info
    ppx(nb)
  end
end
