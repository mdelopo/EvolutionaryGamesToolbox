
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