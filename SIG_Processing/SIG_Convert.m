clc
clear

params = struct( ...
    'Subject', 'TP', ... % Subject Name
    'Date', '20230614', ... % Select the date to convert (YYYYMMDD)
    'Subject_Side', 'Right', ... % What side of the body ('Left' or 'Right')
    'Trial_Length', 5, ... % Sec.
    'GoCue_Time', 1); % Sec.

base_dir = 'C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Toe_Startle';
file_dir = strcat(base_dir, '\', params.Subject, '\', params.Date, '\RawFiles\');
save_dir = strcat(base_dir, '\', params.Subject, '\', params.Date, '\');
open_file = strcat(file_dir, '*.mat');
file = dir(open_file);

for ii = 1:length(file)
    file_name = file(ii).name(1:end-4);
    disp(file_name);
    xtra_info = extractAfter(file_name, strcat(params.Subject, '_'));
    params.Task = xtra_info(1:end-3);
    [sig] = raw_to_SIG(params);
    sig.meta.side = params.Subject_Side;
    save(strcat(save_dir, file_name, '.mat'), 'sig', '-v7.3');
    clear sig
end



