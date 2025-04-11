function Move = TitForTwoTats(History)
% Plays Defect only if opponent defected twice in a row.
    round = nnz(History(:,1)) +1;
    if  round < 3
        Move = 1;
    elseif isequal(History(round - 2: round - 1, 2), [2; 2]) 
        Move = 2;
    else
        Move = 1;
    end
end