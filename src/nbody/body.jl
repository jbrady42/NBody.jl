
type Body
  mass::Float64
  pos::Vector{Float64}
  vel::Vector{Float64}

  id::Integer

  function Body(;mass=0.0, pos=Vector{Float64}, vel=Vector{Float64}, id=0)
    # accel_hist_len = 4
    # accel_hist = zeros(Float64, NDIMS, accel_hist_len)

    new(mass, pos, vel, id)
  end
end

function Body(d::Dict{String, Any})
  b = Body(
    mass = d["mass"],
    pos = d["pos"],
    vel = d["vel"]
  )
  b.id = if haskey(d, "id")
    d["id"]
  else
    0
  end
  b
end


######## IO ###########

import Base.show
function show(io::IO, a::Body)
  print(io, "mass:  ", a.mass, "\n")
  print(io, "pos:   ", join(a.pos, ", "), "\n")
  print(io, "vel:   ", join(a.vel, ", "), "\n")
end

# function pp(io::IO, a::Body, nb::NBodySystem)
#   acc = accel(a, nb)
#   show(io, a)
#   print(io, "accel: ", join(acc, ", "), "\n")
# end
#
# function pp(a::Body, nb::NBodySystem)
#   pp(STDOUT, a, nb)
# end

# import Base.print
# function print(io::IO, a::Body)
#   @printf io "%24.16e\n" a.mass
#
#   map(Array[a.pos, a.vel]) do b
#     map(x-> @printf(io,"%24.16e",x), b)
#     print(io, "\n")
#   end
# end

function read_body()
  mass = parse(Float64, readline())
  pos = map(x -> parse(Float64, x), split(readline()))
  vel = map(x -> parse(Float64, x), split(readline()))
  return Body(mass, pos, vel)
end

#######################

function accel(body::Body, bodies::Array{Body}, soft_len)
  acc = zeros(body.vel)
  for a in bodies
    if a != body
      r = a.pos - body.pos
      r2 = dot(r,r) + soft_len*soft_len
      r3 = r2*sqrt(r2)
      acc += r*(a.mass/r3)
    end
  end
  acc
end

# function jerk(body::Body)
# 	r2 = dot(body.pos, body.pos)
# 	r3 = r2 * sqrt(r2) # we want r^(2/3)
# 	j = (body.vel+body.pos*(-3*(dot(body.pos,body.vel))/r2))*(-body.mass/r3)
# 	return j
# end

function collision_time_scale(body::Body, bodies::Array{Body})
  time_scale_sq = Inf
  for b in bodies
    if b != body
      r = b.pos - body.pos
      v = b.vel - body.vel

      r2 = dot(r,r)
      v2 = dot(v,v)

      estimate_sq = r2 / v2

      if time_scale_sq > estimate_sq
        time_scale_sq = estimate_sq
      end

      a = (body.mass + b.mass) / r2
      estimate_sq = sqrt(r2) / a

      if time_scale_sq > estimate_sq
        time_scale_sq = estimate_sq
      end
    end
  end

  sqrt(time_scale_sq)
end


####### Energy #########

function kin_energy(body::Body)
  return 0.5 * body.mass * dot(body.vel, body.vel)
end

function pot_energy(body::Body, bodies, soft_len)
  p = 0
  for a in bodies
    if a != body
      r = a.pos - body.pos
      p += -body.mass*a.mass/sqrt(dot(r,r) + soft_len*soft_len)
    end
  end
  return p
end
