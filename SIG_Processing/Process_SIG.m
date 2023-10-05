function [sig] = Process_SIG(sig)

%% Check for common sources of errors
if ~isstruct(sig)
    disp('NaN Sig File!')
    sig = NaN;
    return
end

%% Start React Processing
% Remove trials with early EMG activation
[sig] = Remove_FalseStarts(sig);

% Remove late starts
if strcmp(sig.meta.task, 'StartReact')
    [sig] = Remove_LateStarts(sig);
end

% Remove bad trials
[sig] = Remove_BadTrials(sig);

%% Individualized processing

% Had to readjust startle headphones
if strcmp(sig.meta.date, '20230929') && strcmp(sig.meta.subject, 'KP') && strcmp(sig.meta.task, 'StartMEP')
    for ii = 1:22
        [sig] = Remove_Trial(sig, ii);
    end
end

% Configuration was written as cMEP instead of MEP
if strcmp(sig.meta.date, '20230906') && strcmp(sig.meta.subject, 'HE')
    state_idx = strcmp(sig.trial_info_table_header, 'State');
    for ii = 1:height(sig.trial_info_table)
        sig.trial_info_table{ii,state_idx} = strrep(sig.trial_info_table{ii,state_idx}, 'c', '');
    end
end

