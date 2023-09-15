function [signal_file] = Load_Raw_SIG(Group, Subject, Date, Test, Task)

%% Define the file location
base_dir = strcat('C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Toe_Startle\', ...
    Group, '\', Subject, '\', Date, '\');
file_dir = strcat(base_dir, '\RawFiles\', Test, '\');
open_file = dir(strcat(file_dir, '*.mat'));

% Find the names of each file
file_names = strings;
for ii = 1:length(open_file)
    file_names{ii} = open_file(ii).name;
end

% Only look at the selected task
task_idx = contains(file_names, Task);
file_name = char(file_names(task_idx));

% Load the file
signal_file = load(strcat(file_dir, '\', file_name));

field_names = fieldnames(signal_file);
field_idx = contains(field_names, 'wave_data');
file_title = field_names{field_idx};
signal_file = signal_file.(file_title);
signal_file.file_name = file_name;







