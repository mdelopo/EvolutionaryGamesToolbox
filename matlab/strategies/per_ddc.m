function Move = per_ddc(History)
% Permanently cycles the moves D, D, C.
round = nnz(History(:,1)) +1;
if mod(round, 3) == 0
    Move = 1;
else
    Move = 2;
end
end