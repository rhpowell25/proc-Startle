clc
clear

params = struct( ...
    'Group', 'Control', ... & 'Control', 'SCI'
    'Subject', 'HP', ... % Subject Name
    'Date', '20231107', ... % Select the date to convert (YYYYMMDD)
    'Subject_Side', 'Right'); % What side of the body ('Left' or 'Right')

% Find the file location
base_dir = 'Z:\Lab Members\Henry\AbH Startle\Data\';
save_dir = strcat(base_dir, params.Group, '\', params.Subject, '\');
file_dir = strcat(save_dir, 'RawFiles\', params.Date, '\');
file_type = strcat(file_dir, '*.mat');
all_files = dir(file_type);

for ii = 1:length(all_files)
    % File name
    file_name = all_files(ii).name;
    disp(file_name);
    % Find the task & muscle tested
    Task_Muscle = extractAfter(file_name, strcat(params.Date, '_', params.Subject, '_'));
    params.Task = extractBefore(Task_Muscle, '_');
    params.Muscle = char(extractBetween(Task_Muscle, strcat(params.Task, '_'), '_'));
    
    [sig] = raw_to_SIG(params);
    sig.meta.side = params.Subject_Side;
    save(strcat(save_dir, file_name, '.mat'), 'sig', '-v7.3');
end





