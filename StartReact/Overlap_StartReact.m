function Overlap_StartReact(sig, Muscle, Save_Figs)

%% Display the function being used
disp('Overlap Start React Function:');

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial reaction times
[per_trial_F_EMG, ~] = Trial_StartReact(sig, 'F', Muscle, 0, 0);
[per_trial_Fs_EMG, ~] = Trial_StartReact(sig, 'F+s', Muscle, 0, 0);
[per_trial_FS_EMG, ~] = Trial_StartReact(sig, 'F+S', Muscle, 0, 0);

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Title info
Subject = sig.meta.subject;
Task = strrep(sig.meta.task, '_', ' ');

% When do you want to start & stop plotting
start_length = 1.07; % Sec.
start_idx = start_length/bin_width;
stop_length = 1.25; % Sec.
stop_idx = round(stop_length/bin_width);

% Font specifications
label_font_size = 25;
legend_font_size = 25;
title_font_size = 25;
mean_line_width = 2;
font_name = 'Arial';
figure_size = 2000;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));

%% Calculating average EMG (Average Across trials)
avg_F_EMG = mean(per_trial_F_EMG{1,1}, 2);

avg_Fs_EMG = mean(per_trial_Fs_EMG{1,1}, 2);

avg_FS_EMG = mean(per_trial_FS_EMG{1,1}, 2);

%% Plot the individual EMG traces

EMG_figure = figure;
EMG_figure.Position = [100 25 figure_size figure_size / 2];
hold on

% Titling the plot
fig_title = strcat(Task, {' '}, 'Reaction Times:', {' '}, Subject);
%title(fig_title, 'FontSize', title_font_size)

% Labels
ylabel('Avg EMG (mV)', 'FontSize', label_font_size);
xlabel('Time (sec.)', 'FontSize', label_font_size);

% Setting the x-axis limits
xlim([absolute_timing(start_idx), absolute_timing(stop_idx)]);

% Mean EMG
plot(absolute_timing(start_idx:stop_idx), avg_F_EMG(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', 'k');
plot(absolute_timing(start_idx:stop_idx), avg_Fs_EMG(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', [.7 .7 .7]);
plot(absolute_timing(start_idx:stop_idx), avg_FS_EMG(start_idx:stop_idx), ...
    'LineWidth', 2, 'Color', 'r');

% Legend
%legend('F', 'F+s', 'F+S', 'NumColumns', 1, 'FontName', font_name, ...
%    'Location', 'NorthWest', 'FontSize', legend_font_size)
% Remove the legend's outline
%legend boxoff

% Increase the font size
set(gca,'fontsize', label_font_size)
set(gca,'XColor', 'none','YColor','none')
set(gca, 'color', 'none');
    
Axes_Legend('sec', 'mv')

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



