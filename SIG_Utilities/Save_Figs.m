function Save_Figs(Fig_Title, Save_File)

%% Define the save directory & save the figures
if ~isequal(Save_File, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    save_title = strrep(Fig_Title, ':', '');
    save_title = strrep(save_title, '.', '');
    save_title = strrep(save_title, '/', '_');
    if ~strcmp(Save_File, 'All')
        saveas(gcf, fullfile(save_dir, char(save_title)), Save_File)
    end
    if strcmp(Save_File, 'All')
        saveas(gcf, fullfile(save_dir, char(save_title)), 'png')
        saveas(gcf, fullfile(save_dir, char(save_title)), 'pdf')
        saveas(gcf, fullfile(save_dir, char(save_title)), 'fig')
    end
    close gcf
end