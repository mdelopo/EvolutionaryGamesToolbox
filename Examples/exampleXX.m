%% Example showcase of TourTheImi and AnalyzeMarkovChain
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [1; 5; 3];
K = 1;
T = 100;
J = 15;
P1 = TourTheImi(B, Strategies, POP0, K, T, J);
AnalyzeMarkovChain(P1, POP0, Strategies,"Example showcase of TourTheImi and AnalyzeMarkovChain");
[P2, BST2] = TourSimImi(B, Strategies, POP0, K, T, J);
plotPopulationsTourSimImi(Strategies,P2,"Populations of Strategies TourSimImi");