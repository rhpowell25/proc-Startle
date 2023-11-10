function StartReact_AVG_Violin(Muscle, Group, Save_Figs)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Group', Group, ... % Group Name ('Control', 'SCI')
    'Subject', 'All', ... % Subject Name
    'Task', 'StartReact', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 0; 

% Font specifications
line_width = 3;
axis_expansion = 0.025;
plot_colors = [1 0 0; .7 .7 .7; 0, 0, 0];
label_font_size = 25;
title_font_size = 25;
p_value_dims = [0.1 0.45 0.44 0.44];
legend_size = 25;
font_name = 'Arial';
fig_size = 1000;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Extract the control StartReact metrics
[rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
rxn_times = zeros(length(rxn_time_excel), 3);
States = strings(length(rxn_time_excel), 3);
for ii = 1:length(rxn_time_excel)
    rxn_idx = contains(rxn_time_excel{ii,1}.Properties.VariableNames, 'rxn_time');
    F_idx = strcmp(rxn_time_excel{ii,1}.State, 'F');
    States(ii,1) = 'F';
    rxn_times(ii,1) = table2array(mean(rxn_time_excel{ii,1}(F_idx,rxn_idx)));
    Fs_idx = strcmp(rxn_time_excel{ii,1}.State, 'F+s');
    States(ii,2) = 'F+s';
    rxn_times(ii,2) = table2array(mean(rxn_time_excel{ii,1}(Fs_idx,rxn_idx)));
    FS_idx = strcmp(rxn_time_excel{ii,1}.State, 'F+S');
    States(ii,3) = 'F+S';
    rxn_times(ii,3) = table2array(mean(rxn_time_excel{ii,1}(FS_idx,rxn_idx)));
end

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 25 fig_size fig_size];
hold on

% Title
fig_title = strcat('Reaction Times:', {' '}, Sampling_Params.Group, {' '}, Sampling_Params.Task, ...
    {' '}, '[', Sampling_Params.Muscle, ']');
%sgtitle(fig_title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('States', 'FontSize', label_font_size)
ylabel('Reaction Time (Sec.)', 'FontSize', label_font_size);

% Plot
if strcmp(plot_choice, 'Box')
    boxplot(rxn_times, States, 'GroupOrder', {'F+S', 'F+s', 'F'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot(rxn_times, States, ...
        'ViolinColor', plot_colors, 'GroupOrder', {'F+S', 'F+s', 'F'});
end

set(gca,'fontsize', label_font_size)

% Find the y_limits
y_min = min(rxn_times, [], 'all');
y_max = max(rxn_times, [], 'all');

% Set the axis-limits
xlim([0.5 3.5]);
ylim([y_min - axis_expansion, y_max + axis_expansion])

% Axis Editing
figure_axes = gca;
set(gca,'linewidth', line_width)
% Set ticks to outside
set(figure_axes,'TickDir','out');
% Remove the top and right tick marks
set(figure_axes,'box','off')

% Only label every other tick
y_labels = string(figure_axes.YAxis.TickLabels);
y_labels(2:2:end) = NaN;
figure_axes.YAxis.TickLabels = y_labels;

% Annotation of the p_value
if isequal(plot_stats, 1)

    % Do the statistics
    [~, rxntime_p_val] = ttest2(rxn_times(States == 'F+S'), ...
        rxn_times(States == 'F+s'));

    if round(rxntime_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(rxntime_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
    
    if isequal(round(rxntime_p_val, 3), 0)
        p_value_string = strcat('p <', {' '}, '0.001');
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ...
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        save_title = strrep(fig_title, ':', '');
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








