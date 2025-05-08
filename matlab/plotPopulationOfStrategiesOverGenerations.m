function fig = plotPopulationOfStrategiesOverGenerations(Strategies, POP, Title)
% Determine number of generations
num_generations = size(POP, 1);
% Create generation index
generations = 1:num_generations;

fig = figure;
% Plot each strategy
for i=1:size(POP,2)
    plot(generations, POP(:,i), 'LineWidth', 2); hold on;
end
% Add labels and legend
xlabel('Generation');
ylabel('Population');
legend_strategies = replace(Strategies,"_","\_");
legend(legend_strategies);
title(Title);
subtitle('Population of Strategies Over Generations')
grid on;
set(1, 'units', 'centimeters', 'pos', [0 0 (21-5.1) (29.7-5.1)/3.5])
exportgraphics(fig,'figures/'+Title+'.pdf','ContentType','vector')
end