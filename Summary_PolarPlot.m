function [plot_metric] = Summary_PolarPlot(Group, Subject, Save_File)

%% Display the function being used
disp('Polar Plot Function:');

%% Some variable extraction & definitions

% Plot the Δ reaction time or RS Gain? ('Reaction Time' or 'RS Gain')
plot_choice = 'RS Gain';

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
r_axis_angle = 135;

%% Plotting the polar plots

[Task_Name, delta_rxn_time, RS_Gain] = RS_Gain_Summary(Group, Subject);

if strcmp(plot_choice, 'Reaction Time')
    plot_metric = delta_rxn_time;
elseif strcmp(plot_choice, 'RS Gain')
    plot_metric = RS_Gain;
end

% Remove any Nan's from the plot metric
nan_idx = isnan(plot_metric);
plot_metric(nan_idx) = [];
Task_Name(nan_idx) = [];

% Add an extra gain value to connect the plot
Polar_plot_metric = [plot_metric; plot_metric(1)];

% Define the degrees
degree_place = linspace(0, 360, length(Polar_plot_metric));

figure
polarplot(deg2rad(degree_place), Polar_plot_metric, 'LineWidth', Plot_Params.mean_line_width, 'Color', 'k')
hold on

% Label the theta axis
set(gca,'TickLabelInterpreter','none')
thetaticks(degree_place)
thetaticklabels(Task_Name)

% Titling the polar plot
Fig_Title = sprintf('%s: %s', plot_choice, Subject);
title(Fig_Title, 'FontSize', Plot_Params.title_font_size)

% Only label every other tick
figure_axes = gca;
figure_axes.RAxisLocation = r_axis_angle;
figure_axes.RColor = 'k';
figure_axes.ThetaColor = 'k';
figure_axes.LineWidth = Plot_Params.axes_line_width;
figure_axes.FontSize = Plot_Params.axis_font_size;
r_labels = string(figure_axes.RAxis.TickLabels);
r_labels(1:2:end) = NaN;
figure_axes.RAxis.TickLabels = r_labels;
% Set The Font
set(figure_axes,'fontname', Plot_Params.font_name);

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)

