function StartMEP_AVG_Violin(Muscle, Group, Save_File)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Group', Group, ... % Group Name ('Control', 'SCI')
    'Subject', 'All', ... % Subject Name
    'Task', 'StartMEP', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 1; 

% Font specifications
axis_expansion = 0.025;
plot_colors = [1 0 0; .7 .7 .7; 0, 0, 0];
label_font_size = 25;
title_font_size = 25;
p_value_dims = [0.1 0.45 0.44 0.44];
legend_size = 25;
font_name = 'Arial';
fig_size = 1000;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Extract the control StartReact metrics
[rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
MEP_amps = zeros(length(rxn_time_excel), 3);
States = strings(length(rxn_time_excel), 3);
for ii = 1:length(rxn_time_excel)
    Muscle_idx = contains(rxn_time_excel{ii,1}.Properties.VariableNames, Muscle);
    MEP_idx = strcmp(rxn_time_excel{ii,1}.State, 'MEP');
    States(ii,1) = 'MEP';
    MEP_amps(ii,1) = table2array(mean(rxn_time_excel{ii,1}(MEP_idx,Muscle_idx)));
    fifty_idx = strcmp(rxn_time_excel{ii,1}.State, 'MEP+50ms');
    States(ii,2) = 'MEP+50ms';
    MEP_amps(ii,2) = mean(table2array(rxn_time_excel{ii,1}(fifty_idx,Muscle_idx)));
    eighty_idx = strcmp(rxn_time_excel{ii,1}.State, 'MEP+80ms');
    States(ii,3) = 'MEP+80ms';
    MEP_amps(ii,3) = mean(table2array(rxn_time_excel{ii,1}(eighty_idx,Muscle_idx)));
end

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 25 fig_size fig_size];
hold on

% Title
Fig_Title = strcat('Reaction Times:', {' '}, Sampling_Params.Group, {' '}, Sampling_Params.Task, ...
    {' '}, '[', Sampling_Params.Muscle, ']');
%sgtitle(Fig_Title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('States', 'FontSize', label_font_size)
ylabel('Peak-To-Peak Amplitude (mv.)', 'FontSize', label_font_size);

% Plot
if strcmp(plot_choice, 'Box')
    boxplot(MEP_amps, States, 'GroupOrder', {'F+S', 'F+s', 'F'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot(MEP_amps, States, ...
        'ViolinColor', plot_colors, 'GroupOrder', {'MEP', 'MEP+50ms', 'MEP+80ms'});
end

set(gca,'fontsize', label_font_size)

% Find the y_limits
y_min = min(MEP_amps, [], 'all');
y_max = max(MEP_amps, [], 'all');

% Set the axis-limits
xlim([0.5 3.5]);
ylim([y_min - axis_expansion, y_max + axis_expansion])

% Axis Editing
figure_axes = gca;
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
    [~, rxntime_p_val] = ttest2(MEP_amps(States == 'F+S'), ...
        MEP_amps(States == 'F+s'));

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

    %% Save the file if selected
    Save_Figs(Fig_Title, Save_File)
    
end







