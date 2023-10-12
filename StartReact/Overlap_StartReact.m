function Overlap_StartReact(sig, muscle_group, Save_Figs)

%% Display the function being used
disp('Overlap Start React Function:');

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial reaction times
[per_trial_F_EMG, EMG_Names] = Trial_StartReact(sig, 'F', muscle_group, 0, 0);
[per_trial_Fs_EMG, ~] = Trial_StartReact(sig, 'F+s', muscle_group, 0, 0);
[per_trial_FS_EMG, ~] = Trial_StartReact(sig, 'F+S', muscle_group, 0, 0);

bin_width = sig.bin_width;
trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Title info
Subject = sig.meta.subject;
Task = strrep(sig.meta.task, '_', ' ');

% When do you want to start & stop plotting
start_length = 1; % Sec.
start_idx = start_length/bin_width;
stop_length = 1.3; % Sec.
stop_idx = round(stop_length/bin_width);

% Font specifications
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
figure_width = 700;
figure_height = 350;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));

%% Calculating average EMG (Average Across trials)
avg_F_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_F_EMG{ii,1} = zeros(length(per_trial_F_EMG{1,1}),1);
    for mm = 1:length(per_trial_F_EMG{1,1})
        avg_F_EMG{ii,1}(mm) = mean(per_trial_F_EMG{ii,1}(mm,:));
    end
end
avg_Fs_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_Fs_EMG{ii,1} = zeros(length(per_trial_Fs_EMG{1,1}),1);
    for mm = 1:length(per_trial_Fs_EMG{1,1})
        avg_Fs_EMG{ii,1}(mm) = mean(per_trial_Fs_EMG{ii,1}(mm,:));
    end
end
avg_FS_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_FS_EMG{ii,1} = zeros(length(per_trial_FS_EMG{1,1}),1);
    for mm = 1:length(per_trial_FS_EMG{1,1})
        avg_FS_EMG{ii,1}(mm) = mean(per_trial_FS_EMG{ii,1}(mm,:));
    end
end

%% Plot the individual EMG traces

fig_titles = struct([]);

for ii = 1:length(EMG_Names)

    EMG_figure = figure;
    EMG_figure.Position = [300 100 figure_width figure_height];
    hold on

    % Titling the plot
    fig_titles{ii} = strcat(Task, {' '}, 'Reaction Times:', {' '}, Subject);
    title(fig_titles{ii}, 'FontSize', title_font_size)

    % Labels
    y_label = strcat(EMG_Names{ii}, {' '}, 'EMG');
    ylabel(y_label, 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

    % Setting the x-axis limits
    xlim([absolute_timing(start_idx), absolute_timing(stop_idx)]);
    
    % Mean EMG
    plot(absolute_timing(start_idx:stop_idx), avg_F_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'k');
    plot(absolute_timing(start_idx:stop_idx), avg_Fs_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', [.7 .7 .7]);
    plot(absolute_timing(start_idx:stop_idx), avg_FS_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'r');
    
    % Legend
    legend('F', 'F+s', 'F+S', 'NumColumns', 1, 'FontName', font_name, ...
        'Location', 'NorthWest', 'FontSize', legend_font_size)
    % Remove the legend's outline
    legend boxoff

end % End of the muscle loop

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



