function [persistant_idxs] = F_Wave_Persistance(sig)

%% Basic Settings, some variable extractions, & definitions

% Muscle
EMG_name = sig.meta.muscle;
EMG_idx = strcmpi(sig.EMG_names, EMG_name);

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

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

%% Extract the EMG
if strcmp(EMG_Choice, 'Raw')
    EMG = sig.raw_EMG;
end

if strcmp(EMG_Choice, 'Rect')
    raw_EMG = sig.raw_EMG;
    % DC removal of the EMG
    Zeroed_EMG = struct([]);
    for ii = 1:length(raw_EMG)
        for pp = 1:width(raw_EMG{ii})
            Zeroed_EMG{ii}(:,pp) = raw_EMG{ii}(:,pp) - mean(raw_EMG{ii}(:,pp));
        end
    end
    % Rectify the EMG
    EMG = struct([]);
    for ii = 1:length(Zeroed_EMG)
        for pp = 1:width(Zeroed_EMG{ii})
            EMG{ii,1}(:,pp) = abs(Zeroed_EMG{ii}(:,pp));
        end
    end
end

if strcmp(EMG_Choice, 'Proc')
    EMG = sig.EMG;
end

%% Extract the baseline EMG & find the peak to peak amplitude for each trial
baseline_start = stim_idx - baseline_idxs;
baseline_stop = stim_idx;

Baseline_EMG = struct([]);
Baseline_peaktopeak = zeros(length(EMG), 1);
%figure
%hold on
for ii = 1:length(Baseline_peaktopeak)
    Baseline_EMG{ii,1} = EMG{ii}(baseline_start:baseline_stop, EMG_idx);
    %plot(Baseline_EMG{ii,1})
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

persistant_idxs = find(F_Wave_peaktopeak >= Baseline_peaktopeak + F_Wave_min);


