function [persistant_idxs, inpersistant_idxs] = F_Wave_Persistance(sig, EMG_Choice)

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Muscle
EMG_name = sig.meta.muscle;
EMG_idx = strcmpi(sig.EMG_names, EMG_name);

% F-Wave minimum amplitude
F_Wave_min = 0.02; % 20 µV

% Bin width and baseline indices
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of stimulus
stim_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
stim_idx = stim_time / bin_width;

% Baseline period
baseline_length = 0.02; % Sec.
baseline_idxs = baseline_length / bin_width;

% F-Wave period
F_Wave_length = 0.1; % Sec.
post_M_Max_time = 0.03; % Sec.
post_M_Max_idx = post_M_Max_time / bin_width;
F_Wave_idxs = F_Wave_length / bin_width;

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));

%% Extract the EMG

[~, EMG] = Extract_EMG(sig, EMG_Choice, sig.meta.muscle, rewarded_idxs);

%% Extract the baseline EMG & find the peak to peak amplitude for each trial
baseline_start = stim_idx - baseline_idxs;
baseline_stop = stim_idx;

Baseline_EMG = struct([]);
Baseline_peaktopeak = zeros(length(EMG), 1);
%figure
%hold on
for ii = 1:length(Baseline_peaktopeak)
    Baseline_EMG{ii,1} = EMG{ii}(baseline_start:baseline_stop, EMG_idx);
    %plot(EMG{ii}(baseline_start:end, EMG_idx))
    Baseline_peaktopeak(ii,1) = peak2peak(Baseline_EMG{ii,1});
    %pause(1)
end

%% Extract the F-Wave EMG & find the peak to peak amplitude for each trial
F_Wave_start = stim_idx + post_M_Max_idx;
F_Wave_stop = F_Wave_start + F_Wave_idxs;

F_Wave_EMG = struct([]);
F_Wave_peaktopeak = zeros(length(EMG), 1);
%figure
%hold on
for ii = 1:length(F_Wave_peaktopeak)
    F_Wave_EMG{ii,1} = EMG{ii}(F_Wave_start:F_Wave_stop, EMG_idx);
    %plot(F_Wave_EMG{ii,1})
    F_Wave_peaktopeak(ii,1) = peak2peak(F_Wave_EMG{ii,1});
    %pause(0.5)
end

%% Find the trials with a valid F-Wave

persistant_idxs = find(F_Wave_peaktopeak >= (Baseline_peaktopeak + F_Wave_min));
inpersistant_idxs = find(F_Wave_peaktopeak < (Baseline_peaktopeak + F_Wave_min));

