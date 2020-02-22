
# Will come in handy to random sample from binomial distributions
using Distributions
using Random
using DelimitedFiles
using MAT
Random.seed!();

# Set time of simulation
# deltat = 24;
deltat = 4; # hours
tspan = 6*10*365*deltat;
Nstep = tspan/deltat

# Set number of alterations
alt = 3;

# Create array of population cells, necrotics, and activity per voxel
N = 80;
#G = Array{Int64}(undef,N,N,N,2^alt);
#Nec = Array{Int64}(undef,N,N,N);
#Act = Array{Int64}(undef,N,N,N);
#Rho = Array{Int64}(undef,N,N,N);

G = zeros(N,N,N,2^alt);
Nec = zeros(N,N,N);
Act = zeros(N,N,N);
Rho = zeros(N,N,N);

# Set carrying capacity and initial cell number
P0 = 1e1;
K = 2e5;
# Assign initial cell number to population 1 at central voxel
G[Int64(N/2),Int64(N/2),Int64(N/2),1] = P0;

# Set number of time steps to be taken between system evaluations
Neval = Int64(Nstep/20)+1;

# Create monitor variables
threshold = 0.2*K;
totpop = zeros(Neval);
totpop[1] = P0;
totnec = zeros(Neval);
totnec[1] = 0;
vol = zeros(Neval);
Rvol = zeros(Neval);
vol[1] = 0;
Rvol[1] = 1;
totnew = zeros(Neval);
Rtotnew = zeros(Neval);
totnew[1] = 0;
Rtotnew[1] = 0;
Shannon = zeros(Neval);
Simpson = zeros(Neval);
Shannon[1] = 0;
Simpson[1] = 1;
pops = zeros(2^alt,Neval); # Total cell number per voxel (space)
pops[1,1] = P0;
popt = Array{Int64}(undef,N,N,N); # All populations cell number per time
popt[Int64(N/2),Int64(N/2),Int64(N/2)] = P0;
Vol2 = zeros(Neval);
Vol2[1] = 0;
start = time();


# Create swapping matrix
Gnext = G;
G2 = G;
Necnext = Nec;
Actnext = Act;
Rhonext = Rho;

# For SIMS1 and SIMS2
# Set all rates
# Grate = 1200;
# Drate = 2000;
# Mutrate = 2000;
# Migrate = 1000;
# # Set all weights
# Gweight = [0.35,0.3,0.25];
# Dweight = [-0.15,-0.05,-0.45];
# Mutweight = [0.2,0.2,0.55];
# Migweight = [0.8,0,0];
#
# # Set all rates (slightly tuned)
# Grate = 1000;
# Drate = 1660;
# Mutrate = 1660;
# Migrate = 850;
# # Set all weights (slightly tuned)
# Gweight = [0.32,0.28,0.25];
# Dweight = [-0.15,-0.05,-0.45];
# Mutweight = [0.18,0.18,0.52];
# Migweight = [0.65,0.05,0.05];
#
# Set all rates (slightly tuned)
# MinGrate = 50;     # Around 2 days
# MaxGrate = 250;    # Around 15 days
# MinDrate = 50;
# MaxDrate = 400;
# MinMutrate = 80;
# MaxMutrate = 240;
# MinMigrate = 40;   # Around 2 days
# MaxMigrate = 300;  # Around 25 days


MinGrate = 80;     
MaxGrate = 250;    # Around 15 days
MinDrate = 80;
MaxDrate = 400;
MinMutrate = 80;
MaxMutrate = 240;
MinMigrate = 80;
MaxMigrate = 300;  # Around 25 days

Grate = 1;
Migrate = 10;
while (Grate/Migrate) < 0.25 || (Migrate/Grate) < 0.1
    global Grate;
    global Migrate;
    global MinGrate;     # Around 20 days
    global MaxGrate;    # Around 200 days
    global MinMigrate;   # Around 12 days
    global MaxMigrate;
    Grate = rand(Uniform(MinGrate,MaxGrate));
    Migrate = rand(Uniform(MinMigrate,MaxMigrate));
end
Drate = rand(Uniform(MinDrate,MaxDrate));
Mutrate = rand(Uniform(MinMutrate,MaxMutrate));

# filename = string("Params.txt");
# open(filename, "w") do f
#     write(f, "$Grate $Drate $Mutrate $Migrate\n");
# end

io = open("Params.txt", "w");
write(io,"$Grate $Drate $Mutrate $Migrate\n")
close(io);

# Grate = 1100;
# Drate = 1800;
# Mutrate = 1800;
# Migrate = 1000;
# Set all weights (slightly tuned)
Gweight = [0.32,0.28,0.25];
Dweight = [-0.15,-0.05,-0.45];
Mutweight = [0.18,0.18,0.32];
Migweight = [0.65,0.05,0.05];

# Gweight = [rand(Uniform(0.2,0.3)),rand(Uniform(0.2,0.3)),rand(Uniform(0.2,0.3))];
# Dweight = [rand(Uniform(-0.25,-0.1)),rand(Uniform(-0.25,-0.1)),rand(Uniform(-0.25,-0.1))];
# Mutweight = [rand(Uniform(0.15,0.3)),rand(Uniform(0.15,0.3)),rand(Uniform(0.15,0.3))];
# Migweight = [rand(Uniform(0.15,0.3)),rand(Uniform(0.15,0.3)),rand(Uniform(0.15,0.3))];

# io = open("Params.txt", "w");
# write(io,"$Grate $Drate $Mutrate $Migrate $Gweight $Dweight $Mutweight $Migweight\n")
# close(io);

# # Set all rates (slightly tuned)
# Grate = 1100;
# Drate = 1800;
# Mutrate = 1800;
# Migrate = 1000;
# # Set all weights (slightly tuned)
# Gweight = [0.32,0.28,0.25];
# Dweight = [-0.15,-0.05,-0.45];
# Mutweight = [0,0,0];
# Migweight = [0.65,0.05,0.05];

# # Set of rates and weights for SIMS3
# Grate = 1200;
# Drate = 3000;
# Mutrate = 2000;
# Migrate = 1000;
# Gweight = [0.25,0.167,0.083];
# Dweight = [0.15,0.05,0.3];
# Mutweight = [0.2,0.2,0.4];
# Migweight = [0.5,0,0];

# # Set of rates and weights for SIMS4
# Grate = 800;
# Drate = 2500;
# Mutrate = 1500;
# Migrate = 700;
# Gweight = [0.25,0.167,0.083];
# Dweight = [0.15,0.05,0.3];
# Mutweight = [0.2,0.2,0.4];
# Migweight = [0.6,0,0];

# Create weights for surrounding voxels (Moore neighbourhood)
c = 0;
wcube = zeros(26);
sumcube = 0;

for i in [-1,0,1]
    for j in [-1,0,1]
        for k in [-1,0,1]
            global c;
            global wcube;
            global sumcube;
            if abs(i)+abs(j)+abs(k)!=0
                c = c+1;
                wcube[c] = 1/sqrt(abs(i)+abs(j)+abs(k));
                # println(i,", ",j,", ",k,", ",wcube[c]);
                sumcube = sumcube + wcube[c];
            end
        end
    end
end

c = 0;
for i in [-1,0,1]
    for j in [-1,0,1]
        for k in [-1,0,1]
            global c;
            global wcube;
            global sumcube;
            if abs(i)+abs(j)+abs(k)!=0
                c = c+1;
                wcube[c] = wcube[c]/sumcube;
            end
        end
    end
end

# Let the system evolve
elapsed = 0;
evalstep = 1;
voxPop = 0;
Occ = [CartesianIndex(Int(N/2),Int(N/2),Int(N/2))];
ROcc = [CartesianIndex(Int(N/2),Int(N/2),Int(N/2))];
t = 0;

# for t in 1:Nstep
@time while Vol2[evalstep] < 100000
    t = t + 1;
    # if t%round(Nstep/Neval) == 1
    #     global start = time();
    # end
    # Take care of local scope. Variables updated inside
    # for loop need to be assigned to global scope
    global G;
    global t;
    global Nec;
    global Act;
    global Rho;
    global Gnext;
    global Necnext;
    global Actnext;
    global Rhonext;
    global evalstep;
    global elapsed;
    global totpop;
    global totnec;
    global vol;
    global Rvol;
    global totnew;
    global Rtotnew;
    global Shannon;
    global Simpson;
    global pops;
    global popt;
    global Occ;
    global G2;
    global Gweight;
    global Dweight;
    global Migweight;
    global Mutweight;
    global wcube;
    global Vol2;
    global ROcc;
    # global start;

    # Iterate along each voxel
    # i = zeros(length(Occ));
    # j = zeros(length(Occ));
    # k = zeros(length(Occ));

    for l in 1:length(Occ)
        # i[l] = Int(Occ[l][1]);
        # j[l] = Int(Occ[l][2]);
        # k[l] = Int(Occ[l][3]);

        i = Int(Occ[l][1]);
        j = Int(Occ[l][2]);
        k = Int(Occ[l][3]);


    # for i in 1:N
    #     for j in 1:N
    #         for k in 1:N

                # Reinitialize activity at each time step
                Act[i,j,k] = 0;
                # Only evaluate voxel if there is at least 1 cell
                if sum(G[i,j,k,:]) > 0
                    for e in 1:2^alt
                        # Only evaluate population if there is at least 1 cell
                        if G[i,j,k,e] > 0

                            # Code below converts decimal number to binary string
                            binG = string(e-1, base=2);     # First of all, we retrieve binary string
                            while length.(binG) < 3         # As the string may not be of length 0, we solve this
                                binG = string("0",binG);
                            end
                            binGa = split(binG,"");         # Now we need an array instead of a string
                            binGb = zeros(length(binGa));   # We create a new variable to store int array
                            for i in 1:length(binGa)        # We convert array elements from char to int
                               binGb[i] = parse(Int,binGa[i]);
                            end

                            # Retrieve voxel info
                            Popgen = G[i,j,k,e];
                            Popvox = sum(G[i,j,k,:]);
                            Necvox = Nec[i,j,k];

                            # Reproduction event
                            # born = rep(Popgen,Popvox,K,Necvox,Grate,deltat,e,alt);
                            grate = Grate*(1-binGb[1]*Gweight[1]-binGb[2]*Gweight[2]-binGb[3]*Gweight[3]);
                            Prep = (deltat/grate)*(1-(Popvox+Necvox)/K);
                            if Prep > 1
                                Prep = 1;
                            end
                            if Prep < 0
                                Prep = 0;
                            end
                            born = rand(Binomial(Int64(Popgen),Prep));
                            Gnext[i,j,k,e] = Gnext[i,j,k,e] + born;
                            Actnext[i,j,k] = Actnext[i,j,k] + born;
                            # println(" Newborn cells: ",born)

                            # Death event
                            drate = Drate*(1-binGb[1]*Dweight[1]-binGb[2]*Dweight[2]-binGb[3]*Dweight[3]);
                            Pkill = (deltat/drate)*(Popvox+Necvox)/K;
                            if Pkill > 1
                                Pkill = 1;
                            end
                            if Pkill < 0
                                Pkill = 0;
                            end
                            dead = rand(Binomial(Int64(Popgen),Pkill));
                            Gnext[i,j,k,e] = Gnext[i,j,k,e] - dead;
                            Necnext[i,j,k] = Necnext[i,j,k] + dead;
                            # println(" Dead cells: ",dead)

                            # Migration event
                            migrate = Migrate*(1-binGb[1]*Migweight[1]-binGb[2]*Migweight[2]-binGb[3]*Migweight[3]);
                            Pmig = (deltat/migrate)*(Popvox+Necvox)/K;
                            if Pmig > 1
                                Pmig = 1;
                            end
                            if Pmig < 0
                                Pmig = 0;
                            end
                            migrants = rand(Binomial(Int64(Popgen),Pmig));

                            neigh = 0;
                            # left = migrants;
                            moore = 18;
                            moore = 26;
                            vonN = 6;
                            # multinom = Multinomial(migrants,repeat([1/moore],moore));
                            multinom = Multinomial(migrants,wcube);
                            gone = rand(multinom);
                            for movi in [-1,0,1]
                                for movj in [-1,0,1]
                                    for movk = [-1,0,1]
                                        xmov = i+movi;
                                        ymov = j+movj;
                                        zmov = k+movk;

                                        # if xmov < N+1 && ymov < N+1 && zmov < N+1 && xmov > 0 && ymov > 0 && zmov > 0 && abs(movi)+abs(movj)+abs(movk)==1
                                        # if xmov < N+1 && ymov < N+1 && zmov < N+1 && xmov > 0 && ymov > 0 && zmov > 0 && abs(movi)+abs(movj)+abs(movk)!=3 && abs(movi)+abs(movj)+abs(movk)!=0
                                        if xmov < N+1 && ymov < N+1 && zmov < N+1 && xmov > 0 && ymov > 0 && zmov > 0 && abs(movi)+abs(movj)+abs(movk)!=0

                                            neigh = neigh + 1;
                                            Gnext[xmov,ymov,zmov,e] = Gnext[xmov,ymov,zmov,e] + gone[neigh];
                                            Gnext[i,j,k,e] = Gnext[i,j,k,e] - gone[neigh];

                                            # if neigh < 6
                                            #     gone = rand(Binomial(Int64(migrants),1/6));
                                            #     Gnext[xmov,ymov,zmov,e] = Gnext[xmov,ymov,zmov,e] + gone;
                                            #     Gnext[i,j,k,e] = Gnext[i,j,k,e] - gone;
                                            #     left = left - gone;
                                            # else
                                            #     gone = left;
                                            #     if left < 0
                                            #         gone = 0;
                                            #     end
                                            #     Gnext[xmov,ymov,zmov,e] = Gnext[xmov,ymov,zmov,e] + gone;
                                            #     Gnext[i,j,k,e] = Gnext[i,j,k,e] - gone;
                                            # end
                                            # println("Migrating to: ",xmov," ",ymov," ",zmov," ",Gnext[xmov,ymov,zmov,e])
                                        end

                                    end
                                end
                            end

                            # Mutation event
                            mutrate = Mutrate*(1-binGb[1]*Mutweight[1]-binGb[2]*Mutweight[2]-binGb[3]*Mutweight[3]);
                            Pmut = (deltat/mutrate)*(Popgen/K);
                            if Pmut > 1
                                Pmut = 1;
                            end
                            if Pmut < 0
                                Pmut = 0;
                            end
                            r = rand(1);
                            r = r[1];
                            if r < Pmut && e != 2^alt
                                # Pick a random empty slot and turn it to mutated
                                nonalter = findall(x -> x < 1, binGb);
                                r2 = rand(1:length(nonalter));
                                mutating = nonalter[r2];
                                binGb[mutating] = 1;

                                # Switch binary array back to binary string
                                binGc = string(Int(binGb[1]),Int(binGb[2]),Int(binGb[3]));

                                # Code below retrieves back decimal number from binary string
                                decG = parse(Int, binGc, base=2)+1;
                                Gnext[i,j,k,e] = Gnext[i,j,k,e] - 1;
                                Gnext[i,j,k,decG] = Gnext[i,j,k,decG] + 1;
                            end



                            # Just checking if cell number is more o less coherent
                            # println("  Total cells: ",G[i,j,k,e])

                        end
                    end

                    # Housekeeping
                    if t%round(Nstep/Neval) == 0
                        totpop[evalstep+1] = totpop[evalstep+1] + sum(G[i,j,k,:]);
                        totnec[evalstep+1] = totnec[evalstep+1] + sum(Nec[i,j,k]);
                        Rtotnew[evalstep+1] = Rtotnew[evalstep+1] + sum(Act[i,j,k]);
                        Rvol[evalstep+1] = Rvol[evalstep+1] + 1;

                        for e = 1:(2^alt)
                            pops[e,evalstep+1] = pops[e,evalstep+1] + G[i,j,k,e];
                        end

                        if sum(G[i,j,k,:]) > threshold
                            totnew[evalstep+1] = totnew[evalstep+1] + sum(Act[i,j,k]);
                            vol[evalstep+1] = vol[evalstep+1] + 1;
                        end
                    end
                end
    #         end
    #     end
    # end
    end

    G = Gnext;
    Nec = Necnext;
    Act = Actnext;
    Rho = Rhonext;

    # Do this at each step, as it will help retrieving occupied indices
    # for i = 1:N
    #     for j = 1:N
    #         for k = 1:N
    #             popt[i,j,k] = sum(G[i,j,k,:]);
    #             #println(i," ",j," ",k," ",popt[i,j,k])
    #         end
    #     end
    # end
    G2 = sum(G,dims = 4);
    #popt = G2[:,:,:,1];
    popt = G2[:,:,:,1]+Nec;


    Occ = findall(x -> x > 0, popt);
    #println(Occ)
    #println(popt)

    # Housekeeping
    # if t%round(Nstep/Neval) == 0
    if t%round(Nstep/Neval) == 0
        Shannon[evalstep+1] = 0;
        Simpson[evalstep+1] = 0;

        ROcc =  findall(x -> x > threshold, popt);
        Vol2[evalstep+1] = size(ROcc,1);
        ROcc = [];

        # filename = string("Act_space_",string(Int64(t)),".txt");
        # open(filename, "w") do f
        #     for i in 1:N
        #         for j in 1:N
        #             for k in 1:N
        #                 global G;
        #                 if Act[i,j,k] > 0
        #                     wpop = Act[i,j,k];
        #                     write(f, "$wpop $i $j $k\n");
        #                 end
        #             end
        #         end
        #     end
        # end
        #
        # filename = string("Nec_space_",string(Int64(t)),".txt");
        # open(filename, "w") do f
        #     for i in 1:N
        #         for j in 1:N
        #             for k in 1:N
        #                 global G;
        #                 if Nec[i,j,k] > 0
        #                     wpop = Nec[i,j,k];
        #                     write(f, "$wpop $i $j $k\n");
        #                 end
        #             end
        #         end
        #     end
        # end

        # for e = 1:2^alt
        #     if pops[e,evalstep+1] > 0;
        #         Shannon[evalstep+1] = Shannon[evalstep+1] - (pops[e,evalstep+1]/totpop[evalstep+1])*log(pops[e,evalstep+1]/totpop[evalstep+1]);
        #         Simpson[evalstep+1] = Simpson[evalstep+1] + (pops[e,evalstep+1]/totpop[evalstep+1])^2;
        #
        #         filename = string("Gen",string(e),"_space_",string(Int64(t)),".txt");
        #         open(filename, "w") do f
        #             for i in 1:N
        #                 for j in 1:N
        #                     for k in 1:N
        #                         global G;
        #                         if G[i,j,k,e] > 0
        #                             wpop = G[i,j,k,e];
        #                             write(f, "$wpop $i $j $k\n");
        #                         end
        #                     end
        #                 end
        #             end
        #         end
        #     end
        # end

        for e = 1:2^alt
            if pops[e,evalstep+1] > 0;
                Shannon[evalstep+1] = Shannon[evalstep+1] - (pops[e,evalstep+1]/totpop[evalstep+1])*log(pops[e,evalstep+1]/totpop[evalstep+1]);
                Simpson[evalstep+1] = Simpson[evalstep+1] + (pops[e,evalstep+1]/totpop[evalstep+1])^2;
            end
        end

        filename = string("Gen_space_",string(Int64(t)),".txt");
        open(filename, "w") do f
            for i in 1:N
                for j in 1:N
                    for k in 1:N
                        if sum(G[i,j,k,:]) > 0
                            global G;
                            wpop1 = G[i,j,k,1];
                            wpop2 = G[i,j,k,2];
                            wpop3 = G[i,j,k,3];
                            wpop4 = G[i,j,k,4];
                            wpop5 = G[i,j,k,5];
                            wpop6 = G[i,j,k,6];
                            wpop7 = G[i,j,k,7];
                            wpop8 = G[i,j,k,8];
                            actF = Act[i,j,k];
                            necF = Nec[i,j,k];
                            write(f, "$i $j $k $wpop1 $wpop2 $wpop3 $wpop4 $wpop5 $wpop6 $wpop7 $wpop8 $actF $necF\n");
                        end
                    end
                end
            end
        end


        elapsed = elapsed + time() - start;
        println("Cell no: ",totpop[evalstep+1],"; Volume: ",Rvol[evalstep+1],"; Activity: ",Rtotnew[evalstep+1],"; Necrotics: ",totnec[evalstep+1],"; Het: ",Shannon[evalstep+1])
        println("     Volume (alt): ",Vol2[evalstep+1])
        println("Time step: ",t,"; Time elapsed: ",elapsed)

        evalstep = evalstep + 1;

        global start = time();


    end

end


# Store tracking variables into files
writedlm("Totpop.txt", totpop);
writedlm("Totnec.txt", totnec);
writedlm("VolPET.txt", vol);
writedlm("Vol_real.txt", Rvol);
writedlm("ActPET.txt", totnew);
writedlm("Act_real.txt", Rtotnew);
writedlm("Shannon.txt", Shannon);
writedlm("Simpson.txt", Simpson);
writedlm("Genspop.txt", pops);


# open("Gen1_space.txt", "w") do f
#     for i in 1:N
#         for j in 1:N
#             for k in 1:N
#                 global G;
#                 if G[i,j,k,1] > 0
#                     wpop = G[i,j,k,1];
#                     write(f, "$wpop $i $j $k\n");
#                 end
#             end
#         end
#     end
# end

#function rep()




# using Plots

# plot(Rvol)

# using Distributions

# sum(G[40,40,40,:]);
# rand(1,100)