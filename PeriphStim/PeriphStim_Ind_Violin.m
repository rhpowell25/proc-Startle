function PeriphStim_Ind_Violin(sig, Wave_Choice, Save_File)

%% File Description:

% -- Inputs --
% Save_Figs: 'pdf', 'png', 'fig', 'All', or 0

%% Basic Settings, some variable extractions, & definitions

% Do you want to use a boxplot or violinplot? ('Box', 'Violin')
plot_choice = 'Violin';

% Define the muscle groups of interest
%muscle_groups = {'ABH'; 'TA'; 'SOL'};
muscle_groups = {'ABH'};

% Title info
Subject = sig.meta.subject;

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
plot_colors = [0 0.5 0];
axis_expansion = 0.05;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Initialize the output variables

title_strings = struct([]);

%% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;
  
%% Extract the peripheral nerve stimulations
[persistant_idxs] = F_Wave_Persistance(sig);
all_trials_metric = strings(length(persistant_idxs), length(muscle_groups));
Plot_Metric = zeros(length(persistant_idxs), length(muscle_groups));
% Collect the peak to peak amplitudes
for ii = 1:length(muscle_groups)
    [Plot_Metric(:,ii)] = Trial_PeriphStim(sig, muscle_groups{ii,1}, Wave_Choice, 0, 0);
    all_trials_metric(:,ii) = repmat(muscle_groups(ii), length(persistant_idxs), 1);
end

%% Plot the violin plot

for ii = 1:length(muscle_groups)

    plot_fig = figure;
    plot_fig.Position = [200 50 Plot_Params.fig_size Plot_Params.fig_size];
    hold on

    % Find the y_limits
    y_min = min(Plot_Metric(:,ii));
    y_max = max(Plot_Metric(:,ii));
    
    % Title
    Fig_Title = strcat('Peak', {' '}, Wave_Choice, '-Wave', {' '}, Subject, ...
        {' '}, '[', muscle_groups{ii}, ']');
    title_strings{ii} = Fig_Title;
    title(Fig_Title, 'FontSize', Plot_Params.title_font_size, 'Interpreter', 'none');
    
    % Plot
    if strcmp(plot_choice, 'Box')
        boxplot(Plot_Metric(:,ii), all_trials_metric(:,ii));
        % Color the box plots
        box_axes = findobj(gca,'Tag','Box');
        patch(get(box_axes, 'XData'), get(box_axes, 'YData'), plot_colors, 'FaceAlpha', .5);
    elseif strcmp(plot_choice, 'Violin')
        Violin_Plot(Plot_Metric(:,ii), all_trials_metric(:,ii), 'ViolinColor', plot_colors);
    end

    set(gca,'fontsize', Plot_Params.label_font_size)

    % Set the axis-limits
    xlim([0.5 1.5]);
    ylim([y_min - axis_expansion, y_max + axis_expansion])
    
    % Labels
    y_label = strcat('Peak', {' '}, Wave_Choice, '-Wave');
    if strcmp(Wave_Choice, 'Force')
        y_label = strcat(y_label, {' '}, '(N)');
    elseif strcmp(Wave_Choice, 'EMG')
        y_label = strcat(y_label, {' '}, '(mV)');
    end
    ylabel(y_label, 'FontSize', Plot_Params.label_font_size);

end

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)







