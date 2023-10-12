function Check_MVC(sig, Plot_Choice, muscle_group, Save_Figs)

%% Display the function being used
disp('Check MVC Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to plot the rewarded or failed trials ('R' or 'F')
trial_choice = 'R';

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Bin width
bin_width = sig.bin_width;

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Font specifications
label_font_size = 15;
title_font_size = 15;
figure_width = 800;
figure_height = 700;

%% Indexes for rewarded trials

% Convert to the trial table
matrix_variables = sig.trial_info_table_header';
trial_info_table = cell2table(sig.trial_info_table);
trial_info_table.Properties.VariableNames = matrix_variables;

% Indexes for rewarded trials
rewarded_idxs = find(strcmp(trial_info_table.result, trial_choice));

%% Extract the EMG & Force

if isequal(Plot_Choice, 'EMG')
    [Plot_Names, Plot_Metric] = Extract_EMG(sig, EMG_Choice, muscle_group, rewarded_idxs);
end

% Extract the selected Force
if isequal(Plot_Choice, 'Force')
    Plot_Names = {'Force'};
    [Plot_Metric] = Extract_Force(sig, 1, 1, rewarded_idxs);
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(Plot_Metric{1,1}));

%% Putting all succesful trials in one array

per_trial_Plot_Metric = struct([]);
if isequal(Plot_Choice, 'EMG')
    for ii = 1:length(Plot_Names)
        per_trial_Plot_Metric{ii,1} = zeros(length(Plot_Metric{1,1}),length(Plot_Metric));
        for mm = 1:length(Plot_Metric)
            per_trial_Plot_Metric{ii,1}(:,mm) = Plot_Metric{mm}(:, ii);
        end
    end
elseif isequal(Plot_Choice, 'Force')
    for ii = 1:length(Plot_Metric)
        per_trial_Plot_Metric{1,1}(:,ii) = Plot_Metric{ii}(:,1);
    end
end

%% Plot the individual EMG traces on the top

fig_titles = struct([]);
ss = 1;

for ii = 1:width(per_trial_Plot_Metric{1})

    EMG_figure = figure;
    EMG_figure.Position = [300 75 figure_width figure_height];
    hold on

    for pp = 1:length(Plot_Names)

        subplot(length(Plot_Names),1,pp)
        hold on
    
        % Titling the plot
        Trial_num = trial_info_table.number(rewarded_idxs(ii));
        EMG_title = strcat(Plot_Names{pp}, {' '}, num2str(Trial_num));
        fig_titles{ss} = strcat('MVC:', {' '}, EMG_title{1});
        title(fig_titles{ss}, 'FontSize', title_font_size)
    
        % Labels
        if isequal(Plot_Choice, 'EMG')
            ylabel('EMG (mV)', 'FontSize', label_font_size);
        elseif isequal(Plot_Choice, 'Force')
            ylabel('Force (N)', 'FontSize', label_font_size);
        end
        xlabel('Time (sec.)', 'FontSize', label_font_size);

        % Plot the EMG
        plot(absolute_timing, per_trial_Plot_Metric{pp}(:,ii))

        % Plot the force
        if isequal(Plot_Choice, 1)
            plot(absolute_timing, per_trial_Plot_Metric{1}(:,pp))
        end

        % Horizontal line indicating max
        EMG_max = max(per_trial_Plot_Metric{pp}(:,ii));
        line([absolute_timing(1) absolute_timing(end)], [EMG_max EMG_max], ... 
        'LineStyle','--', 'Color', 'k')

        ss = ss + 1;

    end % End of the individual trial loop

end % End of the muscle loop

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0)
    save_dir = 'C:\Users\rpowell\Desktop\';
    for ii = 1:numel(findobj('type','figure'))
        save_title = strrep(fig_titles{ii}, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
        save_title = strrep(save_title, '[', '_');
        save_title = strrep(save_title, ']', '_');
        if ~strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), Save_Figs)
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'fig')
        end
        close gcf
    end
end
