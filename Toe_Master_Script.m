%% Loading the Signal Files
clear
clc
close all 

% Group Name ('Control', 'SCI')
Group = 'SCI';
% Subject Name
Subject = 'PM';
% Select the date to analyze (YYYYMMDD)
Date = '20230909';
% What Task do you want to load? ('AbH_Flex', 'StartMEP', 'Fwaves')
Task = 'Fwave';

% Load the sig file
[sig] = Load_SIG(Group, Subject, Date, Task);
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
% StartReact ('F', 'F+s', 'F+S')
% F-Waves ('Fwaves')
% StartMEP ('MEP', 'MEP+50ms', 'MEP+80ms', 'MEP+100ms')
State = 'Fwaves';

%% Run the EMG Plotting Functions

% Plot MEP's
[peaktopeak_MEP] = StartMEP(sig, muscle_group, State, Plot_Figs, Save_Figs);

% Plot F-Waves
[peaktopeak_FWave] = F_Wave(sig, muscle_group, Plot_Figs, Save_Figs);

% Check that the onset times make sense
Check_EMG_Onset(sig, State, muscle_group, Save_Figs)

% Per Trial EMG
Trial_SIG_EMG(sig, State, muscle_group, Save_Figs)
% Average EMG
Avg_SIG_EMG(sig, State, muscle_group, Save_Figs)

% Overlap EMG plotting
OverlapSIGEMG(sig, muscle_group, Save_Figs)

%% Run the force plotting functions

% Average force
Trial_SIG_Force(sig, State, muscle_group, Save_Figs)

% Overlap force plotting
OverlapSIGForce(sig, Save_Figs)

%% Excel Generation

% Save the matrix to Excel? (1 = Yes, 0 = No)
Save_Excel = 1;

% Load the subject details
[Subjects, Dates] = Signal_File_Details(Group);

Reaction_Time_Excel(Group, Subjects, Dates, Save_Excel)

%% Summary Plotting 

% Load the data summaries
for ii = 1:length(Subjects)
    [Task_Name, Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Group, Subjects{ii});
end

% Violin plot of Δ reaction time in each subject (Comparing Conditions)
Reaction_Time_ViolinPlot(Group, 'All', Plot_Figs, Save_Figs);
for ii = 1:length(Subjects)
    Reaction_Time_ViolinPlot(Group, Subjects{ii}, Plot_Figs, Save_Figs);
end

% Startle MEP peak to peak amplitude
StartMEP_ViolinPlot(sig, Plot_Figs, Save_Figs)

% Violin plot of Δ reaction time across subjects
Summary_ViolinPlot(Group, Save_Figs)

%% Task Comparisons

% Reaction time histograms (Comparing Tasks)
State_Histogram(Group, State, Save_Figs)

% Polar plots of Reticulospinal gain
for ii = 1:length(Subjects)
    [~] = Summary_PolarPlot(Group, Subjects{ii}, Save_Figs);
end

% Comapare Task PCA
Check_Synergy(sig_task_one, sig_task_two, muscle_group, Save_Figs)








