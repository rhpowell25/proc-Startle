function [sig] = raw_to_SIG(params)
%% Extract the paramaters

Subject = params.Subject;
Date = params.Date;
Subject_Side = params.Subject_Side;
Task = params.Task;
Muscle = params.Muscle;
GoCue_Time = params.GoCue_Time;

%% Load the signal file & extract some basic information
[signal_file] = Load_Raw_SIG(params);

file_name = signal_file.file_name;
bin_width = signal_file.interval;
trial_length = bin_width * double(signal_file.points);

%% Extract trial numbers the signal file

trial_num = zeros(length(signal_file.frameinfo), 1);
for ii = 1:length(trial_num)
    trial_num(ii) = signal_file.frameinfo(ii).number;
end

%% Extract states the signal file

States = strings;
for ii = 1:length(trial_num)
    State = signal_file.frameinfo(ii).label;
    States{ii,1} = extractBefore(State, ' (s');
end

%% Extract trial start, gocue, & end time the signal file

trial_start = zeros(length(trial_num), 1);
trial_gocue = zeros(length(trial_num), 1);
trial_end = zeros(length(trial_num), 1);
trial_result = cell(length(trial_num),1);
for ii = 1:length(trial_num)
    trial_start(ii) = signal_file.frameinfo(ii).start;
    trial_gocue(ii) = trial_start(ii) + GoCue_Time;
    trial_end(ii) = trial_start(ii) + trial_length;
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

% How many channels do you want to extract
EMG_length = 3;

% Extract the EMG names
EMG_names = struct([]);
for pp = 1:EMG_length
    EMG_names{pp,1} = signal_file.chaninfo(pp).title;
end
% Extract the raw EMG
raw_EMG = struct([]);
for pp = 1:length(trial_num)
    raw_EMG{pp,1} = signal_file.values(:,1:EMG_length,pp);
end

% Sampling rate
samp_rate = double(signal_file.points) / trial_length;

%% Extract the force from the signal file
for ii = 1:length(signal_file.chaninfo)
    if strcmp(signal_file.chaninfo(ii).title, 'Force')
        Force_idx = ii;
        break
    else
        Force_idx = NaN;
    end
end

if ~isnan(Force_idx)
    Force = struct([]);
    for pp = 1:length(trial_num)
        Force{pp,1} = signal_file.values(:,Force_idx,pp);
    end
end

%% Generate the sig structure
sig = struct([]);

% Meta data
sig(1).meta = struct([]);
sig.meta(1).rawFileName = file_name(1:end-4);
sig.meta.date = Date;
sig.meta.task = Task;
sig.meta.muscle = Muscle;
sig.meta.subject = Subject;
sig.meta.side = Subject_Side;

% Bin width
sig.bin_width = bin_width;

% Truth values
sig.has_EMG = true;
if ~isnan(Force_idx)
    sig.has_force = true;
    sig.force = Force;
else
    sig.has_force = false;
end

% Trial info
sig.trial_info_table_header = table_header;
sig.trial_info_table = table2cell(Trial_Table);

% Add the trial information arrays
sig.trial_gocue_time = trial_gocue;
sig.trial_start_time = trial_start;
sig.trial_end_time = trial_end;
sig.trial_result = char(trial_result);

% EMG names
sig.EMG_names = EMG_names;
% Raw EMG
sig.raw_EMG = raw_EMG;
% EMG
[EMG] = Raw_2_EMG(raw_EMG, samp_rate);
sig.EMG = EMG;



