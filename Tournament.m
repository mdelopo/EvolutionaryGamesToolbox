clear;
clc;

%prompt = "Define game bimatrix. ";
% = input(prompt);

prompt = "How many rounds will the tournament be? ";
rounds = input(prompt);

flags = [false, false]; % Flags for defection by either player

game = zeros(2, rounds);
player = 1;
for round = 1:rounds
    if player == 1 
        game(1, round) = grim(player, round, game, flags);
        if game(1, round) == 'D'
            flags(1) = true;
        end
        player = 2;
    end;
    if player == 2
        game(2, round) = tit4tat(player, round, game, flags);
        if game(2, round) == 'D'
            flags(2) = true;
        end
        player = 1;
    end;
end;

game

function decision = cooperate(player, round, game, flags)
decision = 'C';
end

function decision = defect(player, round, game, flags)
decision = 'D';
end

function decision = tit4tat(player, round, game, flags)
if round == 1
    decision = 'C';
else
    decision = game(3 - player, round - 1);
end
end

function decision = grim(player, round, game, flags)
    if flags(3 - player) == false
        decision = 'C';
    else
        decision = 'D';
    end
end