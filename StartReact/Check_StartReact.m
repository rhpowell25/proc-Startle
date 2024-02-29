function Check_StartReact(sig, State, muscle_group, Save_File)

%% Display the function being used
disp('Check StartReact Function:');

%% Check for common sources of errors
if ~strcmp(State, 'All') && ~strcmp(State, 'F') && ~strcmp(State, 'F+s') && ~strcmp(State, 'F+S')
    disp('Incorrect State for StartReact')
    return
end

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Title info
Subject = sig.meta.subject;

bin_width = sig.bin_width;

GoCue_idx = 1.1 / bin_width;

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2; % Sec.
stop_idx = stop_length/bin_width;

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;

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

[EMG_onset_idx] = Detect_Onset(sig, State, muscle_group);

%% Find the average and standard deviation 

avg_baseline = zeros(1, width(EMG{1,1}));
std_baseline = zeros(1, width(EMG{1,1}));
for ii = 1:width(EMG{1,1})
    baseline_EMG = zeros(length(EMG), length(EMG{1,1}(1:GoCue_idx, ii)));
    for pp = 1:length(EMG)
        baseline_EMG(pp,:) = EMG{pp}(1:GoCue_idx, ii);
    end
    % Find the mean and standard deviation
    avg_baseline_EMG = mean(baseline_EMG);
    avg_baseline(1,ii) = mean(avg_baseline_EMG);
    std_baseline(1,ii) = mean(std(baseline_EMG));
end

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

for ii = 1:width(all_trials_EMG{ii})

    EMG_figure = figure;
    EMG_figure.Position = [300 75 Plot_Params.fig_size Plot_Params.fig_size];
    hold on

    for pp = 1:length(EMG_Names)

        subplot(length(EMG_Names),1,pp)
        hold on
    
        % Titling the plot
        Trial_num = trial_info_table.number(rewarded_idxs(ii));
        EMG_title = strcat(EMG_Names{pp}, {' '}, num2str(Trial_num));
        Fig_Title = strcat('Reaction Time: [', State, ']', {' '}, Subject, {' '}, EMG_title{1});
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);

        % Plot the EMG
        plot(absolute_timing(1:stop_idx), all_trials_EMG{pp}(1:stop_idx,ii))

        % Horizontal line indicating cutoff 
        EMG_std = avg_baseline + 5*std_baseline;
        line([absolute_timing(1) absolute_timing(stop_idx)], [EMG_std EMG_std], ... 
            'LineStyle','--', 'Color', 'k')

        EMG_gocue_idx = find(round(absolute_timing, 3) == 1);
        % Plot the go-cues as dark green dots
        if ~isempty(all_trials_EMG{pp,1}(EMG_gocue_idx,ii))
            plot(1, all_trials_EMG{pp,1}(EMG_gocue_idx(1),ii), ...
                'Marker', '.', 'Color', [0 0.5 0], 'Markersize', 15);
        end
        
        % Plot the EMG onset as red dots
        if ~EMG_onset_idx(ii,pp) == 0
            plot(absolute_timing(EMG_onset_idx(ii,pp)), ...
                all_trials_EMG{pp,1}(EMG_onset_idx(ii,pp),ii), ...
                'Marker', '.', 'Color', 'r', 'Markersize', 15);
        end

        % Collect the y-axis
        y_limits = ylim;

        if ~EMG_onset_idx(ii,pp) == 0
            % Vertical line indicating EMG onset
            line([absolute_timing(EMG_onset_idx(ii,pp)) absolute_timing(EMG_onset_idx(ii,pp))], ...
                [y_limits(1) y_limits(2)], 'LineStyle','--', 'Color', 'r')
        end

        % Set the axis-limits
        ylim([y_limits(1) y_limits(2)]);

        %% Save the file if selected
        Save_Figs(Fig_Title, Save_File)

    end % End of the individual trial loop

end % End of the muscle loop
