%% Loading the SIG Files
clear
clc
%close all 

% Group Name ('Control', 'SCI')
Group = 'SCI';
% Subject Name
Subject = 'PM';
% What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
Task = 'StartMEP';
% What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
Muscle = 'ABH';

% Load the sig file
[sig] = Load_SIG(Group, Subject, Task, Muscle);
% Process the sig file
[sig] = Process_SIG(sig);

% Analysis Specifications 

% Decide whether or not to plot (1 = Yes; 0 = No)
Plot_Figs = 1;
% Save the figures to desktop? ('pdf', 'png', 'fig', 0 = no)
Save_File = 0;
% What muscle groups do you want to look at? ('ABH', 'TA', 'SOL', 'QUAD', or 'All')
muscle_group = 'ABH';

% Select the state to analyze 
% StartReact ('F', 'F+s', 'F+S', 'All')
% StartMEP ('MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms')
State = 'All';

%% Load the subject details
% Group Name ('Control', 'SCI')
Group = 'SCI';
[Subjects] = SIG_File_Details(Group);
Task = 'StartReact';

for ii = 1:length(Subjects)
    [sig] = Load_SIG(Group, Subjects{ii}, Task, 'ABH');
    [sig] = Process_SIG(sig);
    %[~] = Trial_PeriphStim(sig, 'ABH', 'F', 1, 'png');
    %Check_MVC(sig, 'EMG', 'ABH', 0)
    Overlap_StartReact(sig, 'ABH', 0)
    %[~] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_Figs);
    %Overlap_StartMEP(sig, 'ABH', 'png')
end

%% Baseline EMG analysis

[~] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_File);

%% MVC Plotting

% Do you want to analyze the EMG or force? ('Force', 'EMG')
Plot_Choice = 'EMG';

% Check that the MVC's make sense
Check_MVC(sig, Plot_Choice, muscle_group, Save_File)

% Per Trial MVC
[~, ~] = Trial_MVC(sig, Plot_Choice, muscle_group, Plot_Figs, Save_File);
% Average MVC
Avg_MVC(sig, Plot_Choice, muscle_group, Save_File)

% MVC peak amplitudes
MVC_Ind_Violin(sig, Plot_Choice, Save_File);

%% Peripheral Nerve Stimulation Plotting

% Do you want to plot the F-Waves or M-Max's ('F', 'M')
Wave_Choice = 'F';

% Per Trial peripheral nerve stimulation
[~] = Trial_PeriphStim(sig, muscle_group, Wave_Choice, Plot_Figs, Save_File);

% Peak to peak amplitudes
PeriphStim_Ind_Violin(sig, Wave_Choice, Save_File)

%% StartReact Plotting

% Check that the onset times make sense
Check_StartReact(sig, State, muscle_group, Save_File)

% Per Trial StartReact
[~, ~] = Trial_StartReact(sig, State, muscle_group, Plot_Figs, Save_File);
% Average StartReact
Avg_StartReact(sig, State, muscle_group, Save_File)
% Overlap EMG plotting
Overlap_StartReact(sig, muscle_group, Save_File)

% StartReact reaction times
StartReact_Ind_Violin(sig, Save_File);

%% StartMEP Plotting

% Check that the MEP's don't have too much noise
Check_StartMEP(sig, State, muscle_group, Save_File)

% Check the 
% Per Trial MEP's
[~, ~] = Trial_StartMEP(sig, State, muscle_group, Plot_Figs, Save_File);
% Average MEP's
[~, ~] = Avg_StartMEP(sig, State, muscle_group, Plot_Figs, Save_File);
% Overlap MEP plotting
Overlap_StartMEP(sig, muscle_group, Save_File)

% Startle MEP peak to peak amplitude
StartMEP_Ind_Violin(sig, Save_File)

%% Excel Generation

% Group Name ('Control', 'SCI')
Group = 'Control';
% Save the matrix to Excel? (1 = Yes, 0 = No)
Save_Excel = 1;

% Load the subject details
[Subjects] = SIG_File_Details(Group);

MVC_Excel(Group, {'AW'}, Save_Excel)
StartReact_Excel(Group, {'AW'}, Save_Excel)
StartMEP_Excel(Group, {'HP'}, Save_Excel)

% Summary Excel
Excel_Summary(Group, Save_Excel)

%% Summary Plotting (Group Comparisons)

% Background EMG
BackgroundEMG_Group_Violin(Task, Muscle, Save_File)

% MVC
MVC_Group_Violin(Muscle, 'EMG', Save_File)
MVC_Group_Violin(Muscle, 'Force', Save_File)

% F-Waves
PeriphStim_Group_Violin(Muscle, 'F', Save_File)
% M-Max's
PeriphStim_Group_Violin(Muscle, 'M', Save_File)

% StartReact
StartReact_AVG_Violin(Muscle, Group, Save_File)
StartReact_Group_Violin(Muscle, 'RS', Save_File)
StartReact_Group_Violin(Muscle, 'Delta', Save_File)
StartReact_Group_Violin(Muscle, 'F', Save_File)
StartReact_Group_Violin(Muscle, 'F+s', Save_File)
StartReact_Group_Violin(Muscle, 'F+S', Save_File)
StartReact_Group_Line(Muscle, Save_File)

% StartMEP
StartMEP_AVG_Violin(Muscle, Group, Save_File)
StartMEP_Group_Violin(Muscle, 'MEP', Save_File)
StartMEP_Group_Violin(Muscle, 'MEP+50ms', Save_File)
StartMEP_Group_Violin(Muscle, 'MEP+80ms', Save_File)
StartMEP_Group_Violin(Muscle, 'MEP+100ms', Save_File)
StartMEP_Group_Line(Muscle, Save_File)

% Polar plots of Reticulospinal gain
for ii = 1:length(Subjects)
    [~] = Summary_PolarPlot(Group, Subjects{ii}, Save_File);
end

%% Summary Plotting (Group Comparisons)
clear
clc 

% Save the figures to desktop? ('pdf', 'png', 'fig', 0 = no)
Save_File = 0;

Sampling_Params = struct( ...
    'Group', 'All', ... % Group Name ('Control', 'SCI')
    'Subject', 'All', ... % Subject Name
    'Task', 'MVC', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', 'ABH', ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

AbH_Violin_Plot(Sampling_Params, Save_File)






