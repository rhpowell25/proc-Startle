function OverlapSIGEMG(sig, muscle_group, Save_Figs)

%% Display the function being used
disp('Overlap sig EMG Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start & stop plotting
start_length = 1; % Sec.
start_idx = start_length/bin_width;
stop_length = 1.4; % Sec.
stop_idx = round(stop_length/bin_width);

% Font specifications
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
figure_width = 700;
figure_height = 400;

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
[EMG_Names, F_EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, F_rewarded_idxs);
[~, Fs_EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, Fs_rewarded_idxs);
[~, FS_EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, FS_rewarded_idxs);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(F_EMG{1,1}));

%% Putting all succesful trials in one array
all_trials_F_EMG = struct([]);
for ii = 1:length(EMG_Names)
    all_trials_F_EMG{ii,1} = zeros(length(F_EMG{1,1}),length(F_EMG));
    for mm = 1:length(F_EMG)
        all_trials_F_EMG{ii,1}(:,mm) = F_EMG{mm}(:, ii);
    end
end
all_trials_Fs_EMG = struct([]);
for ii = 1:length(EMG_Names)
    all_trials_Fs_EMG{ii,1} = zeros(length(Fs_EMG{1,1}),length(Fs_EMG));
    for mm = 1:length(Fs_EMG)
        all_trials_Fs_EMG{ii,1}(:,mm) = Fs_EMG{mm}(:, ii);
    end
end
all_trials_FS_EMG = struct([]);
for ii = 1:length(EMG_Names)
    all_trials_FS_EMG{ii,1} = zeros(length(FS_EMG{1,1}),length(FS_EMG));
    for mm = 1:length(FS_EMG)
        all_trials_FS_EMG{ii,1}(:,mm) = FS_EMG{mm}(:, ii);
    end
end
    
%% Calculating average EMG (Average Across trials)
cross_trial_avg_F_EMG = struct([]);
for ii = 1:length(EMG_Names)
    cross_trial_avg_F_EMG{ii,1} = zeros(length(F_EMG{1,1}),1);
    for mm = 1:length(F_EMG{1,1})
        cross_trial_avg_F_EMG{ii,1}(mm) = mean(all_trials_F_EMG{ii,1}(mm,:));
    end
end
cross_trial_avg_Fs_EMG = struct([]);
for ii = 1:length(EMG_Names)
    cross_trial_avg_Fs_EMG{ii,1} = zeros(length(Fs_EMG{1,1}),1);
    for mm = 1:length(Fs_EMG{1,1})
        cross_trial_avg_Fs_EMG{ii,1}(mm) = mean(all_trials_Fs_EMG{ii,1}(mm,:));
    end
end
cross_trial_avg_FS_EMG = struct([]);
for ii = 1:length(EMG_Names)
    cross_trial_avg_FS_EMG{ii,1} = zeros(length(FS_EMG{1,1}),1);
    for mm = 1:length(FS_EMG{1,1})
        cross_trial_avg_FS_EMG{ii,1}(mm) = mean(all_trials_FS_EMG{ii,1}(mm,:));
    end
end

%% Plot the individual EMG traces

fig_titles = struct([]);

for ii = 1:length(EMG_Names)

    EMG_figure = figure;
    EMG_figure.Position = [300 100 figure_width figure_height];
    hold on

    % Titling the plot
    EMG_title = EMG_Names{ii};
    fig_titles{ii} = sprintf('EMG Reaction Times: %s', EMG_title);
    title(fig_titles{ii}, 'FontSize', title_font_size)

    % Labels
    ylabel('EMG', 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

    % Setting the x-axis limits
    xlim([absolute_timing(start_idx), absolute_timing(stop_idx)]);
    
    % Mean EMG
    plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_F_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'k');
    plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_Fs_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', [.7 .7 .7]);
    plot(absolute_timing(start_idx:stop_idx), cross_trial_avg_FS_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'r');
    
    % Legend
    legend('F', 'F+s', 'F+S', 'NumColumns', 1, 'FontName', font_name, ...
        'Location', 'NorthWest', 'FontSize', legend_font_size)
    % Remove the legend's outline
    legend boxoff

end % End of the muscle loop

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        save_title = strrep(fig_titles{ii}, ':', '');
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



