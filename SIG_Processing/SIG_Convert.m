clc
clear

params = struct( ...
    'Group', 'SCI', ... & 'Control', 'SCI'
    'Subject', 'DM', ... % Subject Name
    'Task', 'StartMEP', ... % 'MVC', 'FWave', 'StartReact', 'StartMEP'
    'Muscle', 'ABH', ... % 'ABH', 'TA', 'SOL', 'QUAD'
    'Date', '20231005', ... % Select the date to convert (YYYYMMDD)
    'Subject_Side', 'Right', ... % What side of the body ('Left' or 'Right')
    'GoCue_Time', 2); % Sec. (MVC = 1, FWave = 0.5, StartReact = 1, StartMEP = 2)

% Find the file location
base_dir = 'Z:\Lab Members\Henry\AbH Startle\Data\';
save_dir = strcat(base_dir, params.Group, '\', params.Subject, '\');
file_dir = strcat(save_dir, 'RawFiles\', params.Date, '\');
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





