%% Loading the Signal Files
clear
clc
close all 

% Subject Name
Subject = 'EB';
% Select the date to analyze (YYYYMMDD)
Date = '20230602';
% What Task do you want to load? ('AbH_Flex', 'AbH_Abd', 'TA', or 'SOL')
Task = 'TA';

% Load the sig file
[sig] = Load_SIG(Subject, Date, Task);
% Process the sig file
[sig] = Process_SIG(sig);

%% Analysis Specifications 

% Decide whether or not to plot (1 = Yes; 0 = No)
Plot_Figs = 1;
% Save the figures to desktop? ('pdf', 'png', 'fig', 0 = no)
Save_Figs = 'png';
% What muscle groups do you want to look at? ('ABH', 'TA', 'SOL', or 'All')
muscle_group = 'TA';
% Select the state to analyze ('F', 'F+s', 'F+S', 'All')
State = 'F+S';

%% Run the EMG Plotting Functions

% Per Trial EMG
Per_Trial_SIG_EMG(sig, State, muscle_group, Save_Figs)

%% Average EMG
Trial_SIG_EMG(sig, State, muscle_group, Save_Figs)

% Overlap EMG plotting
OverlapSIGEMG(sig, muscle_group, Save_Figs)

%% Excel Generation

% Save the matrix to Excel? (1 = Yes, 0 = No)
Save_Excel = 1;

[Subjects, Dates] = Signal_File_Details;

Reaction_Time_Excel(Subjects, Dates, Save_Excel)

%% Summary Plotting 

for ii = 1:length(Subjects)
    [Task_Name, Delta_rxn_time, RS_Gain] = RS_Gain_Summary(Subjects{ii});
end

% Violin plot of Δ reaction time in each subject
for ii = 1:length(Subjects)
    Reaction_Time_ViolinPlot('ST', Plot_Figs, Save_Figs);
end

% Polar plots of Reticulospinal gain
for ii = 1:length(Subjects)
    [~] = Summary_PolarPlot(Subjects{ii}, Save_Figs);
end

% Violin plot of Δ reaction time across subjects
Summary_ViolinPlot(Subjects, Save_Figs)












