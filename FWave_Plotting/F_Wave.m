function [peaktopeak_FWave] = F_Wave(sig, muscle_group, Plot_Figs, Save_Figs)

%% Display the function being used
disp('F-Wave Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to manually set the y-axis?
man_y_axis = 'No';
%man_y_axis = [-2, 3];

% Do you want to include the M-Max ('Yes', 'No')
M_Max = 'No';

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

Subject = sig.meta.subject;

% Bin width and baseline indices
bin_width = sig.bin_width;

% Rounding to remove floating point errors
round_digit = abs(floor(log10(bin_width)));

% Time of stimulus & time after M-Max
stim_time = unique(round((sig.trial_gocue_time - sig.trial_start_time), round_digit)); % Sec.
post_M_Max_time = 0.03; % Sec.
F_Wave_length = 0.1; % Sec.

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% When do you want to start & stop plotting
if strcmp(M_Max, 'Yes')
    start_time = stim_time + 0.0012; % Sec.
else
    start_time = stim_time + post_M_Max_time; % Sec.
end
start_idx = round(start_time/bin_width);
stop_time = start_time + F_Wave_length; % Sec.
stop_idx = round(stop_time/bin_width);

% Font specifications
axis_expansion = 0.1;
label_font_size = 15;
title_font_size = 15;
figure_width = 700;
figure_height = 350;
legend_font_size = 15;
font_name = 'Arial';

%% Indexes for persistant trials

[persistant_idxs] = F_Wave_Persistance(sig);

FWave_persistance = (length(persistant_idxs) / length(sig.trial_result))*100;

%% Extract the EMG
[EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, persistant_idxs);

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(EMG{1,1}));

%% Pulling all the trials & finding their peak to peak amplitudes
all_trials_EMG = struct([]);
for ii = 1:length(EMG_Names)
    all_trials_EMG{ii,1} = zeros(length(EMG{1,1}(start_idx:stop_idx, 1)), length(EMG));
    peaktopeak_FWave = NaN(length(EMG), 1);
    for mm = 1:length(EMG)
        all_trials_EMG{ii,1}(:,mm) = EMG{mm}(start_idx:stop_idx, ii);
        if strcmp(M_Max, 'No')
            peaktopeak_FWave(mm,1) = peak2peak(all_trials_EMG{ii,1}(:,mm));
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
        EMG_title = strcat('F-Waves: ', {' '}, Subject, {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size)
    
        % Labels
        ylabel('EMG (mV)', 'FontSize', label_font_size);
        xlabel('Time (sec.)', 'FontSize', label_font_size);
    
        for pp = 1:width(all_trials_EMG{ii})
            
            plot(absolute_timing(start_idx:stop_idx), all_trials_EMG{ii}(:,pp))
        end % End of the individual trial loop
    
        % Set the axis
        xlim([start_time, stop_time])
        if ~ischar(man_y_axis)
            ylim([man_y_axis(1),  man_y_axis(2) + axis_expansion])
        end
        
        % Annotations
        if strcmp(M_Max, 'No')
            % Annotation of the F-Wave peristance
            FWave_persistance = round(mean(FWave_persistance), 2);
            legend_dims = [0.555 0.425 0.44 0.44];
            persistance_string = strcat('persistance =', {' '}, mat2str(FWave_persistance), '%');
            legend_string = {char(persistance_string)};
            ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ...
                'FitBoxToText', 'on', 'verticalalignment', 'top', ...
                'EdgeColor','none', 'horizontalalignment', 'center');
            ann_legend.FontSize = legend_font_size;
            ann_legend.FontName = font_name;
        
            % Annotation of the mean peak to peak amplitude
            avg_peaktopeak = round(mean(peaktopeak_FWave), 2);
            legend_dims = [0.555 0.325 0.44 0.44];
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
