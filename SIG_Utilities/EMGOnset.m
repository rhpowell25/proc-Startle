function [avg_baseline, std_baseline, EMG_onset_idx] = EMGOnset(EMG)

%% Basic settings, some variable extractions, & definitions

trial_length = 5; % Sec.
bin_width = trial_length / length(EMG{1});

GoCue_idx = 1.1 / bin_width;

std_multiplier = 5;

Plot_Figs = 0;

% Which method do you want to use (1, 2, 3)
onset_method = 1;

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

%% Method 1
if isequal(onset_method, 1)
    disp('Wrong Method!')
    EMG_onset_idx = NaN;
    return
end
%% Method 2

if isequal(onset_method, 2)

    % Window to calculate the EMG onset
    half_window_size = 4; % Bins
    step_size = 1; % Bins
    
    EMG_onset_idx = zeros(length(EMG), width(EMG{1,1}));
    % Loop through each trial
    for ii = 1:length(EMG)
        for pp = 1:width(EMG{1,1})
            % Find the baseline EMG
            %avg_baseline = mean(EMG{ii}(1:GoCue_idx, pp));
            %std_baseline = std(EMG{ii}(1:GoCue_idx, pp));
            baseline_EMG_cutoff = avg_baseline(1,pp) + std_multiplier*std_baseline(1,pp);
            % Sliding average
            [sliding_avg, ~, array_idxs] = Sliding_Window(EMG{ii,1}(:,pp), half_window_size, step_size);
            % Find the peak cursor position
            temp_1 = find(sliding_avg == max(sliding_avg));
            % Find the onset of this peak
            temp_2 = find(sliding_avg(GoCue_idx:temp_1) > baseline_EMG_cutoff);
            temp_2 = temp_2 + GoCue_idx - 1;
            
            window_idxs = array_idxs{temp_2(1)};
            EMG_onset_idx(ii,1) = window_idxs(1);
    
            if isequal(Plot_Figs, 1)
                figure
                hold on
                subplot(2, 1, 1)
                plot(sliding_avg)
                line([EMG_onset_idx(ii,1) EMG_onset_idx(ii,1)], [min(sliding_avg) max(sliding_avg)], ... 
                    'LineStyle','--', 'Color', 'r')
                line([1 length(sliding_avg)], [baseline_EMG_cutoff baseline_EMG_cutoff], ... 
                    'LineStyle','--', 'Color', 'r')
                subplot(2, 1, 2)
                plot(EMG{ii,1}(:,pp))
                line([EMG_onset_idx(ii,1) EMG_onset_idx(ii,1)], [min(EMG{ii,1}(:,pp)) max(EMG{ii,1}(:,pp))], ... 
                    'LineStyle','--', 'Color', 'r')
                line([1 length(EMG{ii,1}(:,pp))], [baseline_EMG_cutoff baseline_EMG_cutoff], ... 
                    'LineStyle','--', 'Color', 'r')
            end

        end
    end
end

%% Method 3
if isequal(onset_method, 3)
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

