function [EMG_Names, EMG] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs)

%% Extract the EMG
if strcmp(EMG_Choice, 'Raw')
    temp_EMG = sig.raw_EMG;
end

if strcmp(EMG_Choice, 'Rect')
    raw_EMG = sig.raw_EMG;
    % DC removal of the EMG
    Zeroed_EMG = struct([]);
    for ii = 1:length(raw_EMG)
        for pp = 1:width(raw_EMG{ii})
            Zeroed_EMG{ii}(:,pp) = raw_EMG{ii}(:,pp) - mean(raw_EMG{ii}(:,pp));
        end
    end
    % Rectify the EMG
    temp_EMG = struct([]);
    for ii = 1:length(Zeroed_EMG)
        for pp = 1:width(Zeroed_EMG{ii})
            temp_EMG{ii,1}(:,pp) = abs(Zeroed_EMG{ii}(:,pp));
        end
    end
end

if strcmp(EMG_Choice, 'Proc')
    temp_EMG = sig.EMG;
end

%% Use only the selected EMG
if ~strcmp(muscle_group, 'All')
    EMG_name_idx = find(strcmp(sig.EMG_names, muscle_group));
else
    EMG_name_idx = 1:length(sig.EMG_names);
end
EMG_Names = sig.EMG_names(EMG_name_idx);

% Extract the selected EMG
EMG = struct([]);
for ii = 1:length(rewarded_idxs)
    EMG{ii,1} = temp_EMG{rewarded_idxs(ii)}(:,EMG_name_idx);
end

