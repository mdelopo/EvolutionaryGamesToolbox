function Move = TwoTitsForTat(History)
% A player starts by cooperating and replies to each defect by two defections.
round = nnz(History(:,1)) +1;
if  round<3
    Move = TitForTat(History);
elseif History(round-1,2)==2 || History(round-2,2)==2
    Move = 2;
else
    Move=1;
end
end