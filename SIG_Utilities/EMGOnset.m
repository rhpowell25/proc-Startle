function [EMG_onset_idx] = EMGOnset(EMG)

%% Basic settings, some variable extractions, & definitions

trial_length = 5; % Sec.
bin_size = trial_length / length(EMG{1});

GoCue_idx = 1.1 / bin_size;

std_multiplier = 5;

Plot_Figs = 0;

%% Defines onset time via the EMG onset

EMG_onset_idx = zeros(length(EMG), width(EMG{1,1}));
% Loops through EMG
for ii = 1:length(EMG)
    for pp = 1:width(EMG{1,1})
        % Subsample the EMG
        sub_EMG = EMG{ii}(:,pp);
        % Find the peak EMG
        peak_EMG_idx = find(sub_EMG == max(sub_EMG));
        peak_EMG_idx = peak_EMG_idx(1);
        % Find the baseline EMG
        baseline_EMG_cutoff = mean(sub_EMG(1:GoCue_idx)) + std_multiplier*std(sub_EMG(1:GoCue_idx));
        % Find the EMG above & below the cutoff
        EMG_under_cutoff = find(sub_EMG(GoCue_idx:peak_EMG_idx) <= baseline_EMG_cutoff);
        EMG_over_cutoff = find(sub_EMG(GoCue_idx:peak_EMG_idx) > baseline_EMG_cutoff);
        % Find the nonconsecutive under cutoffs
        diff_EMG_under_cutoff = EMG_under_cutoff(diff(EMG_under_cutoff) > 1);
        % Find the consecutive over cutoffs
        diff_EMG_over_cutoff = EMG_over_cutoff(diff(EMG_over_cutoff) == 1);
        % Find the intersection between these
        over_under_intersection = intersect(diff_EMG_under_cutoff + 1, diff_EMG_over_cutoff);
        if isempty(over_under_intersection)
            over_under_intersection = intersect(EMG_under_cutoff + 1, EMG_over_cutoff);
        end
        try
            EMG_onset_idx(ii,pp) = over_under_intersection(1) + GoCue_idx;
        catch
            EMG_onset_idx(ii,pp) = NaN;
        end
    end
end

if isequal(Plot_Figs, 1)
    x = intersect(EMG_under_cutoff, EMG_over_cutoff - 1);
    figure
    hold on
    absolute_timing = linspace(0, trial_length, length(sub_EMG));
    plot(absolute_timing, sub_EMG)
    line([absolute_timing(1) absolute_timing(end)], [baseline_EMG_cutoff baseline_EMG_cutoff], ... 
            'LineStyle','--', 'Color', 'k')
    line([absolute_timing(x(1) + GoCue_idx - 1) ...
        absolute_timing(x(1) + GoCue_idx - 1)], [min(sub_EMG) max(sub_EMG)], ... 
            'LineStyle','--', 'Color', 'r')
    scatter(absolute_timing(EMG_over_cutoff + GoCue_idx - 1), sub_EMG(EMG_over_cutoff + GoCue_idx - 1), 'r', '.')
    scatter(absolute_timing(EMG_under_cutoff + GoCue_idx - 1), sub_EMG(EMG_under_cutoff + GoCue_idx - 1), 'k', '.')
    xlim([1.1 1.4])
end

