function decision = TitForTat(game, player)
    if  game(player,1)==0
        decision = 1;
    else
        decision = game(3 - player, find(game(player,:),1,'last'));
    end
end