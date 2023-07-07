function Summary_ViolinPlot(Subjects, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Do you want to connect the dots? (1 = Yes, 0 = No)
connect_dots = 0;

% Font specifications
plot_line_size = 1;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

delta_rxn_time = struct([]);
Task_Name = struct([]);
for ii = 1:length(Subjects)
    [Task_Name{ii}, delta_rxn_time{ii}, ~] = RS_Gain_Summary(Subjects{ii});
end

%% Put the reaction time changes in the same array

AbH_Flex_rxn_time = zeros(length(Task_Name),1);
AbH_Abd_rxn_time = zeros(length(Task_Name),1);
TA_rxn_time = zeros(length(Task_Name),1);
SOL_rxn_time = zeros(length(Task_Name),1);
for ii = 1:length(Task_Name)
    AbH_Flex_rxn_time(ii) = delta_rxn_time{ii}(strcmp(Task_Name{ii}, {'AbH_Flex'}));
    AbH_Abd_rxn_time(ii) = delta_rxn_time{ii}(strcmp(Task_Name{ii}, {'AbH_Abd'}));
    TA_rxn_time(ii) = delta_rxn_time{ii}(strcmp(Task_Name{ii}, {'TA'}));
    SOL_rxn_time(ii) = delta_rxn_time{ii}(strcmp(Task_Name{ii}, {'SOL'}));
end

d_rxn_time = cat(1, AbH_Flex_rxn_time, AbH_Abd_rxn_time, TA_rxn_time, SOL_rxn_time);
AbH_Flex_string = cell(length(AbH_Flex_rxn_time), 1);
AbH_Flex_string(:) = {'AbH Flex'};
AbH_Abd_string = cell(length(AbH_Abd_rxn_time), 1);
AbH_Abd_string(:) = {'AbH Abd'};
TA_string = cell(length(TA_rxn_time), 1);
TA_string(:) = {'TA'};
SOL_string = cell(length(SOL_rxn_time), 1);
SOL_string(:) = {'SOL'};
Task_Names = cat(1, AbH_Flex_string, AbH_Abd_string, TA_string, SOL_string);

%% Plot the violin plot

violin_fig = figure;
violin_fig.Position = [200 50 fig_size fig_size];
hold on
    
% Title
title_string = 'Control Subjects: Fs - FS';
title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Task', 'FontSize', label_font_size)
ylabel('Δ Reaction Time (Sec.)', 'FontSize', label_font_size);
    
% Violin plot
Violin = Violin_Plot(d_rxn_time, Task_Names);

%% Connect each subject across violin plots
if isequal(connect_dots, 1)

    % Collect the scatter locations
    task_x_pos = struct([]);
    task_y_pos = struct([]);
    for ii = 1:length(Task_Name{1})
        task_x_pos{ii,1} = Violin(ii).ScatterPlot.XData;
        task_y_pos{ii,1} = Violin(ii).ScatterPlot.YData;
    end
    % Rearrange the arrays by subject
    subject_x_pos = struct([]);
    subject_y_pos = struct([]);
    for ii = 1:length(Task_Name)
        for pp = 1:length(Task_Name{1})
            subject_x_pos{ii}(pp) = task_x_pos{pp}(ii);
            subject_y_pos{ii}(pp) = task_y_pos{pp}(ii);
        end
    end
    % Connect the subjects
    for ii = 1:length(subject_x_pos)
        plot(subject_x_pos{ii}, subject_y_pos{ii}, ...
            'LineWidth', plot_line_size, 'linestyle','--')
    end

end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        save_title = strrep(title_string, ':', '');
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








