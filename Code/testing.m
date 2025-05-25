addpath('./strategies/');
rounds =10;
History=zeros(rounds,2);

for round = 1:rounds % Play the game
        History(round,1) = SneakyTitForTat(History);
        History(round,2) = soft_majo(flip(History,2));
end
History