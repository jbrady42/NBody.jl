using NBody

function main()
  nb = NBody.read_nbody_json()
  NBody.write_stats(nb)
  # NBody.write_snapshot(nb)
end

main()
