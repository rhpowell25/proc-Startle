function [per_trial_EMG, EMG_Names] = Trial_StartMEP(sig, State, muscle_group, Plot_Figs, Save_Figs)

%% Display the function being used
disp('Per Trial Startled MEP Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to manually set the y-axis?
%man_y_axis = 'No';
man_y_axis = [-1.5, 1];

% Do you want to include the stimulus artifact ('Yes', 'No')
stim_art = 'No';

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

% Title info
Subject = sig.meta.subject;

% Bin width
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of stimulus & time after stimulus artifact
stim_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
array_length = 0.125; % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start & stop plotting
if strcmp(stim_art, 'Yes')
    start_time = stim_time - 0.01; % Sec.
else
    post_stim_art = 0.03; % Sec.
    start_time = stim_time + post_stim_art; % Sec.
end
start_idx = round(start_time/bin_width);
stop_time = start_time + array_length; % Sec.
stop_idx = round(stop_time/bin_width);

% Font specifications
axis_expansion = 0.1;
label_font_size = 15;
title_font_size = 15;
figure_width = 700;
figure_height = 350;
legend_font_size = 15;
font_name = 'Arial';

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

%% Extract the EMG
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);

%figure
%hold on
%absolute_timing = linspace(0, 4, length(EMG{1,1}));
%for ii = 1:length(EMG)
%    plot(absolute_timing, EMG{ii,1})
%end

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
        EMG_figure.Position = [300 100 figure_width figure_height];
        hold on

        % Titling the plot
        EMG_title = strcat('MEPs:', {' '}, Subject, {' '}, State, {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', label_font_size);
        xlabel('Time (sec.)', 'FontSize', label_font_size);
    
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
        save_title = strcat('Per-Trial', {' '}, save_title);
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
