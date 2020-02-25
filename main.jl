# Will come in handy to random sample from binomial distributions
using Distributions
using Random

# import predefined constants / parameters
include("constants.jl")
# import helper functions
include("tools.jl")
# main data structure
include("grid.jl")

const seedVal = 42
Random.seed!(seedVal)

c = Constants()
###########################################
deltat = c.deltat
tspan = c.tspan
Nstep = c.Nstep
alt = c.alt
N = c.N
P0 = c.P0
K = c.K
Neval = c.Neval
threshold = c.threshold
MinGrate = c.MinGrate
MaxGrate = c.MaxGrate
MinDrate = c.MinDrate
MaxDrate = c.MaxDrate
MinMutrate = c.MinMutrate
MaxMutrate = c.MaxMutrate
MinMigrate = c.MinMigrate
MaxMigrate = c.MaxMigrate
Gweight = c.Gweight
Dweight = c.Dweight
Mutweight = c.Mutweight
Migweight = c.Migweight
Grate = c.Grate
Migrate = c.Migrate
Drate = c.Drate
Mutrate = c.Mutrate
#########################################
g = Grid(N, alt, P0)

# Create monitor variable
m = Monitor(Neval)

start = time()

open("files/Params.txt", "w") do file
    println(file, Grate, " ", Drate, " ", Mutrate, " ", Migrate)
end

# Create weights for surrounding voxels (Moore neighbourhood)
c = 0
wcube = zeros(26)
sumcube = 0

for i in [-1, 0, 1]
    for j in [-1, 0, 1]
        for k in [-1, 0, 1]
            global c
            global wcube
            global sumcube
            if abs(i) + abs(j) + abs(k) != 0
                c = c + 1
                wcube[c] = 1 / sqrt(abs(i) + abs(j) + abs(k))
                sumcube = sumcube + wcube[c]
            end
        end
    end
end

c = 0
for i in [-1, 0, 1]
    for j in [-1, 0, 1]
        for k in [-1, 0, 1]
            global c
            global wcube
            global sumcube
            if abs(i) + abs(j) + abs(k) != 0
                c = c + 1
                wcube[c] = wcube[c] / sumcube
            end
        end
    end
end

# Let the system evolve
elapsed = 0
evalstep = 1
voxPop = 0
Occ = [CartesianIndex(Int(N/2), Int(N/2), Int(N/2))]
ROcc = [CartesianIndex(Int(N/2), Int(N/2), Int(N/2))]
# t = 0

for t in 1:Nstep
# @time while Vol2[evalstep] < 100000
    # t = t + 1;
    # Take care of local scope. Variables updated inside
    # for loop need to be assigned to global scope

    # global t;

    global evalstep
    global elapsed

    global Occ
    global Gweight
    global Dweight
    global Migweight
    global Mutweight
    global wcube
    global ROcc
    # global start;

    grid_time_step!(g, m, t, Occ, alt, K, Grate, Drate, Dweight, Migweight,
        Mutrate, Mutweight, deltat)

    grid_update!(g)
    m.popt = g.G2[:, :, :, 1] + g.Nec

    Occ = findall(x -> x > 0, m.popt)
    # Housekeeping
    if t % round(Nstep / Neval) == 0
        update_monitor_stats!(m, evalstep, threshold)
        save_gen_space(g, t, N, "files/")

        elapsed = elapsed + time() - start
        print_curr_stats(m, t, elapsed, evalstep)
        evalstep = evalstep + 1

        global start = time()
    end
end

# Store tracking variables into files in `files` subfolder
monitor2files(m, "files/")
