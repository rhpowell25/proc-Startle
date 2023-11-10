
function [max_MVC] = MVC_Normalization(sig, muscle_group)

%% Loading the MVC's

% Do you want to analyze the EMG or force? ('Force', 'EMG')
Plot_Choice = 'EMG';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Group Name ('Control', 'SCI')
Group = sig.meta.group;
% Subject Name
Subject = sig.meta.subject;
% What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
Task = 'MVC';

% Load the sig file
[sig_MVC] = Load_SIG(Group, Subject, Task, muscle_group);
% Process the sig file
[sig_MVC] = Process_SIG(sig_MVC);

%% Convert to the trial table
matrix_variables = sig_MVC.trial_info_table_header';
trial_info_table = cell2table(sig_MVC.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, 'R'));

%% Find the max MVC

% Extract the EMG or force
if isequal(Plot_Choice, 'EMG')
    [~, Plot_Metric] = Extract_EMG(sig_MVC, EMG_Choice, muscle_group, rewarded_idxs);
    muscle_group = {muscle_group};
elseif isequal(Plot_Choice, 'Force')
    muscle_group = {'Force'};
    [Plot_Metric] = Extract_Force(sig_MVC, 1, 1, rewarded_idxs);
end

all_trials_max_metric = zeros(length(Plot_Metric), length(muscle_group));
all_trials_metric = strings(length(Plot_Metric), length(muscle_group));
for pp = 1:length(muscle_group)
    all_trials_metric(:,pp) = repmat(muscle_group(pp), length(Plot_Metric), 1);
    for ii = 1:length(Plot_Metric)
        all_trials_max_metric(ii,pp) = max(Plot_Metric{ii,1}(:,pp));
    end
end

max_MVC = max(all_trials_max_metric);



