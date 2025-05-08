function Move = per_ccd(History)
% Permanently cycles the moves C, C, D.
round = nnz(History(:,1)) +1;
if mod(round, 3) == 0
    Move = 2;
else
    Move = 1;
end
end