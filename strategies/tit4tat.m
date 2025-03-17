function decision = tit4tat(player, round, game, flags)
if round == 1
    decision = 'C';
else
    decision = game(3 - player, round - 1);
end
end