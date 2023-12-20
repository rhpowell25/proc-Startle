function Avg_StartReact(sig, State, muscle_group, Save_File)

%% Display the function being used
disp('Average StartReact Function:');

%% Check for common sources of errors
if ~strcmp(State, 'All') && ~strcmp(State, 'F') && ~strcmp(State, 'F+s') && ~strcmp(State, 'F+S')
    disp('Incorrect State for StartReact')
    return
end

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial reaction times
[per_trial_EMG, EMG_Names] = Trial_StartReact(sig, State, muscle_group, 0, 0);

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [0, 0.2];

Task = strrep(sig.meta.task, '_', ' ');
bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to stop plotting
stop_length = 2; % Sec.
stop_idx = stop_length/bin_width;

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
axis_expansion = 0.025;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));
    
%% Calculating average EMG (Average Across trials)
cross_trial_avg_EMG = struct([]);
cross_trial_std_EMG = struct([]);
for ii = 1:length(EMG_Names)
    cross_trial_avg_EMG{ii,1} = zeros(length(per_trial_EMG{1,1}),1);
    cross_trial_std_EMG{ii,1} = zeros(length(per_trial_EMG{1,1}),1);
    for mm = 1:length(per_trial_EMG{1,1})
        cross_trial_avg_EMG{ii,1}(mm) = mean(per_trial_EMG{ii,1}(mm,:));
        cross_trial_std_EMG{ii,1}(mm) = std(per_trial_EMG{ii,1}(mm,:));
    end
end

%% Find the y-axis limits
if ischar(man_y_axis)
    y_limits = zeros(length(EMG_Names),2);
    for ii = 1:height(y_limits)
        y_limits(ii,1) = min(cross_trial_avg_EMG{ii,1});
        y_limits(ii,2) = max(cross_trial_avg_EMG{ii,1});
    end
    axis_min = min(y_limits(:,1));
    axis_max = max(y_limits(:,2));
else
    axis_min =  man_y_axis(1);
    axis_max = man_y_axis(2);
end

%% Plot the mean EMG traces

EMG_figure = figure;
EMG_figure.Position = [300 75 Plot_Params.fig_size Plot_Params.fig_size / 2];
hold on

% Title
Fig_Title = strcat('Average EMG:', {' '}, Task, {' '}, '[', State, ']');
sgtitle(Fig_Title, 'FontSize', Plot_Params.title_font_size)

for ii = 1:length(EMG_Names)
    subplot(length(EMG_Names),1,ii)
    hold on
    
    % Y Labels
    ylabel('EMG (mV)', 'FontSize', Plot_Params.label_font_size);
    
    % Mean EMG
    plot(absolute_timing(1:stop_idx), cross_trial_avg_EMG{ii,1}(1:stop_idx), ...
        'LineWidth', 2, 'Color', 'k');
    
    % Standard Deviation
    plot(absolute_timing(1:stop_idx), cross_trial_avg_EMG{ii,1}(1:stop_idx) + cross_trial_std_EMG{ii,1}(1:stop_idx), ...
        'LineWidth', 1, 'LineStyle','--', 'Color', 'r');
    
    legend(sprintf('%s', EMG_Names{ii}), ... 
            'NumColumns', 1, 'FontSize', Plot_Params.legend_size, 'FontName', Plot_Params.font_name, ...
            'Location', 'NorthEast');
    legend boxoff

    % Set the axis
    ylim([axis_min, axis_max + axis_expansion])
end

% X Label
xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)
