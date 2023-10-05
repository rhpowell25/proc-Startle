
function [sig] = Remove_FalseStarts(sig)

%% Find outliers in peak to peak baseline raw EMG
[cutoff_trials] = Baseline_EMG(sig, 'ABH', 0, 0);

%% Mark those trials as fails in sig file

for ii = 1:length(cutoff_trials)
    [sig] = Remove_Trial(sig, cutoff_trials{ii});
end

