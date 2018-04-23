clear all 
close all
clc

%% NB : FOLLOW NOTE : ADD BUTTERWORTH FILTER!!!

BCI_folder_path = 'C:\Users\utente\Documents\GitHub\BCI\';

addpath(genpath('biosig'))
addpath(genpath('eeglab_current'))


% open channel_location and laplacian
load('laplacian_16_10-20_mi.mat')
load('channel_location_16_10-20_mi.mat')

%% READ FILE
filename1 = 'anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';
filename2 = 'anonymous.20170613.162331.offline.mi.mi_bhbf.gdf';
filename3 = 'anonymous.20170613.162934.offline.mi.mi_bhbf.gdf';
%filename4 = 'anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf'; % this
%is online 

% MIKE FAI IL CICLO
[s, h] = sload(filename1);
signals = s(:,1:end-1); % Let's consider only the 16 channels

fs = h.SampleRate;

%% Defining event types
FIX = hex2dec('312');
CUEH = hex2dec('305');
CUEF = hex2dec('303');
CONT_FEED = hex2dec('30d');
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');



%% SPATIAL FILTERING
sfilter = 'CAR' ; % Lap, BigLap

switch sfilter
    
    case 'CAR'
        signalsF = bsxfun(@minus, signals, mean(signals, 2));
       %  signalsF = signals - mean(signals,2);
    case 'Lap'
        
        
    case 'BigLap'
        
end

%% Power Specrtal Density PSD - pwelch

nCh = length(chanlocs16);

duration = 1;
shift = 0.0625;

start = 1:fs*shift:length(signals)-fs*duration;
stop = duration*fs:fs*shift:length(signals); 
f_interest = 4:2:48;

window = fs*duration;
overlap = shift*fs;


PSD_perfile = zeros(length(start),length(f_interest),16);
for i = 1:length(start)    
    [PSD_perfile(i,:,:),f] = pwelch(signalsF(start(i):stop(i),:), window,overlap,f_interest,512);
end

% CONCATENARE PSD

% FARE PLOOOTT 

% CONTROLLARE SQUEEZE

% FARE SPETTROGRAMMA PER CANALE: FREQ IN FUNZIONE DEL TEMPO (SAMPLES/fs)

% plot SPECTRAL DENSITY PER CHANNEL

% EXTRACTION OF CUES AND FIXATION
% NORMALIZE WITH RESPECT TO REST : A - R / R

% GRAND AVARAGE AND TOPOPLOT!!



%% Build event and signal matrix EEG
% keep track of the label to the file they come from
% take only the offline event so the first 3 files

filenames = {filename1, filename2 , filename3};
dur = [];
pos = [];
typ = [];
fileNum = [];
signals = [];

for i = 1:length(filenames)
   [s, h ] = sload(filenames{i});
   dur = [dur; h.EVENT.DUR];
   pos = [pos; h.EVENT.POS];
   typ = [typ; h.EVENT.TYP];
   fileNum = [fileNum; i*ones(length(h.EVENT.DUR),1)];
   signals = [signals; s];
end

fs = h.EVENT.SampleRate; % the sample rate is equal for every file
signals = signals(:,1:end-1); % Let's consider only the 16 channels
clear i s h

% Plot EEG 
eegplot(signals')

% Divde the duration by the SAMPLE RATE to have the duration in seconds
dur_sec = dur/fs ;

%% EXTRACTION


% Start and Stop Position extraction

EventIds = [CUEF, CUEH, CONT_FEED, FIX];


% Build the Start-Stop Position cell array with information about the Event
% Id, start/stop pos and indexes on the respected condition of Type ==
% EventId
InfoTrials = BuildTrials(EventIds, pos,typ, dur, signalsF);

% MU AND BETA FREQ 




%% Grand Average

GrandAvgHand = mean(signalsHand,3);
GrandAvgFeet = mean(signalsFeet,3);

figure();
topoplot(mean(signalsHand,1), chanlocs16);
figure();
topoplot(mean(signalsFeet,1), chanlocs16);


