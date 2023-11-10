function Overlap_StartMEP(sig, Muscle, Save_Figs)

%% Display the function being used
disp('Overlap Startled MEP Function:');

%% Basic Settings, some variable extractions, & definitions
% Do you want to exclude the 100 ISI
exclude_hund = 1;

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [-0.19, -0.13];

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
plot_length = 0.075; % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start & stop plotting
if strcmp(stim_art, 'Yes')
    pre_stim_art = 0.01; % Sec.
    start_time = stim_time - pre_stim_art; % Sec.
else
    post_stim_art = 0.03; % Sec.
    start_time = stim_time + post_stim_art; % Sec.
end
start_idx = round(start_time/bin_width);
stop_time = start_time + plot_length; % Sec.
stop_idx = round(stop_time/bin_width);

% Font specifications
state_colors = [0 0 0; 1 0 0; 0 0.5 0];
%state_colors = [0 0 0; .7 .7 .7; 1 0 0; 0 0.5 0];
line_width = 5;
axis_expansion = 0;
label_font_size = 25;
legend_font_size = 25;
title_font_size = 25;
font_name = 'Arial';
figure_size = 1500;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Extract the per trial startled MEP's

% Find all the states tested
State_idx = strcmp(sig.trial_info_table_header, 'State');
State_list = strings;
for ii = 1:height(sig.trial_info_table)
    State_list{ii} = char(sig.trial_info_table{ii,State_idx});
end
States = unique(State_list)';

if exclude_hund == 1
    States(strcmp(States, 'MEP+100ms')) = [];
end

% Extract the EMG for each state
per_trial_MEP = struct([]);
for ii = 1:length(States)
    [per_trial_MEP{ii,1}, EMG_Names] = Trial_StartMEP(sig, States{ii}, Muscle, 0, 0);
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));
    
%% Calculating average & peak to peak MEP (Average Across trials)
avg_MEP = struct([]);
peaktopeak_MEP = struct([]);
for ii = 1:length(EMG_Names)
    for mm = 1:length(States)
        avg_MEP{ii,1}{mm,1} = mean(per_trial_MEP{mm,1}{ii,1}, 2);
        peaktopeak_MEP{ii,1}{mm,1} = peak2peak(per_trial_MEP{mm,1}{ii,1}(start_idx:stop_idx,:));
    end
end

%% Plot the individual EMG traces

for ii = 1:length(EMG_Names)

    EMG_figure = figure;
    EMG_figure.Position = [300 25 figure_size figure_size];
    hold on

    % Titling the plot
    fig_title = strcat('MEPs:', {' '}, Subject, {' '}, '[', EMG_Names{ii}, ']');
    %title(fig_title, 'FontSize', title_font_size)

    % Labels
    ylabel('EMG (mV)', 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

    % Setting the x-axis limits
    % Set the axis
    xlim([start_time, stop_time])
    if ~ischar(man_y_axis)
        ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
    end
    
    % Mean EMG
    State_Labels = strings;
    for pp = 1:length(States)
        % Set the color according to the state
        plot(absolute_timing(start_idx:stop_idx), avg_MEP{ii,1}{pp,1}(start_idx:stop_idx), ...
            'LineWidth', line_width, 'Color', state_colors(pp,:));
        % Concatenate the state with its peak to peak amplitude
        State_Labels{pp} = char(States{pp});
        %State_Labels{pp} = char(strcat(State_Labels{pp}, {' '}, '[',...
        %    mat2str(round(mean(peaktopeak_MEP{ii,1}{pp,1}), 2)), ']'));
    end
    
    % Increase the font size
    set(gca,'fontsize', label_font_size)
    set(gca,'XColor', 'none','YColor','none')
    set(gca, 'color', 'none');
    
    Axes_Legend('sec', 'mv')

    % Legend
    legend(State_Labels, 'NumColumns', 1, 'FontName', font_name, ...
        'Location', 'NorthEast', 'FontSize', legend_font_size)
    % Remove the legend's outline
    legend boxoff
    
    % Axis Editing
    figure_axes = gca;
    % Set ticks to outside
    set(figure_axes,'TickDir','out');
    % Remove the top and right tick marks
    set(figure_axes,'box','off')
    
    % Replace tick labels
    x_labels = string(figure_axes.XAxis.TickLabels);
    y_labels = string(figure_axes.YAxis.TickLabels);
    x_labels(1:2:end) = NaN;
    y_labels(1:2:end) = NaN;
    figure_axes.XAxis.TickLabels = x_labels;
    figure_axes.YAxis.TickLabels = y_labels;

end % End of the muscle loop

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        save_title = strrep(fig_title, ':', '');
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



