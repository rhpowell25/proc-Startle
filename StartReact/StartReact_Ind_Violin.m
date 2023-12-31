function StartReact_Ind_Violin(sig, Save_File)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Group', sig.meta.group, ... % Group Name ('Control', 'SCI')
    'Subject', sig.meta.subject, ... % Subject Name
    'Task', sig.meta.task, ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', sig.meta.muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 1;

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
plot_colors = [1 0 0; .7 .7 .7; 0, 0, 0];
p_value_dims = [0.025 0.45 0.44 0.44];
axis_expansion = 0.05;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Load the reaction time excel
[rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
rxn_times = rxn_time_excel{1,1}.rxn_time;
States = string(rxn_time_excel{1,1}.State);

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 25 Plot_Params.fig_size Plot_Params.fig_size];
hold on

% Title
Fig_Title = strcat('Reaction Times:', {' '}, Sampling_Params.Subject, {' '}, Sampling_Params.Task, ...
    {' '}, '[', Sampling_Params.Muscle, ']');
%sgtitle(Fig_Title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('States', 'FontSize', Plot_Params.label_font_size)
ylabel('Reaction Time (Sec.)', 'FontSize', Plot_Params.label_font_size);

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

set(gca,'fontsize', Plot_Params.label_font_size)

% Find the y_limits
y_min = min(rxn_times);
y_max = max(rxn_times);

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
    [~, rxntime_p_val] = ttest2(rxn_times(States == 'F+S'), ...
        rxn_times(States == 'F+s'));

    if round(rxntime_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(rxntime_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = Plot_Params.legend_size;
        ann_p_value.FontName = Plot_Params.font_name;
    end
    
    if isequal(round(rxntime_p_val, 3), 0)
        p_value_string = strcat('p <', {' '}, '0.001');
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ...
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = Plot_Params.legend_size;
        ann_p_value.FontName = Plot_Params.font_name;
    end
end

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)




