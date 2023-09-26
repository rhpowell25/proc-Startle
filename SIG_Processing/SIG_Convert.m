clc
clear

params = struct( ...
    'Group', 'SCI', ... & 'Control', 'SCI'
    'Subject', 'SS', ... % Subject Name
    'Task', 'MVC', ... % 'StartReact', 'MVC', 'FWave', 'StartMEP'
    'Muscle', 'ABH', ... % 'ABH', 'TA', 'SOL', 'QUAD'
    'Date', '20230919', ... % Select the date to convert (YYYYMMDD)
    'Subject_Side', 'Right', ... % What side of the body ('Left' or 'Right')
    'GoCue_Time', 1); % Sec. (StartReact = 1, FWave = 0.5)

% Find the file location
base_dir = 'Z:\Lab Members\Henry\AbH Startle';
save_dir = strcat(base_dir, '\', params.Group, '\', params.Subject, '\', params.Date, '\');
file_dir = strcat(save_dir, 'RawFiles\');
file_type = strcat(file_dir, '*.mat');
all_files = dir(file_type);

% Find the specific file
Task_files = contains({all_files.name}, params.Task);
Muscle_files = contains({all_files.name}, params.Muscle);
file_idx = find((Task_files & Muscle_files) == 1);
% Convert the file
file_name = all_files(file_idx).name(1:end-4);
disp(file_name);
[sig] = raw_to_SIG(params);
sig.meta.side = params.Subject_Side;
save(strcat(save_dir, file_name, '.mat'), 'sig', '-v7.3');





