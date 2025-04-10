function Move = TwoTitsForTat(History)
% Starts by cooperating and replies to each defect by two defections
     numRounds = size(History, 1);
    %First Move: Always Cooperate
    if numRounds == 0 || History(1,1) == 0 
        Move = 1;
        return;
    end
    
    punishRounds = 0;
    i = 1;
    %Loop Through History to Check for Unpunished Defections
    while i <= numRounds
        if History(i,2) == 0
            for j = 1:2
                if i + j <= numRounds
                    if History(i + j, 1) == 0
                        continue; % We already punished in this round
                    end
                else
                    % Future punishment still pending
                    punishRounds = 1;
                    break;
                end
            end
        end
        if punishRounds == 1
            break;
        end
        i = i + 1;
    end

    if punishRounds == 1
        Move = 0; % Still need to punish
    else
        Move = 1; % Otherwise, cooperate
    end
end
      

