%%
clear
clc
Group = 'Control';
file_dir = strcat('Z:\Lab Members\Henry\AbH Startle\Data', '\', Group, '\**\*.mat');
files = dir(file_dir);
for ii = 1:length(files)
    file_name = files(ii).name;
    sig_dir = files(ii).folder;
    if contains(sig_dir, 'RawFiles')
        continue
    else
        % Load the sig file
        load(strcat(sig_dir, '\', file_name), 'sig')
        sig.meta.group = Group;
        disp(file_name);
        save(strcat(sig_dir, '\', file_name), 'sig', '-v7.3');
        clear sig
    end
end