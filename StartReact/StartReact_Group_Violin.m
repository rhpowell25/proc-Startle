function StartReact_Group_Violin(Muscle, State, Save_Figs)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Subject', 'All', ... % Subject Name
    'Task', 'StartReact', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', State, ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Box';

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 0; 

% Font specifications
line_width = 3;
axis_expansion = 0.025;
plot_colors = [0.85 0.325 0.098; 0 0.447 0.741];
label_font_size = 25;
title_font_size = 25;
p_value_dims = [0.175 0.45 0.44 0.44];
legend_size = 25;
font_name = 'Arial';
fig_size = 1000;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Extract the control StartReact metrics
Sampling_Params.Group = 'Control';
if strcmp(State, 'RS')
    [~, con_StartReact] = RS_Gain_Summary(Sampling_Params);
elseif strcmp(State, 'Delta')
    [con_StartReact, ~] = RS_Gain_Summary(Sampling_Params);
else
    [rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
    con_StartReact = zeros(length(rxn_time_excel), 1);
    for ii = 1:length(con_StartReact)
        con_StartReact(ii,1) = mean(rxn_time_excel{ii,1}.rxn_time, 'omitnan');
    end
end
merged_con = repmat({'Control'}, length(con_StartReact), 1);

%% Extract the SCI StartReact metrics
Sampling_Params.Group = 'SCI';
if strcmp(State, 'RS')
    [~, SCI_StartReact] = RS_Gain_Summary(Sampling_Params);
elseif strcmp(State, 'Delta')
    [SCI_StartReact, ~] = RS_Gain_Summary(Sampling_Params);
else
    [rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
    SCI_StartReact = zeros(length(rxn_time_excel), 1);
    for ii = 1:length(SCI_StartReact)
        SCI_StartReact(ii,1) = mean(rxn_time_excel{ii,1}.rxn_time, 'omitnan');
    end
end
merged_SCI = repmat({'SCI'}, length(SCI_StartReact), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
y_max = max([con_StartReact; SCI_StartReact]);
y_min = min([con_StartReact; SCI_StartReact]);

% Title & y-label
y_label = 'Time (sec.)';
if strcmp(State, 'RS')
    title_string = 'Reticulospinal Gain';
    y_label = '';
elseif strcmp(State, 'Delta')
    title_string = '[F+s] - [F+S]';
else
    title_string = strcat('[', State, ']');
end
title_string = strcat('StartReact:', {' '}, title_string);

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 25 fig_size fig_size];
hold on

% Title
%title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Plot
if strcmp(plot_choice, 'Box')
    boxplot([con_StartReact; SCI_StartReact], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot([con_StartReact; SCI_StartReact], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'}, 'ViolinColor', plot_colors);
end

set(gca,'fontsize', label_font_size)

% Labels
xlabel('Group', 'FontSize', label_font_size)
ylabel(y_label, 'FontSize', label_font_size)

% Set the axis-limits
xlim([0.5 2.5]);
ylim([y_min - axis_expansion y_max + axis_expansion]);

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

% Do the statistics
[~, peaktopeak_p_val] = ttest2(con_StartReact, SCI_StartReact);

% Annotation of the p_value
if isequal(plot_stats, 1)
    if round(peaktopeak_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(peaktopeak_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'left');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
    
    if isequal(round(peaktopeak_p_val, 3), 0)
        p_value_string = strcat('p <', {' '}, '0.001');
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ...
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'left');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
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








