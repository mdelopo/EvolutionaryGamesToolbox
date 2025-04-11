function Move = Alternator(History)
%Alternates between cooperating and defecting
%Starts by cooperating in the first round

round = nnz(History(:,1))+1;
if mod(round, 2) == 0
    Move = 2;
else
    Move = 1;
end
end