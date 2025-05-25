%% Defectors may be strong
clear; clc;
B = [3 0; 5 1];
Strategies = ["per_ddc", "Alternator", "soft_majo"];
POP0 = [100; 100; 100];
T = 1000;
J = 90;
[POP1] = TourTheFit(B, Strategies, POP0, T, J);
[POP2] = TourSimFit(B, Strategies, POP0, T, J);
[POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
% Plot Populations of Strategies Over Generations
fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Defectors may be strong");