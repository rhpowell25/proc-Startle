function [per_trial_EMG, EMG_Names] = Trial_StartReact(sig, State, muscle_group, Plot_Figs, Save_File)

%% Display the function being used
disp('Per Trial StartReact Function:');

%% Check for common sources of errors
if ~strcmp(State, 'All') && ~strcmp(State, 'F') && ~strcmp(State, 'F+s') && ~strcmp(State, 'F+S')
    disp('Incorrect State for StartReact')
    per_trial_EMG = NaN;
    EMG_Names = NaN;
    return
end

%% Basic Settings, some variable extractions, & definitions

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [0, 0.2];

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Title info
Subject = sig.meta.subject;

% Bin width and baseline indices
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of the go cue
gocue_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
gocue_idx = round(gocue_time/bin_width);

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start and stop plotting
start_time = 0; % Sec.
if isequal(start_time, 0)
    start_idx = 1;
else
    start_idx = start_time/bin_width;
end
stop_time = 5; % Sec.
stop_idx = stop_time/bin_width;

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
axis_expansion = 0.1;

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
if strcmp(State, 'All')
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));
else
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
        strcmp(trial_info_table.State, State));
end

%% Extract the EMG & find its onset
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

% Find its onset
[EMG_onset_idx] = Detect_Onset(sig, State, muscle_group);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(EMG{1,1}));

%% Putting all succesful trials in one array
per_trial_EMG = struct([]);
for ii = 1:length(EMG_Names)
    per_trial_EMG{ii,1} = zeros(length(EMG{1,1}),length(EMG));
    for mm = 1:length(EMG)
        per_trial_EMG{ii,1}(:,mm) = EMG{mm}(:, ii);
    end
end

%% Plot the individual EMG traces on the top

if isequal(Plot_Figs, 1)
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 Plot_Params.fig_size Plot_Params.fig_size];
        hold on
    
        % Titling the plot
        Fig_Title = strcat('Reaction Time:', {' '}, Subject, {' '}, '[', State, ']', {' '}, EMG_Names{ii});
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);
    
        for pp = 1:width(per_trial_EMG{ii})
    
            plot(absolute_timing(start_idx:stop_idx), per_trial_EMG{ii}(start_idx:stop_idx,pp))
    
            % Plot the go-cues as dark green dots
            if ~isempty(per_trial_EMG{ii,1}(gocue_idx,pp))
                plot(1, per_trial_EMG{ii,1}(gocue_idx(1),pp), ...
                    'Marker', '.', 'Color', [0 0.5 0], 'Markersize', 15);
            end
            % Plot the EMG onset as red dots
            if ~isnan(EMG_onset_idx(pp,ii))
                plot(absolute_timing(EMG_onset_idx(pp,ii)), per_trial_EMG{ii,1}(EMG_onset_idx(pp,ii),pp), ...
                    'Marker', '.', 'Color', 'r', 'Markersize', 15);
            end
            %pause(0.5)
    
        end % End of the individual trial loop
    
        if ~ischar(man_y_axis)
            % Set the axis
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end
    
        %% Save the file if selected
        Save_Figs(Fig_Title, Save_File)

    end % End of the muscle loop
end


