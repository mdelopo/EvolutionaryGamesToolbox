function Move = TwoTitsForTat(History)
    
    persistent punishment

    if isempty(punishment)
        punishment = 0; %tracks how many times we need to defect
    end
   
    % First move: cooperate
    if History(1,1) == 0
        Move = 1;
        return;
    end

    % Check if opponent defected last round
    if History(find(History(:,1), 1, 'last'), 2) == 2  % opponent defected
        punishment = punishment + 2;
    end

    if punishment > 0
        Move = 2; % defect
        punishment = punishment - 1;
    else
        Move = 1; % cooperate
    end
end