function State_Histogram(Group, State, Save_Figs)

%% File Description:

% This function plots a histogram of reaction times (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Load all subject details from the group
Subjects = 'PM';

% Font specifications
label_font_size = 17;
legend_size = 13;
mean_line_width = 2;
title_font_size = 20;
fig_size = 600;

% Plot colors
plot_colors = struct([]);
plot_colors{1} = [0 0.4470 0.7410];
plot_colors{2} = [0.4940 0.1840 0.5560];
plot_colors{3} = [0.6350 0.0780 0.1840];

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables
Task_Name = {'AbH_Flex'; 'TA'; 'SOL'};

State_rxn_time = struct([]);
avg_rxn_time = zeros(length(Task_Name),1);

%% Look through all the tasks
for ii = 1:length(Task_Name)

    [State_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subjects, Task_Name{ii}, State);
    
    if ~isempty(State_rxn_time_excel)
        State_rxn_time{ii,1} = State_rxn_time_excel{1,1}.rxn_time;
        avg_rxn_time(ii,1) = mean(State_rxn_time{ii,1});
    else
        State_rxn_time{ii,1} = NaN;
        avg_rxn_time(ii,1) = NaN;
    end
end

%% Plot the histograms

hist_fig = figure;
hist_fig.Position = [200 50 fig_size fig_size];
hold on

% Title
State_title = State;
title_string = (strcat('EMG Reaction Times:', {' '}, State_title));
sgtitle(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Axis Editing
figure_axes = gca;
% Set ticks to outside
set(figure_axes,'TickDir','out');
% Remove the top and right tick marks
set(figure_axes,'box','off')
% Set the tick label font size
figure_axes.FontSize = label_font_size;

% Labels
xlabel('Reaction Time (Sec.)', 'FontSize', label_font_size)
ylabel('Trials', 'FontSize', label_font_size);

for ii = 1:3%length(Task_Name)
    if isnan(State_rxn_time{ii,1})
        continue
    end
    % State histogram
    histogram(State_rxn_time{ii}, 10, 'EdgeColor', 'k', 'FaceColor', plot_colors{ii});
end

% Get the axes
y_limits = ylim;
x_limits = xlim;

% Plot dummy points for the legend
dummy_Flex = plot(-1,-1, 's', 'MarkerSize',20, 'LineWidth', 1.5, ...
        'MarkerEdgeColor', plot_colors{1}, 'MarkerFaceColor', plot_colors{1});
dummy_Abd = plot(-2,-1, 's', 'MarkerSize',20, 'LineWidth', 1.5, ...
        'MarkerEdgeColor',plot_colors{2}, 'MarkerFaceColor',plot_colors{2});
dummy_Plant = plot(-3,-1, 's', 'MarkerSize',20, 'LineWidth', 1.5, ...
        'MarkerEdgeColor',plot_colors{3}, 'MarkerFaceColor',plot_colors{3});

% Set the axis
xlim([x_limits(1), x_limits(2)])
ylim([y_limits(1), y_limits(2)])

% Plot the means
for ii = 1:3%length(avg_rxn_time)
    line([avg_rxn_time(ii) avg_rxn_time(ii)], [y_limits(1) y_limits(2)], ... 
        'LineStyle','--', 'Color', plot_colors{ii}, 'LineWidth', mean_line_width)
end

% Plot the legend
legend([dummy_Flex, dummy_Abd, dummy_Plant], ... 
    {'AbH Flexion', 'AbH Abduction', 'Plantar Flexion'}, ... 
    'FontSize', legend_size, 'Location', 'NorthEast')
legend boxoff

% Only label every other tick
x_labels = string(figure_axes.XAxis.TickLabels);
y_labels = string(figure_axes.YAxis.TickLabels);
x_labels(1:2:end) = NaN;
y_labels(1:2:end) = NaN;
figure_axes.XAxis.TickLabels = x_labels;
figure_axes.YAxis.TickLabels = y_labels;

%% Statistics

% Put the reaction time changes in the same array
d_rxn_time = cat(1, State_rxn_time{1}, State_rxn_time{2}, State_rxn_time{3});

AbH_Flex_string = cell(length(State_rxn_time{1}), 1);
AbH_Flex_string(:) = {'AbH Flex'};
AbH_Abd_string = cell(length(State_rxn_time{2}), 1);
AbH_Abd_string(:) = {'AbH Abd'};
Plantar_string = cell(length(State_rxn_time{3}), 1);
Plantar_string(:) = {'Plantar'};
Task_Names = cat(1, AbH_Flex_string, AbH_Abd_string, Plantar_string);

[p,t,stats] = anova1(d_rxn_time, Task_Names);
[c,m,h,gnames] = multcompare(stats);

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        save_title = strrep(title_string, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
        save_title = strrep(save_title, '{ }', ' ');
        if ~strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), Save_Figs)
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'fig')
        end
        close gcf
    end
end








