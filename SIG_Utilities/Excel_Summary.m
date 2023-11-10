function Excel_Summary(Group, Save_Excel)

%% Basic Settings, some variable extractions, & definitions

Save_Path = strcat('Z:\Lab Members\Henry\AbH Startle\Excel_Data\', Group, '\');

% Load all subject details from the group
[Subjects] = SIG_File_Details(Group);

% What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
Task = 'StartReact';

% What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
Muscle = 'ABH';

%% Load the reaction times
AbH_excel = struct([]);
for ii = 1:length(Subjects)
    [F_excel, ~] = Load_AbH_Excel(Group, Subjects{ii,1}, Task, Muscle, 'F');
    [Fs_excel, ~] = Load_AbH_Excel(Group, Subjects{ii,1}, Task, Muscle, 'F+s');
    [FS_excel, ~] = Load_AbH_Excel(Group, Subjects{ii,1}, Task, Muscle, 'F+S');

    % Generate the per-subject table
    table_height = 25;
    AbH_excel{ii,1} = array2table(NaN(table_height, 3));
    AbH_excel{ii,1}.Properties.VariableNames{1,1} = strcat(Subjects{ii,1}, '_F');
    AbH_excel{ii,1}{1:height(F_excel{1,1}),1} = F_excel{1,1}.rxn_time;
    AbH_excel{ii,1}{table_height, 1} = mean(F_excel{1,1}.rxn_time);
    AbH_excel{ii,1}.Properties.VariableNames{1,2} = strcat(Subjects{ii,1}, '_F+s');
    AbH_excel{ii,1}{1:height(Fs_excel{1,1}),2} = Fs_excel{1,1}.rxn_time;
    AbH_excel{ii,1}{table_height, 2} = mean(Fs_excel{1,1}.rxn_time);
    AbH_excel{ii,1}.Properties.VariableNames{1,3} = strcat(Subjects{ii,1}, '_F+S');
    AbH_excel{ii,1}{1:height(FS_excel{1,1}),3} = FS_excel{1,1}.rxn_time;
    AbH_excel{ii,1}{table_height, 3} = mean(FS_excel{1,1}.rxn_time);
end

%% Generate the summary table

for ii = 1:length(AbH_excel)
    if isequal(ii,1)
        summary_excel = AbH_excel{ii,1};
    else
        summary_excel = [summary_excel AbH_excel{ii,1}];
    end
end

%% Save to Excel
if isequal(Save_Excel, 1)

    % Define the file name
    filename = char(strcat(Group, '_Summary_Excel'));

    % Save the file
    if ~exist(Save_Path, 'dir')
        mkdir(Save_Path);
    end
    writetable(summary_excel, strcat(Save_Path, filename, '.xlsx'))

end







