function Trial_SIG_Force(sig, State, muscle_group, Save_Figs)

%% Display the function being used
disp('Average sig EMG Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2; % Sec.
stop_idx = stop_length/bin_width;

% Where will the gocue be plotted
GoCue_idx = 1 / bin_width;

% Font specifications
label_font_size = 15;
title_font_size = 15;
figure_width = 700;
figure_height = 700;

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

%% Extract the force & find its onset
% Extract the selected force
Force = struct([]);
for ii = 1:length(rewarded_idxs)
    Force{ii,1} = sig.force{rewarded_idxs(ii)};
end

[~, EMG] = Extract_EMG(sig, 'Raw', muscle_group, rewarded_idxs);

% Find its onset
[EMG_onset_idx] = EMGOnset(EMG);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(Force{1,1}));

%% Putting all succesful trials in one array
all_trials_force = zeros(length(Force{1,1}),length(Force));
for ii = 1:length(Force)
    all_trials_force(:,ii) = Force{ii};
end
    
%% Calculating average force (Average Across trials)
cross_trial_avg_force = zeros(length(Force{1,1}),1);
cross_trial_std_force = zeros(length(Force{1,1}),1);
for ii = 1:length(Force{1,1})
    cross_trial_avg_force(ii) = mean(all_trials_force(ii,:));
    cross_trial_std_force(ii) = std(all_trials_force(ii,:));
end

%% Plot the individual force traces on the top

force_figure = figure;
force_figure.Position = [300 100 figure_width figure_height];
subplot(211) % Top Plot
hold on

% Titling the plot
title(sprintf('Force [%s] Reaction Time', State), 'FontSize', title_font_size)

% Labels
ylabel('Force (mV)', 'FontSize', label_font_size);
xlabel('Time (sec.)', 'FontSize', label_font_size);

for ii = 1:width(all_trials_force)

    plot(absolute_timing(1:stop_idx), all_trials_force(1:stop_idx,ii))

    % Plot the go-cues as dark green dots
    if ~isempty(all_trials_force(GoCue_idx,ii))
        plot(1, all_trials_force(GoCue_idx(1),ii), ...
            'Marker', '.', 'Color', [0 0.5 0], 'Markersize', 15);
    end
    % Plot the EMG onset as red dots
    if ~isnan(EMG_onset_idx(ii))
        plot(absolute_timing(EMG_onset_idx(ii)), all_trials_force(EMG_onset_idx(ii),ii), ...
            'Marker', '.', 'Color', 'r', 'Markersize', 15);
    end

end % End of the individual trial loop

%% Plot the mean EMG on the bottom

subplot(212) % Bottom Plot
hold on

% Labels
ylabel('Force (mV)', 'FontSize', label_font_size);
xlabel('Time (sec.)', 'FontSize', label_font_size);

% Mean EMG
plot(absolute_timing(1:stop_idx), cross_trial_avg_force(1:stop_idx), ...
    'LineWidth', 2, 'Color', 'k');

% Standard Deviation
plot(absolute_timing(1:stop_idx), cross_trial_avg_force(1:stop_idx) + cross_trial_std_force(1:stop_idx), ...
    'LineWidth', 1, 'LineStyle','--', 'Color', 'r');
%plot(absolute_timing(1:stop_idx), cross_trial_avg_force(1:stop_idx) - cross_trial_std_force(1:stop_idx), ...
%    'LineWidth', 1, 'LineStyle','--', 'Color', 'r');

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        fig_info = get(subplot(211),'title');
        save_title = get(fig_info, 'string');
        save_title = strrep(save_title, ':', '');
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
