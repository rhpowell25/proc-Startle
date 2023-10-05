function [toe_rxn_time_excel, file_names] = Load_Toe_Excel(Group, Subject, Muscle, State)
%% Import the excel spreadsheets of the selected drug

% Define where the excel spreadsheets are saved
Base_Path = strcat('Z:\Lab Members\Henry\AbH Startle\Excel_Data\', Group, '\');

% Identify all the excel files in the data path
Excel_Path = strcat(Base_Path, '*.xlsx');
Excel_Files = dir(Excel_Path);
% Convert the struc to a table
Excel_Files_In_Path = struct2table(Excel_Files(~([Excel_Files.isdir])));

%% Find the excel files that use the desired task
if ~strcmp(Muscle, 'All')
    Excel_Task = find(contains(Excel_Files_In_Path.name, Muscle));
else
    Excel_Task = (1:length(Excel_Files_In_Path.name));
end

%% Find the excel files that are from the desired subject
if ~strcmp(Subject, 'All')
    Excel_Subject = find(contains(Excel_Files_In_Path.name, Subject));
else
    Excel_Subject = (1:length(Excel_Files_In_Path.name));
end

%% Find the intersection of Subject & Task
Excel_Choice = intersect(Excel_Task, Excel_Subject);

%% Build the output arrays

toe_rxn_time_excel = struct([]);

file_names = strings;

%% Loop through each of experiments

% Initialize the counter
cc = 1;
for xx = 1:length(Excel_Choice)

    %% Load the output table

    if isequal(length(Excel_Choice), 1)
        table_path = strcat(Base_Path, Excel_Files_In_Path.name(Excel_Choice(1)));
        Excel_File = strrep(char(Excel_Files_In_Path.name(Excel_Choice(1))), '.xlsx', '');
    else
        table_path = strcat(Base_Path, Excel_Files_In_Path.name(Excel_Choice(xx)));
        Excel_File = strrep(char(Excel_Files_In_Path.name(Excel_Choice(xx))), '.xlsx', '');
    end
    % Continue if the file is open and unsaved
    if contains(Excel_Files_In_Path.name(Excel_Choice(xx)), '~')
        continue
    end

    temp_excel = readtable(char(table_path));

    % Subsample according to State
    if ~strcmp(State, 'All')
        State_idx = strcmp(temp_excel.State, State);
        temp_excel = temp_excel(State_idx,:);  
    end
    toe_rxn_time_excel{cc,1} = temp_excel(:,:);

    % File Name
    file_names(cc,1) = strrep(Excel_File, '_', {' '});

    % Add to the counter
    cc = cc + 1;

end

%% Merge all the experiments if you selected 'All' for Subject
if strcmp(Subject, 'All')

    % Define the merged session table
    merged_session = struct([]);
    merged_variables = toe_rxn_time_excel{1,1}.Properties.VariableNames;
    merged_session{1,1} = array2table(zeros(0, width(merged_variables)));
    merged_session{1,1}.Properties.VariableNames = merged_variables;

    for xx = 1:length(file_names)
        if isempty(toe_rxn_time_excel{xx})
            continue
        end
        merged_session{1,1} = [merged_session{1,1}; toe_rxn_time_excel{xx}];
    end

    toe_rxn_time_excel = merged_session;

end


        






