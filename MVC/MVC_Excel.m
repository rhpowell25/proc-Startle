function MVC_Excel(Group, Subjects, Save_Excel)

%% Some of the analysis specifications

Save_Path = strcat('C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Excel_Data\', Group, '\');

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
%EMG_Choice = 'Rect';

% Do you want to analyze the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Initialize the output variables
Muscle = {'ABH'};

%% Loop through the different experiments
for xx = 1:length(Subjects)

    %% Loop through each task
    for jj = 1:length(Muscle)
    
        %% Load the signal file
        [sig] = Load_SIG(Group, Subjects{xx}, 'MVC', Muscle{jj});

        % Skip the file if unable to load
        if ~isstruct(sig)
            continue
        end

        % Process the sig file
        [sig] = Process_SIG(sig);

        % Date
        Date = sig.meta.date;

        %% Indexes for rewarded trials

        % Convert to the trial table
        matrix_variables = sig.trial_info_table_header';
        trial_info_table = cell2table(sig.trial_info_table);
        trial_info_table.Properties.VariableNames = matrix_variables;

        % Indexes for rewarded trials
        rewarded_idxs = strcmp(trial_info_table.result, trial_choice);

        % Rewarded trial table
        Trial_Table = trial_info_table(rewarded_idxs, :);

        %% Extract the max MVC

        [~, all_trials_max_EMG, ~] = Trial_MVC(sig, 'EMG', Muscle{jj}, 0, 0);
        [~, all_trials_max_Force, ~] = Trial_MVC(sig, 'Force', Muscle{jj}, 0, 0);

        %% Create the excel table
    
        % Create the table addition
        excel_length = length(Trial_Table.number);
        excel_number = array2table(NaN(excel_length, 1));
        excel_number.Properties.VariableNames = {'Trial'};
        excel_number.Trial = Trial_Table.number;
        excel_EMG = array2table(NaN(excel_length, 1));
        excel_EMG.Properties.VariableNames = {'MVC_EMG'};
        excel_EMG.MVC_EMG = all_trials_max_EMG;
        excel_Force = array2table(NaN(excel_length, 1));
        excel_Force.Properties.VariableNames = {'MVC_Force'};
        excel_Force.MVC_Force = all_trials_max_Force;
    
        % Join the tables
        xds_excel = [excel_number excel_EMG excel_Force];
    
        %% Save to Excel
    
        if isequal(Save_Excel, 1)
    
            % Define the file name
            filename = char(strcat(sig.meta.task, '_', Muscle{jj}, '_', Date, '_', Subjects{xx,1}));
    
            % Save the file
            if ~exist(Save_Path, 'dir')
                mkdir(Save_Path);
            end
            writetable(xds_excel, strcat(Save_Path, filename, '.xlsx'))
    
        end

    end % End of the Task loop

end % End the Subject loop




