function [Time_Settings] = MEP_Time_Settings(params)

%% Define the time settings to view the MEP

% Show the stimulus artifact? ('Yes', 'No')
if strcmp(params.stim_art, 'No')
    pre_gocue = -0.03; % Sec
else
    pre_gocue = 0.01; % Sec.
end

% Show the silent period?
if strcmp(params.silent_period, 'No')
    post_gocue = 0.125; % Sec.
else
    post_gocue = 0.2; % Sec
end

% Full length to be plotted
plot_length = post_gocue + pre_gocue;

Time_Settings = struct(...
    'pre_gocue', pre_gocue, ...
    'post_gocue', post_gocue, ...
    'plot_length', plot_length);


