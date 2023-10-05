function [sig] = Remove_Trial(sig, trial)

%% Remove a bad trial from the sig file

% Find the trial
trial_idx = find(strcmp(sig.trial_info_table_header, 'number'));
bad_trial_idx = find(cell2mat(sig.trial_info_table(:, trial_idx)) == trial);

% Mark it as a failure
result_idx = find(strcmp(sig.trial_info_table_header, 'result'));
sig.trial_info_table(bad_trial_idx, result_idx) = {'F'};
sig.trial_result(bad_trial_idx) = 'F';
