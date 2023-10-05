function Summary_ViolinPlot(Group, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Load the subject details
[Subjects] = Signal_File_Details(Group);

% Do you want to connect the dots? (1 = Yes, 0 = No)
connect_dots = 1;

% Font specifications
plot_line_size = 1;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end


%% Collect the change in reaction times
delta_rxn_time = zeros(length(Subjects), 1);
Muscle = 'ABH';
for ii = 1:length(Subjects)
    [delta_rxn_time(ii), ~] = RS_Gain_Summary(Group, Muscle, Subjects{ii});
end

%% Collect the F-Wave amplitudes

%% Put the reaction time changes in the same array
Task_string = cell(length(delta_rxn_time), 1);
Task_string(:) = {Muscle};

%% Plot the violin plot

violin_fig = figure;
violin_fig.Position = [200 50 fig_size fig_size];
hold on
    
% Title
title_string = strcat(Group, {' '}, 'Subjects: Fs - FS');
title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Task', 'FontSize', label_font_size)
ylabel('Δ Reaction Time (Sec.)', 'FontSize', label_font_size);
    
% Violin plot
Violin = Violin_Plot(delta_rxn_time, Task_string);

%% Statistics
%[p,t,stats] = anova1(d_rxn_time, Task_Names);
%[c,m,h,gnames] = multcompare(stats);

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








