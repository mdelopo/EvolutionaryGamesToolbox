function Move = Grim(History)
    if any(History(find(History(:, 1),1,'last'), 2)==2)
        Move = 2;
    else
        Move = 1;
    end
end