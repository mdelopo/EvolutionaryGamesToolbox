function Move = Detective(History)
% Starts with C, D, C, C. If the opponent defects at least once in the first fixed rounds,
% play as TFT forever, else defect forever.
startingMoves = [1 2 1 1];
round = nnz(History(:,1)) +1;
if round <= length(startingMoves)
    Move = startingMoves(round);
elseif any(History(1:length(startingMoves),2)==2)
    Move=TitForTat(History);
else
    Move=All_D(History);
end
end