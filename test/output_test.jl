using NBody
using JSON

nb = read_nbody()
# println(json(nb))
NBody.write_snapshot(nb)
NBody.write_snapshot(nb)