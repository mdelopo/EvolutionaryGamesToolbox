function decision = Grim(player, round, game, flags)
    if flags(3 - player) == false
        decision = 1;
    else
        decision = 2;
    end
end