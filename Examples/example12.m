%% Sensitivity to game length: Second Simulation
clear; clc;
B = [3 0; 5 1];
Strategies = ["per_ccd", "soft_majo", "per_ddc"];
POP0 = [300; 100; 244];
T = 6;
J = 250;
[POP1] = TourTheFit(B, Strategies, POP0, T, J);
[POP2] = TourSimFit(B, Strategies, POP0, T, J);
[POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
% Plot Populations of Strategies Over Generations
fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Sensitivity to game length - Second Simulation");