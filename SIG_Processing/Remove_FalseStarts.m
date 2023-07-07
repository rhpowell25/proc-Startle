
function [sig] = Remove_FalseStarts(sig)

%% Find the peak to peak baseline raw EMG for each trial
baseline_start = 0.8 / sig.bin_width;
baseline_stop = 1 / sig.bin_width;

peak_2_peak = zeros(length(sig.raw_EMG), width(sig.raw_EMG{1}));
for ii = 1:length(peak_2_peak)
    for pp = 1:width(sig.raw_EMG{1})
        peak_2_peak(ii,pp) = peak2peak(sig.raw_EMG{ii}(baseline_start:baseline_stop, pp));
    end
end

%% Find outliers in peak to peak baseline raw EMG
peak_2_peak_outliers = struct([]);
for ii = 1:width(peak_2_peak)
    peak_2_peak_outliers{ii} = find(peak_2_peak(:,ii) > prctile(peak_2_peak(:,ii), 95));
end

%% Combine the outliers into a single array
False_Start_idxs = peak_2_peak_outliers{1};
for ii = 2:length(peak_2_peak_outliers)
    False_Start_idxs = cat(1, False_Start_idxs, peak_2_peak_outliers{ii});
end

False_Start_idxs = unique(False_Start_idxs);

%% Find the trial indexes of the false starts

trial_idx = find(strcmp(sig.trial_info_table_header, 'number'));
bad_trials = sig.trial_info_table(False_Start_idxs, trial_idx);

%% Mark those trials as fails in sig file

for ii = 1:length(bad_trials)
    [sig] = Remove_Trial(sig, bad_trials{ii});
end

