function Per_Trial_SIG_EMG(sig, State, muscle_group, Save_Figs)

%% Display the function being used
disp('Per Trial SIG EMG Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'F';

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
title_font_size = 15;
figure_width = 800;
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

%% Plot the individual EMG traces on the top

fig_titles = struct([]);
ss = 1;

for ii = 1:width(all_trials_EMG{ii})

    EMG_figure = figure;
    EMG_figure.Position = [300 75 figure_width figure_height];
    hold on

    for pp = 1:length(EMG_Names)

        subplot(length(EMG_Names),1,pp)
        hold on
    
        % Titling the plot
        Trial_num = trial_info_table.number(rewarded_idxs(ii));
        EMG_title = strcat(EMG_Names{pp}, {' '}, num2str(Trial_num));
        fig_titles{ss} = sprintf('EMG [%s] Reaction Time: %s', State, EMG_title{1});
        title(fig_titles{ss}, 'FontSize', title_font_size)
    
        % Labels
        ylabel('EMG', 'FontSize', label_font_size);
        xlabel('Time (sec.)', 'FontSize', label_font_size);

        % Plot the EMG
        plot(absolute_timing(1:stop_idx), all_trials_EMG{pp}(1:stop_idx,ii))

        % Horizontal line indicating cutoff 
        EMG_std = mean(all_trials_EMG{pp}(1:GoCue_idx,ii)) + ...
            5*std(all_trials_EMG{pp}(1:GoCue_idx,ii));
        line([absolute_timing(1) absolute_timing(stop_idx)], [EMG_std EMG_std], ... 
        'LineStyle','--', 'Color', 'k')

        EMG_gocue_idx = find(round(absolute_timing, 3) == 1);
        % Plot the go-cues as dark green dots
        if ~isempty(all_trials_EMG{pp,1}(EMG_gocue_idx,ii))
            plot(1, all_trials_EMG{pp,1}(EMG_gocue_idx(1),ii), ...
                'Marker', '.', 'Color', [0 0.5 0], 'Markersize', 15);
        end
        % Plot the EMG onset as red dots
        if ~isnan(EMG_onset_idx(ii,pp))
            plot(absolute_timing(EMG_onset_idx(ii,pp)), ...
                all_trials_EMG{pp,1}(EMG_onset_idx(ii,pp),ii), ...
                'Marker', '.', 'Color', 'r', 'Markersize', 15);
        end

        ss = ss + 1;

    end % End of the individual trial loop

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
        save_title = strrep(save_title, '[', '_');
        save_title = strrep(save_title, ']', '_');
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
