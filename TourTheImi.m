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

% Convert string array to cell array if necessary
if isstring(Strategies)
    Strategies = cellstr(Strategies);
end

% Ensure POP0 is a column vector
POP0 = POP0(:);

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
initialStateIdx = findStateIndex(POP0', states);

% For each possible state
for i = 1:numStates
    currentState = states(i, :);
    
    % Skip states with zero population for any strategy that has agents in POP0
    % This is to ensure we only consider states reachable from the initial state
    if ~isStateReachable(currentState, POP0')
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
% Calculate the average payoff for each strategy in the current state

numStrategies = length(Strategies);
payoffs = zeros(1, numStrategies);
totalPopulation = sum(state);

% If there's only one individual, all payoffs remain 0
if totalPopulation <= 1
    return;
end

% Calculate payoffs for each strategy
for i = 1:numStrategies
    if state(i) == 0
        % Set payoff to NaN for strategies with no population
        payoffs(i) = NaN;
        continue;
    end
    
    totalStrategyPayoff = 0;
    totalMatches = 0;
    
    % Play against each strategy (including itself)
    for j = 1:numStrategies
        if state(j) == 0
            continue;  % Skip strategies with no population
        end
        
        % Get the strategy functions
        strategy1 = str2func(Strategies{i});
        strategy2 = str2func(Strategies{j});
        
        % Simulate T rounds of play
        singleMatchPayoff = simulatePlay(B, strategy1, strategy2, T);
        
        % Calculate total payoff from all matches against this strategy
        if i == j && state(i) > 1
            % When playing against the same strategy type, don't play against yourself
            numMatches = state(i) * (state(j) - 1) / 2;  % Divide by 2 to avoid double counting
            totalStrategyPayoff = totalStrategyPayoff + (singleMatchPayoff * numMatches);
            totalMatches = totalMatches + numMatches;
        elseif i ~= j
            numMatches = state(i) * state(j);
            totalStrategyPayoff = totalStrategyPayoff + (singleMatchPayoff * numMatches);
            totalMatches = totalMatches + numMatches;
        end
    end
    
    % Calculate average payoff per match
    if totalMatches > 0
        payoffs(i) = totalStrategyPayoff / totalMatches;
    else
        payoffs(i) = 0;  % No matches played
    end
end

end

function payoff = simulatePlay(B, strategy1, strategy2, T)
% Simulate T rounds of play between two strategies and return the total payoff for the first strategy

% Initialize history (only keeping track of as many rounds as needed by strategies)
History = zeros(T, 2);
totalPayoff = 0;

% Play T rounds
for round = 1:T
    History(round, 1) = strategy1(History);
    History(round, 2) = strategy2(flip(History,2));
    
    % Calculate payoff for player 1
    totalPayoff = totalPayoff + B(History(round, 1), History(round, 2));
end

payoff = totalPayoff;

end

function transitions = calculateTransitions(state, payoffs, K, numStrategies)
% Calculate the transition probabilities based on imitation dynamics

% Handle NaN values in payoffs (for strategies with no population)
payoffs(isnan(payoffs)) = -Inf;  % Ensure strategies with no agents aren't considered "best"

% Find best-performing strategies
maxPayoff = max(payoffs);
bestStrategyIndices = find(payoffs == maxPayoff);
numBestStrategies = length(bestStrategyIndices);

% If all strategies have the same payoff, no transitions occur
if all(ismember(find(state > 0), bestStrategyIndices))
    transitions = [state, 1];  % Stay in current state with probability 1
    return;
end

% Calculate total population of non-best strategies
nonBestStrategyIndices = setdiff(find(state > 0), bestStrategyIndices);
nonBestPopulation = sum(state(nonBestStrategyIndices));

% If there are no non-best strategies with population, no transitions occur
if nonBestPopulation == 0
    transitions = [state, 1];  % Stay in current state with probability 1
    return;
end

% Adjust K if there aren't enough non-best agents to select K imitators
actualK = min(K, nonBestPopulation);

% Initialize matrix to store possible transitions
possibleTransitions = [];

% Calculate hypergeometric probabilities for each possible distribution of imitators
for i = nonBestStrategyIndices
    % Maximum number of agents that can switch from strategy i
    maxSwitchers = min(state(i), actualK);
    
    for numSwitchers = 0:maxSwitchers
        % Probability of selecting exactly numSwitchers from strategy i
        probSelecting = hygepdf(numSwitchers, nonBestPopulation, state(i), actualK);
        
        % For each best strategy they could imitate
        for b = 1:numBestStrategies
            bestStratIdx = bestStrategyIndices(b);
            
            % Create new state after imitation
            newState = state;
            newState(i) = newState(i) - numSwitchers;
            newState(bestStratIdx) = newState(bestStratIdx) + numSwitchers;
            
            % Calculate transition probability (equal chance to choose any best strategy)
            probability = probSelecting / numBestStrategies;
            
            % Add this transition
            possibleTransitions = [possibleTransitions; [newState, probability]];
        end
    end
end

% Combine identical transitions by summing probabilities
if ~isempty(possibleTransitions)
    [uniqueStates, ~, ic] = unique(possibleTransitions(:, 1:numStrategies), 'rows');
    transitions = zeros(size(uniqueStates, 1), numStrategies + 1);
    
    for i = 1:size(uniqueStates, 1)
        idx = (ic == i);
        transitions(i, :) = [uniqueStates(i, :), sum(possibleTransitions(idx, numStrategies+1))];
    end
else
    % If no transitions were calculated, stay in the same state
    transitions = [state, 1];
end

end

%function p = hygepdf(x, M, K, n)
% Hypergeometric probability density function
% x: number of successes (items selected from the success group)
% M: population size (total number of items)
% K: number of success states in the population
% n: number of samples drawn
%
% Returns the probability of getting exactly x successes

%if x < 0 || x > K || x > n || n > M
%    p = 0;
%    return;
%end

%p = nchoosek(K, x) * nchoosek(M-K, n-x) / nchoosek(M, n);
%end