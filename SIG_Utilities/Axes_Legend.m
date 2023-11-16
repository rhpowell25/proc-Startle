function Axes_Legend(x_units, y_units)

%% Collect information from the figure
%set(gcf, 'Position', get(0, 'Screensize'));
fig_pos = get(gcf, 'Position'); %// gives x left, y bottom, width, height
fig_width = fig_pos(3);
fig_height = fig_pos(4);

x_y_ratio = round(fig_width / fig_height);

y_lims = ylim;
x_lims = xlim;

%% Percent of the figure the legend takes up
x_divider = 12;
y_divider = 4;
if x_y_ratio > 1
    y_divider = y_divider / x_y_ratio;
elseif x_y_ratio < 1
    x_divider = x_divider * x_y_ratio;
end

%% Thick lines for axes labeling

y_length = y_lims(2) - y_lims(1);
x_length = x_lims(2) - x_lims(1);

y_marker_length = round(5*(y_length / y_divider))/5;
x_marker_length = round(5*(x_length / x_divider))/5;

% X-axis line
line([x_lims(2) - x_marker_length x_lims(2)], [y_lims(1) y_lims(1)], ... 
    'Color', 'k', 'LineWidth', 3)
% Y-axis line
line([x_lims(2) x_lims(2)], [y_lims(1) y_lims(1) + y_marker_length], ... 
    'Color', 'k', 'LineWidth', 3)

% X-axis text
x_text = strcat(string(x_marker_length), {'  '}, x_units);
x_text_x_position = x_lims(2) - (x_marker_length / 2);
x_text_y_position = y_lims(1) - (y_length * 0.05);
text(x_text_x_position, x_text_y_position, x_text, 'FontSize', 30, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% Y-axis text
y_text = strcat(string(y_marker_length), {'  '}, y_units);
y_text_x_position = x_lims(2) + (x_length * 0.05);
y_text_y_position = y_lims(1) + (y_marker_length / 2);
y_axis = text(y_text_x_position, y_text_y_position, y_text, 'FontSize', 30, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
y_axis.Rotation = 90;


