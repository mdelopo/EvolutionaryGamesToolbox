function Move = per_ccccd(History)
% Permanently cycles the moves C, C, D.
round = nnz(History(:,1)) +1;
if mod(round, 5) == 0
    Move = 2;
else
    Move = 1;
end
end