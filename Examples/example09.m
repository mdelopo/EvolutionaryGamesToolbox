%% Testing "Total" mode for best strategy calculation
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [1; 4; 5];
K = 1;
T = 100;
J = 15;
P = TourTheImi(B, Strategies, POP0, K, T, J, "Total");
AnalyzeMarkovChain(P, POP0, Strategies,"Testing Total mode for best strategy calculation");