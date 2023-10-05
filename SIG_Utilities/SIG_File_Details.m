function [Names] = SIG_File_Details(Group)

%% Define the experiments that will be examined 

Names = strings;
if strcmp(Group, 'Control')
    Names{1,1} = 'HE';
    Names{2,1} = 'MA';
    Names{3,1} = 'RR';
    Names{4,1} = 'KP';
    Names{5,1} = 'FR';
    %Names{1,1} = 'EB';
    %Names{1,1} = 'HK';
    %Names{1,1} = 'ST';
    %Names{1,1} = 'JA';
    %Names{1,1} = 'GaM';
    %Names{1,1} = 'TP';
    %Names{1,1} = 'AW';
    %Names{1,1} = 'RM';
end
if strcmp(Group, 'SCI')
    Names{1,1} = 'SS';
    Names{2,1} = 'PM';
    Names{3,1} = 'JW';
    Names{4,1} = 'WM';
    %Names{1,1} = 'MR';
end
