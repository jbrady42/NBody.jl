const NDIMS = 2

type Body
	mass::Float64
	pos::Vector{Float64}
	vel::Vector{Float64}

	initial_energy

	step
	prev_accel::Array{Float64, 2}


	function Body(mass=0.0, pos=Vector{Float64}(NDIMS), vel=Vector{Float64}(NDIMS))
		accel_hist_len = 4
		accel_hist = zeros(Float64, NDIMS, accel_hist_len)

		new(mass, pos, vel, 0, 0, accel_hist)
	end
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

#######################

function accel(body::Body)
	r2 = dot(body.pos, body.pos)
	r3 = r2 * sqrt(r2) # we want r^(2/3)
	acc = body.pos * (-body.mass / r3)
	return acc
end

function jerk(body::Body)
	r2 = dot(body.pos, body.pos)
	r3 = r2 * sqrt(r2) # we want r^(2/3)
	j = (body.vel+body.pos*(-3*(dot(body.pos,body.vel))/r2))*(-body.mass/r3)
	return j
end

function prev_accel(body::Body, n::Int)
	return body.prev_accel[:,n]
end

function set_prev_accel!(body::Body, n::Int, prev::Vector)
	body.prev_accel[:,n] = prev
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
	body.initial_energy = total_energy(body)
end
