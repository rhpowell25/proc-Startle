function [Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Group, Muscle, Subject)

%% Look through all the tasks

[F_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Muscle, 'F');
[Fs_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Muscle, 'F+s');
[FS_rxn_time_excel, ~] = Load_Toe_Excel(Group, Subject, Muscle, 'F+S');

if ~isempty(F_rxn_time_excel)
    F_rxn_time = mean(F_rxn_time_excel{1,1}.rxn_time, 'omitnan');
    Fs_rxn_time = mean(Fs_rxn_time_excel{1,1}.rxn_time, 'omitnan');
    FS_rxn_time = mean(FS_rxn_time_excel{1,1}.rxn_time, 'omitnan');
    
    Delta_rxn_time = Fs_rxn_time - FS_rxn_time;
    RS_Gain = (F_rxn_time - FS_rxn_time) / (F_rxn_time - Fs_rxn_time);
else
    Delta_rxn_time = NaN;
    RS_Gain = NaN;
end