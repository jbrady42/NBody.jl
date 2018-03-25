using NBody
using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table s begin
    "--seed", "-s"
      help = "Position only"
      arg_type = Int128
      default = abs(rand(Int128))

    "--number", "-n"
      help = "Number of particles"
      arg_type = Int
      default = 3
      range_tester = x-> x>0
  end

  return parse_args(s)
end

function main(args)
  if args["seed"] > 0
    srand(args["seed"])
  end

  nb = quiet_plummer(args["number"])
  NBody.write_snapshot(nb)

  println(STDERR, "Seed: $(args["seed"])")
end

function frand(low, high)
  low + rand() * (high - low)
end

function sperical(r)
  vec = Array{Float64}(3)

  theta = acos(frand(-1, 1))
  phi = frand(0, 2*pi)

  vec[1] = r * sin(theta) * cos(phi)
  vec[2] = r * sin(theta) * sin(phi)
  vec[3] = r * cos(theta)
  vec
end

function mk_plummer(n)
  res = NBody.NBodySystem(n)

  # scale to viral radius
  scalefactor = 16 / (3 * pi)

  res.bodies = map(1:n) do i
    mass = 1 / n

    radius = 1 / sqrt( rand() ^ (-2//3) - 1)
    pos = sperical(radius) / scalefactor

    x = 0.0
    y = 0.1
    while y > x*x*(1 - x*x) ^ 3.5
      x = frand(0, 1)
      y = frand(0, 0.1)
    end

    velocity = x * sqrt(2) * (1 + radius*radius) ^ (-1//4)
    vel = sperical(velocity) * sqrt(scalefactor)

    NBody.Body(
      mass = mass,
      pos = pos,
      vel = vel,
      id = i
    )
  end

  res
end

function quiet_plummer(n)
  res = NBody.NBodySystem(n)

  # scale to viral radius
  scalefactor = 16 / (3 * pi)

  cum_mass_min = 0
  cum_mass_max = 1/n

  res.bodies = map(1:n) do i
    mass = 1 / n

    cum_mass = frand(cum_mass_min, cum_mass_max)
    cum_mass_min = cum_mass_max
    cum_mass_max += 1/n

    radius = 1 / sqrt( cum_mass ^ (-2//3) - 1)
    pos = sperical(radius) / scalefactor

    x = 0.0
    y = 0.1
    while y > x*x*(1 - x*x) ^ 3.5
      x = frand(0, 1)
      y = frand(0, 0.1)
    end

    velocity = x * sqrt(2) * (1 + radius*radius) ^ (-1//4)
    vel = sperical(velocity) * sqrt(scalefactor)

    NBody.Body(
      mass = mass,
      pos = pos,
      vel = vel,
      id = i
    )
  end

  res
end

main(parse_commandline())
