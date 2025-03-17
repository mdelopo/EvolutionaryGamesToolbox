clear;
clc;

% Create a figure window
f = figure('Position', [500 300 500 300], 'Name', 'Bimatrix Game Input', 'NumberTitle', 'off', 'UserData', []);

% Define default matrices
A_default = [3 1; 4 2];
B_default = [3 4; 1 2];

% Add text labels
uicontrol('Style', 'text', 'Position', [50 210 180 20], 'String', 'Enter Payoff Matrix A:', 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [270 210 180 20], 'String', 'Enter Payoff Matrix B:', 'HorizontalAlignment', 'left');

% Create UI tables for A and B
uitable('Parent', f, 'Data', A_default, 'Position', [50 100 180 100], ...
        'ColumnEditable', true(1, size(A_default,2)), 'Tag', 'A_table', 'ColumnName', {});
uitable('Parent', f, 'Data', B_default, 'Position', [270 100 180 100], ...
        'ColumnEditable', true(1, size(B_default,2)), 'Tag', 'B_table', 'ColumnName', {});

% Create a button to confirm input
uicontrol('Style', 'pushbutton', 'String', 'Confirm', 'Position', [200 50 100 30], ...
          'Callback', @confirmCallback);

% Pause execution until GUI is closed
uiwait(f);

% Retrieve stored matrices
if isvalid(f) % Check if figure still exists before accessing its data
    data = get(f, 'UserData');
    A = data.A;
    B = data.B;
    
    % Display the matrices
    fprintf('First payoff matrix (A):\n');
    disp(A);
    fprintf('Second payoff matrix (B):\n');
    disp(B);
    
    close(f); % Close the UI after retrieving data
end


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
    end;
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

% Callback function to retrieve table data
function confirmCallback(~, ~)
    f = gcbf; % Get figure handle
    if isvalid(f) % Ensure the figure exists before proceeding
        A_table = findobj('Tag', 'A_table');
        B_table = findobj('Tag', 'B_table');

        % Store matrices in figure UserData
        set(f, 'UserData', struct('A', A_table.Data, 'B', B_table.Data));

        % Resume execution and close GUI
        uiresume(f);
    end
end                                                                                                                                                                                                                                                                                             

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