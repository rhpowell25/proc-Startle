%% Loading the Signal Files
clear
clc
close all 

% Group Name ('Control', 'SCI')
Group = 'SCI';
% Subject Name
Subject = 'JW';
% What Task do you want to load? ('StartReact', 'StartMEP', 'FWave')
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
Save_Figs = 'png';
% What muscle groups do you want to look at? ('ABH', 'TA', 'SOL', 'QUAD', or 'All')
muscle_group = 'ABH';

% Select the state to analyze 
% StartReact ('F', 'F+s', 'F+S', 'All')
% StartMEP ('MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms')
State = 'F';

%Check_StartReact(sig, State, muscle_group, Save_Figs)
Overlap_StartReact(sig, muscle_group, Save_Figs)
StartReact_Ind_Violin(sig, Plot_Figs, Save_Figs);
%% Load the subject details
% Group Name ('Control', 'SCI')
Group = 'SCI';
[Subjects] = SIG_File_Details(Group);
Task = 'StartReact';

for ii = 1:length(Subjects)
    [sig] = Load_SIG(Group, Subjects{ii}, Task, 'ABH');
    [sig] = Process_SIG(sig);
    Overlap_StartReact(sig, muscle_group, Save_Figs)
    StartReact_Ind_Violin(sig, Plot_Figs, Save_Figs);
end

%% Baseline EMG analysis

[~] = Baseline_EMG(sig, muscle_group, Plot_Figs, Save_Figs);

%% Peripheral Nerve Stimulation Plotting

% Plot F-Waves
[~] = Periph_Stim(sig, muscle_group, 'F', Plot_Figs, Save_Figs);
% Plot M-Max's
[~] = Periph_Stim(sig, muscle_group, 'M', Plot_Figs, Save_Figs);

%% StartReact Plotting

% Check that the onset times make sense
Check_StartReact(sig, State, muscle_group, Save_Figs)

% Per Trial EMG
[~, ~] = Trial_StartReact(sig, State, muscle_group, Plot_Figs, Save_Figs);
% Average EMG
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
StartMEP_BoxPlot(sig, muscle_group, Plot_Figs, Save_Figs)

%% Run the force plotting functions

% Average force
Trial_SIG_Force(sig, State, muscle_group, Save_Figs)

% Overlap force plotting
OverlapSIGForce(sig, Save_Figs)

%% Excel Generation

% Group Name ('Control', 'SCI')
Group = 'SCI';
% Save the matrix to Excel? (1 = Yes, 0 = No)
Save_Excel = 1;

% Load the subject details
[Subjects] = SIG_File_Details(Group);

StartReact_Excel(Group, Subjects, Save_Excel)

%% Summary Plotting (Group Comparisons)

% F-Waves
Periph_Stim_BoxPlot(Muscle, 'F', Save_Figs)
% M-Max's
Periph_Stim_BoxPlot(Muscle, 'M', Save_Figs)

% StartMEP
StartMEP_ViolinPlot(Muscle, 'MEP', Save_Figs)
StartMEP_ViolinPlot(Muscle, 'MEP+50ms', Save_Figs)
StartMEP_ViolinPlot(Muscle, 'MEP+80ms', Save_Figs)
StartMEP_ViolinPlot(Muscle, 'MEP+100ms', Save_Figs)

% StartReact
StartReact_Group_Violin(Muscle, 'RS', Save_Figs)
StartReact_Group_Violin(Muscle, 'Delta', Save_Figs)
StartReact_Group_Violin(Muscle, 'F', Save_Figs)
StartReact_Group_Violin(Muscle, 'F+s', Save_Figs)
StartReact_Group_Violin(Muscle, 'F+S', Save_Figs)

% Violin plot of Δ reaction time across subjects
Summary_ViolinPlot(Group, Save_Figs)

% Polar plots of Reticulospinal gain
for ii = 1:length(Subjects)
    [~] = Summary_PolarPlot(Group, Subjects{ii}, Save_Figs);
end









