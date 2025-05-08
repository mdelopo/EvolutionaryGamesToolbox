addpath('./strategies/');
rounds =10;
History=zeros(rounds,2);

for round = 1:rounds % Play the game
        History(round,1) = TwoTitsForTat(History);
        History(round,2) = SneakyTitForTat(flip(History,2));
end