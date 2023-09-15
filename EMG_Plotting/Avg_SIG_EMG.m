function Avg_SIG_EMG(sig, State, muscle_group, Save_Figs)

%% Display the function being used
disp('Average sig EMG Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [0, 0.2];

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Proc';

Task = strrep(sig.meta.task, '_', ' ');
bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2; % Sec.
stop_idx = stop_length/bin_width;

% Font specifications
axis_expansion = 0.025;
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
figure_width = 700;
figure_height = 350;

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
if strcmp(State, 'All')
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));
else
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
        strcmp(trial_info_table.State, State));
end

%% Extract the EMG & find its onset
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(EMG{1,1}));

%% Putting all succesful trials in one array
all_trials_EMG = struct([]);
for ii = 1:length(EMG_Names)
    all_trials_EMG{ii,1} = zeros(length(EMG{1,1}),length(EMG));
    for mm = 1:length(EMG)
        all_trials_EMG{ii,1}(:,mm) = EMG{mm}(:, ii);
    end
end
    
%% Calculating average EMG (Average Across trials)
cross_trial_avg_EMG = struct([]);
cross_trial_std_EMG = struct([]);
for ii = 1:length(EMG_Names)
    cross_trial_avg_EMG{ii,1} = zeros(length(EMG{1,1}),1);
    cross_trial_std_EMG{ii,1} = zeros(length(EMG{1,1}),1);
    for mm = 1:length(EMG{1,1})
        cross_trial_avg_EMG{ii,1}(mm) = mean(all_trials_EMG{ii,1}(mm,:));
        cross_trial_std_EMG{ii,1}(mm) = std(all_trials_EMG{ii,1}(mm,:));
    end
end

%% Find the y-axis limits
if ischar(man_y_axis)
    y_limits = zeros(length(EMG_Names),2);
    for ii = 1:height(y_limits)
        y_limits(ii,1) = min(cross_trial_avg_EMG{ii,1});
        y_limits(ii,2) = max(cross_trial_avg_EMG{ii,1});
    end
    axis_min = min(y_limits(:,1));
    axis_max = max(y_limits(:,2));
else
    axis_min =  man_y_axis(1);
    axis_max = man_y_axis(2);
end

%% Plot the mean EMG traces

EMG_figure = figure;
EMG_figure.Position = [300 75 figure_width figure_height];
hold on

% Title
fig_title = strcat('Average EMG:', {' '}, Task, {' '}, '[', State, ']');
sgtitle(fig_title, 'FontSize', title_font_size)

for ii = 1:length(EMG_Names)
    subplot(length(EMG_Names),1,ii)
    hold on
    
    % Y Labels
    ylabel('EMG', 'FontSize', label_font_size);
    
    % Mean EMG
    plot(absolute_timing(1:stop_idx), cross_trial_avg_EMG{ii,1}(1:stop_idx), ...
        'LineWidth', 2, 'Color', 'k');
    
    % Standard Deviation
    plot(absolute_timing(1:stop_idx), cross_trial_avg_EMG{ii,1}(1:stop_idx) + cross_trial_std_EMG{ii,1}(1:stop_idx), ...
        'LineWidth', 1, 'LineStyle','--', 'Color', 'r');
    %plot(absolute_timing(1:stop_idx), cross_trial_avg_EMG{ii,1}(1:stop_idx) - cross_trial_std_EMG{ii,1}(1:stop_idx), ...
    %    'LineWidth', 1, 'LineStyle','--', 'Color', 'r');
    
    legend(sprintf('%s', EMG_Names{ii}), ... 
            'NumColumns', 1, 'FontSize', legend_font_size, 'FontName', font_name, ...
            'Location', 'NorthEast');
    legend boxoff

    % Set the axis
    ylim([axis_min, axis_max + axis_expansion])
end

% X Label
xlabel('Time (sec.)', 'FontSize', label_font_size);

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        fig_title = strrep(fig_title, ':', '');
        fig_title = strrep(fig_title, 'vs.', 'vs');
        fig_title = strrep(fig_title, 'mg.', 'mg');
        fig_title = strrep(fig_title, 'kg.', 'kg');
        fig_title = strrep(fig_title, '.', '_');
        fig_title = strrep(fig_title, '/', '_');
        if ~strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(fig_title)), Save_Figs)
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'fig')
        end
        close gcf
    end
end
