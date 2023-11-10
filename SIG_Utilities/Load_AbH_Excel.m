function [AbH_excel, file_names] = Load_AbH_Excel(Sampling_Params)

%% Import the excel spreadsheets of the selected drug

% Define where the excel spreadsheets are saved
Base_Path = strcat('Z:\Lab Members\Henry\AbH Startle\Excel_Data\', Sampling_Params.Group, '\');

% Identify all the excel files in the data path
Excel_Path = strcat(Base_Path, '*.xlsx');
Excel_Files = dir(Excel_Path);
% Convert the struc to a table
Excel_Files_In_Path = struct2table(Excel_Files(~([Excel_Files.isdir])));

%% Find the excel files that are from the desired subject
if ~strcmp(Sampling_Params.Subject, 'All')
    Excel_Subject = find(contains(Excel_Files_In_Path.name, Sampling_Params.Subject));
else
    Excel_Subject = (1:length(Excel_Files_In_Path.name));
end

%% Find the excel files that use the desired task
if ~strcmp(Sampling_Params.Muscle, 'All')
    Excel_Task = find(contains(Excel_Files_In_Path.name, Sampling_Params.Task));
else
    Excel_Task = (1:length(Excel_Files_In_Path.name));
end

%% Find the excel files that use the desired muscle
if ~strcmp(Sampling_Params.Muscle, 'All')
    Excel_Muscle = find(contains(Excel_Files_In_Path.name, Sampling_Params.Muscle));
else
    Excel_Muscle = (1:length(Excel_Files_In_Path.name));
end

%% Find the intersection of Subject & Task
Excel_Choice = intersect(intersect(Excel_Subject, Excel_Muscle, 'stable'), Excel_Task, 'stable');

% End the function if no excel present
if isempty(Excel_Choice)
    disp('No excel to load!')
    %AbH_excel = {NaN}; 
    %file_names = {NaN};
    %return
end

%% Build the output arrays

AbH_excel = struct([]);

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
    if ~strcmp(Sampling_Params.State, 'All')
        State_idx = strcmp(temp_excel.State, Sampling_Params.State);
        temp_excel = temp_excel(State_idx,:);  
    end
    AbH_excel{cc,1} = temp_excel(:,:);

    % File Name
    file_names(cc,1) = strrep(Excel_File, '_', {' '});

    % Add to the counter
    cc = cc + 1;

end

%% Merge all the experiments if you selected 'All' for Subject
if strcmp(Sampling_Params.trial_sessions, 'All')

    % Define the merged session table
    merged_session = struct([]);
    merged_variables = AbH_excel{1,1}.Properties.VariableNames;
    merged_session{1,1} = array2table(zeros(0, width(merged_variables)));
    merged_session{1,1}.Properties.VariableNames = merged_variables;

    for xx = 1:length(file_names)
        if isempty(AbH_excel{xx})
            continue
        end
        merged_session{1,1} = [merged_session{1,1}; AbH_excel{xx}];
    end

    AbH_excel = merged_session;

end


        






