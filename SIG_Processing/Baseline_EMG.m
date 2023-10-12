
function [cutoff_trials] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_Figs)

%% Display the function being used
disp('Baseline EMG Histogram:');

%% Basic Settings, some variable extractions, & definitions

% What peak to peak baseline EMG amplitude do you want as the cut off (mV)
cutoff_amp = 0.1;

% How much before & after the gocue do you want to analyze (Sec.)
baseline_start = 0.2;
baseline_stop = 0;

% Do you want to plot the cuttoff amplitude (1 = Yes, 0 = No)
show_cuttoff = 0;

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [0, 0.2];

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Raw';

% Title info
Subject = sig.meta.subject;
Task = sig.meta.task;

% Bin width and baseline indices
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of the go cue
gocue_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start and stop plotting
start_time = gocue_time - baseline_start; % Sec.
if isequal(start_time, 0)
    start_idx = 1;
else
    start_idx = round(start_time/bin_width);
end
stop_time = gocue_time + baseline_stop; % Sec.; % Sec.
stop_idx = round(stop_time/bin_width);

% Font specifications
axis_expansion = 0;
label_font_size = 15;
title_font_size = 15;
mean_line_width = 3;
figure_width = 700;
figure_height = 700;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));

% States
states = trial_info_table.State(rewarded_idxs);

%% Extract the EMG & find its onset
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(EMG{1,1}));

%% Find the peak to peak baseline raw EMG for each trial

peak_2_peak = zeros(length(EMG), width(EMG{1}));
for ii = 1:length(peak_2_peak)
    for pp = 1:width(EMG{1})
        % Adjust for StartMEP intervals
        if contains(states{ii}, '50ms')
            temp_start = start_idx - (0.05 / bin_width);
            temp_stop = stop_idx - (0.05 / bin_width);
        elseif contains(states{ii}, '80ms')
            temp_start = start_idx - (0.08 / bin_width);
            temp_stop = stop_idx - (0.08 / bin_width);
        elseif contains(states{ii}, '100ms')
            temp_start = start_idx - (0.1 / bin_width);
            temp_stop = stop_idx - (0.1 / bin_width);
        else
            temp_start = start_idx;
            temp_stop = stop_idx;
        end
        peak_2_peak(ii,pp) = peak2peak(EMG{ii}(temp_start:temp_stop, pp));
    end
end

%% Find cutt off peak to peak baseline raw EMG
peak_2_peak_cuttofs = struct([]);
for ii = 1:width(peak_2_peak)
    peak_2_peak_cuttofs{ii} = find(peak_2_peak(:,ii) > cutoff_amp);
end

%% Combine the outliers into a single array
cuttoff_idxs = peak_2_peak_cuttofs{1};
for ii = 1:length(peak_2_peak_cuttofs)
    cuttoff_idxs = cat(1, cuttoff_idxs, peak_2_peak_cuttofs{ii});
end

cuttoff_idxs = unique(cuttoff_idxs);

%% Find the trial indexes of the false starts

trial_idx = find(strcmp(sig.trial_info_table_header, 'number'));
cutoff_trials = sig.trial_info_table(cuttoff_idxs, trial_idx);

%% Plot a histogram of the peak to peak baseline EMG amplitudes

if isequal(Plot_Figs, 1)

    % Histogram
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 figure_width figure_height];
        hold on
    
        % Titling the plot
        EMG_title = strcat('Baseline EMG Histogram:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        xlabel('Peak-to-peak amplitude (mV)', 'FontSize', label_font_size);
        ylabel('Trials', 'FontSize', label_font_size);
    
        % Plot the histogram
        histogram(peak_2_peak(:,ii), 25, 'EdgeColor', 'k', 'FaceColor', [.5 0 .5])
    
        % Set the axis
        x_limits = xlim;
        y_limits = ylim;
        xlim([x_limits(1), x_limits(2) + axis_expansion])
        ylim([y_limits(1), y_limits(2) + axis_expansion])

        % Plot the cuttoff amplitude
        if isequal(show_cuttoff, 1)
            line([cutoff_amp cutoff_amp], [y_limits(1) y_limits(2) + 0.25], ... 
                'LineStyle','--', 'Color', 'k', 'LineWidth', mean_line_width)
        end

        if ~ischar(man_y_axis)
            % Set the axis
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end
    
    end % End of the muscle loop

    % Per Trial Baseline EMG
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 figure_width figure_height / 2];
        hold on

        post_gocue_idx = 10;
    
        % Titling the plot
        EMG_title = strcat('Baseline EMG:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        ylabel('Peak-to-peak amplitude (mV)', 'FontSize', label_font_size);
        xlabel('Time (sec.)', 'FontSize', label_font_size);
    
        % Adjust for StartMEP intervals
        if strcmp(Task, 'StartMEP')
            start_time = gocue_time - baseline_start - 0.1;
            temp_start = start_idx - (0.1 / bin_width);
        end

        % Plot the baseline EMG
        for pp = 1:length(EMG)
            plot(absolute_timing(temp_start:stop_idx + post_gocue_idx), ...
                EMG{pp}(temp_start:stop_idx + post_gocue_idx, ii));
        end
    
        % Set the axis
        y_limits = ylim;
        xlim([start_time, (stop_idx + post_gocue_idx)*bin_width])
        ylim([y_limits(1), y_limits(2) + axis_expansion])

        % Plot the cuttoff amplitude
        if isequal(show_cuttoff, 1)
            line([cutoff_amp cutoff_amp], [y_limits(1) y_limits(2) + 0.25], ... 
                'LineStyle','--', 'Color', 'k', 'LineWidth', mean_line_width)
        end

        if ~ischar(man_y_axis)
            % Set the axis
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end
    
    end % End of the muscle loop
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        fig_info = get(gca,'title');
        save_title = get(fig_info, 'string');
        save_title = strrep(save_title, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
        if ~strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), Save_Figs)
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'fig')
        end
        close gcf
    end
end
