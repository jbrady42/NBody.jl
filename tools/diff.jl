using NBody
using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table s begin
    "--position_only", "-p"
      help = "Position only"
      action = :store_true
  end

  parse_args(s)
end

function read_nb()
  str = readline(STDIN)
  NBody.read_nbody_json(str)
end

function main(args)
  nb_a = read_nb()
  nb_b = read_nb()

  nb_c = NBody.diff(nb_a, nb_b)

  distance = if args["position_only"]
    NBody.abs_pos(nb_c)
  else
    NBody.abs(nb_c)
  end

  @printf("Phase Space Distance: %.16e\n", distance)
end

main(parse_commandline())
