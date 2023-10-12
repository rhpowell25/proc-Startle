function [Force] = Extract_Force(sig, Zero_Force, Calib_Force, rewarded_idxs)

%% Extract the Force

temp_force = sig.force;

%% Zero the force
if isequal(Zero_Force, 1)
    % Time of the go cue
    gocue_times = sig.trial_gocue_time - sig.trial_start_time;
    for ii = 1:length(temp_force)
        gocue_idx = gocue_times(ii)/sig.bin_width;
        baseline_force = mean(temp_force{ii,1}(1:gocue_idx));
        temp_force{ii,1} = temp_force{ii,1} - baseline_force;
    end
end

%% Reverse the signs if the max is negative
max_abs_force_idx = abs(temp_force{1,1}) == max(abs(temp_force{1,1}));
if temp_force{1,1}(max_abs_force_idx) < 0
    for ii = 1:length(temp_force)
        temp_force{ii,1} = temp_force{ii,1}*-1;
    end
end

%% Calibrate the force
if isequal(Calib_Force, 1)
    [Force_Calib] = SIG_File_Details('Force');
    for ii = 1:length(temp_force)
        temp_force{ii,1} = temp_force{ii,1}*str2double(Force_Calib);
    end
end

%% Use only the selected Force 

% Extract the selected Force
Force = struct([]);
for ii = 1:length(rewarded_idxs)
    Force{ii,1} = temp_force{rewarded_idxs(ii)};
end

