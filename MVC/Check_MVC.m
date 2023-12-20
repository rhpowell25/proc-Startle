function Check_MVC(sig, Plot_Choice, Muscle, Save_File)

%% Display the function being used
disp('Check MVC Function:');

%% Basic Settings, some variable extractions, & definitions

% Do you want to use the raw EMG or processed EMG? ('Raw', 'Rect', 'Proc')
EMG_Choice = 'Rect';

% Bin width
bin_width = sig.bin_width;

% Window to calculate the peak MVC
half_window_time = 0.5; % Sec.
half_window_size = half_window_time / bin_width; % Bins
step_size = 1; % Bins

trial_length = length(sig.raw_EMG{1})*bin_width; % Sec.

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Indexes for rewarded trials

% Indexes for rewarded trials
[rewarded_idxs] = Rewarded_Indexes(sig, NaN, NaN);

%% Extract the EMG / Force

if strcmp(Plot_Choice, 'EMG') % Extract EMG
    [Plot_Names, Plot_Metric] = Extract_EMG(sig, EMG_Choice, Muscle, rewarded_idxs);
elseif strcmp(Plot_Choice, 'Force') % Extract Force
    Plot_Names = {'Force'};
    [Plot_Metric] = Extract_Force(sig, 1, 1, rewarded_idxs);
elseif strcmp(Plot_Choice, 'Both') % Extract both
    [Plot_Names, Plot_Metric] = Extract_EMG(sig, EMG_Choice, Muscle, rewarded_idxs);
    Plot_Names = cat(1, Plot_Names, 'Force');
    [Force] = Extract_Force(sig, 1, 1, rewarded_idxs);
    for ii = 1:length(Plot_Metric)
        Plot_Metric{ii} = cat(2, Plot_Metric{ii}, Force{ii});
    end
end

%% Find the average peak of each MVC

if strcmp(Plot_Choice, 'Force')
    MVC_idx = 1;
else
    MVC_idx = find(strcmp(Plot_Names, sig.meta.muscle));
end

MVC_max = zeros(length(Plot_Metric), 1);
MVC_max_idx = struct([]);
for ii = 1:length(Plot_Metric)
    % Sliding average
    [sliding_avg, ~, array_idxs] = ...
        Sliding_Window(Plot_Metric{ii,1}(:,MVC_idx), half_window_size, step_size);
    % Find the max MVC
    temp_1 = array_idxs(sliding_avg == max(sliding_avg));
    MVC_max_idx{ii,1} = temp_1{1};
    temp_2 = sliding_avg(sliding_avg == max(sliding_avg));
    MVC_max(ii) = temp_2(1);
end

%% Define the absolute timing
absolute_timing = linspace(0, trial_length, length(Plot_Metric{1,1}));

%% Putting all succesful trials in one array

per_trial_Plot_Metric = struct([]);
if strcmp(Plot_Choice, 'EMG') || strcmp(Plot_Choice, 'Both')
    for ii = 1:length(Plot_Names)
        per_trial_Plot_Metric{ii,1} = zeros(length(Plot_Metric{1,1}),length(Plot_Metric));
        for mm = 1:length(Plot_Metric)
            per_trial_Plot_Metric{ii,1}(:,mm) = Plot_Metric{mm}(:, ii);
        end
    end
elseif strcmp(Plot_Choice, 'Force')
    for ii = 1:length(Plot_Metric)
        per_trial_Plot_Metric{1,1}(:,ii) = Plot_Metric{ii}(:,1);
    end
end

%% Plot the individual EMG traces on the top

for ii = 1:width(per_trial_Plot_Metric{1})

    EMG_figure = figure;
    EMG_figure.Position = [300 5 Plot_Params.fig_size Plot_Params.fig_size];
    
    hold on

    for pp = 1:length(Plot_Names)

        subplot(length(Plot_Names),1,pp)
        hold on
    
        % Titling the plot
        Trial_num = trial_info_table.number(rewarded_idxs(ii));
        EMG_title = strcat(Plot_Names{pp}, {' '}, num2str(Trial_num));
        Fig_Title = strcat('MVC:', {' '}, EMG_title{1});
        title(Fig_Title, 'FontSize', Plot_Params.title_font_size)
    
        % Labels
        if strcmp(Plot_Choice, 'EMG')
            y_label = 'EMG';
            y_unit = 'mV';
            line_color = 'b';
        elseif strcmp(Plot_Choice, 'Force')
            y_label = 'Force';
            y_unit = 'N';
            line_color = 'k';
        elseif strcmp(Plot_Choice, 'Both')
            y_label = 'EMG';
            y_unit = 'mV';
            line_color = 'b';
            if isequal(pp, length(Plot_Names))
                y_label = 'Force';
                y_unit = 'N';
                line_color = 'k';
            end
        end
        ylabel(strcat(y_label, {' '}, '(', y_unit, ')'), 'FontSize', Plot_Params.label_font_size);
        xlabel('Time (sec.)', 'FontSize', Plot_Params.label_font_size);

        % Plot the EMG
        Metric_Line = plot(absolute_timing, per_trial_Plot_Metric{pp}(:,ii), line_color, ...
            'LineWidth', Plot_Params.mean_line_width);

        % Find the y_limits
        y_limits = ylim;

        % Horizontal line indicating max
        if pp == MVC_idx
            line([absolute_timing(MVC_max_idx{ii,1}(1)) absolute_timing(MVC_max_idx{ii,1}(1))], ...
                [y_limits(1) y_limits(end)], 'LineWidth', Plot_Params.mean_line_width, ...
                'LineStyle','--', 'Color', 'r')
            line([absolute_timing(MVC_max_idx{ii,1}(end)) absolute_timing(MVC_max_idx{ii,1}(end))], ...
                [y_limits(1) y_limits(end)], 'LineWidth', Plot_Params.mean_line_width, ...
                'LineStyle','--', 'Color', 'r')
        end

        if pp >= (length(Plot_Names) - 1)
            Axes_Legend('sec', y_unit)
        end

        % Legend
        legend(Metric_Line, Plot_Names{pp}, 'NumColumns', 1, 'FontName', Plot_Params.font_name, ...
            'Location', 'NorthWest', 'FontSize', Plot_Params.legend_size)
        % Remove the legend's outline
        legend boxoff

        % Set the axis
        %ylim([0 2])
        ylim([y_limits(1) y_limits(end)])
        %xlim([0.5 4])
        ss = ss + 1;

        % Remove the original axes
        title('')
        set(gca,'XColor', 'none', 'YColor','none')
        set(gca, 'color', 'none');

        % Axis Editing
        figure_axes = gca;
        % Set ticks to outside
        set(figure_axes,'TickDir','out');
        % Remove the top and right tick marks
        set(figure_axes,'box','off')
        
        % Replace tick labels
        x_labels = string(figure_axes.XAxis.TickLabels);
        y_labels = string(figure_axes.YAxis.TickLabels);
        x_labels(1:2:end) = NaN;
        y_labels(1:2:end) = NaN;
        figure_axes.XAxis.TickLabels = x_labels;
        figure_axes.YAxis.TickLabels = y_labels;

    %% Save the file if selected
    Save_Figs(Fig_Title, Save_File)

    end % End of the individual trial loop

end % End of the muscle loop
