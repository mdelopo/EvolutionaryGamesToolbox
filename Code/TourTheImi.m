function P = TourTheImi(B, Strategies, POP0, K, T, J, mode)
% TourTheImi - Constructs the transition matrix for imitation dynamics
% Each state is a valid population distribution summing to N

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

S = length(Strategies);         % Number of strategies
N = sum(POP0);                  % Total number of agents

% Enumerate all states: integer partitions of N into S bins
allStates = generateStates(N, S);
numStates = size(allStates, 1);

% Initialize transition matrix
P = zeros(numStates, numStates);

% Precompute strategy function handles
strategyFuncs = cellfun(@str2func, Strategies, 'UniformOutput', false);

% Map from population to index
stateMap = containers.Map;
for i = 1:numStates
    stateMap(mat2str(allStates(i, :))) = i;
end

% Loop over all possible states
for s = 1:numStates
    currPop = allStates(s, :);

    % Find best Strategies depending on mode
    if mode == "Individual"
        bestStrats = calculateBestStrategiesFromIndividuals(B, Strategies, currPop, T);
    else
        payoffs = calculatePayoffs(B, Strategies, currPop, T);
        maxPayoff = max(payoffs);
        bestStrats = find(payoffs == maxPayoff);
    end
    nonBestStrats = setdiff(1:S, bestStrats);
    totalNonBest = sum(currPop(nonBestStrats));

    % If no imitation possible, self-transition
    if totalNonBest == 0 || K == 0
        P(s, s) = 1;
        continue;
    end

    actualK = min(K, totalNonBest);

    % Generate all possible reassignment combinations
    % Who switches and to which best strategy (uniformly random)
    transitionCounts = containers.Map;

    % Enumerate possible ways to choose actualK agents from non-best strategies
    agentPool = [];
    for i = nonBestStrats
        agentPool = [agentPool, repmat(i, 1, currPop(i))];
    end

    combos = nchoosek(1:length(agentPool), actualK);
    for c = 1:size(combos,1)
        selected = agentPool(combos(c,:));
        nextPop = currPop;

        for idx = 1:length(selected)
            from = selected(idx);
            to = bestStrats(randi(length(bestStrats)));
            nextPop(from) = nextPop(from) - 1;
            nextPop(to) = nextPop(to) + 1;
        end

        key = mat2str(nextPop);
        if isKey(transitionCounts, key)
            transitionCounts(key) = transitionCounts(key) + 1;
        else
            transitionCounts(key) = 1;
        end
    end

    % Normalize and update P
    keysList = keys(transitionCounts);
    for k = 1:length(keysList)
        targetState = str2num(keysList{k}); %#ok<ST2NM>
        j = stateMap(mat2str(targetState));
        P(s, j) = transitionCounts(keysList{k}) / size(combos,1);
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

function states = generateStates(N, S)
% Generate all integer compositions of N into S parts
if S == 1
    states = N;
else
    states = [];
    for i = 0:N
        subStates = generateStates(N - i, S - 1);
        states = [states; [i * ones(size(subStates,1),1), subStates]];
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