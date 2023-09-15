function Check_Synergy(sig_task_one, sig_task_two, muscle_group, Save_Figs)

%% What do you want plotted?
% 'PC1', 'PC2', 'PC3', 'Nonlin', or 'Time'
x_plot = 'PC1';
y_plot = 'PC2';

%% Basic settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Subjecty
Subject = sig_task_one.meta.subject;

% Date
file_name = sig_task_one.meta.rawFileName;
xtra_info = extractAfter(file_name, '_');
Date = erase(file_name, strcat('_', xtra_info));

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig_task_one.trial_info_table_header';
trial_info_table = cell2table(sig_task_one.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs_task_one = find(strcmp(trial_info_table.result, trial_choice));

% Convert to the trial table
matrix_variables = sig_task_two.trial_info_table_header';
trial_info_table = cell2table(sig_task_two.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs_task_two = find(strcmp(trial_info_table.result, trial_choice));

%% Extract the EMG

[~, EMG_task_one] = Extract_EMG(sig_task_one, 'Raw', muscle_group, rewarded_idxs_task_one);
[~, EMG_task_two] = Extract_EMG(sig_task_two, 'Raw', muscle_group, rewarded_idxs_task_two);

% Put the EWG into a single array
merged_EMG_task_one = zeros(length(EMG_task_one), )
% Load unsorted waveforms
unsorted_waveforms = sig_task_two.spike_waveforms{1,N};

% Load the unsorted spikes
unsorted_spikes = sig_task_two.spikes{1,N};

% Find the associated sorted units
sorted_unit_idxs = find(contains(sig_task_one.unit_names, current_unit));

% Calculate the principle components
if contains(x_plot, 'PC') || contains(y_plot, 'PC')
    [~, Principal_Comps, ~] = pca(unsorted_waveforms);
end

% Calculate the nonlinear energy
if contains(x_plot, 'Nonlin') || contains(y_plot, 'Nonlin')
    unsorted_nonlin = mean(sig_task_two.nonlin_waveforms{1,N}, 2);
end

%% Define the figure

% X Axis
if strcmp(x_plot, 'PC1')
    x_axis = Principal_Comps(:,1);
    x_label = 'Principal Component 1';
elseif strcmp(x_plot, 'PC2')
    x_axis = Principal_Comps(:,2);
    x_label = 'Principal Component 2';
elseif strcmp(x_plot, 'PC3')
    x_axis = Principal_Comps(:,3);
    x_label = 'Principal Component 3';
elseif strcmp(x_plot, 'Nonlin')
    x_axis = unsorted_nonlin;
    x_label = 'Nonlinear Energy';
elseif strcmp(x_plot, 'Time')
    x_axis = unsorted_spikes;
    x_label = 'Time';
end
% Y Axis
if strcmp(y_plot, 'PC1')
    y_axis = Principal_Comps(:,1);
    y_label = 'Principal Component 1';
elseif strcmp(y_plot, 'PC2')
    y_axis = Principal_Comps(:,2);
    y_label = 'Principal Component 2';
elseif strcmp(y_plot, 'PC3')
    y_axis = Principal_Comps(:,3);
    y_label = 'Principal Component 3';
elseif strcmp(y_plot, 'Nonlin')
    y_axis = unsorted_nonlin;
    y_label = 'Nonlinear Energy';
elseif strcmp(y_plot, 'Time')
    y_axis = unsorted_spikes;
    y_label = 'Time';
end

% Font specifications
label_font_size = 20;
title_font_size = 15;
% Figure size
figure_width = 800;
figure_height = 600;

marker_size = 2;

% Generate the figure
sort_figure = figure;
sort_figure.Position = [150 150 figure_width figure_height];
hold on

% Set the background as black
set(gca,'Color','k')

% Set the common title
fig_title = strcat('Spike Sorting -', {' '}, char(sig_task_two.unit_names(N)));
save_title = strcat(Date, '_', Subject, '_', fig_title);
sgtitle(fig_title, 'FontSize', (title_font_size + 5));

% Axis Labels
ylabel(y_label, 'FontSize', label_font_size)
xlabel(x_label, 'FontSize', label_font_size)

% Only label every other tick
figure_axes = gca;
x_labels = string(figure_axes.XAxis.TickLabels);
y_labels = string(figure_axes.YAxis.TickLabels);
x_labels(1:end) = NaN;
y_labels(1:end) = NaN;
figure_axes.XAxis.TickLabels = x_labels;
figure_axes.YAxis.TickLabels = y_labels;
% Set ticks to outside
set(figure_axes,'TickDir','out');
% Remove the top and right tick marks
set(figure_axes,'box','off');

%% Plotting

% Plot the unsorted threshold crossings
scatter(x_axis, y_axis, ...
    marker_size, 'MarkerEdgeColor', [1 1 1], 'MarkerFaceColor', [1 1 1])

if strcmp(Sort_Check, 'K_Means')
    % How many clusters do you want?
    num_clusters = length(sorted_unit_idxs);
    [k_means_idx, ~] = kmeans(cat(2, x_axis, y_axis), num_clusters, 'Replicates', 5);
    
    for ii = 1:num_clusters
        % Define the plotting colors
        if ii == 1
            plot_color = 'y';
        elseif ii == 2
            plot_color = 'g';
        elseif ii == 3
            plot_color = 'c';
        elseif ii == 4
            plot_color = 'r';
        end

        scatter(x_axis(k_means_idx == ii), y_axis(k_means_idx == ii), ...
            marker_size, 'MarkerEdgeColor', plot_color, 'MarkerFaceColor', plot_color)
        scatter(x_axis(k_means_idx == ii), y_axis(k_means_idx == ii), ...
            marker_size, 'MarkerEdgeColor', plot_color, 'MarkerFaceColor', plot_color)
    end
end

if strcmp(Sort_Check, 'Sort')
    % Loop through each sorted unit
    for ii = 1:length(sorted_unit_idxs)
       
        % Define the plotting colors
        if ii == 1
            plot_color = 'y';
        elseif ii == 2
            plot_color = 'g';
        elseif ii == 3
            plot_color = 'c';
        elseif ii == 4
            plot_color = 'r';
        end
    
        % Load the sorted spikes
        sorted_spikes = sig_task_one.spikes{1,sorted_unit_idxs(ii)};
    
        % Find the indices of the sorted spikes
        sorted_spike_idxs = find(ismember(unsorted_spikes, sorted_spikes));
        
        % Plot the unsorted threshold crossings
        scatter(x_axis(sorted_spike_idxs), y_axis(sorted_spike_idxs), ...
            marker_size, 'MarkerEdgeColor', plot_color, 'MarkerFaceColor', plot_color)
    
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for uu = numel(findobj('type','figure')):-1:1
        set(gcf, 'InvertHardcopy', 'off');
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

