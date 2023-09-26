function [signal_file] = Load_Raw_SIG(params)

%% Extract the paramaters

Group = params.Group;
Subject = params.Subject;
Date = params.Date;
Task = params.Task;
Muscle = params.Muscle;

%% Define the file location
base_dir = strcat('Z:\Lab Members\Henry\AbH Startle\', ...
    Group, '\', Subject, '\', Date, '\');
file_dir = strcat(base_dir, 'RawFiles\');
open_file = dir(strcat(file_dir, '*.mat'));

% Find the names of each file
file_names = {open_file.name};

% Only look at the selected task
Task_files = contains(file_names, Task);
Muscle_files = contains(file_names, Muscle);
file_idx = (Task_files & Muscle_files) == 1;
file_name = char(file_names(file_idx));

% Load the file
signal_file = load(strcat(file_dir, '\', file_name));

field_names = fieldnames(signal_file);
field_idx = contains(field_names, 'wave_data');
file_title = field_names{field_idx};
signal_file = signal_file.(file_title);
signal_file.file_name = file_name;







