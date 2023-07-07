function [delta_rxn_time] = Summary_PolarPlot(Subject, Save_Figs)

%% Display the function being used
disp('Polar Plot Function:');

%% Some variable extraction & definitions

% Font & axis specifications
title_font_size = 15;
plot_line_size = 3;
axes_font_size = 20;
r_axes_angle = 135;
axes_line_size = 2;
font_name = 'Arial';

if ~isequal(Save_Figs, 0)
    % Do you want a save title or blank title (1 = save_title, 0 = blank)
    Fig_Save_Title = 1;
end

%% Plotting the polar plots

[Task_Name, delta_rxn_time, ~] = RS_Gain_Summary(Subject);

% Add an extra gain value to connect the plot
Polar_rxn_time = [delta_rxn_time; delta_rxn_time(1)];

% Define the degrees
degree_place = linspace(0, 360, 5);

figure
polarplot(deg2rad(degree_place), Polar_rxn_time, 'LineWidth', plot_line_size, 'Color', 'k')
hold on

% Label the theta axis
set(gca,'TickLabelInterpreter','none')
thetaticks(degree_place)
thetaticklabels(Task_Name)

% Titling the polar plot
fig_title = sprintf('Reaction Time Change: %s', Subject);
title(fig_title, 'FontSize', title_font_size)

% Only label every other tick
figure_axes = gca;
figure_axes.RAxisLocation = r_axes_angle;
figure_axes.RColor = 'k';
figure_axes.ThetaColor = 'k';
figure_axes.LineWidth = axes_line_size;
figure_axes.FontSize = axes_font_size;
r_labels = string(figure_axes.RAxis.TickLabels);
r_labels(1:2:end) = NaN;
figure_axes.RAxis.TickLabels = r_labels;
% Set The Font
set(figure_axes,'fontname', font_name);

%% Define the save directory & save the figure
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = 1:length(findobj('type','figure'))
        fig_title = strrep(fig_title, ':', '');
        fig_title = strrep(fig_title, 'vs.', 'vs');
        fig_title = strrep(fig_title, 'mg.', 'mg');
        fig_title = strrep(fig_title, 'kg.', 'kg');
        fig_title = strrep(fig_title, '.', '_');
        fig_title = strrep(fig_title, '/', '_');
        if isequal(Fig_Save_Title, 0)
            title '';
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(fig_title)), 'fig')
        else
            saveas(gcf, fullfile(save_dir, char(fig_title)), Save_Figs)
        end
        close gcf
    end
end



