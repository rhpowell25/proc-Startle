function Overlap_StartMEP(sig, muscle_group, Save_Figs)

%% Display the function being used
disp('Overlap Startled MEP Function:');

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial started MEP's
[per_trial_MEP_EMG, EMG_Names] = Trial_StartMEP(sig, 'MEP', muscle_group, 0, 0);
[per_trial_fifty_EMG, ~] = Trial_StartMEP(sig, 'MEP+50ms', muscle_group, 0, 0);
[per_trial_eighty_EMG, ~] = Trial_StartMEP(sig, 'MEP+80ms', muscle_group, 0, 0);
[per_trial_hundred_EMG, ~] = Trial_StartMEP(sig, 'MEP+100ms', muscle_group, 0, 0);

% Bin width
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of stimulus & time after stimulus artifact
stim_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
plot_length = 0.05; % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Title info
Subject = sig.meta.subject;

% When do you want to start & stop plotting
post_stim_art = 0.03; % Sec.
start_time = stim_time + post_stim_art; % Sec.
start_idx = round(start_time/bin_width);
stop_time = start_time + plot_length; % Sec.
stop_idx = round(stop_time/bin_width);

% Font specifications
label_font_size = 15;
legend_font_size = 12;
title_font_size = 15;
font_name = 'Arial';
figure_width = 700;
figure_height = 700;

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));
    
%% Calculating average EMG (Average Across trials)
avg_MEP_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_MEP_EMG{ii,1} = zeros(length(per_trial_MEP_EMG{1,1}),1);
    for mm = 1:length(per_trial_MEP_EMG{1,1})
        avg_MEP_EMG{ii,1}(mm) = mean(per_trial_MEP_EMG{ii,1}(mm,:));
    end
end
avg_fifty_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_fifty_EMG{ii,1} = zeros(length(per_trial_fifty_EMG{1,1}),1);
    for mm = 1:length(per_trial_fifty_EMG{1,1})
        avg_fifty_EMG{ii,1}(mm) = mean(per_trial_fifty_EMG{ii,1}(mm,:));
    end
end
avg_eighty_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_eighty_EMG{ii,1} = zeros(length(per_trial_eighty_EMG{1,1}),1);
    for mm = 1:length(per_trial_eighty_EMG{1,1})
        avg_eighty_EMG{ii,1}(mm) = mean(per_trial_eighty_EMG{ii,1}(mm,:));
    end
end
avg_hundred_EMG = struct([]);
for ii = 1:length(EMG_Names)
    avg_hundred_EMG{ii,1} = zeros(length(per_trial_hundred_EMG{1,1}),1);
    for mm = 1:length(per_trial_hundred_EMG{1,1})
        avg_hundred_EMG{ii,1}(mm) = mean(per_trial_hundred_EMG{ii,1}(mm,:));
    end
end

%% Plot the individual EMG traces

for ii = 1:length(EMG_Names)

    EMG_figure = figure;
    EMG_figure.Position = [300 100 figure_width figure_height];
    hold on

    % Titling the plot
    EMG_title = strcat('MEPs:', {' '}, Subject, {' '}, '[', EMG_Names{ii}, ']');
    title(EMG_title, 'FontSize', title_font_size)

    % Labels
    y_label = strcat(EMG_Names{ii}, {' '}, 'EMG');
    ylabel(y_label, 'FontSize', label_font_size);
    xlabel('Time (sec.)', 'FontSize', label_font_size);

    % Setting the x-axis limits
    xlim([absolute_timing(start_idx), absolute_timing(stop_idx)]);
    
    % Mean EMG
    plot(absolute_timing(start_idx:stop_idx), avg_MEP_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'k');
    plot(absolute_timing(start_idx:stop_idx), avg_fifty_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', 'r');
    plot(absolute_timing(start_idx:stop_idx), avg_eighty_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', [0 0.5 0]);
    plot(absolute_timing(start_idx:stop_idx), avg_hundred_EMG{ii,1}(start_idx:stop_idx), ...
        'LineWidth', 2, 'Color', [.7 .7 .7]);
    
    % Legend
    legend('MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms', 'NumColumns', 1, 'FontName', font_name, ...
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



