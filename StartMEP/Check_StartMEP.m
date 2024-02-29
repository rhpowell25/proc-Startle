function Check_StartMEP(sig, State, muscle_group, Save_File)

%% Display the function being used
disp('Check StartMEP Function:');

%% Check for common sources of errors
if ~strcmp(State, 'All') && ~strcmp(State, 'MEP') && ~strcmp(State, 'MEP+50ms') ...
        && ~strcmp(State, 'MEP+80ms') && ~strcmp(State, 'MEP+100ms')
    disp('Incorrect State for StartMEP')
    return
end

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Raw';

bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of the go cue
gocue_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
gocue_idx = round(gocue_time/bin_width);

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2.5; % Sec.
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
        Fig_Titles = sprintf('EMG [%s] Reaction Time: %s', State, EMG_title{1});
        title(Fig_Titles, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);

        % Plot the EMG
        plot(absolute_timing(1:stop_idx), all_trials_EMG{pp}(1:stop_idx,ii))

        % Horizontal line indicating cutoff 
        EMG_std = mean(all_trials_EMG{pp}(1:gocue_idx,ii)) + ...
            5*std(all_trials_EMG{pp}(1:gocue_idx,ii));
        line([absolute_timing(1) absolute_timing(stop_idx)], [EMG_std EMG_std], ... 
        'LineStyle','--', 'Color', 'k')

        %% Save the file if selected
        Save_Figs(Fig_Title, Save_File)

    end % End of the individual trial loop

end % End of the muscle loop
