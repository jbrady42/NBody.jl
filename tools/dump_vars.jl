using NBody

function main()
    while !eof(STDIN)
        str = readline(STDIN)
        nb = read_nbody_json(str)

        dump_nb(nb)
    end
end

function dump_nb(nb)
    for b in nb.bodies
        map(x-> @printf("%24.16f",x), b.pos)
        println()
    end
end

main()
