function decision = TitForTat(player, round, game, flags)
if round == 1
    decision = 1;
else
    decision = game(3 - player, round - 1);
end
end