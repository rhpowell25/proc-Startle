function PeriphStim_Group_Violin(Muscle, Wave_Choice, Save_File)

%% Basic Settings, some variable extractions, & definitions

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Plot persistance or peak-to-peak amplitude? ('Persist', 'Peak')
Plot_Choice = 'Peak';

% Do you want to normalize the F-wave? (1 = Yes, 0 = No)
norm_wave = 1;

% Do you want to show the statistics? (1 = Yes, 0 = No)
plot_stats = 0; 

% Load all subject details from the group
[Control_Names] = SIG_File_Details('Control');
[SCI_Names] = SIG_File_Details('SCI');

% Font specifications
line_width = 3;
axis_expansion = 0.1;
plot_colors = [0.85 0.325 0.098; 0 0.447 0.741];
label_font_size = 25;
title_font_size = 25;
p_value_dims = [0.51 0.45 0.44 0.44];
legend_size = 25;
font_name = 'Arial';
fig_size = 1000;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Extract the control peripheral nerve stimulations
con_Plot_Metric = struct([]);
for ii = 1:length(Control_Names)
    % Load the sig file
    [sig] = Load_SIG('Control', Control_Names{ii}, 'FWave', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    if strcmp(Plot_Choice, 'Peak')
        % Collect the peak to peak amplitudes
        [per_trial_Plot_Metric] = Trial_PeriphStim(sig, Muscle, Wave_Choice, 0, 0);
        if isequal(norm_wave, 1) && strcmp(Wave_Choice, 'F')
            [peak_M_Wave] = Trial_PeriphStim(sig, Muscle, 'M', 0, 0);
            per_trial_Plot_Metric = per_trial_Plot_Metric / mean(peak_M_Wave) * 100;
        end
        con_Plot_Metric{ii,1} = mean(per_trial_Plot_Metric);
    elseif strcmp(Plot_Choice, 'Persist')
        % Collect the F-Wave persistance
        [persistant_idxs, ~] = F_Wave_Persistance(sig, 'Raw');
        con_Plot_Metric{ii,1} = (length(persistant_idxs) / length(sig.trial_result))*100;
    end
end

%% Extract the SCI peripheral nerve stimulations
SCI_Plot_Metric = struct([]);
for ii = 1:length(SCI_Names)
    % Load the sig file
    [sig] = Load_SIG('SCI', SCI_Names{ii}, 'FWave', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    if strcmp(Plot_Choice, 'Peak')
        % Collect the peak to peak amplitudes
        [per_trial_Plot_Metric] = Trial_PeriphStim(sig, Muscle, Wave_Choice, 0, 0);
        if isequal(norm_wave, 1) && strcmp(Wave_Choice, 'F')
            [peak_M_Wave] = Trial_PeriphStim(sig, Muscle, 'M', 0, 0);
            per_trial_Plot_Metric = per_trial_Plot_Metric / mean(peak_M_Wave) * 100;
        end
        SCI_Plot_Metric{ii,1} = mean(per_trial_Plot_Metric);
    elseif strcmp(Plot_Choice, 'Persist')
        % Collect the F-Wave persistance
        [persistant_idxs, ~] = F_Wave_Persistance(sig, 'Raw');
        SCI_Plot_Metric{ii,1} = (length(persistant_idxs) / length(sig.trial_result))*100;
    end
end

%% Merge the amplitudes or persistance
% Control
merged_con_Plot_Metric = [];
for ii = 1:length(Control_Names)
    merged_con_Plot_Metric = cat(1, merged_con_Plot_Metric, con_Plot_Metric{ii,1});
end
merged_con = repmat({'Control'}, length(merged_con_Plot_Metric), 1);

% SCI
merged_SCI_Plot_Metric = [];
for ii = 1:length(SCI_Names)
    merged_SCI_Plot_Metric = cat(1, merged_SCI_Plot_Metric, SCI_Plot_Metric{ii,1});
end
merged_SCI = repmat({'SCI'}, length(merged_SCI_Plot_Metric), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
y_max = max([merged_con_Plot_Metric; merged_SCI_Plot_Metric]);
y_min = min([merged_con_Plot_Metric; merged_SCI_Plot_Metric]);

% Title & y-label
if strcmp(Wave_Choice, 'F')
    Fig_Title = 'F-Wave';
    if isequal(norm_wave, 1)
        Fig_Title = strcat('Normalized', {' '}, Fig_Title);
    end
elseif strcmp(Wave_Choice, 'M')
    Fig_Title = 'M-Max';
end
if strcmp(Plot_Choice, 'Peak')
    Fig_Title = strcat(Fig_Title, {' '}, 'Peak-Peak Amplitude:');
    y_label = 'Peak-Peak Amplitude';
    if isequal(norm_wave, 1) && strcmp(Wave_Choice, 'F')
        y_label = strcat(y_label, {' '}, '(% of M-Max)');
    else
        y_label = strcat(y_label, {' '}, '(mV)');
    end
    
elseif strcmp(Plot_Choice, 'Persist')
    Fig_Title = strcat(Fig_Title, {' '}, 'Persistance:');
    y_label = 'Persistance (%)';
end

%% Plot the Violin Plot

plot_fig = figure;
plot_fig.Position = [200 50 fig_size fig_size];
hold on

% Title
%title(Fig_Title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Group', 'FontSize', label_font_size)
ylabel(y_label, 'FontSize', label_font_size)

% Plot
if strcmp(plot_choice, 'Box')
    boxplot([merged_con_Plot_Metric; merged_SCI_Plot_Metric], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot([merged_con_Plot_Metric; merged_SCI_Plot_Metric], [merged_con; merged_SCI], 'GroupOrder', ...
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

% Do the statistics
[~, peaktopeak_p_val] = ttest2(merged_con_Plot_Metric, merged_SCI_Plot_Metric);

% Annotation of the p_value
if isequal(plot_stats, 1)
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

%% Statistics

%[p,t,stats] = anova1(d_rxn_time, Task_Names);
%[c,m,box_axes,gnames] = multcompare(stats);

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)








