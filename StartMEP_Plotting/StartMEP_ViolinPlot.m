function StartMEP_ViolinPlot(Muscle, State, Save_Figs)

%% Basic Settings, some variable extractions, & definitions

% Load all subject details from the group
[Control_Names] = Signal_File_Details('Control');
[SCI_Names] = Signal_File_Details('SCI');

% Do you want to show the statistics (1 = Yes, 0 = No)
plot_stats = 0; 

% Font specifications
axis_expansion = 0.15;
violin_colors = [0.85 0.325 0.098; 0 0.447 0.741];
label_font_size = 17;
title_font_size = 20;
p_value_dims = [0.51 0.45 0.44 0.44];
legend_size = 15;
font_name = 'Arial';
fig_size = 600;

% Close all previously open figures if you're saving 
if ~isequal(Save_Figs, 0)
    close all
end

%% Extract the control StartMEP metrics
con_StartMEP = struct([]);
for ii = 1:length(Control_Names)

    % Load the sig file
    [sig] = Load_SIG('Control', Control_Names{ii}, 'StartMEP', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    if strcmp(State, 'MEP')
        [peaktopeak_MEP, ~] = Avg_StartMEP(sig, State, Muscle, 0, 0);
        con_StartMEP{ii,1} = mean(peaktopeak_MEP{1,1});
    else
        [test_peaktopeak, ~] = Avg_StartMEP(sig, 'MEP', Muscle, 0, 0);
        [peaktopeak_MEP, ~] = Avg_StartMEP(sig, State, Muscle, 0, 0);
        con_StartMEP{ii,1} = mean(peaktopeak_MEP{1,1}) / mean(test_peaktopeak{1,1}) * 100;
    end
end

%% Extract the SCI StartMEP metrics
SCI_StartMEP = struct([]);
for ii = 1:length(SCI_Names)
    
    % Load the sig file
    [sig] = Load_SIG('SCI', SCI_Names{ii}, 'StartMEP', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    if strcmp(State, 'MEP')
        [peaktopeak_MEP, ~] = Avg_StartMEP(sig, State, Muscle, 0, 0);
        SCI_StartMEP{ii,1} = mean(peaktopeak_MEP{1,1});
    else
        [test_peaktopeak, ~] = Avg_StartMEP(sig, 'MEP', Muscle, 0, 0);
        [peaktopeak_MEP, ~] = Avg_StartMEP(sig, State, Muscle, 0, 0);
        SCI_StartMEP{ii,1} = mean(peaktopeak_MEP{1,1}) / mean(test_peaktopeak{1,1}) * 100;
    end
end

%% Merge the StartMEP metrics
% Control
merged_con_StartMEP = [];
for ii = 1:length(Control_Names)
    merged_con_StartMEP = cat(1, merged_con_StartMEP, con_StartMEP{ii,1});
end
merged_con = repmat({'Control'}, length(merged_con_StartMEP), 1);

% SCI
merged_SCI_StartMEP = [];
for ii = 1:length(SCI_Names)
    merged_SCI_StartMEP = cat(1, merged_SCI_StartMEP, SCI_StartMEP{ii,1});
end
merged_SCI = repmat({'SCI'}, length(merged_SCI_StartMEP), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
y_max = max([merged_con_StartMEP; merged_SCI_StartMEP]);
y_min = min([merged_con_StartMEP; merged_SCI_StartMEP]);

% Title & y-label
if strcmp(State, 'MEP')
    y_label = 'Peak-To-Peak Amplitude (mV)';
else
    y_label = 'Peak-To-Peak Amplitude (%)';
    axis_expansion = axis_expansion * 100;
end
title_string = strcat('StartMEP:', {' '}, '[', State, ']');

%% Plot the Violin Plot

Violin_fig = figure;
Violin_fig.Position = [200 50 fig_size fig_size];
hold on

% Plot the box plot
Violin_Plot([merged_con_StartMEP; merged_SCI_StartMEP], [merged_con; merged_SCI], 'GroupOrder', ...
            {'Control', 'SCI'}, 'ViolinColor', violin_colors);
set(gca,'fontsize', label_font_size)

% Title
title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Group', 'FontSize', label_font_size)
ylabel(y_label, 'FontSize', label_font_size)

% Set the axis-limits
xlim([0.5 2.5]);
ylim([y_min - axis_expansion y_max + axis_expansion]);

% Do the statistics
[~, peaktopeak_p_val] = ttest2(merged_con_StartMEP, merged_SCI_StartMEP);

% Annotation of the p_value
if isequal(plot_stats, 1)
    if round(peaktopeak_p_val, 3) > 0
        p_value_string = strcat('p =', {' '}, mat2str(round(peaktopeak_p_val, 3)));
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ... 
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
    
    if isequal(round(peaktopeak_p_val, 3), 0)
        p_value_string = strcat('p <', {' '}, '0.001');
        p_value_string = {char(p_value_string)};
        ann_p_value = annotation('textbox', p_value_dims, 'String', p_value_string, ...
            'FitBoxToText', 'on', 'verticalalignment', 'top', ... 
            'EdgeColor','none', 'horizontalalignment', 'center');
        ann_p_value.FontSize = legend_size;
        ann_p_value.FontName = font_name;
    end
end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
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








