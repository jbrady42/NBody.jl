push!(LOAD_PATH, pwd())

using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table s begin
    "--init_out", "-i"
      help = "Output initial snapshot"
      action = :store_true

    "--extra_diagnostics", "-x"
      help = "Extra diagnostics"
      action = :store_true

    "--softening_length", "-s"
      help = "Softening ength"
      arg_type = Float64
      default = 0.0

    "--total_duration", "-t"
      help = "Duration of the integration"
      arg_type = Float64
      default = 10.0

    "--output_interval", "-o"
      help = "Snapshot output interval"
      arg_type = Float64
      default = 1.0

    "--diagnostics_interval", "-e"
      help = "Diagnostics output interval"
      arg_type = Float64
      default = 1.0

    "--step_size", "-d"
      help = "Integration time step"
      arg_type = Float64
      default = 0.001
  end

  return parse_args(s)
end

function main(args)

  nb = read_nbody()

  # Should get moved in with rest of args
  nb.soften_len = args["softening_length"]

  method = NB.rk4_step

  ea = EvolveArgs(method, args["softening_length"], args["step_size"],
    args["total_duration"], args["output_interval"], args["diagnostics_interval"],
    args["init_out"], args["extra_diagnostics"])

  write_info(args, ea)

  evolve(nb, ea)
end

function write_info(args, ea)
  println(STDERR, "A simple N-Body code")

  d = Dict(
    "Integration method" 							=> ea.integ_method,
    "Integration time step"           => ea.dt,
    "Diagnostics output interval"     => ea.dt_stats,
    "Snapshot output interval"        => ea.dt_output,
    "Duration of the integration"     => ea.time_end,
    "Softening length"                => ea.soften_len
    )
  for (k,v) in d
    @printf(STDERR, "%-30s %-20s\n", k, v)
  end
end


parsed_args = parse_commandline()

# Include after arg handling
using NB

main(parsed_args)
