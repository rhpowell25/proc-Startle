function StartMEP_ViolinPlot(sig, Plot_Figs, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Define the muscle groups of interest
%muscle_groups = {'ABH'; 'TA'; 'SOL'; 'QUAD'};
muscle_groups = {'ABH'};

% Find all the states tested
State_idx = strcmp(sig.trial_info_table_header, 'State');
State_list = strings;
for ii = 1:length(sig.trial_info_table)
    State_list{ii} = char(sig.trial_info_table{ii,State_idx});
end
States = unique(State_list)';

% Font specifications
axis_expansion = 0.25;
label_font_size = 17;
legend_font_size = 13;
title_font_size = 20;
fig_size = 600;
% Legend dimensions
zero_v_fifty_dims = [0.2 0.45 0.44 0.44];
zero_v_eighty_dims = [0.4 0.4 0.44 0.44];
zero_v_hundred_dims = [0.575 0.45 0.44 0.44];

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables

title_strings = struct([]);

%% Look through all the tasks

peaktopeak_MEP = struct([]);

for ii = 1:length(muscle_groups)
    for pp = 1:length(States)
        [peaktopeak_MEP{ii,1}{pp,1}] = StartMEP(sig, muscle_groups{ii}, States{pp,1}, 0, 0);
    end
end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(muscle_groups)
   
        % Put all states into a single array
        all_trials_peaktopeak = [];
        for pp = 1:length(peaktopeak_MEP{ii,1})
            all_trials_peaktopeak = cat(1,all_trials_peaktopeak, peaktopeak_MEP{ii,1}{pp,1});
            if isequal(pp,1)
                all_trials_states = repmat(States(pp,1), length(peaktopeak_MEP{ii,1}{pp,1}), 1);
            else
                all_trials_states = cat(1, all_trials_states, ...
                    repmat(States(pp,1), length(peaktopeak_MEP{ii,1}{pp,1}), 1));
            end
        end

        violin_fig = figure;
        violin_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        y_min = min(all_trials_peaktopeak);
        y_max = max(all_trials_peaktopeak);
        
        % Title
        EMG_title = muscle_groups{ii};
        title_strings{ii} = (sprintf('MEP Peak to Peak Amplitude: %s', EMG_title));
        sgtitle(title_strings{ii}, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % Violin plot
        Violin_Plot(all_trials_peaktopeak, all_trials_states, 'GroupOrder', ...
            {'cMEP', 'cMEP+50ms', 'cMEP+80ms'});
        ylim([y_min - axis_expansion, y_max + axis_expansion])
        
        % Labels
        xlabel('States', 'FontSize', label_font_size)
        ylabel('Peak to Peak Amplitude (mV)', 'FontSize', label_font_size);
        
        % Do the statistics
        zero_MEP = peaktopeak_MEP{ii,1}{strcmp(States, 'cMEP'), 1};
        fifty_MEP = peaktopeak_MEP{ii,1}{strcmp(States, 'cMEP+50ms'), 1};
        eighty_MEP = peaktopeak_MEP{ii,1}{strcmp(States, 'cMEP+80ms'), 1};
        %hundred_MEP = peaktopeak_MEP{ii,1}{strcmp(States, 'MEP+100ms'), 1};
        [~, zero_v_fifty_p_val] = ttest2(zero_MEP, fifty_MEP);
        [~, zero_v_eighty_p_val] = ttest2(zero_MEP, eighty_MEP);
        %[~, zero_v_hundred_p_val] = ttest2(zero_MEP, hundred_MEP);
        
        % Annotation of the zero_v_fifty p-value
        if round(zero_v_fifty_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(zero_v_fifty_p_val, 3)));
        elseif isequal(round(zero_v_fifty_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', zero_v_fifty_dims, 'String', legend_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_legend.FontSize = legend_font_size;

        % Annotation of the zero_v_eighty p-value
        if round(zero_v_eighty_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(zero_v_eighty_p_val, 3)));
        elseif isequal(round(zero_v_eighty_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', zero_v_eighty_dims, 'String', legend_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_legend.FontSize = legend_font_size;

        % Annotation of the zero_v_100 p-value
        if round(zero_v_hundred_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(zero_v_hundred_p_val, 3)));
        elseif isequal(round(zero_v_hundred_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', zero_v_hundred_dims, 'String', legend_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_legend.FontSize = legend_font_size;
    
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
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








