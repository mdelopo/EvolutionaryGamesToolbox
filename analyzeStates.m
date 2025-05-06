function analyzeStates(P, states, Strategies)
% Analyzes a transition matrix P and classifies states as transient, recurrent, or absorbing

% Find the initial state (the state to match with POP0)
initialStateIdx = findInitialState(states, Strategies);
fprintf('Initial state is index %d with population: [%s]\n', initialStateIdx, ...
    strjoin(string(states(initialStateIdx,:)), ', '));

% Ensure P is a valid transition matrix
if size(P, 1) ~= size(P, 2)
    error('Transition matrix P must be square');
end

if size(states, 1) ~= size(P, 1)
    error('Number of states must match the size of the transition matrix');
end

% Convert strategies to cell if it's a string array
if isstring(Strategies)
    Strategies = cellstr(Strategies);
end

numStates = size(P, 1);
numStrategies = length(Strategies);

% Find all reachable states using breadth-first search from the initial state
reachableStates = findReachableStates(P, initialStateIdx);
fprintf('Found %d reachable states out of %d total states.\n', length(reachableStates), numStates);

% Initialize all states as non-reachable
stateClass = cell(numStates, 1);
for i = 1:numStates
    stateClass{i} = 'Non-reachable';
end

% Classify each reachable state
for i = 1:length(reachableStates)
    stateIdx = reachableStates(i);
    if P(stateIdx, stateIdx) == 1
        % If probability of staying is 1, it's an absorbing state
        stateClass{stateIdx} = 'Absorbing';
    else
        % Temporarily mark as transient, will update later for recurrent states
        stateClass{stateIdx} = 'Transient';
    end
end

% Identify recurrent classes among reachable transient states
transientStates = intersect(reachableStates, find(strcmp(stateClass, 'Transient')));
if ~isempty(transientStates)
    % Create adjacency matrix for transient states
    adjMatrix = false(length(transientStates));
    for i = 1:length(transientStates)
        for j = 1:length(transientStates)
            if P(transientStates(i), transientStates(j)) > 0
                adjMatrix(i, j) = true;
            end
        end
    end
    
    % Find communicating classes (strongly connected components)
    commClasses = findCommunicatingClasses(adjMatrix);
    
    % Check if each communicating class is recurrent or transient
    for i = 1:length(commClasses)
        isRecurrent = true;
        for j = 1:length(commClasses{i})
            stateIdx = transientStates(commClasses{i}(j));
            % If there's a positive probability of leaving the class, it's not recurrent
            leavingProb = sum(P(stateIdx, setdiff(reachableStates, transientStates(commClasses{i}))));
            if leavingProb > 0
                isRecurrent = false;
                break;
            end
        end
        
        if isRecurrent
            for j = 1:length(commClasses{i})
                stateIdx = transientStates(commClasses{i}(j));
                stateClass{stateIdx} = 'Recurrent';
            end
        end
    end
end

% Create table with state classification and populations
stateTable = table();
stateTable.State = (1:numStates)';
stateTable.Classification = stateClass;

% Add strategy populations
for i = 1:numStrategies
    varName = ['Pop_' Strategies{i}];
    stateTable.(varName) = states(:, i);
end

% Display results
disp('State Classification and Population Distribution:');
disp(stateTable);

% Count types of states
numAbsorbing = sum(strcmp(stateClass, 'Absorbing'));
numRecurrent = sum(strcmp(stateClass, 'Recurrent'));
numTransient = sum(strcmp(stateClass, 'Transient'));
numNonReachable = sum(strcmp(stateClass, 'Non-reachable'));

fprintf('\nSummary:\n');
fprintf('  Absorbing states: %d\n', numAbsorbing);
fprintf('  Recurrent states: %d\n', numRecurrent);
fprintf('  Transient states: %d\n', numTransient);
fprintf('  Non-reachable states: %d\n', numNonReachable);

% Now create a visualization of the state diagram
figTitle = 'State Transition Diagram';
createStateGraph(P, states, stateClass, Strategies, figTitle);
end

function initialStateIdx = findInitialState(states, POP0)
% Finds the index of the initial state that matches POP0
% POP0 is the initial population distribution [1, 5, 3] in this case

    % Default to looking for [1, 5, 3] population distribution
    if nargin < 2
        POP0 = [1, 5, 3];
    end
    
    % Ensure POP0 is a row vector for comparison
    if size(POP0, 1) > 1
        POP0 = POP0';
    end
    
    % Look for exact match of the population distribution
    for i = 1:size(states, 1)
        if all(states(i, :) == POP0)
            initialStateIdx = i;
            return;
        end
    end
    
    % If no exact match found, default to state 16
    fprintf('Warning: Could not find state matching population [%s]. Using state 16 as default.\n', ...
        strjoin(string(POP0), ', '));
    initialStateIdx = 16;
end

function reachableStates = findReachableStates(P, initialStateIdx)
% Finds all states reachable from the initial state using breadth-first search
    
    numStates = size(P, 1);
    reachable = false(numStates, 1);
    queue = initialStateIdx;
    reachable(initialStateIdx) = true;  % Mark initial state as visited
    
    while ~isempty(queue)
        currentState = queue(1);
        queue(1) = [];
        
        % Find all states that can be reached from the current state
        nextStates = find(P(currentState, :) > 0);
        
        % Add unvisited states to queue
        for nextState = nextStates
            if ~reachable(nextState)
                reachable(nextState) = true;
                queue = [queue, nextState];
            end
        end
    end
    
    reachableStates = find(reachable);
end

function analyzeLongTermBehavior(P, states, Strategies, initialStateIdx)
% Analyzes long-term behavior of the Markov chain
% Computes absorption probabilities and expected time to absorption

% Number of states
numStates = size(P, 1);

% Check if initialStateIdx is valid
if initialStateIdx < 1 || initialStateIdx > numStates
    error('Initial state index out of range');
end

% Get reachable states from the initial state
reachableStates = findReachableStates(P, initialStateIdx);

% Identify absorbing states among reachable states
absorbingStates = [];
for i = 1:length(reachableStates)
    stateIdx = reachableStates(i);
    if P(stateIdx, stateIdx) == 1
        absorbingStates = [absorbingStates; stateIdx];
    end
end
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

% Identify transient states (reachable non-absorbing states)
transientStates = setdiff(reachableStates, absorbingStates);
numTransient = length(transientStates);

if numTransient == 0
    fprintf('No transient states found. The system is already in an absorbing state.\n');
    
    % If initial state is absorbing, show that
    if ismember(initialStateIdx, absorbingStates)
        fprintf('Initial state is already absorbing. No transitions will occur.\n');
    end
    
    return;
end

% Check if initial state is among transient states
if ~ismember(initialStateIdx, transientStates)
    fprintf('Initial state is not a transient state. Cannot calculate absorption probabilities.\n');
    
    % If initial state is absorbing, show that
    if ismember(initialStateIdx, absorbingStates)
        fprintf('Initial state is already absorbing. No transitions will occur.\n');
    else
        fprintf('Initial state is not reachable in the current model.\n');
    end
    
    return;
end

try
    % Canonical form: P = [Q R; 0 I]
    Q = zeros(numTransient, numTransient);
    R = zeros(numTransient, numAbsorbing);
    
    % Fill Q and R with appropriate values
    for i = 1:numTransient
        for j = 1:numTransient
            Q(i, j) = P(transientStates(i), transientStates(j));
        end
        for j = 1:numAbsorbing
            R(i, j) = P(transientStates(i), absorbingStates(j));
        end
    end
    
    % Calculate fundamental matrix N = (I-Q)^(-1)
    I = eye(numTransient);
    N = inv(I - Q);
    
    % Calculate absorption probabilities B = NR
    B = N * R;
    
    % Find row corresponding to initial state in the fundamental matrix
    initialTransientIdx = find(transientStates == initialStateIdx);
    
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
    
catch ME
    fprintf('Error calculating absorption probabilities: %s\n', ME.message);
    fprintf('This often happens with ill-conditioned matrices.\n');
    fprintf('Try using a different numerical approach or simplify the model.\n');
end

end