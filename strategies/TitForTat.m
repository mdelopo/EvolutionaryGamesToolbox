function Move = TitForTat(History)
    if  History(1,1)==0
        Move = 1;
    else
        Move = History(2, find(History(1,:),1,'last'));
    end
end