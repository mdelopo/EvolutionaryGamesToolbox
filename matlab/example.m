B = [3 1; 4 2];
T = 10;
Strategies = ["All_D", "All_C", "Grim", "TitForTat", "Alternator", "SneakyTitForTat", "SpitefulTitForTat", "TwoTitsForTat", "Prober", "Detective", "TitForTwoTats","Cycler", "soft_majo", "per_ddc", "per_ccd", "per_ccccd"];
Pop = [10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10];
scores = Axel(B, Strategies, Pop, T);

% Use fig = plotPopulationOfStrategiesOverGenerations(Strategies, POP,
% Title) to plot a simulation.
% Use fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1,
% POP2, POP3, Title) to plot a triplet of simulations.
%
% Use AnalyzeMarkovChain(P, POP0, Strategies, Title) to plot a Markov
% Chain, with edgeweights and legend.
%% Fitness Dynamics
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
    
    %% 2nd case: Attenuated oscillatory movements
    clear; clc;
    B = [3 0; 5 1];
    Strategies = ["per_ccd", "per_ddc", "soft_majo"];
    POP0 = [450; 1000; 100];
    T = 1000;
    J = 420;
    [POP1] = TourTheFit(B, Strategies, POP0, T, J);
    [POP2] = TourSimFit(B, Strategies, POP0, T, J);
    [POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
    % Plot Populations of Strategies Over Generations
    fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Attenuated oscillatory movements");
    %% 3rd case: Periodic movements
    clear; clc;
    B = [3 0; 5 1];
    Strategies = ["per_ccd", "per_ddc", "soft_majo"];
    POP0 = [300; 200; 100];
    T = 1000;
    J = 1000;
    [POP1] = TourTheFit(B, Strategies, POP0, T, J);
    [POP2] = TourSimFit(B, Strategies, POP0, T, J);
    [POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
    % Plot Populations of Strategies Over Generations
    fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Periodic movements");
    %% 4th case: Increasing oscillations
    clear; clc;
    B = [3 0; 4.72 1];
    Strategies = ["per_ccd", "per_ddc", "soft_majo"];
    POP0 = [300; 400; 200];
    T = 1000;
    J = 450;
    [POP1] = TourTheFit(B, Strategies, POP0, T, J);
    [POP2] = TourSimFit(B, Strategies, POP0, T, J);
    [POP3] = TourSimFit(B, Strategies, POP0, T, J,true);
    % Plot Populations of Strategies Over Generations
    fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2,POP3,"Increasing oscillations");
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
%% Imitation Dynamics
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
    %% Testing default mode ("Individual") for best strategy calculation
    clear; clc;
    B = [3 1; 4 2];
    Strategies = ["All_D", "All_C", "TitForTat"];
    POP0 = [1; 4; 5];
    K = 1;
    T = 100;
    J = 15;
    P = TourTheImi(B, Strategies, POP0, K, T, J);
    AnalyzeMarkovChain(P, POP0, Strategies,"Testing default mode (Individual) for best strategy calculation");
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
    %% Fitness Dynamics vs Imitation Dynamics
    clear; clc;
    B = [3 1; 4 2];
    Strategies = ["All_D", "All_C", "TitForTat"];
    POP0 = [4; 6; 4];
    K = 1;
    T = 100;
    J = 15;
    [POP1] = TourSimFit(B, Strategies, POP0, T, J);
    [POP2] = TourSimImi(B, Strategies, POP0, K, T, J);
    [POP3] = TourSimImi(B, Strategies, POP0, K, T, J, "Total");
    % Plot Populations of Strategies Over Generations
    fig = plotFitnessVSImitation(Strategies, POP1, POP2,POP3,"Fitness Dynamics vs Imitation Dynamics");