function [POP,BST,FIT] = TourSimFit(B,Strategies,POP0,T,J,compensation)
arguments
    B
    Strategies
    POP0
    T
    J
    compensation = false;
end


funList = cellfun(@str2func,Strategies,'uniformOutput',false);
N_strat = length(Strategies);
payoff = zeros(N_strat);
N = sum(POP0);

% Calculate scores for each strategy against each strategy
for i = 1: N_strat
    for j = i: N_strat
        History = zeros(T, 2);
        matchpayoffs = zeros(2, 1);

        % Assign strategy function handles
        strategy1 = funList{i};
        strategy2 = funList{j};

        % Play the game
        for round = 1:T
            History(round, 1) = strategy1(History);
            History(round, 2) = strategy2(flip(History,2));
        end

        % Calculate scores for the match
        for v = 1:T
            matchpayoffs(1) = matchpayoffs(1) + B(History(v, 1) , History(v, 2));
            matchpayoffs(2) = matchpayoffs(2) + B(History(v, 2) , History(v, 1));
        end
        payoff(i, j) = matchpayoffs(1);
        payoff(j, i) = matchpayoffs(2);
    end
end

% Initialize population matrix with POP0
POP = zeros(J + 1, N_strat);
POP(1, :) = POP0;

% Initialize BST and FIT matrices for results of each generation
BST = zeros(J, N_strat);
FIT = zeros(J, N_strat);

% Simulate each generation
for i = 1: J
    % Calculate score of each strategy according to Mathieu et al.
    for j = 1: N_strat
        for k = 1: N_strat
            FIT(i, j) = FIT(i, j) + payoff(j, k) * POP(i, k);
        end
        FIT(i, j) = FIT(i, j) - payoff(j, j);
    end
    % Find and mark best strategy (or strategies)
    maxVal = max(FIT(i,:));
    allMaxIndices = find(FIT(i,:) == maxVal);
    BST(i, allMaxIndices) = 1;

    % Calculate total points and next generation population for
    % each strategy
    total_each = POP(i, :).*FIT(i, :);
    total = sum(total_each);
    for j = 1: N_strat
        POP(i+1, j) = floor(POP(i, j) * FIT(i, j)/total * N);
    end
    % TO DO: Add rounding error detection and fixing
    if(compensation)
        N_new = sum(POP(i+1, :));
        deficiency = N - N_new;
        while(deficiency > 0)
            k = randi(N_strat);
            if POP(i, k)==0
                continue
            end
            POP(i+1, k) = POP(i+1, k) + 1;
            deficiency = deficiency - 1;
        end
    end
end
end