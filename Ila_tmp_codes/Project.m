clear all 
close all
clc

%% NB : FOLLOW NOTE : ADD BUTTERWORTH FILTER!!!

BCI_folder_path = 'C:\Users\utente\Documents\GitHub\BCI\';

addpath(genpath([BCI_folder_path 'biosig']))
addpath(genpath([BCI_folder_path 'eeglab13_4_4b']))
addpath(genpath([BCI_folder_path 'eeglab_current']))
addpath(genpath([BCI_folder_path 'Flavio']))


% open channel_location and laplacian
load('laplacian_16_10-20_mi.mat')
load('channel_location_16_10-20_mi.mat')

%% READ FILE
filename1 = 'anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';
filename2 = 'anonymous.20170613.162331.offline.mi.mi_bhbf.gdf';
filename3 = 'anonymous.20170613.162934.offline.mi.mi_bhbf.gdf';
%filename4 = 'anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf'; % this
%is online 

%% Defining event types
FIX = hex2dec('312');
CUEH = hex2dec('305');
CUEF = hex2dec('303');
CONT_FEED = hex2dec('30d');
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');

%% Build event and signal matrix
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

sampleRate = h.EVENT.SampleRate; % it's equal for every file

signals = signals(:,1:end-1); % Let's consider only the 16 channels
clear i s h

% Plot EEG 
eegplot(signals')

% Divde the duration by the SAMPLE RATE to have the duration in seconds
dur_sec = dur/sampleRate ;

%% FILTER (Butterworth)

[b,a] = butter(2, [8 12]/512/2); % take the sample frequency and devide by 2
fvtool(b,a)
signalsF = filter(b,a,signals);

% Start and Stop Position extraction

EventIds = [CUEF, CUEH, CONT_FEED,FIX];

% Build the Start-Stop Position cell array with information about the Event
% Id, start/stop pos and indexes on the respected condition of Type ==
% EventId
InfoTrials = BuildTrials(EventIds, pos,typ, dur, signalsF);

% MU AND BETA FREQ 


%% SPATIAL FILTERING
% Ear Ref: Use a reference electrode
% CAR : remove the spread activity in the skull 
% we need only a snapshot , take the avarage of each electrode and subtract
% that 
% Laplacian : take the weighted avarage subtracting that from the cross in
% the neighborhood. 16 electrods and matrix moltiplication

% band pass filter and then grand avarage
% you can also extract the power and a moving avarage to visualize the
% power and log of the power
% CAR APPLICATION

% PLOT the single electrode power thanks to the band filter and see the
% power for different 2 class

% topopplot

%% CAR

signalsFeet = InfoTrials{[InfoTrials{:,1}] == CUEF,5};
signalsHand = InfoTrials{[InfoTrials{:,1}] == CUEH,5};

% CARFeet = bsxfun(@minus, signalsFeet, mean(signalsFeet,2));
% CARHand = bsxfun(@minus, signalsHand, mean(signalsHand,2));

CARHand = signalsHand - mean(signalsHand,2);
CARFeet = signalsFeet - mean(signalsFeet,2);

%% Grand Average

GrandAvgHand = mean(signalsHand,3);
GrandAvgFeet = mean(signalsFeet,3);

figure();
topoplot(mean(signalsHand,1), chanlocs16);
figure();
topoplot(mean(signalsFeet,1), chanlocs16);

% LAPLACIAN

% pweltch function: takes the signal, split it in windows also overlapping,
% hamming windows and compute the FFT and avarage the 8 overlapping window.

% apply this pcd
% adjust the events position ?? what does it mean? 
% Start from the windowing -> if an event follow the window 


