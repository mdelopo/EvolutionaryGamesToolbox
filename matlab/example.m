B = [3 1; 4 2];
T = 10;
Strategies = ["All_D", "All_C", "Grim", "TitForTat", "Alternator", "SneakyTitForTat", "SpitefulTitForTat", "TwoTitsForTat", "Prober", "Detective", "TitForTwoTats","Cycler"];
Pop = [10 10 10 10 10 10 10 10 10 10 10 10];
scores = Axel(B, Strategies, Pop, T)
%%
% First Example: Showcase Usage of TourSimFit
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [100; 100; 100];
T = 100;
J = 100;
[POP, BST] = TourSimFit(B, Strategies, POP0, T, J);
% Example: POP is a matrix with size (num_generations x 3)
% Each column corresponds to a strategy

% Determine number of generations
num_generations = size(POP, 1);

% Create generation index
generations = 1:num_generations;

% Plot each strategy
plot(generations, POP(:,1), '-r', 'LineWidth', 2); hold on;
plot(generations, POP(:,2), '-g', 'LineWidth', 2);
plot(generations, POP(:,3), '-b', 'LineWidth', 2);

% Add labels and legend
xlabel('Generation');
ylabel('Population');
legend(Strategies(1), Strategies(2), Strategies(3));
title('Population of Strategies Over Generations');
grid on;
%%
% 1st case: Monotonous Convergence
clear; clc;
B = [3 1; 4 2];
Strategies = ["Grim", "TitForTat", "Alternator"];
POP0 = [100; 100; 100];
T = 100;
J = 100;
[POP, BST] = TourSimFit(B, Strategies, POP0, T, J);
% Example: POP is a matrix with size (num_generations x 3)
% Each column corresponds to a strategy

% Determine number of generations
num_generations = size(POP, 1);

% Create generation index
generations = 1:num_generations;

% Plot each strategy
plot(generations, POP(:,1), '-r', 'LineWidth', 2); hold on;
plot(generations, POP(:,2), '-g', 'LineWidth', 2);
plot(generations, POP(:,3), '-b', 'LineWidth', 2);

% Add labels and legend
xlabel('Generation');
ylabel('Population');
legend(Strategies(1), Strategies(2), Strategies(3));
title('Population of Strategies Over Generations');
grid on;
%%
% Example showcase of TourTheImi and AnalyzeMarkovChain
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
% Testing default mode ("Individual") for best strategy calculation
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [0; 4; 5];
K = 1;
T = 100;
J = 100;
P = TourTheImi(B, Strategies, POP0, K, T, J);
AnalyzeMarkovChain(P, POP0, Strategies);
%%
% Testing "Total" mode for best strategy calculation
clear; clc;
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [0; 4; 5];
K = 1;
T = 100;
J = 100;
P = TourTheImi(B, Strategies, POP0, K, T, J, "Total");
AnalyzeMarkovChain(P, POP0, Strategies);
%%
B = [3 1; 4 2];
Strategies = ["All_D", "All_C", "TitForTat"];
POP0 = [100; 100; 100];
T = 100;
J = 100;
[POP, BST] = TourTheFit(B, Strategies, POP0, T, J);