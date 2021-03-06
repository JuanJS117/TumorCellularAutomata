# Will come in handy to random sample from binomial distributions
using Distributions
using Random

# import predefined constants / parameters
include("constants.jl")
# import helper functions
include("tools.jl")
# main data structure
include("grid.jl")

const seedVal = 3
Random.seed!(seedVal)

c = Constants()
g = Grid(c)
m = Monitor(c)

if !isdir("files/")
    mkpath(joinpath(@__DIR__, "files/"))
end

open(joinpath(@__DIR__, "files/Params.txt"), "w") do file
    println(file, c.Grate, " ", c.Drate, " ", c.Mutrate, " ", c.Migrate)
end

@time for t in 1:c.Nstep
    grid_time_step!(g, c, m, t)

    if t % c.NstepNevalRatio == 0
        update_monitor_stats!(m, c)
        save_gen_space(g, t, c.N, "files/")
        print_curr_stats(m, t)
    end
end

# Store tracking variables into files in `files` subfolder
monitor2files(m, "files/")
