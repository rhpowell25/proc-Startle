function StartReact_Ind_Violin(sig, Plot_Figs, Save_Figs)

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

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Define the muscle groups of interest
%muscle_groups = {'ABH'; 'TA'; 'SOL'; 'QUAD'};
muscle_groups = {'ABH'};

% Title info
Subject = sig.meta.subject;
Task = sig.meta.task;

% Bin size
bin_width = sig.bin_width;

% Find all the states tested
State_idx = strcmp(sig.trial_info_table_header, 'State');
State_list = strings;
for ii = 1:length(sig.trial_info_table)
    State_list{ii} = char(sig.trial_info_table{ii,State_idx});
end
States = unique(State_list)';

% Font specifications
plot_colors = [1 0 0; .7 .7 .7; 0, 0, 0];
axis_expansion = 0.05;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables

title_strings = struct([]);

%% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;
  
%% Loop through all the muscles & states

rxn_time = struct([]);
for ii = 1:length(muscle_groups)
    for pp = 1:length(States)
        % Indexes for rewarded trials
        rewarded_idxs = find(strcmp(trial_info_table.result, 'R') & ...
            strcmp(trial_info_table.State, States{pp,1}));
        % Extract the EMG & find its onset
        [~, EMG] = Extract_EMG(sig, EMG_Choice, muscle_groups{ii,1}, rewarded_idxs);
        % Find its onset
        [EMG_onset_idx] = EMGOnset(EMG);
        % Find the reaction time
        % Rewarded trial table
        Trial_Table = trial_info_table(rewarded_idxs, :);
        gocue_times = Trial_Table.goCueTime - Trial_Table.startTime;
        rxn_time{ii,1}{pp,1} = (EMG_onset_idx * bin_width) - gocue_times;
    end
end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(muscle_groups)
    
        % Put all reaction times & states into a single array
        all_trials_rxn_time = [];
        for pp = 1:length(rxn_time{ii,1})
            all_trials_rxn_time = cat(1,all_trials_rxn_time, rxn_time{ii,1}{pp,1});
            if isequal(pp,1)
                all_trials_states = repmat(States(pp,1), length(rxn_time{ii,1}{pp,1}), 1);
            else
                all_trials_states = cat(1, all_trials_states, ...
                    repmat(States(pp,1), length(rxn_time{ii,1}{pp,1}), 1));
            end
        end

        plot_fig = figure;
        plot_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        y_min = min(all_trials_rxn_time);
        y_max = max(all_trials_rxn_time);
        
        % Title
        EMG_title = strcat('Reaction Times:', {' '}, Subject, {' '}, Task, ...
            {' '}, '[', muscle_groups{ii}, ']');
        title_strings{ii} = EMG_title;
        sgtitle(EMG_title, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % Plot
        if strcmp(plot_choice, 'Box')
            boxplot(all_trials_rxn_time, all_trials_states, 'GroupOrder', {'F+S', 'F+s', 'F'});
            % Color the box plots
            plot_colors = flip(plot_colors, 1);
            box_axes = findobj(gca,'Tag','Box');
            for pp = 1:length(box_axes)
                patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
            end
        elseif strcmp(plot_choice, 'Violin')
            Violin_Plot(all_trials_rxn_time, all_trials_states, ...
                'ViolinColor', plot_colors, 'GroupOrder', {'F+S', 'F+s', 'F'});
        end

        set(gca,'fontsize', label_font_size)
        
        % Set the axis-limits
        xlim([0.5 3.5]);
        ylim([y_min - axis_expansion, y_max + axis_expansion])
        
        % Labels
        xlabel('States', 'FontSize', label_font_size)
        ylabel('Reaction Time (Sec.)', 'FontSize', label_font_size);
    
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        save_title = strrep(title_strings{ii}, ':', '');
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








