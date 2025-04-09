function Move = APavlov(History)
% Adaptive Pavlov. Starts playing TitForTat for 6 rounds, then attempts to
% classify the opponent as one of 4 strategies: All_C, All_D, SneakyTFT and
% Random. Plays accordingly to either achieve cooperation or defect against
% uncooperative opponents.
round = find(History(:, 1),1,'last') +1;
if round <= 6
    Move = TitForTat(History);
elseif isequal(History(1:6,2), [1, 1, 1, 1, 1, 1])
    Move = TitForTat(History); % Play as TFT, assume opponent is Cooperative
elseif sum(History(1:6,2) == 2) == 3
    Move = TitForTwoTats(History); % Assume opponent is SneakyTFT, play accordingly
else 
    Move = All_D(History); % Assume opponent is defective or random
end
end