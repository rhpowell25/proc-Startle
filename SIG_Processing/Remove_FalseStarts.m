
function [sig] = Remove_FalseStarts(sig)

%% Find outliers in peak to peak baseline raw EMG

% What peak to peak baseline EMG amplitude do you want as the cut off (mV)
cutoff_amp = 0.1;

[peak2peak_EMG, trial_idxs] = Baseline_EMG(sig, 'ABH', 0, 0);

cutoff_trials = trial_idxs(peak2peak_EMG >= cutoff_amp);

%% Mark those trials as fails in sig file

for ii = 1:length(cutoff_trials)
    [sig] = Remove_Trial(sig, cutoff_trials(ii));
end

