function Avg_MVC(sig, Plot_Choice, muscle_group, Save_File)

%% Display the function being used
disp('Average MVC Function:');

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial reaction times
[per_trial_Plot_Metric, ~, Plot_Names] = Trial_MVC(sig, Plot_Choice, muscle_group, 0, 0);

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [0, 0.2];

% Title info
Subject = sig.meta.subject;
Task = strrep(sig.meta.task, '_', ' ');

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Font specifications
axis_expansion = 0.025;
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
figure_width = 700;
figure_height = 350;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(per_trial_Plot_Metric{1,1}(:,1)));
    
%% Calculating average plot metric (Average Across trials)
cross_trial_avg_Plot_Metric = struct([]);
cross_trial_std_Plot_Metric = struct([]);
for ii = 1:length(Plot_Names)
    cross_trial_avg_Plot_Metric{ii,1} = zeros(length(per_trial_Plot_Metric{1,1}),1);
    cross_trial_std_Plot_Metric{ii,1} = zeros(length(per_trial_Plot_Metric{1,1}),1);
    for mm = 1:length(per_trial_Plot_Metric{1,1})
        cross_trial_avg_Plot_Metric{ii,1}(mm) = mean(per_trial_Plot_Metric{ii,1}(mm,:));
        cross_trial_std_Plot_Metric{ii,1}(mm) = std(per_trial_Plot_Metric{ii,1}(mm,:));
    end
end

%% Find the y-axis limits
if ischar(man_y_axis)
    y_limits = zeros(length(Plot_Names),2);
    for ii = 1:height(y_limits)
        y_limits(ii,1) = min(cross_trial_avg_Plot_Metric{ii,1});
        y_limits(ii,2) = max(cross_trial_avg_Plot_Metric{ii,1} + cross_trial_std_Plot_Metric{ii,1});
    end
    axis_min = min(y_limits(:,1));
    axis_max = max(y_limits(:,2));
else
    axis_min =  man_y_axis(1);
    axis_max = man_y_axis(2);
end
if isequal(Plot_Choice, 'Force')
    axis_expansion = axis_expansion*10;
end

%% Plot the mean traces

Metric_figure = figure;
Metric_figure.Position = [300 75 figure_width figure_height];
hold on

% Title
Fig_Title = strcat('Average', {' '}, Plot_Choice, ':', {' '}, Subject, {' '}, Task);
sgtitle(Fig_Title, 'FontSize', title_font_size)

for ii = 1:length(Plot_Names)
    subplot(length(Plot_Names),1,ii)
    hold on
    
    % Y Labels
    if isequal(Plot_Choice, 'EMG')
        ylabel('EMG (mV)', 'FontSize', label_font_size);
    elseif isequal(Plot_Choice, 'Force')
        ylabel('Force (N)', 'FontSize', label_font_size);
    end
    
    % Mean EMG
    plot(absolute_timing, cross_trial_avg_Plot_Metric{ii,1}, ...
        'LineWidth', 2, 'Color', 'k');
    
    % Standard Deviation
    plot(absolute_timing, cross_trial_avg_Plot_Metric{ii,1} + cross_trial_std_Plot_Metric{ii,1}, ...
        'LineWidth', 1, 'LineStyle','--', 'Color', 'r');
    
    legend(sprintf('%s', Plot_Names{ii}), ... 
            'NumColumns', 1, 'FontSize', legend_font_size, 'FontName', font_name, ...
            'Location', 'NorthEast');
    legend boxoff

    % Set the axis
    ylim([axis_min, axis_max + axis_expansion])
end

% X Label
xlabel('Time (sec.)', 'FontSize', label_font_size);

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)
