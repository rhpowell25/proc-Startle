function [sig] = Load_SIG(Group, Subject, Date, Task)

%% Define the file location
base_dir = strcat('C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Toe_Startle\', Group, '\', Subject, '\', Date, '\');
open_file = dir(strcat(base_dir, '*.mat'));

% Find the names of each file
file_names = strings;
for ii = 1:length(open_file)
    file_names{ii} = open_file(ii).name;
end

% Only look at the selected task
task_idx = contains(file_names, Task);
file_name = char(file_names(task_idx));

% Load the sig file
try
    load(strcat(base_dir, file_name), 'sig')
catch
    disp('SIG file not found!')
    sig = NaN;
end







