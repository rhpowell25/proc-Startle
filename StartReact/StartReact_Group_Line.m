function StartReact_Group_Line(Muscle, Save_File)

%% Basic Settings, some variable extractions, & definitions

Sampling_Params = struct( ...
    'Subject', 'All', ... % Subject Name
    'Task', 'StartReact', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
    'Muscle', Muscle, ... % What Muscle do you want to load? ('ABH', 'TA', 'SOL', 'QUAD')
    'State', 'All', ... % Select the state to analyze 
    'trial_sessions', 'Ind'); % Individual Sessions or All Sessions? ('Ind' vs 'All')

% Font & plotting specifications
[Plot_Params] = Plot_Parameters;
axis_expansion = 0.05;

% Scatter Marker size & shape
sz = 2500;
marker_metric = '.';

% Close all previously open figures if you're saving 
if ~isequal(Save_File, 0)
    close all
end

%% Extract the control StartMEP metrics

Sampling_Params.Group = 'Control';
[AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
con_ind_StartReact = zeros(length(AbH_excel), 3);
for ii = 1:length(AbH_excel)
    rxn_idx = contains(AbH_excel{ii,1}.Properties.VariableNames, 'rxn_time');
    % F
    F_idxs = strcmp(AbH_excel{ii,1}.State, 'F');
    con_ind_StartReact(ii,1) = mean(table2array(AbH_excel{ii,1}(F_idxs, rxn_idx)));
    % F+s
    Fs_idxs = strcmp(AbH_excel{ii,1}.State, 'F+s');
    con_ind_StartReact(ii,2) = mean(table2array(AbH_excel{ii,1}(Fs_idxs, rxn_idx)));
    % F+S
    FS_idxs = strcmp(AbH_excel{ii,1}.State, 'F+S');
    con_ind_StartReact(ii,3) = mean(table2array(AbH_excel{ii,1}(FS_idxs, rxn_idx)));
end
con_err_StartReact = std(con_ind_StartReact, 'omitnan') / sqrt(length(con_ind_StartReact));
con_avg_StartReact = mean(con_ind_StartReact, 'omitnan');

%% Extract the SCI StartMEP metrics

Sampling_Params.Group = 'SCI';
[AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
SCI_ind_StartReact = zeros(length(AbH_excel), 3);
for ii = 1:length(AbH_excel)
    rxn_idx = contains(AbH_excel{ii,1}.Properties.VariableNames, 'rxn_time');
    % F
    F_idxs = strcmp(AbH_excel{ii,1}.State, 'F');
    SCI_ind_StartReact(ii,1) = mean(table2array(AbH_excel{ii,1}(F_idxs, rxn_idx)));
    % F+s
    Fs_idxs = strcmp(AbH_excel{ii,1}.State, 'F+s');
    SCI_ind_StartReact(ii,2) = mean(table2array(AbH_excel{ii,1}(Fs_idxs, rxn_idx)));
    % F+S
    FS_idxs = strcmp(AbH_excel{ii,1}.State, 'F+S');
    SCI_ind_StartReact(ii,3) = mean(table2array(AbH_excel{ii,1}(FS_idxs, rxn_idx)));
end
SCI_err_StartReact = std(SCI_ind_StartReact, 'omitnan') / sqrt(length(SCI_ind_StartReact));
SCI_avg_StartReact = mean(SCI_ind_StartReact, 'omitnan');

%% Find the y-axis limits & determine title & y-lablel

% Y-axis
y_max = max([con_avg_StartReact + con_err_StartReact; ...
    SCI_avg_StartReact + SCI_err_StartReact], [], 'all') + axis_expansion;
y_min = min([con_avg_StartReact - con_err_StartReact; ...
    SCI_avg_StartReact - SCI_err_StartReact], [], 'all') - axis_expansion;

%% Plot the Violin Plot

plot_fig = figure;
plot_fig.Position = [500 5 Plot_Params.fig_size Plot_Params.fig_size / 2];
hold on

% Title
Fig_Title = 'StartReact:';
%title(Fig_Title, 'FontSize', Plot_Params.title_font_size, 'Interpreter', 'none');

% Labels
xlabel('StartReact Condition', 'FontSize', Plot_Params.label_font_size)
ylabel('Reaction Time', 'FontSize', Plot_Params.label_font_size)

% Plot
for ii = 1:length(con_avg_StartReact)
    scatter(ii, con_avg_StartReact(ii), sz, marker_metric, 'MarkerEdgeColor', ... 
                [0.85 0.325 0.098], 'MarkerFaceColor', [0.85 0.325 0.098])
    % Error
    err_con = errorbar(ii, con_avg_StartReact(ii), ... 
            con_err_StartReact(ii), 'vertical', 'CapSize',18);
    err_con.Color = [0.85 0.325 0.098];
        err_con.LineWidth = Plot_Params.mean_line_width;
end
for ii = 1:length(SCI_avg_StartReact)
    scatter(ii, SCI_avg_StartReact(ii), sz, marker_metric, 'MarkerEdgeColor', ... 
                [0 0.447 0.741], 'MarkerFaceColor', [0 0.447 0.741])
    % Error
    err_SCI = errorbar(ii, SCI_avg_StartReact(ii), ... 
            SCI_err_StartReact(ii), 'vertical', 'CapSize',18);
    err_SCI.Color = [0 0.447 0.741];
        err_SCI.LineWidth = Plot_Params.mean_line_width;
end

% Plot dummy points for the legend
dummy_con = plot(-1, -1, marker_metric, 'MarkerSize', Plot_Params.legend_size + 10, ...
    'MarkerEdgeColor',[0.85 0.325 0.098], 'MarkerFaceColor', [0.85 0.325 0.098], ...
    'LineWidth', Plot_Params.mean_line_width);
dummy_SCI = plot(-2, -2, marker_metric, 'MarkerSize', Plot_Params.legend_size + 10, ...
    'MarkerEdgeColor',[0 0.447 0.741], 'MarkerFaceColor', [0 0.447 0.741], ...
    'LineWidth', Plot_Params.mean_line_width);

% Set the axis-limits
xlim([0 length(con_avg_StartReact) + 1]);
ylim([y_min - axis_expansion y_max + axis_expansion]);

% Plot the legend
legend([dummy_con, dummy_SCI], {'Control','SCI'}, ...
    'FontSize', Plot_Params.legend_size, 'Location', 'southwest');
legend boxoff

% Increase the font size
set(gca,'fontsize', Plot_Params.label_font_size)
set(gca,'linewidth', Plot_Params.mean_line_width - 2)

% Axis Editing
figure_axes = gca;
% Set ticks to outside
set(figure_axes,'TickDir','out');
% Remove the top and right tick marks
set(figure_axes,'box','off')

% Replace tick labels
y_labels = string(figure_axes.YAxis.TickLabels);
x_labels = string(figure_axes.XAxis.TickLabels);
y_labels(2:2:end) = NaN;
for ii = 1:length(x_labels)
    if strcmp(x_labels{ii}, '1')
        x_labels(ii) = 'F';
    elseif strcmp(x_labels{ii}, '2')
        x_labels(ii) = 'F+s';
    elseif strcmp(x_labels{ii}, '3')
        x_labels(ii) = 'F+S';
    else
        x_labels(ii) = NaN;
    end
end
figure_axes.YAxis.TickLabels = y_labels;
figure_axes.XAxis.TickLabels = x_labels;

%% Statistics

column_height = max(height(con_ind_StartReact), height(SCI_ind_StartReact));

StartReact = NaN(column_height, 2*width(con_ind_StartReact));
for ii = 1:width(con_ind_StartReact)
    StartReact(1:height(con_ind_StartReact),ii) = con_ind_StartReact(:, ii);
    StartReact(1:height(SCI_ind_StartReact),(ii+width(con_ind_StartReact))) = ...
        SCI_ind_StartReact(:, ii);
end


[~,~,stats] = anova2(StartReact);
%ranovatbl = ranova(StartReact);
%stats = anova(StartReact);
figure
hold on
[c,~,~,gnames] = multcompare(stats);

% Do the statistics
[~, con_fifty_p_val] = ttest2(con_ind_StartReact(:,1) - 1, zeros(length(con_ind_StartReact(:,1)), 1));
[~, con_eighty_p_val] = ttest2(con_ind_StartReact(:,2) - 1, zeros(length(con_ind_StartReact(:,2)), 1));
[~, SCI_fifty_p_val] = ttest2(SCI_ind_StartReact(:,1) - 1, zeros(length(SCI_ind_StartReact(:,1)), 1));
[~, SCI_eighty_p_val] = ttest2(SCI_ind_StartReact(:,2) - 1, zeros(length(SCI_ind_StartReact(:,2)), 1));

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)








