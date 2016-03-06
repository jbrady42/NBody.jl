
type NBody
	N
	time
	bodies::Array{Body}
	initial_energy
end

####### Energy #########

function kin_energy(nb::NBody)
	return mapreduce(kin_energy, +, nb.bodies)
end

function pot_energy(nb::NBody)
	return mapreduce(pot_energy, +, nb.bodies)  / 2
end

function total_energy(nb::NBody)
	return kin_energy(nb) + pot_energy(nb)
end

function init_energy!(nb::NBody)
	nb.initial_energy = total_energy(nb)
end

######## IO ##########

function read_nbody()
	n = parse(Int, readline())
	current_time = parse(Float64, readline())

	nb = NBody(n, current_time, Array{Body}(n), 0)
	for i in 1:n
		body = read_body()
		body.nbody = nb
		nb.bodies[i] = body
	end
	return nb
end

import Base.show
function show(io::IO, nb::NBody)	
	print(io, "N: ", length(nb.bodies), "\n")
	@printf(io, "time: %24.16e\n", nb.time)
	for a in nb.bodies
		show(io, a)
	end
end

import Base.print
function print(io::IO, nb::NBody)
	print(io, length(nb.bodies), "\n")
	@printf(io, "%24.16e\n", nb.time)
	for a in nb.bodies
		print(io, a)
	end
end

function write_stats(nb::NBody, steps)
	tot_energy = total_energy(nb)
	current_time = 0

	s = """
	Time: $(@sprintf("%.3g", current_time)) , steps: $steps
	E_Kin: $(@sprintf("%.3g", kin_energy(nb)))
	E_Pot: $(@sprintf("%.3g", pot_energy(nb)))
	E_Tot: $(@sprintf("%.3g", tot_energy))
	E_Tot - E_init: $(@sprintf("%.3g", (tot_energy - nb.initial_energy)))
	(E_tot - E_init) / E_init: $(@sprintf("%.3g", (tot_energy - nb.initial_energy) / nb.initial_energy))
	
	"""
	write(STDERR, s)
end
