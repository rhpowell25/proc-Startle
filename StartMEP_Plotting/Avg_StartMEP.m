function [peaktopeak_MEP, EMG_Names] = Avg_StartMEP(sig, State, muscle_group, Plot_Figs, Save_Figs)

%% Display the function being used
disp('Average Startled MEP Function:');

%% Basic Settings, some variable extractions, & definitions

% Extract the per trial MEP's
[per_trial_MEP, EMG_Names] = Trial_StartMEP(sig, State, muscle_group, 0, 0);

% Do you want to manually set the y-axis?
%man_y_axis = 'No';
man_y_axis = [-0.6, 0.1];

% Do you want to include the stimulus artifact ('Yes', 'No')
stim_art = 'No';

% Title info
Subject = sig.meta.subject;

% Bin width and baseline indices
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
axis_expansion = 0;
label_font_size = 15;
title_font_size = 15;
figure_width = 700;
figure_height = 700;
legend_font_size = 15;
font_name = 'Arial';

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

% End the function if no succesful trials
if isnan(per_trial_MEP{1,1})
    disp('No trials with this State')
    peaktopeak_MEP = {NaN};
    EMG_Names = {NaN};
    return
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(sig.raw_EMG{1,1}(:,1)));

%% Finding the mean MEP and the peak to peak amplitudes
avg_MEP = struct([]);
for ii = 1:length(per_trial_MEP)
    for mm = 1:height(per_trial_MEP{ii,1})
        avg_MEP{ii,1}(mm,1) = mean(per_trial_MEP{ii,1}(mm,:));
    end
end

peaktopeak_MEP = struct([]);
for ii = 1:length(per_trial_MEP)
    for mm = 1:width(per_trial_MEP{ii,1})
        peaktopeak_MEP{ii,1}(mm,1) = peak2peak(per_trial_MEP{ii,1}(start_idx:stop_idx,mm));
    end
end

%% Plot the individual EMG traces on the top
if isequal(Plot_Figs, 1)
    for ii = 1:length(EMG_Names)
    
        EMG_figure = figure;
        EMG_figure.Position = [300 100 figure_width figure_height];
        hold on
    
        % Titling the plot
        EMG_title = strcat('MEPs:', {' '}, Subject, {' '}, State, {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', label_font_size);
        xlabel('Time (sec.)', 'FontSize', label_font_size);
    
        plot(absolute_timing(start_idx:stop_idx), avg_MEP{ii}(start_idx:stop_idx), ...
            'LineWidth', 2, 'Color', 'k')
    
        % Set the axis
        xlim([start_time, stop_time])
        if ~ischar(man_y_axis)
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end
    
        % Annotation of the mean peak to peak amplitude
        if strcmp(stim_art, 'No')
            avg_peaktopeak = round(mean(peaktopeak_MEP{ii,1}), 2);
            legend_dims = [0.555 0.425 0.44 0.44];
            pktopk_count_string = strcat('pk-pk =', {' '}, mat2str(avg_peaktopeak), {' '}, 'mV');
            legend_string = {char(pktopk_count_string)};
            ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ...
                'FitBoxToText', 'on', 'verticalalignment', 'top', ...
                'EdgeColor','none', 'horizontalalignment', 'center');
            ann_legend.FontSize = legend_font_size;
            ann_legend.FontName = font_name;
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
