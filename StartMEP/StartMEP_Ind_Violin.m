function StartMEP_Ind_Violin(sig, Save_Figs)

%% File Description:

% This function plots a violin plot of reaction time (defined as the time after the
% go-cue when the EMG of interest exceeds 2 std of the baseline EMG), or the 
% trial length
% The EMG of interest is chosen based on the task / target.
%
% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Group', sig.meta.group, ... % Group Name ('Control', 'SCI')
    'Subject', sig.meta.subject, ... % Subject Name
    'Task', sig.meta.task, ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', sig.meta.muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Box';

% Do you want to show the statistics (1 = Yes, 0 = No)
%plot_stats = 1;

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

%% Load the StartMEP excel
[StartMEP_excel, ~] = Load_AbH_Excel(Sampling_Params);
StartMEP_amp = StartMEP_excel{1,1}.peaktopeak_MEP;
States = string(StartMEP_excel{1,1}.State);

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 50 fig_size fig_size];
hold on

% Title
EMG_title = strcat('Peak to Peak Amplitude:', {' '}, Sampling_Params.Subject, {' '}, Sampling_Params.Task, ...
    {' '}, '[', Sampling_Params.Muscle, ']');
title(EMG_title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('States', 'FontSize', label_font_size)
ylabel('Peak to Peak Amplitude (mV)', 'FontSize', label_font_size);

% Plot
if strcmp(plot_choice, 'Box')
    boxplot(StartMEP_amp, States, 'GroupOrder', ...
        {'MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms'});
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot(StartMEP_amp, States, 'GroupOrder', ...
        {'MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms'}, 'ViolinColor', plot_colors);
end

set(gca,'fontsize', label_font_size)

% Find the y_limits
y_min = min(StartMEP_amp);
y_max = max(StartMEP_amp);

% Set the axis-limits
xlim([0.5 4.5]);
ylim([y_min - axis_expansion, y_max + axis_expansion])

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








