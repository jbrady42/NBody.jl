# NBody

A simple N-Body integrator in Julia.

Based on the The Art of Computational Science.

http://www.artcompsci.org/kali/index.html


#### Available Integrators

- rk4
- rk2
- leapfrog
- euler

### Params
`julia cmd.jl --help`

|Param|Long Form|Description|
|---|---|---|
|`-t`| `--total_duration` | Duration of the integration (type: Float64, default: 10.0) |
|`-o`| `--output_interval` | Snapshot output interval (type: Float64, default: 1.0) |
|`-e`| `--diagnostics_interval` | Diagnostics output interval (type: Float64, default: 1.0) |
|`-d`| `--step_size` | Integration time step (type: Float64, default: 0.001) |
|`-i`| `--integrator` | Integration method (default: "rk4") |
|`-x`| `--extra_diagnostics` |Extra diagnostics |
|`-s`| `--softening_length` | Softening ength (type: Float64, default: 0.0) |
|`-n`| `--no_init_out` | Don't output initial snapshot |
|`-h`| `--help` | show help message and exit |


### Example
See examples folder for additional samples.

#### Data File
NBody systems are specified in a simple JSON file format.
```
{
  "time": 0,
  "bodies": [
    {
      "mass": 0.5,
      "pos": [-10.0, 0.0, 0.0],
      "vel": [0.0, -0.1 , 0.0]
    },
    ...
  ]
}

```


#### Run
```
julia cmd.jl -t integration_time < input_system.json > data/results.out
```

#### Output
Diagnostics are output to STDERR while snapshots are written to STDOUT as newline delimited JSON.

The output format is a single line version of the input JSON format. A single line of output can be used as input allowing resumption.
