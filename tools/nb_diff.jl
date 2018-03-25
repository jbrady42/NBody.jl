using NBody
using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table s begin
    "--position_only", "-p"
      help = "Position only"
      action = :store_true
  end

  return parse_args(s)
end

function main(args)
  str = readline(STDIN)
  nb_a = NBody.read_nbody_json(str)

  str = readline(STDIN)
  nb_b = NBody.read_nbody_json(str)

  nb_c = NBody.diff(nb_a, nb_b)
  # println(nb_c)

  if args["position_only"]
    println(NBody.abs_pos(nb_c))
  else
    println(NBody.abs(nb_c))
  end
end

main(parse_commandline())
