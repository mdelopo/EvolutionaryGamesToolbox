function [POP, BST] = TourSimImi(B, Strategies, POP0, K, T, J, mode)
% TourSimImi - Simulates the Imitation Dynamics Tournament for J generations
%
% Inputs:
%   B - 2x2 payoff matrix for the prisoner's dilemma
%   Strategies - Cell array of strings with strategy names (e.g. {'All_C', 'All_D', 'TitForTat'})
%   POP0 - Initial population distribution (vector with number of agents using each strategy)
%   K - Number of people that imitate the best strategy after each generation
%   T - Number of rounds played for each match in the tournament
%   J - Number of generations for the simulation
%
% Outputs:
%   POP - Matrix of population distributions for each generation (J+1 x numStrategies)
%   BST - Matrix indicating which strategies were best in each generation (J x numStrategies)
%         1 = best strategy, 0 = not best

arguments
    B
    Strategies
    POP0
    K
    T
    J
    mode = "Individual";
end

if mode~="Individual" && mode~="Total"
    disp("Wrong mode for best strategy calculation");
    POP = [];
    BST = [];
    return
end
addpath('./strategies/');

% Number of strategies
numStrategies = length(Strategies);

% Initialize output matrices
POP = zeros(J+1, numStrategies);
BST = zeros(J, numStrategies);

% Set initial population
POP(1, :) = POP0;

% Run the simulation for J generations
for gen = 1:J
    % Get current population distribution
    currentPop = POP(gen, :);

    % Calculate payoffs for each strategy and find the best strategies
    % (those with maximum payoff) depending on mode selected
    if mode == "Individual"
        bestStrategyIndices = calculateBestStrategiesFromIndividuals(B, Strategies, currentPop, T);
    else
        payoffs = calculatePayoffs(B, Strategies, currentPop, T);
        maxPayoff = max(payoffs);
        bestStrategyIndices = find(payoffs == maxPayoff);
    end
    % Record best strategies for this generation
    BST(gen, bestStrategyIndices) = 1;

    % Calculate the population for the next generation
    nextPop = updatePopulation(currentPop, payoffs, K, numStrategies);

    % Store the new population
    POP(gen+1, :) = nextPop;
end

end

function payoffs = calculatePayoffs(B, Strategies, state, T)
% Calculate the total payoff for each strategy in the current state

numStrategies = length(Strategies);
payoffs = zeros(1, numStrategies);
totalPopulation = sum(state);

% If there's only one individual, payoff is 0 (no one to play with)
if totalPopulation <= 1
    return;
end

% Calculate payoffs for each strategy
for i = 1:numStrategies
    if state(i) == 0
        continue;  % Skip strategies with no population
    end

    strategyPayoff = 0;

    % Play against each strategy (including itself)
    for j = 1:numStrategies
        if state(j) == 0
            continue;  % Skip strategies with no population
        end

        % Calculate payoff when strategy i plays against strategy j
        strategy1 = str2func(Strategies{i});
        strategy2 = str2func(Strategies{j});

        % Simulate T rounds of play
        singleMatchPayoff = simulatePlay(B, strategy1, strategy2, T);

        % Calculate total payoff from all matches against this strategy
        % For matches against the same strategy, we need to account for not playing against oneself
        if i == j
            if state(j) > 1  % More than one agent using this strategy
                numMatches = state(i) * (state(j) - 1);
                strategyPayoff = strategyPayoff + singleMatchPayoff * numMatches;
            end
        else
            numMatches = state(i) * state(j);
            strategyPayoff = strategyPayoff + singleMatchPayoff * numMatches;
        end
    end

    payoffs(i) = strategyPayoff;
end

end

function payoff = simulatePlay(B, strategy1, strategy2, T)
% Simulate T rounds of play between two strategies and return the total payoff for strategy I

% Initialize history as a Tx2 array
History = zeros(T, 2);  % Empty initial history

totalPayoff = 0;

for round = 1:T
    % Get moves
    History(round, 1) = strategy1(History);
    History(round, 2) = strategy2(flip(History,2));
    % Calculate payoff for player I
    totalPayoff = totalPayoff + B(History(round, 1), History(round, 2));
end

payoff = totalPayoff;  % Return total payoff, not average

end

function nextPop = updatePopulation(currentPop, payoffs, K, numStrategies)
% Update the population based on imitation dynamics with randomness

% Find the best strategies
maxPayoff = max(payoffs);
bestStrategyIndices = find(payoffs == maxPayoff);
numBestStrategies = length(bestStrategyIndices);

% Find non-best strategies with population
nonBestStrategyIndices = setdiff(1:numStrategies, bestStrategyIndices);
nonBestPopulation = sum(currentPop(nonBestStrategyIndices));

% Initialize next population as current
nextPop = currentPop;

% If there are no non-best strategies with population, no change occurs
if nonBestPopulation == 0
    return;
end

% Adjust K if there aren't enough non-best agents
actualK = min(K, nonBestPopulation);

% If actualK is 0, no imitation happens
if actualK == 0
    return;
end

% Create a pool of agents from non-best strategies
agentPool = [];
for i = nonBestStrategyIndices
    if currentPop(i) > 0
        % Add this strategy's agents to the pool
        agentPool = [agentPool, repmat(i, 1, currentPop(i))];
    end
end

% Randomly select actualK agents to imitate
if ~isempty(agentPool)
    % Randomly shuffle the agent pool
    agentPool = agentPool(randperm(length(agentPool)));

    % Select the first actualK agents
    selectedAgents = agentPool(1:actualK);

    % Count how many of each strategy were selected
    selectedCounts = zeros(1, numStrategies);
    for i = selectedAgents
        selectedCounts(i) = selectedCounts(i) + 1;
    end

    % For each selected agent, randomly choose which best strategy to imitate
    for i = nonBestStrategyIndices
        if selectedCounts(i) > 0
            % Reduce this strategy's population
            nextPop(i) = nextPop(i) - selectedCounts(i);

            % Distribute imitators among best strategies randomly
            for j = 1:selectedCounts(i)
                % Randomly choose a best strategy
                bestIdx = bestStrategyIndices(randi(numBestStrategies));
                nextPop(bestIdx) = nextPop(bestIdx) + 1;
            end
        end
    end
end
end

function bestStrategies = calculateBestStrategiesFromIndividuals(B, Strategies, state, T)
% Determines best strategies by finding the highest individual payoff

numStrategies = length(Strategies);
population = sum(state);
individualPayoffs = zeros(1, population);
individualStrategies = zeros(1, population);

% Create a list of all individuals and their strategies
ind = 1;
for s = 1:numStrategies
    for count = 1:state(s)
        individualStrategies(ind) = s;
        ind = ind + 1;
    end
end

% Assign strategy function handles
strategyFuncs = cellfun(@str2func, Strategies, 'UniformOutput', false);

% Simulate matches between all pairs
for i = 1:population
    for j = 1:population
        if i == j
            continue;
        end
        stratI = strategyFuncs{individualStrategies(i)};
        stratJ = strategyFuncs{individualStrategies(j)};
        payoff = simulatePlay(B, stratI, stratJ, T);
        individualPayoffs(i) = individualPayoffs(i) + payoff;
    end
end

% Find the maximum individual payoff
maxPayoff = max(individualPayoffs);
bestIndividuals = find(individualPayoffs == maxPayoff);
bestStrategies = unique(individualStrategies(bestIndividuals));

end