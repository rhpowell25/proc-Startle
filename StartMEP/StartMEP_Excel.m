function StartMEP_Excel(Group, Subjects, Save_Excel)

%% Some of the analysis specifications

Save_Path = strcat('Z:\Lab Members\Henry\AbH Startle\Excel_Data\', Group, '\');

% Do you want to analyze the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Initialize the output variables
Muscle = {'ABH'};

%% Loop through the different experiments
for xx = 1:length(Subjects)

    %% Loop through each task
    for jj = 1:length(Muscle)
    
        %% Load the signal file
        [sig] = Load_SIG(Group, Subjects{xx}, 'StartMEP', Muscle{jj});

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

        %% Extract the EMG & find its peak to peak amplitude
        [peaktopeak_MEP, ~] = Avg_StartMEP(sig, 'All', Muscle, 0, 0);
        peaktopeak_MEP = peaktopeak_MEP{1,1};
    
        %% Create the table addition

        excel_length = length(Trial_Table.number);
        excel_number = array2table(NaN(excel_length, 1));
        excel_number.Properties.VariableNames = {'Trial'};
        excel_number.Trial = Trial_Table.number;
        excel_state = array2table(NaN(excel_length, 1));
        excel_state.Properties.VariableNames = {'State'};
        excel_state.State = Trial_Table.State;
        excel_peaktopeak_MEP = array2table(NaN(excel_length, 1));
        excel_peaktopeak_MEP.Properties.VariableNames = {'peaktopeak_MEP'};
        excel_peaktopeak_MEP.peaktopeak_MEP = peaktopeak_MEP;
    
        % Join the tables
        xds_excel = [excel_number excel_state excel_peaktopeak_MEP];
    
        %% Save to Excel
    
        if isequal(Save_Excel, 1)
    
            % Define the file name
            filename = char(strcat(Date, '_', Subjects{xx,1}, '_', sig.meta.task, '_', Muscle{jj}));
    
            % Save the file
            if ~exist(Save_Path, 'dir')
                mkdir(Save_Path);
            end
            writetable(xds_excel, strcat(Save_Path, filename, '.xlsx'))
    
        end

    end % End of the Task loop

end % End the Subject loop




