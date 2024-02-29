function [per_trial_EMG, EMG_Names] = Trial_StartMEP(sig, State, muscle_group, Plot_Figs, Save_File)

%% Display the function being used
disp('Per Trial Startled MEP Function:');

%% Check for common sources of errors
if ~strcmp(State, 'All') && ~strcmp(State, 'MEP') && ~strcmp(State, 'MEP+50ms') ...
        && ~strcmp(State, 'MEP+80ms') && ~strcmp(State, 'MEP+100ms')
    disp('Incorrect State for StartMEP')
    per_trial_EMG = NaN;
    EMG_Names = NaN;
    return
end

%% Basic Settings, some variable extractions, & definitions

% Time settings for MEP viewing
params = struct(...
    'stim_art', 'Yes', ... % Show the stimulus artifact? ('Yes', 'No')
    'silent_period', 'Yes'); % Show the silent period? ('Yes', 'No')
[Time_Settings] = MEP_Time_Settings(params);

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [-0.4, 0.7];

% Do you want to include the stimulus artifact ('Yes', 'No')
stim_art = 'No';

% Title info
Subject = sig.meta.subject;

% Bin width
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of stimulus & time after stimulus artifact
stim_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start & stop plotting
start_time = stim_time - Time_Settings.pre_gocue; % Sec.
stop_time = stim_time + Time_Settings.post_gocue; % Sec.

start_idx = round(start_time/bin_width);
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
if strcmp(State, 'All')
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));
else
    rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice) & ...
        strcmp(trial_info_table.State, State));
end

% End the function if no succesful trials
if isempty(rewarded_idxs)
    disp('No trials with this State')
    per_trial_EMG = {NaN};
    EMG_Names = {NaN};
    return
end

%% Extract the EMG
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(EMG{1,1}));

%% Pulling all the trials & finding their peak to peak amplitudes
per_trial_EMG = struct([]);
for ii = 1:length(EMG_Names)
    per_trial_EMG{ii,1} = zeros(length(EMG{1,1}(:, 1)), length(EMG));
    peaktopeak_MEP = NaN(length(EMG), 1);
    for mm = 1:length(EMG)
        per_trial_EMG{ii,1}(:,mm) = EMG{mm}(:, ii);
        if strcmp(stim_art, 'No')
            peaktopeak_MEP(mm,1) = peak2peak(per_trial_EMG{ii,1}(start_idx:stop_idx,mm));
        end
    end
end

%% Plot the individual EMG traces on the top

if isequal(Plot_Figs, 1)
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 Plot_Params.fig_size Plot_Params.fig_size];
        hold on

        % Titling the plot
        Fig_Title = strcat('MEPs:', {' '}, Subject, {' '}, State, {' '}, '[', EMG_Names{ii}, ']');
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);
    
        for pp = 1:width(per_trial_EMG{ii})
            plot(absolute_timing(start_idx:stop_idx), per_trial_EMG{ii}(start_idx:stop_idx,pp))
        end % End of the individual trial loop
    
        % Set the axis
        xlim([start_time, stop_time])
        if ~ischar(man_y_axis)
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end

        % Annotation of the mean peak to peak amplitude
        if strcmp(stim_art, 'No')
            avg_peaktopeak = round(mean(peaktopeak_MEP), 2);
            legend_dims = [0.555 0.425 0.44 0.44];
            pktopk_count_string = strcat('pk-pk =', {' '}, mat2str(avg_peaktopeak), {' '}, 'mV');
            legend_string = {char(pktopk_count_string)};
            ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ...
                'FitBoxToText', 'on', 'verticalalignment', 'top', ...
                'EdgeColor','none', 'horizontalalignment', 'center');
            ann_legend.FontSize = Plot_Params.legend_size;
            ann_legend.FontName = Plot_Params.font_name;
        end

    end % End of the muscle loop

    %% Save the file if selected
    Save_Figs(Fig_Title, Save_File)
end

