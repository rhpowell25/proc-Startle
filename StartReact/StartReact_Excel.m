function StartReact_Excel(Group, Subjects, Save_Excel)

%% Some of the analysis specifications

Save_Path = strcat('Z:\Lab Members\Henry\AbH Startle\Excel_Data\', Group, '\');

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Do you want to analyze the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Initialize the output variables
Muscle = {'ABH'};

%% Loop through the different experiments
for xx = 1:length(Subjects)

    %% Loop through each task
    for jj = 1:length(Muscle)
    
        %% Load the signal file
        [sig] = Load_SIG(Group, Subjects{xx}, 'StartReact', Muscle{jj});

        % Skip the file if unable to load
        if ~isstruct(sig)
            continue
        end

        % Process the sig file
        [sig] = Process_SIG(sig);

        % Bin size
        bin_width = sig.bin_width;

        % Date
        Date = sig.meta.date;

        %% Indexes for rewarded trials

        % Convert to the trial table
        matrix_variables = sig.trial_info_table_header';
        trial_info_table = cell2table(sig.trial_info_table);
        trial_info_table.Properties.VariableNames = matrix_variables;

        % Indexes for rewarded trials
        rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));

        % Rewarded trial table
        Trial_Table = trial_info_table(rewarded_idxs, :);
        gocue_times = Trial_Table.goCueTime - Trial_Table.startTime;

        %% Extract the EMG & find its onset

        % EMG extraction
        [~, EMG] = Extract_EMG(sig, EMG_Choice, Muscle, rewarded_idxs);

        % Find its onset
        [EMG_onset_idx] = EMGOnset(EMG);
    
        %% Find the EMG reaction times
        rxn_time = (EMG_onset_idx * bin_width) - gocue_times;
    
        % Create the table addition
        excel_length = length(Trial_Table.number);
        excel_number = array2table(NaN(excel_length, 1));
        excel_number.Properties.VariableNames = {'Trial'};
        excel_number.Trial = Trial_Table.number;
        excel_state = array2table(NaN(excel_length, 1));
        excel_state.Properties.VariableNames = {'State'};
        excel_state.State = Trial_Table.State;
        excel_rxn_time = array2table(NaN(excel_length, 1));
        excel_rxn_time.Properties.VariableNames = {'rxn_time'};
        excel_rxn_time.rxn_time = rxn_time;
    
        % Join the tables
        xds_excel = [excel_number excel_state excel_rxn_time];
    
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




