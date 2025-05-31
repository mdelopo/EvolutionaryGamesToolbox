%% Sensitivity of Imitation Dynamics, mode = 'Total', to population's size - Case N=10
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_C", "All_D", "Grim"];
POP0 = [0; 0; 10]; % Initial population of strategies
K = 1;
T = 100;
J = 15;
P = TourTheImi(B, Strategies, POP0, K, T, J,'Total');
PlotStateTransitionGraph(P, POP0, Strategies,"Sensitivity of Imitation Dynamics, mode='Total', to population's size - Case N="+sum(POP0));