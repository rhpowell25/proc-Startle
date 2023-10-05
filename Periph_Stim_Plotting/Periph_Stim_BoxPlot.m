function Periph_Stim_BoxPlot(Muscle, Wave_Choice, Save_Figs)

%% Basic Settings, some variable extractions, & definitions

% Plot persistance or peak-to-peak amplitude? ('Persist', 'Peak')
Plot_Choice = 'Persist';

% Load all subject details from the group
[Control_Names] = Signal_File_Details('Control');
[SCI_Names] = Signal_File_Details('SCI');

% Font specifications
axis_expansion = 2;
box_colors = [0 0.447 0.741; 0.85 0.325 0.098];
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

%% Extract the control peripheral nerve stimulations
con_peaktopeak = struct([]);
con_persist = struct([]);
for ii = 1:length(Control_Names)

    % Load the sig file
    [sig] = Load_SIG('Control', Control_Names{ii}, 'FWave', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    % Collect the peak to peak amplitudes
    [peaktopeak_Periph_Stim] = Periph_Stim(sig, Muscle, Wave_Choice, 0, 0);
    con_peaktopeak{ii,1} = mean(peaktopeak_Periph_Stim);
    % Collect the F-Wave persistance
    [persistant_idxs] = F_Wave_Persistance(sig);
    con_persist{ii,1} = (length(persistant_idxs) / length(sig.trial_result))*100;
end

%% Extract the SCI peripheral nerve stimulations
SCI_peaktopeak = struct([]);
SCI_persist = struct([]);
for ii = 1:length(SCI_Names)

    % Load the sig file
    [sig] = Load_SIG('SCI', SCI_Names{ii}, 'FWave', Muscle);
    % Process the sig file
    [sig] = Process_SIG(sig);
    % Collect the peak to peak amplitudes
    [peaktopeak_Periph_Stim] = Periph_Stim(sig, Muscle, Wave_Choice, 0, 0);
    SCI_peaktopeak{ii,1} = mean(peaktopeak_Periph_Stim);
    % Collect the F-Wave persistance
    [persistant_idxs] = F_Wave_Persistance(sig);
    SCI_persist{ii,1} = (length(persistant_idxs) / length(sig.trial_result))*100;
end

%% Merge the amplitudes & persistance
% Control
merged_con_peaktopeak = [];
merged_con_persist = [];
for ii = 1:length(Control_Names)
    merged_con_peaktopeak = cat(1, merged_con_peaktopeak, con_peaktopeak{ii,1});
    merged_con_persist = cat(1, merged_con_persist, con_persist{ii,1});
end
merged_con = repmat({'Control'}, length(merged_con_peaktopeak), 1);

% SCI
merged_SCI_peaktopeak = [];
merged_SCI_persist = [];
for ii = 1:length(SCI_Names)
    merged_SCI_peaktopeak = cat(1, merged_SCI_peaktopeak, SCI_peaktopeak{ii,1});
    merged_SCI_persist = cat(1, merged_SCI_persist, SCI_persist{ii,1});
end
merged_SCI = repmat({'SCI'}, length(merged_SCI_peaktopeak), 1);

%% Find the y-axis limits & determine title & y-lablel
% Y-axis
if strcmp(Plot_Choice, 'Peak')
    y_max = max([merged_con_peaktopeak; merged_SCI_peaktopeak]);
    y_min = min([merged_con_peaktopeak; merged_SCI_peaktopeak]);
elseif strcmp(Plot_Choice, 'Persist')
    y_max = max([merged_con_persist; merged_SCI_persist]);
    y_min = min([merged_con_persist; merged_SCI_persist]);
end

% Title & y-label
if strcmp(Wave_Choice, 'F')
    title_string = 'F-Wave';
elseif strcmp(Wave_Choice, 'M')
    title_string = 'M-Max';
end
if strcmp(Plot_Choice, 'Peak')
    title_string = strcat(title_string, {' '}, 'Peak-Peak Amplitude:');
    y_label = 'Peak-Peak Amplitude (mV)';
elseif strcmp(Plot_Choice, 'Persist')
    title_string = strcat(title_string, {' '}, 'Persistance:');
    y_label = 'Persistance (%)';
end

%% Plot the Box Plot

box_fig = figure;
box_fig.Position = [200 50 fig_size fig_size];
hold on

% Plot the box plot
if strcmp(Plot_Choice, 'Peak')
    boxplot([merged_con_peaktopeak; merged_SCI_peaktopeak], [merged_con; merged_SCI]);
elseif strcmp(Plot_Choice, 'Persist')
    boxplot([merged_con_persist; merged_SCI_persist], [merged_con; merged_SCI]);
end
% Increase the font size
set(gca,'fontsize', label_font_size)

% Color the box plots
box_axes = findobj(gca,'Tag','Box');
for ii = 1:length(box_axes)
    patch(get(box_axes(ii), 'XData'), get(box_axes(ii), 'YData'), box_colors(ii,:), 'FaceAlpha', .5);
end

% Title
title(title_string, 'FontSize', title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Group', 'FontSize', label_font_size)
ylabel(y_label, 'FontSize', label_font_size)

% Set the axis-limits
xlim([0.5 2.5]);
ylim([y_min - axis_expansion y_max + axis_expansion]);

% Do the statistics
[~, peaktopeak_p_val] = ttest2(merged_con_peaktopeak, merged_SCI_peaktopeak);

% Annotation of the p_value
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

%% Statistics

%[p,t,stats] = anova1(d_rxn_time, Task_Names);
%[c,m,box_axes,gnames] = multcompare(stats);

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








