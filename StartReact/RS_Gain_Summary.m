function [Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Sampling_Params)

%% Look through all the tasks
Sampling_Params.State = 'F';
[F_rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
Sampling_Params.State = 'F+s';
[Fs_rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);
Sampling_Params.State = 'F+S';
[FS_rxn_time_excel, ~] = Load_AbH_Excel(Sampling_Params);


if ~isempty(F_rxn_time_excel)
    Delta_rxn_time = zeros(length(F_rxn_time_excel), 1);
    RS_Gain = zeros(length(F_rxn_time_excel), 1);
    for ii = 1:length(F_rxn_time_excel)
        F_rxn_time = mean(F_rxn_time_excel{ii,1}.rxn_time, 'omitnan');
        Fs_rxn_time = mean(Fs_rxn_time_excel{ii,1}.rxn_time, 'omitnan');
        FS_rxn_time = mean(FS_rxn_time_excel{ii,1}.rxn_time, 'omitnan');
        
        Delta_rxn_time(ii) = Fs_rxn_time - FS_rxn_time;
        RS_Gain(ii) = (F_rxn_time - FS_rxn_time) / (F_rxn_time - Fs_rxn_time);
    end
else
    Delta_rxn_time = NaN;
    RS_Gain = NaN;
end