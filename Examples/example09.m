%% Sensitivity of winner to population's size: First Simulation
clear; clc;
B = [3 0; 5 1];
Strategies = ["per_ddc", "soft_majo", "Alternator"];
POP0 = [100; 159; 100];
T = 1000;
J = 120;
[POP1] = TourTheFit(B, Strategies, POP0, T, J);
[POP2] = TourSimFit(B, Strategies, POP0, T, J);
[POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
% Plot Populations of Strategies Over Generations
fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Sensitivity of winner to population's size - First Simulation");