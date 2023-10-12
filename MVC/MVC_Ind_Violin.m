function MVC_Ind_Violin(sig, Plot_Choice, Plot_Figs, Save_Figs)

%% File Description:

% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Box';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Define the muscle groups of interest
%muscle_groups = {'ABH'; 'TA'; 'SOL'};
muscle_groups = {'ABH'};

% Title info
Subject = sig.meta.subject;
Task = sig.meta.task;

% Font specifications
plot_colors = [1 0 0];
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
  
%% Loop through all the trials

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, 'R'));
% Extract the EMG or force
if isequal(Plot_Choice, 'EMG')
    [~, Plot_Metric] = Extract_EMG(sig, EMG_Choice, muscle_groups, rewarded_idxs);
elseif isequal(Plot_Choice, 'Force')
    muscle_groups = {'Force'};
    [Plot_Metric] = Extract_Force(sig, 1, 1, rewarded_idxs);
end

% Find its max
all_trials_max_metric = zeros(length(Plot_Metric), length(muscle_groups));
all_trials_metric = strings(length(Plot_Metric), length(muscle_groups));
for pp = 1:length(muscle_groups)
    all_trials_metric(:,pp) = repmat(muscle_groups(pp), length(Plot_Metric), 1);
    for ii = 1:length(Plot_Metric)
        all_trials_max_metric(ii,pp) = max(Plot_Metric{ii,1}(:,pp));
    end
end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(muscle_groups)

        plot_fig = figure;
        plot_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        y_min = min(all_trials_max_metric(:,ii));
        y_max = max(all_trials_max_metric(:,ii));
        
        % Title
        title_string = strcat('Peak', {' '}, Task, {' '}, Subject, ...
            {' '}, '[', muscle_groups{ii}, ']');
        title_strings{ii} = title_string;
        title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % Plot
        if strcmp(plot_choice, 'Box')
            boxplot(all_trials_max_metric(:,ii), all_trials_metric(:,ii));
            % Color the box plots
            box_axes = findobj(gca,'Tag','Box');
            patch(get(box_axes, 'XData'), get(box_axes, 'YData'), plot_colors, 'FaceAlpha', .5);
        elseif strcmp(plot_choice, 'Violin')
            Violin_Plot(all_trials_max_metric(:,ii), all_trials_metric(:,ii), 'ViolinColor', plot_colors);
        end

        set(gca,'fontsize', label_font_size)

        % Set the axis-limits
        xlim([0.5 1.5]);
        ylim([y_min - axis_expansion, y_max + axis_expansion])
        
        % Labels
        y_label = strcat('Peak', {' '}, Plot_Choice);
        if strcmp(Plot_Choice, 'Force')
            y_label = strcat(y_label, {' '}, '(N)');
        elseif strcmp(Plot_Choice, 'EMG')
            y_label = strcat(y_label, {' '}, '(mV)');
        end
        ylabel(y_label, 'FontSize', label_font_size);
    
    end
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








