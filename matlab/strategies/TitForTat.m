function Move = TitForTat(History)
    if  History(1,1)==0
        Move = 1;
    else
        Move = History(find(History(:, 1),1,'last'), 2);
    end
end