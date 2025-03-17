clear;
clc;
addpath('./strategies/');

guiUtils;

strList= {'cooperate','defect','tit4tat','grim'};
funList = cellfun(@str2func,strList,'uniformOutput',false);

prompt = "How many rounds will the tournament be? ";
rounds = input(prompt);
prompt = "Which strategy will the first player follow? ";
strategy1 = funList{find(strcmp(strList,input(prompt,'s')))};
prompt = "Which strategy will the second player follow? ";
strategy2 = funList{find(strcmp(strList,input(prompt,'s')))};


flags = [false, false]; % Flags for defection by either player

game = zeros(2, rounds);
player = 1;
for round = 1:rounds
    if player == 1 
        game(1, round) = strategy1(player, round, game, flags);
        if game(1, round) == 'D'
            flags(1) = true;
        end
        player = 2;
    end
    if player == 2
        game(2, round) = strategy2(player, round, game, flags);
        if game(2, round) == 'D'
            flags(2) = true;
        end
        player = 1;
    end
end

fprintf('%s: %s\n',char(strategy1), game(1,:));
fprintf('%s: %s\n',char(strategy2), game(2,:));

scores = [0 0]; % Calculate scores for the two players
for i = 1:rounds
    if game(1,i) == 'C' && game(2,i) == 'C'
        scores(1) = scores(1) + A(1,1);
        scores(2) = scores(2) + B(1,1);
    elseif game(1,i) == 'C' && game(2,i) == 'D'
        scores(1) = scores(1) + A(1,2);
        scores(2) = scores(2) + B(1,2);
    elseif game(1,i) == 'D' && game(2,i) == 'C'
        scores(1) = scores(1) + A(2,1);
        scores(2) = scores(2) + B(2,1);
    else
        scores(1) = scores(1) + A(2,2);
        scores(2) = scores(2) + B(2,2);
    end
end

fprintf('%s: %d\n',char(strategy1), scores(1));
fprintf('%s: %d\n',char(strategy2), scores(2));
