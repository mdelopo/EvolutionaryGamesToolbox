%% Fitness Dynamics vs Imitation Dynamics
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [4; 6; 4];
K = 1;
T = 100;
J = 15;
[POP1] = TourSimFit(B, Strategies, POP0, T, J);
[POP2] = TourSimImi(B, Strategies, POP0, K, T, J);
[POP3] = TourSimImi(B, Strategies, POP0, K, T, J, "Total");
% Plot Populations of Strategies Over Generations
fig = plotFitnessVSImitation(Strategies, POP1, POP2,POP3,"Fitness Dynamics vs Imitation Dynamics");