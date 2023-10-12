function StartMEP_Ind_Violin(sig, muscle_group, Plot_Figs, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Box';

% Title info
Subject = sig.meta.subject;
Task = sig.meta.task;

% Find all the states tested
State_idx = strcmp(sig.trial_info_table_header, 'State');
State_list = strings;
for ii = 1:length(sig.trial_info_table)
    State_list{ii} = char(sig.trial_info_table{ii,State_idx});
end
States = unique(State_list)';

% Font specifications
%plot_colors = [0 0 0; 1 0 0; 0 0.5 0];
plot_colors = [0 0 0; 1 0 0; 0 0.5 0; .7 .7 .7];
axis_expansion = 0.02;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Loop through all the muscles & states

peaktopeak_MEP = struct([]);
for ii = 1:length(States)
    [peaktopeak_MEP{ii,1}, EMG_Names] = Avg_StartMEP(sig, States{ii}, muscle_group, 0, 0);
end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(EMG_Names)
   
        % Put all peak-to-peak amplitudes & states into a single array
        all_trials_peaktopeak = [];
        for pp = 1:length(States)
            all_trials_peaktopeak = cat(1,all_trials_peaktopeak, peaktopeak_MEP{pp,1}{ii,1});
            if isequal(pp,1)
                all_trials_states = repmat(States(pp,1), length(peaktopeak_MEP{pp,1}{ii,1}), 1);
            else
                all_trials_states = cat(1, all_trials_states, ...
                    repmat(States(pp,1), length(peaktopeak_MEP{pp,1}{ii,1}), 1));
            end
        end

        violin_fig = figure;
        violin_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        y_min = min(all_trials_peaktopeak);
        y_max = max(all_trials_peaktopeak);
        
        % Title
        EMG_title = strcat('Peak to Peak Amplitude:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', EMG_Names{ii}, ']');
        title(EMG_title, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % Plot
        if strcmp(plot_choice, 'Box')
            boxplot(all_trials_peaktopeak, all_trials_states, 'GroupOrder', ...
                {'MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms'});
            % Color the box plots
            plot_colors = flip(plot_colors, 1);
            box_axes = findobj(gca,'Tag','Box');
            for pp = 1:length(box_axes)
                patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
            end
        elseif strcmp(plot_choice, 'Violin')
            Violin_Plot(all_trials_peaktopeak, all_trials_states, 'GroupOrder', ...
                {'MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms'}, 'ViolinColor', plot_colors);
        end

        %Violin_Plot(all_trials_peaktopeak, all_trials_states, 'GroupOrder', ...
        %    {'MEP', 'MEP+50ms', 'MEP+80ms'}, 'ViolinColor', state_colors);

        set(gca,'fontsize', label_font_size)

        xlim([0.5 4.5]);
        ylim([y_min - axis_expansion, y_max + axis_expansion])
        
        % Labels
        xlabel('States', 'FontSize', label_font_size)
        ylabel('Peak to Peak Amplitude (mV)', 'FontSize', label_font_size);
        
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        fig_info = get(gca,'title');
        save_title = get(fig_info, 'string');
        save_title = strrep(save_title, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
        save_title = strrep(save_title, '{ }', ' ');
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








