function Reaction_Time_ViolinPlot(Subject, Plot_Figs, Save_Figs)

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
label_font_size = 17;
legend_font_size = 13;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Initialize the output variables
Task_Name = {'AbH_Flex'; 'AbH_Abd'; 'TA'; 'SOL'};

title_strings = struct([]);

F_rxn_time = struct([]);
Fs_rxn_time = struct([]);
FS_rxn_time = struct([]);

%% Look through all the tasks
for ii = 1:length(Task_Name)

    [F_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F');
    [Fs_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F+s');
    [FS_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F+S');
    
    F_rxn_time{ii,1} = F_rxn_time_excel.rxn_time;
    Fs_rxn_time{ii,1} = Fs_rxn_time_excel.rxn_time;
    FS_rxn_time{ii,1} = FS_rxn_time_excel.rxn_time;

end

%% Plot the violin plot

if isequal(Plot_Figs, 1)
    for ii = 1:length(Task_Name)
    
        violin_fig = figure;
        violin_fig.Position = [200 50 fig_size fig_size];
        hold on

        % Find the y_limits
        F_min = min(F_rxn_time{ii});
        Fs_min = min(Fs_rxn_time{ii});
        FS_min = min(FS_rxn_time{ii});
        arr_min = cat(1, F_min, Fs_min, FS_min);
        y_min = min(arr_min) - 0.1;
        F_max = max(F_rxn_time{ii});
        Fs_max = max(Fs_rxn_time{ii});
        FS_max = max(FS_rxn_time{ii});
        arr_max = cat(1, F_max, Fs_max, FS_max);
        y_max = max(arr_max) + 0.1;
        
        % Title
        Task_title = Task_Name{ii};
        title_strings{ii} = (sprintf('EMG Reaction Times: %s', Task_title));
        sgtitle(title_strings{ii}, 'FontSize', title_font_size, 'Interpreter', 'none');
        
        % F violin plot
        subplot(1,3,1)
        hold on
        violin_positions = (1:length(F_rxn_time{ii}));
        Violin_Plot(F_rxn_time(ii), violin_positions, 'ViolinColor', [0.9290, 0.6940, 0.1250]);
        ylim([y_min, y_max])
        
        % Labels
        xlabel('F', 'FontSize', label_font_size)
        ylabel('Reaction Time (Sec.)', 'FontSize', label_font_size);
    
        % Fs violin plot
        subplot(1,3,2)
        hold on
        violin_positions = (1:length(Fs_rxn_time{ii}));
        Violin_Plot(Fs_rxn_time(ii), violin_positions, 'ViolinColor', [0.5, 0, 0.5]);
        ylim([y_min, y_max])
        
        % Labels
        xlabel('F+s', 'FontSize', label_font_size)
    
        % FS violin plot
        subplot(1,3,3)
        hold on
        violin_positions = (1:length(FS_rxn_time{ii}));
        Violin_Plot(FS_rxn_time(ii), violin_positions, 'ViolinColor', [1, 0, 0]);
        ylim([y_min, y_max])
        
        % Labels
        xlabel('F+S', 'FontSize', label_font_size)
        
        % Do the statistics
        [~, violin_plot_p_val] = ttest2(Fs_rxn_time{ii}, FS_rxn_time{ii});
        
        % Annotation of the p-value
        if round(violin_plot_p_val, 3) > 0
            legend_dims = [0.015 0.45 0.44 0.44];
            p_value_string = strcat('p =', {' '}, mat2str(round(violin_plot_p_val, 3)));
            legend_string = {char(p_value_string)};
            ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ... 
                'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
                'EdgeColor','none', 'horizontalalignment', 'center');
            ann_legend.FontSize = legend_font_size;
        end
        if isequal(round(violin_plot_p_val, 3), 0)
            legend_dims = [0.015 0.45 0.44 0.44];
            p_value_string = strcat('p <', {' '}, '0.001');
            legend_string = {char(p_value_string)};
            ann_legend = annotation('textbox', legend_dims, 'String', legend_string, ... 
                'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
                'EdgeColor','none', 'horizontalalignment', 'center');
            ann_legend.FontSize = legend_font_size;
        end
    
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








