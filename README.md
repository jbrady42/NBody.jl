# NBody

A simple N-Body integrator in Julia.

Based on the The Art of Computational Science.

http://www.artcompsci.org/kali/index.html

### Params
julia cmd.jl --help

### Example

#### Data File
`test.in`


|-----|-----|
|2||
|0||
|1||
|0.5| 0|
|0| 7.071067811865475e-01|
|1||
|-0.5| 0|
|0| -7.071067811865475e-01|


#### Run
julia cmd.jl < test.in
