"""
    Contains constants / initial conditions of simulation.
"""
struct Constants
    # Set time of simulation
    deltat::Int64 # hours
    tspan::Int64
    Nstep::Float64
    # Set number of alterations
    alt::Int64
    # Grid dimensions N x N x N
    N::Int64
    # Set carrying capacity and initial cell number
    P0::Float64
    K::Int64
    # Set number of time steps to be taken between system evaluations
    Neval::Int64
    threshold::Float64
    MinGrate::Int64
    MaxGrate::Int64     # Around 15 days
    MinDrate::Int64
    MaxDrate::Int64
    MinMutrate::Int64
    MaxMutrate::Int64
    MinMigrate::Int64
    MaxMigrate::Int64  # Around 25 days
    # Set all weights (slightly tuned)
    Gweight::Array{Float64, 1}
    Dweight::Array{Float64, 1}
    Mutweight::Array{Float64, 1}
    Migweight::Array{Float64, 1}

    function Constants()
        deltat = 4
        # tspan = 6*10*365*deltat;
        tspan = 1000
        Nstep = tspan / deltat
        alt = 3
        N = 80
        P0 = 1e1
        K = 2e5
        Neval = Int64(ceil(Nstep / 20)) + 1;
        threshold = 0.2 * K
        MinGrate = 80
        MaxGrate = 250
        MinDrate = 80
        MaxDrate = 400
        MinMutrate = 80
        MaxMutrate = 240
        MinMigrate = 80
        MaxMigrate = 300
        # Set all weights (slightly tuned)
        Gweight = [0.32, 0.28, 0.25]
        Dweight = [-0.15, -0.05, -0.45]
        Mutweight = [0.18, 0.18, 0.32]
        Migweight = [0.65, 0.05, 0.05]

        new(deltat, tspan, Nstep, alt, N, P0, K, Neval, threshold, MinGrate,
        MaxGrate, MinDrate, MaxDrate, MinMutrate, MaxMutrate, MinMigrate,
        MaxMigrate, Gweight, Dweight, Mutweight, Migweight)
    end
end
