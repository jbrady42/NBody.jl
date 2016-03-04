
module NB

type Body
	mass::Float64
	pos::Vector{Float64}
	vel::Vector{Float64}

	Body(mass=0.0, pos=Vector{Float64}(3), vel=Vector{Float64}(3)) = new(mass, pos, vel)	
end

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

end
