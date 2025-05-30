function SC = PlotStateTransitionGraph(P, POP0, Strategies, Title)
    global figurepath
    % INPUTS:
    %   P         - Transition matrix (NxN)
    %   POP0      - Initial population vector (1xS)
    %   Strategies- Cell array of strategy names {'AllD', 'AllC', 'TFT', ...}
    %   Title     - Title for the plot

	state_space = GenerateStateSpace(length(Strategies), sum(POP0), POP0');
	[src, dst, probs] = find(P);

	numStates = size(P,1);
	N = sum(POP0); % Number of agents

    l1 = Sta2Num001([N 0 0], state_space);
    l2 = Sta2Num001([0 N 0], state_space);
    l3 = Sta2Num001([0 0 N], state_space);

    PP = P^100;
    SC = PP(:, [l2 l1 l3]);

    for l = 1:numStates
        if min(min(SC)) == -inf
            SC(l, :) = [0 0 0];
        else
            SC(l, :) = SC(l, :) / (sum(SC(l, :)) + 0.01);
        end
    end
    fig = figure;
    % Set figure size for A4 landscape minus 2.54 cm margins
    a4_height_cm = 29.7;
    a4_width_cm = 21.0;
    margin_cm = 2.54;

    usable_width = a4_width_cm - 2 * margin_cm;
    usable_height = (a4_height_cm - 2 * margin_cm);
    %usable_height=usable_width;
    % Adjust figure position and size (on screen)
    set(fig, 'Units', 'centimeters');
    set(fig, 'Position', [0, 0, usable_width, usable_height*0.6]);

    % Set correct paper settings for exporting
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize', [usable_width, usable_height*0.6]);
    set(fig, 'PaperPosition', [0, 0, usable_width, usable_height*0.6]);

    G = digraph(P);
    G = rmedge(G, 1:numnodes(G), 1:numnodes(G));
	disp(['Size of state_space: ', mat2str(size(state_space))]);
    h = plot(G, 'XData', state_space(:,2), 'YData', state_space(:,3));
    h.NodeColor = SC;
    % h.MarkerSize = 7;
    % h.ArrowSize = 7;
    % h.EdgeLabelColor = "#A2142F";
    % h.EdgeLabel = arrayfun(@(w) sprintf('%.2f', w), G.Edges.Weight, 'UniformOutput', false);
    % h.EdgeFontSize = 5;
    grid on;
    title(Title);
    xlabel('Population of All-D');
    ylabel('Population of Grim');
    exportgraphics(fig,figurepath+Title+'.pdf','ContentType','vector')
end

function idx = Sta2Num001(stateVec, S)
    % Find the row index in S that matches stateVec exactly
    idx = find(ismember(S, stateVec, 'rows'), 1);
    
    if isempty(idx)
        error('State not found in S.');
    end
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