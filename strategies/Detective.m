function Move = Detective(History)
% Starts with C, D, C, C, or with the given sequence of moves. If the opponent defects at
% least once in the first fixed rounds, play as TFT forever, else defect forever.
startingMoves = [1 2 1 1];
round = find(History(:, 1),1,'last') +1;
if round <= length(startingMoves)
    Move = startingMoves(round);
elseif any(History(1:length(startingMoves),2)==2)
    Move=TitForTat(History);
else
    Move=All_D(History);
end
end