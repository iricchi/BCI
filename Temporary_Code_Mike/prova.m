clear all
close all
clc

[s, h ] = sload('anonymous.20170613.161402.offline.mi.mi_bhbf.gdf');
fs = h.SampleRate;
%% CAR
s = s(:,1:end-1);
CAR = s - mean(s,2);

% eegplot(s(1:5000,:)')
% eegplot(CAR(1:5000,:)')

%% PWELCH

duration = 1;
shift = 0.0625;

start = 1:fs*shift:length(s)-fs*duration;
stop = duration*fs:fs*shift:length(s); 
f_interest = 4:2:48;

window = fs*duration;
overlap = shift*fs;
data = zeros(length(start),length(f_interest),16);
for i = 1:length(start)    
    [data(i,:,:),f] = pwelch(CAR(start(i):stop(i),:), window,overlap,f_interest,512);
end
