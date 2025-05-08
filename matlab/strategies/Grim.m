function Move = Grim(History)
    if any(History(1:nnz(History(:,1)), 2)==2)
        Move = 2;
    else
        Move = 1;
    end
end