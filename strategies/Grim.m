function decision = Grim(game, player)
    if any(game(3 - player,find(game(player,:),1,'last'))==2)
        decision = 2;
    else
        decision = 1;
    end
end