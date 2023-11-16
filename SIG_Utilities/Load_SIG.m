function [sig] = Load_SIG(Group, Subject, Task, Muscle)

%% Define the file location
base_dir = 'C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Data\';
folder_dir = strcat(base_dir, Group, '\', Subject, '\');
open_file = dir(strcat(folder_dir, '*.mat'));

% Find the names of each file
file_names = {open_file.name};

% Only look at the selected task
Task_files = contains(file_names, Task);
Muscle_files = contains(file_names, Muscle);
file_idx = (Task_files & Muscle_files) == 1;
file_name = char(file_names(file_idx));

% Load the sig file
try
    load(strcat(folder_dir, file_name), 'sig')
catch
    disp('SIG file not found!')
    sig = NaN;
end







