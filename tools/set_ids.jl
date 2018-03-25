using NBody

function main()
  nb = NBody.read_nbody_json()
  NBody.set_ids(nb)
  NBody.write_snapshot(nb)
end

main()
