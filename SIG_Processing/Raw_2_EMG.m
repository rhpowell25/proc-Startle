
function [EMG] = Raw_2_EMG(Raw_EMG, samp_rate)

%% DC removal of the EMG

%figure
%hold on
%plot(Raw_EMG{1,1}(:,1))

Zeroed_EMG = struct([]);
for ii = 1:length(Raw_EMG)
    for pp = 1:width(Raw_EMG{ii})
        Zeroed_EMG{ii}(:,pp) = Raw_EMG{ii}(:,pp) - mean(Raw_EMG{ii}(:,pp));
    end
end

%figure
%hold on
%plot(Zeroed_EMG{1,1}(:,1))

%% Run a Notch filter to remove 60 Hz noise

disp('Running the notch filter:')

% Design the notch filer
notch_filter = designfilt('bandstopiir', 'FilterOrder', 4, ...
           'HalfPowerFrequency1', 59,'HalfPowerFrequency2', 61, ...
           'DesignMethod','butter','SampleRate', samp_rate);

% Define the filtered EMG
notched_EMG = struct([]);
for ii = 1:length(Zeroed_EMG)
    for pp = 1:width(Zeroed_EMG{ii})
        % Apply the Notch Filter
        notched_EMG{ii}(:,pp) = filtfilt(notch_filter, Zeroed_EMG{ii}(:,pp));
    end
end

%figure
%hold on
%plot(notched_EMG{1,1}(:,1))

%% High pass filter the EMG

% Construct filter off 1/2 the sampling frequency (to prevent aliasing)
nyquist_num = 2;

disp('Running high pass filter:')

% High pass 4th order Butterworth band pass filter (50 Hz)
[b_high, a_high] = butter(4, nyquist_num*50/samp_rate, 'high');
highpassed_EMG = struct([]);
for ii = 1:length(notched_EMG)
    for pp = 1:width(notched_EMG{ii})
        highpassed_EMG{ii}(:,pp) = filtfilt(b_high, a_high, notched_EMG{ii}(:,pp));
    end
end

%figure
%hold on
%plot(highpassed_EMG{1,1}(:,1))

%% Rectify the EMG

disp('Rectifying EMG:')

Rect_EMG = struct([]);
for ii = 1:length(highpassed_EMG)
    for pp = 1:width(highpassed_EMG{ii})
        Rect_EMG{ii,1}(:,pp) = abs(highpassed_EMG{ii}(:,pp));
    end
end

%% Low pass 4th order Butterworth band pass filter (10 Hz)

disp('Running low pass filter:')

[b_low, a_low] = butter(4, nyquist_num*10/samp_rate, 'low');

EMG = struct([]);
for ii = 1:length(Rect_EMG)
    for pp = 1:width(Rect_EMG{ii})
        EMG{ii, 1}(:,pp) = filtfilt(b_low, a_low, Rect_EMG{ii}(:,pp));
    end
end





