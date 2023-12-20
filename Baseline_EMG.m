
function [peak2peak_EMG, rewarded_idxs] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_File)

%% Display the function being used
disp('Baseline EMG Histogram:');

%% Basic Settings, some variable extractions, & definitions

% How much before & after the gocue do you want to analyze (Sec.)
before_gocue = 0.101;
after_gocue = -0.001;

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
start_time = gocue_time - before_gocue; % Sec.
if isequal(start_time, 0)
    start_idx = 1;
else
    start_idx = round(start_time/bin_width);
end
stop_time = gocue_time + after_gocue; % Sec.; % Sec.
stop_idx = round(stop_time/bin_width);

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
axis_expansion = 0;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
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

peak2peak_EMG = zeros(length(EMG), width(EMG{1}));
baseline_EMG = zeros(length(EMG), (stop_idx - start_idx + 1));
for ii = 1:length(peak2peak_EMG)
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
        peak2peak_EMG(ii,pp) = peak2peak(EMG{ii}(temp_start:temp_stop, pp));
        baseline_EMG(ii,:) = EMG{ii}(temp_start:temp_stop, pp);
    end
end

%% Plot a histogram of the peak to peak baseline EMG amplitudes

if isequal(Plot_Figs, 1)

    % Histogram
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 Plot_Params.fig_size Plot_Params.fig_size];
        hold on
    
        % Titling the plot
        Fig_Title = strcat('Baseline EMG Histogram:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', EMG_Names{ii}, ']');
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        xlabel('Peak-to-peak amplitude (mV)', 'FontSize', Plot_Params.label_font_size);
        ylabel('Trials', 'FontSize', Plot_Params.label_font_size);
    
        % Plot the histogram
        histogram(peak2peak_EMG(:,ii), 25, 'EdgeColor', 'k', 'FaceColor', [.5 0 .5])
    
        % Set the axis
        x_limits = xlim;
        y_limits = ylim;
        xlim([x_limits(1), x_limits(2) + axis_expansion])
        ylim([y_limits(1), y_limits(2) + axis_expansion])

        if ~ischar(man_y_axis)
            % Set the axis
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end

        %% Save the file if selected
        Save_Figs(Fig_Title, Save_File)
    
    end % End of the muscle loop

    % Per Trial Baseline EMG
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 Plot_Params.fig_size Plot_Params.fig_size / 2];
        hold on

        post_gocue_idx = 5;
    
        % Titling the plot
        Fig_Title = strcat('Baseline EMG:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', EMG_Names{ii}, ']');
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        ylabel('Peak-to-peak amplitude (mV)', 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);
    
        % Adjust for StartMEP intervals
        if strcmp(Task, 'StartMEP')
            start_time = gocue_time - before_gocue - 0.1;
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

        if ~ischar(man_y_axis)
            % Set the axis
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end

        %% Save the file if selected
        Save_Figs(Fig_Title, Save_File)
    
    end % End of the muscle loop
    
end % End of the Plot_Fig statement

