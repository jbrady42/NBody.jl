using NBody

function main()
  nb = NBody.read_nbody_json()
  qs = NBody.quartiles(nb)

  s = """
  Quartiles
  r(1/4):   $(@sprintf("%.4g", qs[1]))
  r(2/4):   $(@sprintf("%.4g", qs[2]))
  r(3/4):   $(@sprintf("%.4g", qs[3]))
  r(1):     $(@sprintf("%.4g", qs[4]))

  """
  write(STDERR, s)
  # NBody.write_snapshot(nb)
end

main()
