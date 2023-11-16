function MVC_Ind_Violin(sig, Plot_Choice, Save_File)

%% File Description:

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

% Font specifications
plot_colors = [1 0 0];
axis_expansion = 0.05;
label_font_size = 17;
title_font_size = 20;
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Load the MVC excel
[MVC_excel, ~] = Load_AbH_Excel(Sampling_Params);
if strcmp(Plot_Choice, 'EMG') 
    MVC_amp = MVC_excel{1,1}.MVC_EMG;
elseif strcmp(Plot_Choice, 'Force')
    MVC_amp = MVC_excel{1,1}.MVC_Force;
end
MVC_metric = repmat(Sampling_Params.Muscle, length(MVC_amp), 1);

%% Plot the violin plot

plot_fig = figure;
plot_fig.Position = [200 50 fig_size fig_size];
hold on

% Title
Fig_Title = strcat('Peak', {' '}, Sampling_Params.Task, {' '}, Sampling_Params.Subject, ...
    {' '}, '[', Sampling_Params.Muscle, ']');
title(Fig_Title, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
y_label = strcat('Peak', {' '}, Plot_Choice);
if strcmp(Plot_Choice, 'Force')
    y_label = strcat(y_label, {' '}, '(N)');
elseif strcmp(Plot_Choice, 'EMG')
    y_label = strcat(y_label, {' '}, '(mV)');
end
ylabel(y_label, 'FontSize', label_font_size);

% Plot
if strcmp(plot_choice, 'Box')
    boxplot(MVC_amp, MVC_metric);
    % Color the box plots
    box_axes = findobj(gca,'Tag','Box');
    patch(get(box_axes, 'XData'), get(box_axes, 'YData'), plot_colors, 'FaceAlpha', .5);
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot(MVC_amp, MVC_metric, 'ViolinColor', plot_colors);
end

set(gca,'fontsize', label_font_size)

% Find the y_limits
y_min = min(MVC_amp);
y_max = max(MVC_amp);

% Set the axis-limits
xlim([0.5 1.5]);
ylim([y_min - axis_expansion, y_max + axis_expansion])

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)









