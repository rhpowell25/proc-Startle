function PeriphStim_Ind_Violin(sig, Wave_Choice, Save_Figs)

%% File Description:

% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Define the muscle groups of interest
%muscle_groups = {'ABH'; 'TA'; 'SOL'};
muscle_groups = {'ABH'};

% Title info
Subject = sig.meta.subject;

% Font specifications
plot_colors = [0 0.5 0];
axis_expansion = 0.05;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables

title_strings = struct([]);

%% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;
  
%% Extract the peripheral nerve stimulations
[persistant_idxs] = F_Wave_Persistance(sig);
all_trials_metric = strings(length(persistant_idxs), length(muscle_groups));
Plot_Metric = zeros(length(persistant_idxs), length(muscle_groups));
% Collect the peak to peak amplitudes
for ii = 1:length(muscle_groups)
    [Plot_Metric(:,ii)] = Trial_PeriphStim(sig, muscle_groups{ii,1}, Wave_Choice, 0, 0);
    all_trials_metric(:,ii) = repmat(muscle_groups(ii), length(persistant_idxs), 1);
end

%% Plot the violin plot

for ii = 1:length(muscle_groups)

    plot_fig = figure;
    plot_fig.Position = [200 50 fig_size fig_size];
    hold on

    % Find the y_limits
    y_min = min(Plot_Metric(:,ii));
    y_max = max(Plot_Metric(:,ii));
    
    % Title
    title_string = strcat('Peak', {' '}, Wave_Choice, '-Wave', {' '}, Subject, ...
        {' '}, '[', muscle_groups{ii}, ']');
    title_strings{ii} = title_string;
    title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');
    
    % Plot
    if strcmp(plot_choice, 'Box')
        boxplot(Plot_Metric(:,ii), all_trials_metric(:,ii));
        % Color the box plots
        box_axes = findobj(gca,'Tag','Box');
        patch(get(box_axes, 'XData'), get(box_axes, 'YData'), plot_colors, 'FaceAlpha', .5);
    elseif strcmp(plot_choice, 'Violin')
        Violin_Plot(Plot_Metric(:,ii), all_trials_metric(:,ii), 'ViolinColor', plot_colors);
    end

    set(gca,'fontsize', label_font_size)

    % Set the axis-limits
    xlim([0.5 1.5]);
    ylim([y_min - axis_expansion, y_max + axis_expansion])
    
    % Labels
    y_label = strcat('Peak', {' '}, Wave_Choice, '-Wave');
    if strcmp(Wave_Choice, 'Force')
        y_label = strcat(y_label, {' '}, '(N)');
    elseif strcmp(Wave_Choice, 'EMG')
        y_label = strcat(y_label, {' '}, '(mV)');
    end
    ylabel(y_label, 'FontSize', label_font_size);

end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        save_title = strrep(title_strings{ii}, ':', '');
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








