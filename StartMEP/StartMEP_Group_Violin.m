function StartMEP_Group_Violin(Muscle, State, Save_Figs)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Task', 'StartMEP', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', State, ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Load all subject details from the group
[Control_Names] = SIG_File_Details('Control');
[SCI_Names] = SIG_File_Details('SCI');

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 0;

% Font specifications
line_width = 3;
axis_expansion = 0.5;
mean_line_width = 4;
plot_colors = [0.85 0.325 0.098; 0 0.447 0.741];
label_font_size = 25;
title_font_size = 25;
p_value_dims = [0.51 0.45 0.44 0.44];
legend_size = 25;
font_name = 'Arial';
fig_size = 1000;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Extract the control StartMEP metrics
Sampling_Params.Group = 'Control';
con_StartMEP = struct([]);
for ii = 1:length(Control_Names)
    Sampling_Params.Subject = Control_Names{ii};
    if strcmp(State, 'MEP')
        [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
        Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
        MEP_idx = strcmp(AbH_excel{1,1}.State, 'MEP');
        if ~isempty(AbH_excel)
            con_StartMEP{ii,1} = table2array(mean(AbH_excel{1,1}(MEP_idx, Muscle_idx), 'omitnan'));
        end
    else
        Sampling_Params.State = 'MEP';
        [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
        Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
        if ~isempty(AbH_excel)
            test_idx = strcmp(AbH_excel{1,1}.State, 'MEP');
            test_peaktopeak = table2array(mean(AbH_excel{1,1}(test_idx, Muscle_idx), 'omitnan'));
            Sampling_Params.State = State;
            [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
            Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
            cond_idx = strcmp(AbH_excel{1,1}.State, State);
            cond_amps = table2array(AbH_excel{1,1}(cond_idx, Muscle_idx));
            con_StartMEP{ii,1} = mean(cond_amps, 'omitnan') / test_peaktopeak * 100;
        end
    end
end

%% Extract the SCI StartMEP metrics
Sampling_Params.Group = 'SCI';
SCI_StartMEP = struct([]);
for ii = 1:length(SCI_Names)
    Sampling_Params.Subject = SCI_Names{ii};
    if strcmp(State, 'MEP')
        [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
        Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
        MEP_idx = strcmp(AbH_excel{1,1}.State, 'MEP');
        if ~isempty(AbH_excel)
            SCI_StartMEP{ii,1} = table2array(mean(AbH_excel{1,1}(MEP_idx, Muscle_idx), 'omitnan'));
        end
    else
        Sampling_Params.State = 'MEP';
        [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
        Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
        if ~isempty(AbH_excel)
            test_idx = strcmp(AbH_excel{1,1}.State, 'MEP');
            test_peaktopeak = table2array(mean(AbH_excel{1,1}(test_idx, Muscle_idx), 'omitnan'));
            Sampling_Params.State = State;
            [AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
            Muscle_idx = contains(AbH_excel{1,1}.Properties.VariableNames, Muscle);
            cond_idx = strcmp(AbH_excel{1,1}.State, State);
            cond_amps = table2array(AbH_excel{1,1}(cond_idx, Muscle_idx));
            SCI_StartMEP{ii,1} = mean(cond_amps, 'omitnan') / test_peaktopeak * 100;
        end
    end
end

%% Merge the StartMEP metrics
% Control
merged_con_StartMEP = [];
for ii = 1:length(con_StartMEP)
    merged_con_StartMEP = cat(1, merged_con_StartMEP, con_StartMEP{ii,1});
end
merged_con = repmat({'Control'}, length(merged_con_StartMEP), 1);

% SCI
merged_SCI_StartMEP = [];
for ii = 1:length(SCI_StartMEP)
    merged_SCI_StartMEP = cat(1, merged_SCI_StartMEP, SCI_StartMEP{ii,1});
end
merged_SCI = repmat({'SCI'}, length(merged_SCI_StartMEP), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
y_max = max([merged_con_StartMEP; merged_SCI_StartMEP]);
y_min = min([merged_con_StartMEP; merged_SCI_StartMEP]);

% Title & y-label
if strcmp(State, 'MEP')
    y_label = 'Peak-To-Peak Amplitude (mV)';
else
    y_label = 'Peak-To-Peak Amplitude (%)';
    axis_expansion = axis_expansion * 100;
end
title_string = strcat('StartMEP:', {' '}, '[', State, ']');

%% Plot the Violin Plot

plot_fig = figure;
plot_fig.Position = [200 50 fig_size fig_size];
hold on

% Title
title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Group', 'FontSize', label_font_size)
ylabel(y_label, 'FontSize', label_font_size)

% Plot
if strcmp(plot_choice, 'Box')
    boxplot([merged_con_StartMEP; merged_SCI_StartMEP], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot([merged_con_StartMEP; merged_SCI_StartMEP], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'}, 'ViolinColor', plot_colors);
end

% Increase the font size
set(gca,'fontsize', label_font_size)

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

% Line at the 100% 
if ~strcmp(State, 'MEP')
    line([0.5 2.5], [100 100], ... 
        'LineStyle','--', 'Color', 'k', 'LineWidth', mean_line_width)
end

% Annotation of the p_value
if isequal(plot_stats, 1)

    % Do the statistics
    [~, peaktopeak_p_val] = ttest2(merged_con_StartMEP, merged_SCI_StartMEP);

    if round(peaktopeak_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(peaktopeak_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
    
    if isequal(round(peaktopeak_p_val, 3), 0)
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








