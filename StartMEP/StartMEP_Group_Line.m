function StartMEP_Group_Line(Muscle, Save_File)

%% Basic Settings, some variable extractions, & definitions

% Do you want to exclude the 100 ISI
exclude_hund = 1;

Sampling_Params = struct( ...
    'Subject', 'All', ... % Subject Name
    'Task', 'StartMEP', ... % What Task do you want to load? ('MVC', 'FWave', 'StartReact', 'StartMEP')
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
con_ind_StartMEP = zeros(length(AbH_excel), 3);
for ii = 1:length(AbH_excel)
    Muscle_idx = contains(AbH_excel{ii,1}.Properties.VariableNames, Muscle);
    % MEP
    MEP_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP');
    avg_MEP = table2array(mean(AbH_excel{ii,1}(MEP_idxs, Muscle_idx)));
    % MEP + 50
    fifty_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+50ms');
    fifty_amps = table2array(AbH_excel{ii,1}(fifty_idxs, Muscle_idx));
    con_ind_StartMEP(ii,1) = mean(fifty_amps / avg_MEP);
    % MEP + 80
    eighty_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+80ms');
    eighty_amps = table2array(AbH_excel{ii,1}(eighty_idxs, Muscle_idx));
    con_ind_StartMEP(ii,2) = mean(eighty_amps / avg_MEP);
    % MEP + 100
    hund_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+100ms');
    hund_amps = table2array(AbH_excel{ii,1}(hund_idxs, Muscle_idx));
    con_ind_StartMEP(ii,3) = mean(hund_amps / avg_MEP);
end
con_err_StartMEP = std(con_ind_StartMEP, 'omitnan') / sqrt(length(con_ind_StartMEP));
con_avg_StartMEP = mean(con_ind_StartMEP, 'omitnan');

%% Extract the SCI StartMEP metrics

Sampling_Params.Group = 'SCI';
[AbH_excel, ~] = Load_AbH_Excel(Sampling_Params);
SCI_ind_StartMEP = zeros(length(AbH_excel), 3);
for ii = 1:length(AbH_excel)
    Muscle_idx = contains(AbH_excel{ii,1}.Properties.VariableNames, Muscle);
    % MEP
    MEP_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP');
    avg_MEP = table2array(mean(AbH_excel{ii,1}(MEP_idxs, Muscle_idx)));
    % MEP + 50
    fifty_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+50ms');
    fifty_amps = table2array(AbH_excel{ii,1}(fifty_idxs, Muscle_idx));
    SCI_ind_StartMEP(ii,1) = mean(fifty_amps / avg_MEP);
    % MEP + 80
    eighty_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+80ms');
    eighty_amps = table2array(AbH_excel{ii,1}(eighty_idxs, Muscle_idx));
    SCI_ind_StartMEP(ii,2) = mean(eighty_amps / avg_MEP);
    % MEP + 100
    hund_idxs = strcmp(AbH_excel{ii,1}.State, 'MEP+100ms');
    hund_amps = table2array(AbH_excel{ii,1}(hund_idxs, Muscle_idx));
    SCI_ind_StartMEP(ii,3) = mean(hund_amps / avg_MEP);
end
SCI_err_StartMEP = std(SCI_ind_StartMEP, 'omitnan') / sqrt(length(SCI_ind_StartMEP));
SCI_avg_StartMEP = mean(SCI_ind_StartMEP, 'omitnan');

%% Find the y-axis limits & determine title & y-lablel

if exclude_hund == 1
    con_ind_StartMEP(:,3) = [];
    SCI_ind_StartMEP(:,3) = [];
    con_avg_StartMEP(3) = [];
    con_err_StartMEP(3) = [];
    SCI_avg_StartMEP(3) = [];
    SCI_err_StartMEP(3) = [];
end

% Y-axis
y_max = max([con_avg_StartMEP + con_err_StartMEP; ...
    SCI_avg_StartMEP + SCI_err_StartMEP], [], 'all') + axis_expansion;
y_min = min([con_avg_StartMEP - con_err_StartMEP; ...
    SCI_avg_StartMEP - SCI_err_StartMEP], [], 'all') - axis_expansion;

%% Plot the Violin Plot

plot_fig = figure;
plot_fig.Position = [500 25 Plot_Params.fig_size Plot_Params.fig_size / 2];
hold on

% Title
Fig_Title = 'Normalized StartMEP:';
%title(Fig_Title, 'FontSize', Plot_Params.title_font_size, 'Interpreter', 'none');

% Labels
xlabel('Startle ISI', 'FontSize', Plot_Params.label_font_size)
ylabel('StartMEP / MEP', 'FontSize', Plot_Params.label_font_size)

% Plot
for ii = 1:length(con_avg_StartMEP)
    scatter(ii, con_avg_StartMEP(ii), sz, marker_metric, 'MarkerEdgeColor', ... 
                [0.85 0.325 0.098], 'MarkerFaceColor', [0.85 0.325 0.098])
    % Error
    err_con = errorbar(ii, con_avg_StartMEP(ii), ... 
            con_err_StartMEP(ii), 'vertical', 'CapSize',18);
    err_con.Color = [0.85 0.325 0.098];
        err_con.LineWidth = Plot_Params.mean_line_width;
end
for ii = 1:length(SCI_avg_StartMEP)
    scatter(ii, SCI_avg_StartMEP(ii), sz, marker_metric, 'MarkerEdgeColor', ... 
                [0 0.447 0.741], 'MarkerFaceColor', [0 0.447 0.741])
    % Error
    err_SCI = errorbar(ii, SCI_avg_StartMEP(ii), ... 
            SCI_err_StartMEP(ii), 'vertical', 'CapSize',18);
    err_SCI.Color = [0 0.447 0.741];
        err_SCI.LineWidth = Plot_Params.mean_line_width;
end

% Line at the 100% 
line([0 length(con_avg_StartMEP) + 1], [1 1], ... 
    'LineStyle','--', 'Color', 'k', 'LineWidth', Plot_Params.mean_line_width)

% Plot dummy points for the legend
dummy_con = plot(-1, -1, marker_metric, 'MarkerSize', Plot_Params.legend_size + 10, ...
    'MarkerEdgeColor',[0.85 0.325 0.098], 'MarkerFaceColor', [0.85 0.325 0.098], ...
    'LineWidth', Plot_Params.mean_line_width);
dummy_SCI = plot(-2, -2, marker_metric, 'MarkerSize', Plot_Params.legend_size + 10, ...
    'MarkerEdgeColor',[0 0.447 0.741], 'MarkerFaceColor', [0 0.447 0.741], ...
    'LineWidth', Plot_Params.mean_line_width);

% Set the axis-limits
xlim([0 length(con_avg_StartMEP) + 1]);
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
        x_labels(ii) = '50';
    elseif strcmp(x_labels{ii}, '2')
        x_labels(ii) = '80';
    elseif strcmp(x_labels{ii}, '3') && exclude_hund == 0
        x_labels(ii) = '100';
    else
        x_labels(ii) = NaN;
    end
end
figure_axes.YAxis.TickLabels = y_labels;
figure_axes.XAxis.TickLabels = x_labels;

%% Statistics

column_height = max(height(con_ind_StartMEP), height(SCI_ind_StartMEP));

StartMEP = NaN(column_height, 2*width(con_ind_StartMEP));
for ii = 1:width(con_ind_StartMEP)
    StartMEP(1:height(con_ind_StartMEP),ii) = con_ind_StartMEP(:, ii);
    StartMEP(1:height(SCI_ind_StartMEP),(ii+width(con_ind_StartMEP))) = ...
        SCI_ind_StartMEP(:, ii);
end


%[~,~,stats] = anova1(StartMEP);
%figure
%hold on
%[c,~,~,gnames] = multcompare(stats);

% Do the statistics
[~, con_fifty_p_val] = ttest2(con_ind_StartMEP(:,1) - 1, zeros(length(con_ind_StartMEP(:,1)), 1));
[~, con_eighty_p_val] = ttest2(con_ind_StartMEP(:,2) - 1, zeros(length(con_ind_StartMEP(:,2)), 1));
[~, SCI_fifty_p_val] = ttest2(SCI_ind_StartMEP(:,1) - 1, zeros(length(SCI_ind_StartMEP(:,1)), 1));
[~, SCI_eighty_p_val] = ttest2(SCI_ind_StartMEP(:,2) - 1, zeros(length(SCI_ind_StartMEP(:,2)), 1));

%% Save the file if selected
Save_Figs(Fig_Title, Save_File)







