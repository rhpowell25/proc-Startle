function OverlapSIGForce(sig, Save_Figs)

%% Display the function being used
disp('Overlap sig force Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Title info
Subject = sig.meta.subject;
Task = strrep(sig.meta.task, '_', ' ');

% When do you want to start & stop plotting
start_length = 1; % Sec.
start_idx = start_length/bin_width;
stop_length = 1.7; % Sec.
stop_idx = round(stop_length/bin_width);

% Font specifications
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
F_rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
    strcmp(trial_info_table.State, 'F'));
Fs_rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
    strcmp(trial_info_table.State, 'F+s'));
FS_rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
    strcmp(trial_info_table.State, 'F+S'));

%% Extract the EMG

% Extract the selected force
F_Force = struct([]);
for ii = 1:length(F_rewarded_idxs)
    F_Force{ii,1} = sig.force{F_rewarded_idxs(ii)};
end
Fs_Force = struct([]);
for ii = 1:length(Fs_rewarded_idxs)
    Fs_Force{ii,1} = sig.force{Fs_rewarded_idxs(ii)};
end
FS_Force = struct([]);
for ii = 1:length(FS_rewarded_idxs)
    FS_Force{ii,1} = sig.force{FS_rewarded_idxs(ii)};
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(F_Force{1,1}));

%% Putting all succesful trials in one array
all_trials_F_Force = zeros(length(F_Force{1,1}),length(F_Force));
for ii = 1:length(F_Force)
    all_trials_F_Force(:,ii) = F_Force{ii};
end
all_trials_Fs_Force = zeros(length(Fs_Force{1,1}),length(Fs_Force));
for ii = 1:length(Fs_Force)
    all_trials_Fs_Force(:,ii) = Fs_Force{ii};
end
all_trials_FS_Force = zeros(length(FS_Force{1,1}),length(FS_Force));
for ii = 1:length(FS_Force)
    all_trials_FS_Force(:,ii) = FS_Force{ii};
end
    
%% Calculating average force (Average Across trials)
cross_trial_avg_F_force = zeros(length(F_Force{1,1}),1);
for ii = 1:length(F_Force{1,1})
    cross_trial_avg_F_force(ii) = mean(all_trials_F_Force(ii,:));
end
cross_trial_avg_Fs_force = zeros(length(Fs_Force{1,1}),1);
for ii = 1:length(Fs_Force{1,1})
    cross_trial_avg_Fs_force(ii) = mean(all_trials_Fs_Force(ii,:));
end
cross_trial_avg_FS_force = zeros(length(FS_Force{1,1}),1);
for ii = 1:length(FS_Force{1,1})
    cross_trial_avg_FS_force(ii) = mean(all_trials_FS_Force(ii,:));
end

%% Plot the individual force traces

Force_figure = figure;
Force_figure.Position = [300 100 figure_width figure_height];
hold on

% Titling the plot
fig_title = strcat(Task, ':', {' '}, Subject);
title(fig_title, 'FontSize', title_font_size)

% Labels
ylabel('Force (mV)', 'FontSize', label_font_size);
xlabel('Time (sec.)', 'FontSize', label_font_size);

% Setting the x-axis limits
xlim([absolute_timing(start_idx), absolute_timing(stop_idx)]);

% Mean EMG
plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_F_force(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', 'k');
plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_Fs_force(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', [.7 .7 .7]);
plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_FS_force(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', 'r');

% Legend
legend('F', 'F+s', 'F+S', 'NumColumns', 1, 'FontName', font_name, ...
    'Location', 'NorthWest', 'FontSize', legend_font_size)
% Remove the legend's outline
legend boxoff

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        save_title = strrep(fig_title{ii}, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
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



