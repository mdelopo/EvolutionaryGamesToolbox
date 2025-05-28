function fig = plotPopulationsOfStrategiesOverGenerations(Strategies, POP1, POP2, POP3, Title)
global figurepath

% Determine number of generations
num_generations = size(POP1, 1);
% Create generation index
generations = 1:num_generations;

fig = tiledlayout(3,1);

nexttile
% Plot each strategy
for i=1:size(POP1,2)
    plot(generations, POP1(:,i), 'LineWidth', 2); hold on;
end
% Add labels and legend
subtitle('TourTheFit')
grid on;
xlim([1 size(POP1,1)])

nexttile
% Plot each strategy
for i=1:size(POP2,2)
    plot(generations, POP2(:,i), 'LineWidth', 2); hold on;
end
% Add labels and legend
subtitle('TourSimFit - without compensation')
grid on;
xlim([1 size(POP1,1)])

nexttile
% Plot each strategy
for i=1:size(POP3,2)
    plot(generations, POP3(:,i), 'LineWidth', 2); hold on;
end
% Add labels and legend
subtitle('TourSimFit - with compensation')
grid on;
xlim([1 size(POP1,1)])

t=title(fig,Title);
subtitle(fig,'Populations of Strategies Over Generations');
t.FontWeight = 'bold';
fig.TileSpacing = 'compact';
fig.Padding = 'compact';
legend_strategies = replace(Strategies,"_","\_");
leg = legend(legend_strategies,'Orientation', 'Horizontal');
leg.Layout.Tile = 'south';
xlabel(fig, 'Generation');
ylabel(fig, 'Population');
set(1, 'units', 'centimeters', 'pos', [0 0 (21-5.1) (29.7-5.1)/1.3])

exportgraphics(fig,figurepath+Title+'.pdf','ContentType','vector')
end