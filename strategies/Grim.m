function decision = Grim(player, round, game, flags)
    if flags(3 - player) == false
        decision = 'C';
    else
        decision = 'D';
    end
end