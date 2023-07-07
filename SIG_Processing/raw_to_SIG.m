function [sig] = raw_to_SIG(params)
%% Extract the paramaters

Subject = params.Subject;
Date = params.Date;
Subject_Side = params.Subject_Side;
Task = params.Task;
Trial_Length = params.Trial_Length;
GoCue_Time = params.GoCue_Time;

%% Load the signal file

[signal_file] = Load_Raw_SIG(Subject, Date, Task);
file_name = signal_file.file_name;

%% Extract trial numbers the signal file

trial_num = zeros(length(signal_file.frameinfo), 1);
for ii = 1:length(trial_num)
    trial_num(ii) = signal_file.frameinfo(ii).number;
end

%% Extract states the signal file

States = strings;
for ii = 1:length(trial_num)
    if contains(signal_file.frameinfo(ii).label, strcat('F', ' (s'))
        States{ii,1} = 'F';
    elseif contains(signal_file.frameinfo(ii).label, strcat('F+s', ' (s'))
        States{ii,1} = 'F+s';
    elseif contains(signal_file.frameinfo(ii).label, strcat('F+S', ' (s'))
        States{ii,1} = 'F+S';
    end
end

%% Extract trial start, gocue, & end time the signal file

trial_start = zeros(length(trial_num), 1);
trial_gocue = zeros(length(trial_num), 1);
trial_end = zeros(length(trial_num), 1);
trial_result = cell(length(trial_num),1);
for ii = 1:length(trial_num)
    trial_start(ii) = signal_file.frameinfo(ii).start;
    trial_gocue(ii) = trial_start(ii) + GoCue_Time;
    trial_end(ii) = trial_start(ii) + Trial_Length;
    trial_result{ii} = 'R';
end

%% Create the trial table

% Define the excel matrix headers
table_header = {'number'; 'startTime'; 'endTime'; 'result'; 'goCueTime'; 'State'};

% Create the excel matrix
Trial_Table = array2table(zeros(length(trial_num), length(table_header)));
Trial_Table.Properties.VariableNames = table_header;

% Assign the matrix table
Trial_Table.number = trial_num;
Trial_Table.startTime = trial_start;
Trial_Table.endTime = trial_end;
Trial_Table.result = trial_result;
Trial_Table.goCueTime = trial_gocue;
Trial_Table.State = States;

%% Extract the EMG from the signal file

% Define the EMG names
EMG_names = struct([]);
EMG_names{1} = 'ABH';
EMG_names{2} = 'TA';
EMG_names{3} = 'SOL';

% Define the raw EMG
raw_EMG = struct([]);
for pp = 1:length(trial_num)
    raw_EMG{pp,1} = signal_file.values(:,1:3,pp);
end

% Sampling rate
samp_rate = length(raw_EMG{1}) / Trial_Length;

%% Generate the sig meta structure
sig = struct([]);

sig(1).meta = struct([]);
sig.meta(1).rawFileName = file_name(1:end-4);
sig.meta.date = Date;
sig.meta.task = Task;
sig.meta.subject = Subject;
sig.meta.side = Subject_Side;

% Bin width
bin_width = Trial_Length / length(raw_EMG{1});
sig.bin_width = bin_width;

% Trial info
sig.trial_info_table_header = table_header;
sig.trial_info_table = table2cell(Trial_Table);

% EMG names
sig.EMG_names = EMG_names;
% Raw EMG
sig.raw_EMG = raw_EMG;
% EMG
[EMG] = Raw_2_EMG(raw_EMG, samp_rate);
sig.EMG = EMG;



