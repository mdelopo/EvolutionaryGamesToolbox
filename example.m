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
% Ensure Strategies is a cell array
if isstring(Strategies)
    Strategies = cellstr(Strategies);
end

% Ensure POP0 is a column vector
POP0 = POP0(:);

% Calculate the transition matrix
fprintf('Calculating transition matrix...\n');
P = TourTheImi(B, Strategies, POP0, K, T, J);
fprintf('Transition matrix calculation complete.\n\n');

% Generate all possible states
N = sum(POP0);
numStrategies = length(Strategies);
states = generateStates(N, numStrategies);

% Find the initial state index
initialStateIdx = findStateIndex(POP0', states);
fprintf('Initial state (index %d): [%s]\n', initialStateIdx, strjoin(string(POP0'), ', '));

% Mark reachable states
reachableStates = findReachableStates(P, initialStateIdx);
fprintf('Found %d reachable states out of %d total states.\n', length(reachableStates), size(P, 1));

% Analyze and visualize states
fprintf('Analyzing state properties...\n');
analyzeStates(P, states, Strategies);

% Calculate long-term behavior
fprintf('\nCalculating long-term behavior...\n');
analyzeLongTermBehavior(P, states, Strategies, initialStateIdx);

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

function reachableStates = findReachableStates(P, initialStateIdx)
% Finds all states reachable from the initial state using depth-first search
    
    numStates = size(P, 1);
    reachable = false(numStates, 1);
    stack = initialStateIdx;
    
    while ~isempty(stack)
        currentState = stack(end);
        stack(end) = [];
        
        if ~reachable(currentState)
            reachable(currentState) = true;
            
            % Find all states that can be reached from the current state
            nextStates = find(P(currentState, :) > 0);
            
            % Add unvisited states to stack
            unvisitedNextStates = nextStates(~reachable(nextStates));
            stack = [stack, unvisitedNextStates];
        end
    end
    
    reachableStates = find(reachable);
end

function analyzeLongTermBehavior(P, states, Strategies, initialStateIdx)
% Analyzes long-term behavior of the Markov chain
% Computes absorption probabilities and expected time to absorption

% Number of states
numStates = size(P, 1);

% Identify absorbing states
absorbingStates = find(diag(P) == 1);
numAbsorbing = length(absorbingStates);

if numAbsorbing == 0
    fprintf('No absorbing states found. The system will continue to transition indefinitely.\n');
    return;
end

% Create table for absorbing states
absorbingTable = table();
absorbingTable.State = absorbingStates;

% Add strategy populations for each absorbing state
for i = 1:length(Strategies)
    varName = ['Pop_' Strategies{i}];
    absorbingTable.(varName) = states(absorbingStates, i);
end

% Display absorbing states
fprintf('Absorbing States:\n');
disp(absorbingTable);

% Calculate absorption probabilities
fprintf('\nCalculating absorption probabilities from the initial state...\n');

% Canonical form of the transition matrix
transientStates = setdiff(1:numStates, absorbingStates);
numTransient = length(transientStates);

if isempty(transientStates)
    fprintf('No transient states found. The system is already in an absorbing state.\n');
    return;
end

% Check if initial state is absorbing
if ismember(initialStateIdx, absorbingStates)
    fprintf('Initial state is already absorbing. No transitions will occur.\n');
    return;
end

% Canonical form: P = [Q R; 0 I]
Q = P(transientStates, transientStates);
R = P(transientStates, absorbingStates);

% Calculate fundamental matrix N = (I-Q)^(-1)
I = eye(numTransient);
N = inv(I - Q);

% Calculate absorption probabilities B = NR
B = N * R;

% Find row corresponding to initial state in the fundamental matrix
initialTransientIdx = find(transientStates == initialStateIdx);

if isempty(initialTransientIdx)
    fprintf('Initial state not found in transient states. Cannot calculate absorption probabilities.\n');
    return;
end

% Get absorption probabilities from initial state
absorptionProbs = B(initialTransientIdx, :);

% Expected number of steps before absorption
expectedSteps = sum(N(initialTransientIdx, :));

% Display results
fprintf('\nAbsorption Probabilities from Initial State:\n');
for i = 1:numAbsorbing
    absorbingState = absorbingStates(i);
    fprintf('  Probability of ending in state %d (', absorbingState);
    for j = 1:length(Strategies)
        fprintf('%s: %d', Strategies{j}, states(absorbingState, j));
        if j < length(Strategies)
            fprintf(', ');
        end
    end
    fprintf('): %.4f\n', absorptionProbs(i));
end

fprintf('\nExpected number of steps before absorption: %.2f\n', expectedSteps);

% Generate time evolution plots
plotTimeEvolution(P, states, Strategies, initialStateIdx);

end

function plotTimeEvolution(P, states, Strategies, initialStateIdx)
% Plots the time evolution of the population distribution
    
    % Maximum number of time steps to simulate
    maxSteps = 100;
    
    % Initialize state distribution (starts at initial state with probability 1)
    numStates = size(P, 1);
    stateDistribution = zeros(1, numStates);
    stateDistribution(initialStateIdx) = 1;
    
    % Initialize matrices to store results
    timeSteps = 0:maxSteps;
    stateProbs = zeros(length(timeSteps), numStates);
    stateProbs(1, :) = stateDistribution;
    
    % Calculate state probabilities for each time step
    for t = 1:maxSteps
        stateDistribution = stateDistribution * P;
        stateProbs(t+1, :) = stateDistribution;
    end
    
    % Calculate the strategy distribution over time
    numStrategies = size(states, 2);
    strategyDistribution = zeros(length(timeSteps), numStrategies);
    
    for t = 1:length(timeSteps)
        for s = 1:numStates
            strategyDistribution(t, :) = strategyDistribution(t, :) + stateProbs(t, s) * states(s, :);
        end
    end
    
    % Create plot of strategy evolution
    figure('Name', 'Population Evolution', 'Position', [150, 150, 900, 500]);
    
    % Define colors for each strategy
    colors = lines(numStrategies);
    
    % Plot each strategy's population over time
    hold on;
    for i = 1:numStrategies
        plot(timeSteps, strategyDistribution(:, i), 'LineWidth', 2, 'Color', colors(i,:));
    end
    hold off;
    
    % Add labels and legend
    xlabel('Time Steps');
    ylabel('Expected Population');
    title('Expected Evolution of Strategy Populations Over Time');
    legend(Strategies, 'Location', 'eastoutside');
    grid on;
    
    % Add total population line
    hold on;
    plot(timeSteps, sum(strategyDistribution, 2), 'k--', 'LineWidth', 1);
    hold off;
    
    % Set reasonable y-axis limits
    totalPop = sum(states(initialStateIdx, :));
    ylim([0, totalPop * 1.1]);
end