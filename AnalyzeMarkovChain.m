function AnalyzeMarkovChain(P, POP0, Strategies)
    % INPUTS:
    %   P         - Transition matrix (NxN)
    %   POP0      - Initial population vector (1xS)
    %   Strategies- Cell array of strategy names {'AllD', 'AllC', 'TFT', ...}

    N = size(P,1);              % Number of states
    visited = false(N,1);       % Visited states
    queue = [];                 % For BFS traversal

    % Convert POP0 to index
    [state_space, POP0_index] = GenerateStateSpace(length(Strategies), sum(POP0), POP0');
    queue = [POP0_index];
    visited(POP0_index) = true;

    % Traverse reachable states
    while ~isempty(queue)
        current = queue(1);
        queue(1) = [];
        for next = 1:N
            if P(current,next) > 0 && ~visited(next)
                visited(next) = true;
                queue(end+1) = next;
            end
        end
    end

    % Classify states
    absorbing = false(N,1);
    transient = false(N,1);
    unreachable = ~visited;

    for i = 1:N
        if P(i,i) == 1 && all(P(i,:) == 0 | (1:N)==i)
            absorbing(i) = true;
        elseif any(P(i,:) > 0)
            transient(i) = true;
        end
    end

    % Build graph for visualization using only existing transitions
    [src, dst, probs] = find(P);
    G = digraph(src, dst, probs);

    % Assign colors to all nodes
    colors = zeros(N,3);
    nodeGroups = strings(N,1);
    for i = 1:N
        if i == POP0_index
            colors(i,:) = [0.2 0.4 0.9];  % Blue for starting state
            nodeGroups(i) = "Starting State";
        elseif unreachable(i) && absorbing(i)
            colors(i,:) = [0.5 0.5 1];  % Light blue for unreachable absorbing
            nodeGroups(i) = "Unreachable Absorbing";
        elseif unreachable(i) && transient(i)
            colors(i,:) = [1 0.8 0.6];  % Light orange for unreachable transient
            nodeGroups(i) = "Unreachable Transient";
        elseif absorbing(i)
            colors(i,:) = [0.2 0.6 0.2];  % Green for absorbing
            nodeGroups(i) = "Absorbing";
        elseif transient(i)
            colors(i,:) = [0.8 0.4 0.2];  % Orange for transient
            nodeGroups(i) = "Transient";
        else
            colors(i,:) = [0.7 0.7 0.7];  % Default gray for any other type
            nodeGroups(i) = "Other";
        end
    end

    % Prepare labels
    state_labels = arrayfun(@(i) mat2str(state_space(i,:)), 1:N, 'UniformOutput', false);

    % Plot graph
    figure;
    h = plot(G, 'Layout','force');
    h.NodeLabel = state_labels;
    h.NodeColor = colors;
    h.MarkerSize = 7;
    h.ArrowSize = 10;
    h.EdgeLabel = arrayfun(@(w) sprintf('%.2f', w), G.Edges.Weight, 'UniformOutput', false);

    % Add legend manually
    hold on;
    legendLabels = ["Starting State", "Absorbing", "Transient", ...
                    "Unreachable Absorbing", "Unreachable Transient"];
    legendColors = [0.2 0.4 0.9;  % Blue
                    0.2 0.6 0.2;  % Green
                    0.8 0.4 0.2;  % Orange
                    0.5 0.5 1;    % Light blue
                    1 0.8 0.6];   % Light orange
    hLegend = gobjects(length(legendLabels), 1);
    for i = 1:length(legendLabels)
        hLegend(i) = scatter(nan, nan, 70, legendColors(i,:), ...
                             'filled', 'o', 'MarkerEdgeColor', 'k');
    end
    legend(hLegend, legendLabels, 'Location', 'bestoutside');
    hold off;

    % Display strategy labels
    annotation('textbox', [0.75, 0.01, 0.2, 0.05], 'String', ...
        ['Strategies: ', strjoin(Strategies, ', ')], ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'left');
end

function [state_space, POP0_index] = GenerateStateSpace(num_strategies, total_population, POP0)
    state_space = [];
    POP0_index = -1;

    function recurse(vec, depth, remaining)
        if depth == num_strategies
            vec(depth) = remaining;
            state_space(end+1,:) = vec;
            if isequal(vec, POP0)
                POP0_index = size(state_space,1);
            end
            return;
        end
        for i = 0:remaining
            vec(depth) = i;
            recurse(vec, depth+1, remaining - i);
        end
    end

    recurse(zeros(1,num_strategies), 1, total_population);
end