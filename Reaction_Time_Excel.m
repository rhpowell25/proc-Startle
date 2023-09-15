function Reaction_Time_Excel(Group, Subjects, Dates, Save_Excel)

%% Some of the analysis specifications

Save_Path = strcat('C:\Users\rhpow\Documents\Work\AbilityLab\Perez Lab\Excel_Data\', Group, '\');

% Do you want to use the raw EMG or processed EMG? ('Raw', or 'Proc')
EMG_Choice = 'Raw';

% Do you want to analyze the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Initialize the output variables
Tasks = {'AbH_Flex'; 'AbH_Abd'; 'Plantar'; 'TA'; 'SOL'};

%% Loop through the different experiments
for xx = 1:length(Dates)

    %% Loop through each task
    for jj = 1:length(Tasks)
    
        %% Load the signal file
        [sig] = Load_SIG(Group, Subjects{xx}, Dates{xx}, Tasks{jj});

        % Skip the file if unable to load
        if ~isstruct(sig)
            continue
        end

        % Process the sig file
        [sig] = Process_SIG(sig);

        % Bin size
        bin_width = sig.bin_width;
        
        % What muscle groups do you want to look at? ('ABH', 'TA', 'SOL', or 'All')
        if contains(Tasks{jj}, 'Flex') || contains(Tasks{jj}, 'Abd') || contains(Tasks{jj}, 'Plantar')
            muscle_group = 'ABH';
        else
            muscle_group = Tasks{jj};
        end

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
        if strcmp(EMG_Choice, 'Raw')
            raw_EMG = sig.raw_EMG;
            % DC removal of the EMG
            Zeroed_EMG = struct([]);
            for ii = 1:length(raw_EMG)
                for pp = 1:width(raw_EMG{ii})
                    Zeroed_EMG{ii}(:,pp) = raw_EMG{ii}(:,pp) - mean(raw_EMG{ii}(:,pp));
                end
            end
            % Rectify the EMG
            Rect_EMG = struct([]);
            for ii = 1:length(Zeroed_EMG)
                for pp = 1:width(Zeroed_EMG{ii})
                    Rect_EMG{ii,1}(:,pp) = abs(Zeroed_EMG{ii}(:,pp));
                end
            end
        else
            Rect_EMG = sig.EMG;
        end
        
        % Use only the selected EMG
        if ~strcmp(muscle_group, 'All')
            EMG_name_idx = find(strcmp(sig.EMG_names, muscle_group));
        else
            EMG_name_idx = 1:length(sig.EMG_names);
        end
        
        % Extract the selected EMG
        EMG = struct([]);
        for ii = 1:length(rewarded_idxs)
            EMG{ii,1} = Rect_EMG{rewarded_idxs(ii)}(:,EMG_name_idx);
        end
        
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
            filename = char(strcat(Dates{xx,1}, '_', Subjects{xx,1}, '_', Tasks{jj}));
    
            % Save the file
            if ~exist(Save_Path, 'dir')
                mkdir(Save_Path);
            end
            writetable(xds_excel, strcat(Save_Path, filename, '.xlsx'))
    
        end

    end % End of the Task loop

end % End the Date loop




