B = [3 1; 4 2];
T = 10;
Strategies = ["All_D", "All_C", "Grim", "TitForTat", "Alternator", "SneakyTitForTat", "SpitefulTitForTat", "TwoTitsForTat", "Prober", "Detective", "TitForTwoTats","Cycler"];
Pop = [10 10 10 10 10 10 10 10 10 10 10 10];
scores = Axel(B, Strategies, Pop, T)
%%
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [1; 5; 3];
K = 1;
T = 100;
J = 100;
[POP, BST] = TourSimImi(B, Strategies, POP0, K, T, J);
%%
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [1; 5; 3];
K = 1;
T = 100;
J = 100;
P = TourTheImi(B, Strategies, POP0, K, T, J);
AnalyzeMarkovChain(P, POP0, Strategies);
%%
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [0; 4; 5];
K = 2;
T = 100;
J = 100;
P = TourTheImi(B, Strategies, POP0, K, T, J);
AnalyzeMarkovChain(P, POP0, Strategies);