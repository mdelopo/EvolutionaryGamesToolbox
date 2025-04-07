function Move = Prober(History)
% Starts with D, C, C. If the opponent cooperated at moves 2 and 3, 
% plays defect for the rest of the game. Otherwise plays TFT.
    startingMoves = [2 1 1];
    round = find(History(:, 1),1,'last') +1;
    if round <= length(startingMoves)
        Move = startingMoves(round);
    elseif History(2, 2) == 1 && History(2, 3) == 1
        Move=All_D(History); 
    else
        Move=TitForTat(History);
    end
end