%% 1st case: Monotonous Convergence triple plots
clear; clc;
B = [3 0; 5 1];
Strategies = ["Grim", "TitForTat", "Alternator"];
POP0 = [100; 100; 100];
T = 1000;
J = 10;
[POP1] = TourTheFit(B, Strategies, POP0, T, J);
[POP2] = TourSimFit(B, Strategies, POP0, T, J);
[POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
% Plot Populations of Strategies Over Generations
fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Monotonous Convergence");