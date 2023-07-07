function Trial_SIG_EMG(sig, State, muscle_group, Save_Figs)

%% Display the function being used
disp('Average sig EMG Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2; % Sec.
stop_idx = stop_length/bin_width;

% Where will the gocue be plotted
GoCue_idx = 1 / bin_width;

% Font specifications
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
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

%% Extract the EMG & find its onset
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

% Find its onset
[EMG_onset_idx] = EMGOnset(EMG);

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

%% Plot the individual EMG traces on the top

for ii = 1:length(EMG_Names)

    EMG_figure = figure;
    EMG_figure.Position = [300 100 figure_width figure_height];
    subplot(211) % Top Plot
    hold on

    % Titling the plot
    EMG_title = EMG_Names{ii};
    title(sprintf('EMG [%s] Reaction Time: %s', State, EMG_title), 'FontSize', title_font_size)

    % Labels
    ylabel('EMG', 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

    for pp = 1:width(all_trials_EMG{ii})

        plot(absolute_timing(1:stop_idx), all_trials_EMG{ii}(1:stop_idx,pp))

        % Plot the go-cues as dark green dots
        if ~isempty(all_trials_EMG{ii,1}(GoCue_idx,pp))
            plot(1, all_trials_EMG{ii,1}(GoCue_idx(1),pp), ...
                'Marker', '.', 'Color', [0 0.5 0], 'Markersize', 15);
        end
        % Plot the EMG onset as red dots
        plot(absolute_timing(EMG_onset_idx(pp,ii)), all_trials_EMG{ii,1}(EMG_onset_idx(pp,ii),pp), ...
            'Marker', '.', 'Color', 'r', 'Markersize', 15);

    end % End of the individual trial loop

    %% Plot the mean EMG on the bottom

    subplot(212) % Bottom Plot
    hold on
    
    % Labels
    ylabel('EMG', 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

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

end % End of the muscle loop

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
