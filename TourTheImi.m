function P = TourTheImi(B, Strategies, POP0, K, T, J)
% TourTheImi - Calculates the transition matrix for imitation dynamics
% in an iterated prisoner's dilemma
%
% Inputs:
%   B - 2x2 payoff matrix for the prisoner's dilemma
%   Strategies - Cell array of strings with strategy names (e.g. {'All_C', 'All_D', 'TitForTat'})
%   POP0 - Initial population distribution (vector with number of agents using each strategy)
%   K - Number of people that imitate the best strategy after each generation
%   T - Number of rounds played for each match in the tournament
%   J - Number of generations for the simulation
%
% Output:
%   P - Transition matrix of the Markov chain

addpath('./strategies/');

% Number of strategies
numStrategies = length(Strategies);

% Total population size
N = sum(POP0);

% Generate all possible population distributions (states of the Markov chain)
states = generateStates(N, numStrategies);
numStates = size(states, 1);

% Initialize transition matrix
P = zeros(numStates, numStates);

% Find the index of the initial state
initialStateIdx = findStateIndex(POP0, states);

% For each possible state
for i = 1:numStates
    currentState = states(i, :);
    
    % Skip states with zero population for any strategy that has agents in POP0
    % This is to ensure we only consider states reachable from the initial state
    if ~isStateReachable(currentState, POP0)
        continue;
    end
    
    % Calculate expected payoffs for each strategy in the current state
    payoffs = calculatePayoffs(B, Strategies, currentState, T);
    
    % Calculate the transition probabilities to other states based on imitation dynamics
    transitions = calculateTransitions(currentState, payoffs, K, numStrategies);
    
    % Update the transition matrix
    for j = 1:size(transitions, 1)
        nextState = transitions(j, 1:numStrategies);
        probability = transitions(j, numStrategies+1);
        
        % Find the index of the next state
        nextStateIdx = findStateIndex(nextState, states);
        
        % Update the transition matrix
        P(i, nextStateIdx) = probability;
    end
end

end

function states = generateStates(N, numStrategies)
% Generate all possible population distributions for N people and numStrategies strategies

if numStrategies == 1
    states = N;
    return;
end

states = [];
for i = 0:N
    subStates = generateStates(N-i, numStrategies-1);
    newStates = [i*ones(size(subStates, 1), 1), subStates];
    states = [states; newStates];
end

end

function idx = findStateIndex(state, states)
% Find the index of a specific state in the list of all states

idx = find(all(states == state, 2));
if isempty(idx)
    error('State not found in the list of states');
end

end

function reachable = isStateReachable(currentState, initialState)
% Check if a state is reachable from the initial state
% A state is reachable if it doesn't have agents for strategies that had zero agents initially

reachable = true;
for i = 1:length(initialState)
    if initialState(i) == 0 && currentState(i) > 0
        reachable = false;
        break;
    end
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
% Simulate T rounds of play between two strategies and return the total payoff for the first strategy

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

function transitions = calculateTransitions(state, payoffs, K, numStrategies)
% Calculate the transition probabilities based on imitation dynamics
% Imitators are selected only from non-best performing strategies

totalPopulation = sum(state);

% Find all strategies with the maximum payoff (handling ties)
maxPayoff = max(payoffs);
bestStrategyIndices = find(payoffs == maxPayoff);
numBestStrategies = length(bestStrategyIndices);

% Calculate total population using non-best strategies
nonBestStrategyIndices = setdiff(1:numStrategies, bestStrategyIndices);
nonBestPopulation = sum(state(nonBestStrategyIndices));

% If all agents are already using best strategies, no transitions occur
if nonBestPopulation == 0
    transitions = [state, 1];  % Stay in current state with probability 1
    return;
end

% Adjust K if there aren't enough non-best agents to select K imitators
actualK = min(K, nonBestPopulation);

% If actualK is 0, no imitation happens
if actualK == 0
    transitions = [state, 1];  % Stay in current state with probability 1
    return;
end

% Initialize transitions matrix
possibleTransitions = [];

% For each non-best strategy that has population
for i = nonBestStrategyIndices
    if state(i) == 0
        continue;  % Skip strategies with no population
    end
    
    % Number of people who can change from strategy i
    maxChangers = min(state(i), actualK);
    
    % The probability of selecting imitators from this strategy depends on
    % the proportion of non-best agents using this strategy
    for imitators = 0:maxChangers
        % Calculate probability of selecting exactly 'imitators' agents from strategy i
        % out of actualK total imitators from the non-best population
        probSelectingImitators = hygepdf(imitators, nonBestPopulation, state(i), actualK);
        
        % For each best strategy they could imitate
        for b = 1:numBestStrategies
            bestStrategyIdx = bestStrategyIndices(b);
            
            % Create the new state after imitation
            newState = state;
            newState(i) = newState(i) - imitators;
            newState(bestStrategyIdx) = newState(bestStrategyIdx) + imitators;
            
            % Calculate the probability of this transition
            % This is the probability of selecting the imitators times the probability
            % of choosing this particular best strategy (uniform among all best strategies)
            probability = probSelectingImitators / numBestStrategies;
            
            % Add to possible transitions
            possibleTransitions = [possibleTransitions; [newState, probability]];
        end
    end
end

% Group identical states and sum their probabilities
uniqueStates = unique(possibleTransitions(:,1:numStrategies), 'rows');
transitions = zeros(size(uniqueStates, 1), numStrategies + 1);

for i = 1:size(uniqueStates, 1)
    currentState = uniqueStates(i, :);
    indices = all(possibleTransitions(:,1:numStrategies) == currentState, 2);
    totalProb = sum(possibleTransitions(indices, numStrategies+1));
    transitions(i, :) = [currentState, totalProb];
end

end

function p = hygepdf(x, M, K, n)
% Hypergeometric probability density function
% x: number of successes
% M: population size
% K: number of success states in the population
% n: number of samples

p = nchoosek(K, x) * nchoosek(M-K, n-x) / nchoosek(M, n);
end