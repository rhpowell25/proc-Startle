
function [sig] = Remove_LateStarts(sig)

%% Basic Settings, some variable extractions, & definitions

% How late can a response be? (Sec.)
cutoff_rxn_time = 0.5;

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

muscle_group = sig.meta.muscle;

% Bin width and baseline indices
bin_width = sig.bin_width;

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));

% Rewarded trial table
Trial_Table = trial_info_table(rewarded_idxs, :);
gocue_times = Trial_Table.goCueTime - Trial_Table.startTime;

%% Extract the EMG & find its onset
[~, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

% Find its onset
[EMG_onset_idx] = EMGOnset(EMG);

%% Find the EMG reaction times
rxn_time = (EMG_onset_idx * bin_width) - gocue_times;

% Late starts
cutoff_trials = find(rxn_time > cutoff_rxn_time);

%% Mark those trials as fails in sig file

for ii = 1:length(cutoff_trials)
    [sig] = Remove_Trial(sig, cutoff_trials(ii));
end

