function Move = Alternator(History)
%Alternates between cooperating and defecting
%Starts by cooperating in the first round
    numRounds = size(History, 1);

    if mod(numRounds - 1, 2) == 0
        Move = 1;
    else
        Move = 0;
    end
end