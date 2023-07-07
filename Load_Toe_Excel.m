function [toe_rxn_time_excel, file_names] = Load_Toe_Excel(Subject, Task, State)
%% Import the excel spreadsheets of the selected drug

% Define where the excel spreadsheets are saved
Base_Path = 'C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Excel_Data\';

% Identify all the excel files in the data path
Excel_Path = strcat(Base_Path, '*.xlsx');
Excel_Files = dir(Excel_Path);
% Convert the struc to a table
Excel_Files_In_Path = struct2table(Excel_Files(~([Excel_Files.isdir])));

%% Find the excel files that use the desired task
if ~strcmp(Task, 'All')
    Excel_Task = find(contains(Excel_Files_In_Path.name, Task));
else
    Excel_Task = (1:length(Excel_Files_In_Path.name));
end

%% Find the excel files that are from the desired subject
Excel_Subject = find(contains(Excel_Files_In_Path.name, Subject));

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
        toe_rxn_time_excel = temp_excel(State_idx,:);
    else
        toe_rxn_time_excel = temp_excel;
    end

    % File Name
    file_names(cc,1) = strrep(Excel_File, '_', {' '});

    % Add to the counter
    cc = cc + 1;

end

%% Merge all the experiments if you selected 'All' for Task)
if strcmp(Task, 'All')

    % Define the merged session table
    merged_session = struct([]);
    merged_variables = toe_rxn_time_excel{1,1}.Properties.VariableNames;
    merged_session{1,1} = array2table(zeros(0, width(merged_variables)));
    merged_session{1,1}.Properties.VariableNames = merged_variables;

    for xx = 1:length(file_names)
        if isempty(toe_rxn_time_excel{xx})
            continue
        end
        if ~iscell(toe_rxn_time_excel{xx}.drug_dose_mg_per_kg(1))
            merged_session{1,1} = [merged_session{1,1}; toe_rxn_time_excel{xx}];
        else
            toe_rxn_time_excel{xx}.drug_dose_mg_per_kg = NaN(height(toe_rxn_time_excel{xx}), 1);
            merged_session{1,1} = [merged_session{1,1}; toe_rxn_time_excel{xx}];
        end
    end

    toe_rxn_time_excel = merged_session;

end


        






