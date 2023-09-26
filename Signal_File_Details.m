function [Names, Dates] = Signal_File_Details(Group)

%% Define the experiments that will be examined 

Names = strings;
Dates = strings;
if strcmp(Group, 'Control')
    Names{1,1} = 'EB';
    Names{2,1} = 'HK';
    Names{3,1} = 'ST';
    Names{4,1} = 'JA';
    Names{5,1} = 'GaM';
    Names{6,1} = 'TP';
    Names{7,1} = 'AW';
    Names{8,1} = 'RM';
    Dates{1,1} = '20230602';
    Dates{2,1} = '20230606';
    Dates{3,1} = '20230607';
    Dates{4,1} = '20230607';
    Dates{5,1} = '20230609';
    Dates{6,1} = '20230614';
    Dates{7,1} = '20230623';
    Dates{8,1} = '20230623';
end
if strcmp(Group, 'SCI')
    Names{1,1} = 'SS';
    %Names{1,1} = 'PM';
    %Names{1,1} = 'JW';
    %Names{2,1} = 'MR';
    Dates{1,1} = '20230919';
    %Dates{1,1} = '20230909';
    %Dates{1,1} = '20230830';
    %Dates{2,1} = '20230830';
end
