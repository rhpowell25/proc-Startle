
function [Task_Name, Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Subject)

%% Initialize the output variables
Task_Name = {'AbH_Flex'; 'AbH_Abd'; 'TA'; 'SOL'};
Delta_rxn_time = zeros(length(Task_Name),1);

F_rxn_time = zeros(length(Task_Name),1);
Fs_rxn_time = zeros(length(Task_Name),1);
FS_rxn_time = zeros(length(Task_Name),1);
RS_Gain = zeros(length(Task_Name),1);

%% Look through all the tasks
for ii = 1:length(Task_Name)

    [F_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F');
    [Fs_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F+s');
    [FS_rxn_time_excel, ~] = Load_Toe_Excel(Subject, Task_Name{ii}, 'F+S');
    
    F_rxn_time(ii) = mean(F_rxn_time_excel.rxn_time);
    Fs_rxn_time(ii) = mean(Fs_rxn_time_excel.rxn_time);
    FS_rxn_time(ii) = mean(FS_rxn_time_excel.rxn_time);
    
    Delta_rxn_time(ii) = Fs_rxn_time(ii) - FS_rxn_time(ii);
    RS_Gain(ii) = (F_rxn_time(ii) - FS_rxn_time(ii)) / (F_rxn_time(ii) - Fs_rxn_time(ii));

end

