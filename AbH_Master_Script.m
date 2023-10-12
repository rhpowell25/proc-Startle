%% Loading the SIG Files
clear
clc
close all 

% Group Name ('Control', 'SCI')
Group = 'Control';
% Subject Name
Subject = 'MA';
% What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
Task = 'StartReact';
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
Save_Figs = 0;
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
    % StartReact reaction times
    StartReact_Ind_Violin(sig, 1, 'png');
end

%% Baseline EMG analysis

[~] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_Figs);

%% MVC Plotting

% Do you want to overlay the force? ('Force', 'EMG')
Plot_Choice = 'EMG';

% Check that the MVC's make sense
Check_MVC(sig, Plot_Choice, muscle_group, Save_Figs)

% Per Trial MVC
[~, ~] = Trial_MVC(sig, Plot_Choice, muscle_group, Plot_Figs, Save_Figs);
% Average MVC
Avg_MVC(sig, Plot_Choice, muscle_group, Save_Figs)

% MVC peak amplitudes
MVC_Ind_Violin(sig, Plot_Choice, Plot_Figs, Save_Figs);

%% Peripheral Nerve Stimulation Plotting

% Do you want to plot the F-Waves or M-Max's ('F', 'M')
Wave_Choice = 'F';

% Per Trial peripheral nerve stimulation
[~] = Trial_PeriphStim(sig, muscle_group, Wave_Choice, Plot_Figs, Save_Figs);

% Peak to peak amplitudes
PeriphStim_Ind_Violin(sig, Wave_Choice, Plot_Figs, Save_Figs)

%% StartReact Plotting

% Check that the onset times make sense
Check_StartReact(sig, State, muscle_group, Save_Figs)

% Per Trial StartReact
[~, ~] = Trial_StartReact(sig, State, muscle_group, Plot_Figs, Save_Figs);
% Average StartReact
Avg_StartReact(sig, State, muscle_group, Save_Figs)
% Overlap EMG plotting
Overlap_StartReact(sig, muscle_group, Save_Figs)

% StartReact reaction times
StartReact_Ind_Violin(sig, Plot_Figs, Save_Figs);

%% StartMEP Plotting

% Check that the MEP's don't have too much noise
Check_StartMEP(sig, State, muscle_group, Save_Figs)

% Check the 
% Per Trial MEP's
[~, ~] = Trial_StartMEP(sig, State, muscle_group, Plot_Figs, Save_Figs);
% Average MEP's
[~, ~] = Avg_StartMEP(sig, State, muscle_group, Plot_Figs, Save_Figs);
% Overlap MEP plotting
Overlap_StartMEP(sig, muscle_group, Save_Figs)

% Startle MEP peak to peak amplitude
StartMEP_Ind_Violin(sig, muscle_group, Plot_Figs, Save_Figs)

%% Excel Generation

% Group Name ('Control', 'SCI')
Group = 'SCI';
% Save the matrix to Excel? (1 = Yes, 0 = No)
Save_Excel = 1;

% Load the subject details
[Subjects] = SIG_File_Details(Group);

StartReact_Excel(Group, Subjects, Save_Excel)
StartMEP_Excel(Group, Subjects, Save_Excel)

%% Summary Plotting (Group Comparisons)

% MVC
MVC_Group_Violin(Muscle, 'EMG', Save_Figs)
MVC_Group_Violin(Muscle, 'Force', Save_Figs)

% F-Waves
PeriphStim_Group_Violin(Muscle, 'F', Save_Figs)
% M-Max's
PeriphStim_Group_Violin(Muscle, 'M', Save_Figs)

% StartMEP
StartMEP_Group_Violin(Muscle, 'MEP', Save_Figs)
StartMEP_Group_Violin(Muscle, 'MEP+50ms', Save_Figs)
StartMEP_Group_Violin(Muscle, 'MEP+80ms', Save_Figs)
StartMEP_Group_Violin(Muscle, 'MEP+100ms', Save_Figs)

% StartReact
StartReact_Group_Violin(Muscle, 'RS', Save_Figs)
StartReact_Group_Violin(Muscle, 'Delta', Save_Figs)
StartReact_Group_Violin(Muscle, 'F', Save_Figs)
StartReact_Group_Violin(Muscle, 'F+s', Save_Figs)
StartReact_Group_Violin(Muscle, 'F+S', Save_Figs)

% Polar plots of Reticulospinal gain
for ii = 1:length(Subjects)
    [~] = Summary_PolarPlot(Group, Subjects{ii}, Save_Figs);
end

% Load the subject details
Group = 'SCI';
[Subjects] = SIG_File_Details(Group);
rxn_time = struct([]);
for ii = 1:length(Subjects)
    [rxn_time_excel, ~] = Load_AbH_Excel(Group, Subjects{ii}, 'StartReact', 'ABH', 'F');
    rxn_time{ii,1} = mean(rxn_time_excel{1,1}.rxn_time, 'omitnan');
end






