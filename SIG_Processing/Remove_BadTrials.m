
function [sig] = Remove_BadTrials(sig)

%% Which experiment are you looking at
bad_trials = [];

%% SCI MVC
if strcmp(sig.meta.task, 'MVC')
    if strcmp(sig.meta.subject, 'SS')
        bad_trials = [1; 3];
    end
    if strcmp(sig.meta.subject, 'JW')
        bad_trials = [3; 4];
    end
    if strcmp(sig.meta.subject, 'WM')
        bad_trials = 2;
    end
    if strcmp(sig.meta.subject, 'KP')
        bad_trials = [2; 5];
    end
end

%% SCI StartReact
if strcmp(sig.meta.task, 'StartReact')
    if strcmp(sig.meta.subject, 'DM')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [5; 16; 18; 27; 35; 39; 43; 44; 45; 52; 58; 60];
        end
    end
    if strcmp(sig.meta.subject, 'WM')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = 13;
        end
    end
    if strcmp(sig.meta.subject, 'SS')
        if strcmp(sig.meta.muscle, 'ABH')
            %bad_trials = 13;
        end
    end
    if strcmp(sig.meta.subject, 'PM')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [9; 12; 13; 14; 15; 40; 41; 43; 46];
        end
    end
    if strcmp(sig.meta.subject, 'JW')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [13; 47; 20; 50; 60];
        end
        if strcmp(sig.meta.muscle, 'AbH_Abd')
            bad_trials = [4; 5; 7; 10; 14; 15; 19; 20; 21; 25; 28; 29; 45; 52; 55];
        end
        if strcmp(sig.meta.muscle, 'Plantar')
            bad_trials = [2; 17; 22; 28; 60];
        end
    end
end


%% Control Subjects StartReact

if strcmp(sig.meta.task, 'StartReact')

    if strcmp(sig.meta.subject, 'FR')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [4; 31; 32; 33; 41; 42; 44; 48; 55; 57];
        end
    end
    if strcmp(sig.meta.subject, 'KP')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [14; 25; 35; 45];
        end
    end
    if strcmp(sig.meta.subject, 'RR')
        if strcmp(sig.meta.muscle, 'ABH')
        end
    end
    if strcmp(sig.meta.subject, 'MA')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = [6; 11; 22; 27; 37; 38; 41; 47];
        end
    end
    if strcmp(sig.meta.subject, 'HE')
        if strcmp(sig.meta.muscle, 'ABH')
            bad_trials = 20;
        end
    end
end

%% Control subject startMEP
if strcmp(sig.meta.task, 'StartMEP')
    if strcmp(sig.meta.subject, 'KP')
        % Had to readjust startle headphones
        bad_trials = (1:22)';
    end
end

%% Preliminary testing

% SCI
if strcmp(sig.meta.subject, 'MR')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [3; 5; 7; 8; 9; 10; 11; 12; 13; 26; 31; 36; 42; 46; 48; 52; 56; 59];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 22; 24; 26; 40; 41; 46; 48];
    end
    if strcmp(sig.meta.task, 'Plantar')
        bad_trials = [11; 14; 22; 27; 28; 31; 37; 38; 45; 51; 52; 55; 60];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = [1; 3; 5; 8; 20; 24];
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [16; 17; 18; 19; 20; 21; 23; 24];
    end
end

% Controls
if strcmp(sig.meta.subject, 'HP')
    if strcmp(sig.meta.task, 'Plantar')
        bad_trials = [13; 14];
    end
end

if strcmp(sig.meta.subject, 'AW')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [1; 3; 6; 12; 13; 15; 32; 35; 36; 56; 57; 59];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [18; 42; 45; 47; 53; 57];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = 13;
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [18; 22; 24; 40; 56];
    end
end

if strcmp(sig.meta.subject, 'TP')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [2; 29; 30; 31; 32; 33; 36; 38; 40; 41; 46; 55; 59];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [1; 2; 3; 4; 9; 12; 16; 21; 23; 24; 29; 32; 35; 42; 43; 50; 56; 57; 59];
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [17; 22; 27; 45; 49];
    end
end

if strcmp(sig.meta.subject, 'GaM')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [1; 2; 11; 13; 16; 20; 22; 33; 39; 42; 43; 45; 46; 49; 53; 57; 60];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [9; 14; 22; 25; 28; 34; 36; 45; 49; 50; 53; 55; 56; 57; 60];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = [2; 15; 16; 17; 25];
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [1; 10; 44];
    end
end

if strcmp(sig.meta.subject, 'JA')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [3; 5; 7; 10; 26; 33; 35; 40; 43; 45; 46; 51; 58; 59];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [2; 3; 6; 17; 23; 26; 33; 34; 36; 48; 49; 50; 51; 53; 56];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = [50; 51; 54];
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [20; 22; 46; 53];
    end
end

if strcmp(sig.meta.subject, 'ST')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [3; 12; 14; 26];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [1; 37];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = [8; 12; 47];
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [4; 5];
    end
end

if strcmp(sig.meta.subject, 'HK')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = [2; 4; 6; 7; 8; 15; 20; 29; 32; 47];
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = 16;
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = 1;
    end
    if strcmp(sig.meta.task, 'SOL')
        bad_trials = [13; 49];
    end
end

if strcmp(sig.meta.subject, 'EB')
    if strcmp(sig.meta.task, 'ABH')
        bad_trials = 2;
    end
    if strcmp(sig.meta.task, 'AbH_Abd')
        bad_trials = [50; 53];
    end
    if strcmp(sig.meta.task, 'TA')
        bad_trials = [21; 27; 32; 34; 45; 48; 58];
    end
end

%% Mark those trials as fails in sig file

for ii = 1:length(bad_trials)
    [sig] = Remove_Trial(sig, bad_trials(ii));
end

