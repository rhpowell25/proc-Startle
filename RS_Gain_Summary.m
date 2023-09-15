
function [Task_Name, Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Group, Subject)

%% Initialize the output variables
Task_Name = {'AbH_Flex'; 'AbH_Abd'; 'Plantar'; 'TA'; 'SOL'};
Delta_rxn_time = zeros(length(Task_Name),1);

F_rxn_time = zeros(length(Task_Name),1);
Fs_rxn_time = zeros(length(Task_Name),1);
FS_rxn_time = zeros(length(Task_Name),1);
RS_Gain = zeros(length(Task_Name),1);

%% Look through all the tasks
for ii = 1:length(Task_Name)

    [F_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Task_Name{ii}, 'F');
    [Fs_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Task_Name{ii}, 'F+s');
    [FS_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Task_Name{ii}, 'F+S');
    
    if ~isempty(F_rxn_time_excel)
        F_rxn_time(ii) = mean(F_rxn_time_excel{1,1}.rxn_time, 'omitnan');
        Fs_rxn_time(ii) = mean(Fs_rxn_time_excel{1,1}.rxn_time, 'omitnan');
        FS_rxn_time(ii) = mean(FS_rxn_time_excel{1,1}.rxn_time, 'omitnan');
        
        Delta_rxn_time(ii) = Fs_rxn_time(ii) - FS_rxn_time(ii);
        RS_Gain(ii) = (F_rxn_time(ii) - FS_rxn_time(ii)) / (F_rxn_time(ii) - Fs_rxn_time(ii));
    else
        Delta_rxn_time(ii) = NaN;
        RS_Gain(ii) = NaN;
    end
end

