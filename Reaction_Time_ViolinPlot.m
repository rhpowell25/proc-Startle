function Reaction_Time_ViolinPlot(Group, Subject, Plot_Figs, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Font specifications
axis_expansion = 0.05;
label_font_size = 17;
legend_font_size = 13;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables
%Task_Name = {'AbH_Flex'; 'TA'; 'SOL'};
Muscle_Name = {'ABH'};
title_strings = struct([]);

rxn_time = struct([]);
rxn_state = struct([]);

%% Look through all the tasks
for ii = 1:length(Muscle_Name)

    [rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Muscle_Name{ii}, 'All');
    
    if ~isempty(rxn_time_excel)
        rxn_time{ii,1} = rxn_time_excel{1,1}.rxn_time;
        rxn_state{ii,1} = rxn_time_excel{1,1}.State;
    else
        rxn_time{ii,1} = NaN;
        rxn_state{ii,1} = NaN;
    end
end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(Muscle_Name)

        if isnan(rxn_time{ii,1})
            continue
        end
    
        violin_fig = figure;
        violin_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        y_min = min(rxn_time{ii});
        y_max = max(rxn_time{ii});
        
        % Title
        Task_title = Muscle_Name{ii};
        title_strings{ii} = (sprintf('EMG Reaction Times: %s', Task_title));
        sgtitle(title_strings{ii}, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % Violin plot
        Violin_Plot(rxn_time{ii,1}, rxn_state{ii,1}, 'GroupOrder', {'F', 'F+s', 'F+S'});
        ylim([y_min, y_max + axis_expansion])
        
        % Labels
        xlabel('States', 'FontSize', label_font_size)
        ylabel('Reaction Time (Sec.)', 'FontSize', label_font_size);
        
        % Do the statistics
        F_rxn_time = rxn_time{ii,1}(strcmp(rxn_state{ii,1}, 'F'));
        Fs_rxn_time = rxn_time{ii,1}(strcmp(rxn_state{ii,1}, 'F+s'));
        FS_rxn_time = rxn_time{ii,1}(strcmp(rxn_state{ii,1}, 'F+S'));
        [~, Fvs_p_val] = ttest2(F_rxn_time, Fs_rxn_time);
        [~, Svs_p_val] = ttest2(Fs_rxn_time, FS_rxn_time);
        [~, FvS_p_val] = ttest2(F_rxn_time, FS_rxn_time);
        
        % Annotation of the S-vs-s p-value
        if round(Svs_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(Svs_p_val, 3)));
        elseif isequal(round(Svs_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_dims = [0.55 0.35 0.44 0.44];
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_legend.FontSize = legend_font_size;

        % Annotation of the F-vs-s p-value
        if round(Fvs_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(Fvs_p_val, 3)));
        elseif isequal(round(Fvs_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_dims = [0.025 0.35 0.44 0.44];
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_legend.FontSize = legend_font_size;

        % Annotation of the F-vs-S p-value
        if round(FvS_p_val, 3) > 0
            p_value_string = strcat('p =', {' '}, mat2str(round(FvS_p_val, 3)));
        elseif isequal(round(FvS_p_val, 3), 0)
            p_value_string = strcat('p <', {' '}, '0.001');
        end
        legend_dims = [0.28755 0.45 0.44 0.44];
        legend_string = {char(p_value_string)};
        ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ... 
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








