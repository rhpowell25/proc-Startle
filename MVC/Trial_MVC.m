function [per_trial_Plot_Metric, MVC_max, Plot_Names] = Trial_MVC(sig, Plot_Choice, muscle_group, Plot_Figs, Save_Figs)

%% Display the function being used
disp('Per Trial MVC Function:');

%% Check for common sources of errors
if ~isstruct(sig)
    disp('NaN Sig File!')
    per_trial_Plot_Metric = {NaN};
    Plot_Names = {NaN};
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

% Window to calculate the peak MVC
half_window_time = 0.5; % Sec.
half_window_size = half_window_time / bin_width; % Bins
step_size = 1; % Bins

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Font specifications
axis_expansion = 0.1;
label_font_size = 15;
title_font_size = 15;
figure_width = 700;
figure_height = 350;

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

%% Extract the EMG or force
if isequal(Plot_Choice, 'EMG')
    [Plot_Names, Plot_Metric] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);
elseif isequal(Plot_Choice, 'Force')
    Plot_Names = {'Force'};
    [Plot_Metric] = Extract_Force(sig, 1, 1, rewarded_idxs);
end

%% Find the average peak of each MVC
MVC_max = zeros(length(Plot_Metric), 1);
for ii = 1:length(Plot_Metric)
    % Sliding average
    [sliding_avg, ~, ~] = ...
        Sliding_Window(Plot_Metric{ii,1}, half_window_size, step_size);
    % Find the max MVC
    temp_2 = sliding_avg(sliding_avg == max(sliding_avg));
    MVC_max(ii) = temp_2(1);
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(Plot_Metric{1,1}));

%% Putting all succesful trials in one array

per_trial_Plot_Metric = struct([]);
if isequal(Plot_Choice, 'EMG')
    for ii = 1:length(Plot_Names)
        per_trial_Plot_Metric{ii,1} = zeros(length(Plot_Metric{1,1}),length(Plot_Metric));
        for mm = 1:length(Plot_Metric)
            per_trial_Plot_Metric{ii,1}(:,mm) = Plot_Metric{mm}(:, ii);
        end
    end
elseif isequal(Plot_Choice, 'Force')
    for ii = 1:length(Plot_Metric)
        per_trial_Plot_Metric{1,1}(:,ii) = Plot_Metric{ii}(:,1);
    end
end

%% Plot the individual EMG traces on the top

if isequal(Plot_Figs, 1)
    for ii = 1:length(Plot_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 figure_width figure_height];
        hold on
    
        % Titling the plot
        EMG_title = strcat('MVC:', {' '}, Subject, {' '}, Plot_Names{ii});
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        if isequal(Plot_Choice, 'EMG')
            ylabel('EMG (mV)', 'FontSize', label_font_size);
        elseif isequal(Plot_Choice, 'Force')
            ylabel('Force (N)', 'FontSize', label_font_size);
        end
        xlabel('Time (sec.)', 'FontSize', label_font_size);
    
        for pp = 1:width(per_trial_Plot_Metric{ii})
    
            plot(absolute_timing, per_trial_Plot_Metric{ii}(:,pp))
    
        end % End of the individual trial loop
    
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
