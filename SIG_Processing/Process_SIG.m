function [sig] = Process_SIG(sig)

%% Check for common sources of errors
if ~isstruct(sig)
    disp('NaN Sig File!')
    sig = NaN;
    return
end

%% F-Wave Processing
if strcmp(sig.meta.task, 'FWave')

    % Remove trials with early EMG activation
    %[sig] = Remove_FalseStarts(sig);

end

%% StartReact Processing
if strcmp(sig.meta.task, 'StartReact')

    % Remove trials with early EMG activation
    [sig] = Remove_FalseStarts(sig);

    % Remove late starts
    [sig] = Remove_LateStarts(sig);
    
end

%% StartMEP Processing
if strcmp(sig.meta.task, 'StartMEP')

    % Remove trials with early EMG activation
    [sig] = Remove_FalseStarts(sig);

end

%% Individualized processing

% Remove bad trials
[sig] = Remove_BadTrials(sig);

% Configuration was written as cMEP instead of MEP
if strcmp(sig.meta.date, '20230906') && strcmp(sig.meta.subject, 'HE')
    state_idx = strcmp(sig.trial_info_table_header, 'State');
    for ii = 1:height(sig.trial_info_table)
        sig.trial_info_table{ii,state_idx} = strrep(sig.trial_info_table{ii,state_idx}, 'c', '');
    end
end

