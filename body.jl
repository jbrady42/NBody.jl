
module NB

type Body
	mass::Int
	pos::Vector{Float64}
	vel::Vector{Float64}

	Body(mass=0, pos=Vector{Float64}(3), vel=Vector{Float64}(3)) = new(mass, pos, vel)	
end

import Base.show
function show(io::IO, x::Body)
	print(io, "mass: ", x.mass, "\n")
	print(io, "pos: ", x.pos, "\n")
	print(io, "vel: ", x.vel, "\n")
end

end
