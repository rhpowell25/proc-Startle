function [Names] = SIG_File_Details(Group)

%% Define the experiments that will be examined 

Names = strings;
if strcmp(Group, 'Control')
    Names{1,1} = 'HK';
    Names{2,1} = 'HE';
    Names{3,1} = 'RR';
    Names{4,1} = 'KP';
    Names{5,1} = 'FR';
    Names{6,1} = 'MKL';
    Names{7,1} = 'MF';
    Names{8,1} = 'TP';
    Names{9,1} = 'RM';
end
if strcmp(Group, 'SCI')
    Names{1,1} = 'PM';
    Names{2,1} = 'SS';
    Names{3,1} = 'JW';
    Names{4,1} = 'WM';
    Names{5,1} = 'DM';
    Names{6,1} = 'MW';
    Names{7,1} = 'DC';
    Names{8,1} = 'DS';
    Names{9,1} = 'EM';
end

% Force calibration
if strcmp(Group, 'Force')
    Names(1,1) = 8.4443;
end


