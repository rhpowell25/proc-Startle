function [sig] = Process_SIG(sig)

%% Start React Processing
% Remove trials with early EMG activation
%[sig] = Remove_FalseStarts(sig);

% Remove bad trials
[sig] = Remove_BadTrials(sig);