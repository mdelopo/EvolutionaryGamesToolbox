function Scores = Axel(B, Strategies, Pop, T)
    addpath('./strategies/');
    N = sum(Pop); % Total number of players
    Scores = zeros(N, 1);
    funList = cellfun(@str2func,Strategies,'uniformOutput',false);

    % Compute cumulative population to determine player groups
    PopCumsum = cumsum([0, Pop]); 
    
    for i = 1:N-1
        for j = i+1:N
            game = zeros(2, T);
            matchpayoffs = zeros(2, 1);
            
            % Determine strategy indices
            idx1 = find(i > PopCumsum(1:end-1) & i <= PopCumsum(2:end), 1, 'first');
            idx2 = find(j > PopCumsum(1:end-1) & j <= PopCumsum(2:end), 1, 'first');

            if isempty(idx1) || isempty(idx2)
                error('Strategy index is empty. Check Pop and Strategies inputs.');
            end
            
            % Assign strategy function handles
            strategy1 = funList{idx1}; 
            strategy2 = funList{idx2};

            % Play the game
            for round = 1:T
                game(1, round) = strategy1(game, 1);
                game(2, round) = strategy2(game, 2);
            end
            
            % Calculate scores for the match
            for v = 1:T
                matchpayoffs(1) = matchpayoffs(1) + B(game(1, v) , game(2, v));
                matchpayoffs(2) = matchpayoffs(2) + B(game(2 ,v) , game(1 ,v));
            end

            % Update total scores
            Scores(i) = Scores(i) + matchpayoffs(1);
            Scores(j) = Scores(j) + matchpayoffs(2);
        end
    end
end