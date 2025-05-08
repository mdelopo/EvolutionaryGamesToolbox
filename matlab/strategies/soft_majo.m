function Move = soft_majo(History)
    % Plays opponent's majority move, cooperating in case of equality
    round = nnz(History(:,1)) +1;
    cooperations = sum(History(1:(round-1),2)==1);
    defects = sum(History(1:(round-1),2)==2);
    if defects > cooperations
        Move = 2;
    else
        Move = 1;
    end
end