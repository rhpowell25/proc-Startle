function MVC_Group_Violin(Muscle, Plot_Choice, Save_File)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Subject', 'All', ... % Subject Name
    'Task', 'MVC', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Box';

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 0; 

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
axis_expansion = 0.025;
plot_colors = [0.85 0.325 0.098; 0 0.447 0.741];
p_value_dims = [0.51 0.45 0.44 0.44];

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Extract the control MVC metrics

Sampling_Params.Group = 'Control';
[MVC_excel, ~] = Load_AbH_Excel(Sampling_Params);
con_MVC = zeros(length(MVC_excel), 1);

for ii = 1:length(con_MVC)
    if strcmp(Plot_Choice, 'EMG') 
        MVC_amp = MVC_excel{ii,1}.MVC_EMG;
    elseif strcmp(Plot_Choice, 'Force')
        MVC_amp = MVC_excel{ii,1}.MVC_Force;
    end
    con_MVC(ii,1) = max(MVC_amp);
end
merged_con = repmat({'Control'}, length(con_MVC), 1);

%% Extract the SCI MVC metrics

Sampling_Params.Group = 'SCI';
[MVC_excel, ~] = Load_AbH_Excel(Sampling_Params);
SCI_MVC = zeros(length(MVC_excel), 1);

for ii = 1:length(SCI_MVC)
    if strcmp(Plot_Choice, 'EMG') 
        MVC_amp = MVC_excel{ii,1}.MVC_EMG;
    elseif strcmp(Plot_Choice, 'Force')
        MVC_amp = MVC_excel{ii,1}.MVC_Force;
    end
    SCI_MVC(ii,1) = max(MVC_amp);
end
merged_SCI = repmat({'SCI'}, length(SCI_MVC), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
y_max = max([con_MVC; SCI_MVC]);
y_min = min([con_MVC; SCI_MVC]);

% Title & y-label
if strcmp(Plot_Choice, 'Force')
    y_label = 'Peak Force (N)';
elseif strcmp(Plot_Choice, 'EMG')
    y_label = 'Mean EMG (mV)';
end
Fig_Title = strcat('Peak MVC:', {' '}, Plot_Choice);

%% Plot the Box Plot

plot_fig = figure;
plot_fig.Position = [200 5 Plot_Params.fig_size Plot_Params.fig_size*1.5];
hold on

% Title
%title(Fig_Title, 'FontSize', Plot_Params.title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Group', 'FontSize', Plot_Params.label_font_size)
ylabel(y_label, 'FontSize', Plot_Params.label_font_size)

% Plot
if strcmp(plot_choice, 'Box')
    boxplot([con_MVC; SCI_MVC], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'});
    %scatter(ones(length(con_MVC)), con_MVC, 75, 'k', '.')
    %scatter(ones(length(SCI_MVC)) + 1, SCI_MVC, 75, 'k', '.')
    % Color the box plots
    plot_colors = flip(plot_colors, 1);
    box_axes = findobj(gca,'Tag','Box');
    for pp = 1:length(box_axes)
        patch(get(box_axes(pp), 'XData'), get(box_axes(pp), 'YData'), plot_colors(pp,:), 'FaceAlpha', .5);
    end
elseif strcmp(plot_choice, 'Violin')
    Violin_Plot([con_MVC; SCI_MVC], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'}, 'ViolinColor', plot_colors);
end

set(gca,'fontsize', Plot_Params.label_font_size)

% Set the axis-limits
xlim([0.5 2.5]);
ylim([y_min - axis_expansion y_max + axis_expansion]);

% Axis Editing
figure_axes = gca;
set(gca,'linewidth', Plot_Params.mean_line_width)
% Set ticks to outside
set(figure_axes,'TickDir','out');
% Remove the top and right tick marks
set(figure_axes,'box','off')

% Only label every other tick
y_labels = string(figure_axes.YAxis.TickLabels);
y_labels(2:2:end) = NaN;
figure_axes.YAxis.TickLabels = y_labels;

% Do the statistics
[~, peaktopeak_p_val] = ttest2(con_MVC, SCI_MVC);
fprintf('p = %0.3f \n', peaktopeak_p_val)

% Annotation of the p_value
if isequal(plot_stats, 1)
    if round(peaktopeak_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(peaktopeak_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = Plot_Params.legend_size;
        ann_p_value.FontName = Plot_Params.font_name;
    end
    
    if isequal(round(peaktopeak_p_val, 3), 0)
        p_value_string = strcat('p <', {' '}, '0.001');
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ...
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = Plot_Params.legend_size;
        ann_p_value.FontName = Plot_Params.font_name;
    end
end

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)







