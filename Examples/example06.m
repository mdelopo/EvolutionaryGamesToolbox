%% 5th case: Disordered oscillations
clear; clc;
B = [3 0; 5 1];
Strategies = ["soft_majo", "per_ccccd", "Prober"];
POP0 = [100; 500; 800];
T = 1000;
J = 280;
[POP1] = TourTheFit(B, Strategies, POP0, T, J);
[POP2] = TourSimFit(B, Strategies, POP0, T, J);
[POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
% Plot Populations of Strategies Over Generations
fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Disordered oscillations");