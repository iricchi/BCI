%% Load all data
close all
clear all
clc

BCI_folder_path = 'C:\Users\utente\Documents\GitHub\BCI\';

addpath(genpath([BCI_folder_path 'biosig']))
addpath(genpath([BCI_folder_path 'eeglab13_4_4b']))
addpath(genpath([BCI_folder_path 'eeglab_current']))
addpath(genpath([BCI_folder_path 'Flavio']))


load('channel_location_16_10-20_mi.mat')
load('laplacian_16_10-20_mi.mat')
filename = {};
subject = 'Michael';
%Random Person

switch subject
    case 'Random'
        filename{1}='anonymous.20170613.162934.offline.mi.mi_bhbf.gdf';
        filename{2}='anonymous.20170613.162331.offline.mi.mi_bhbf.gdf';
        filename{3}='anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';
        filename{4}='anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf';
    case 'Ilaria'
        %Ilaria
        filename{1}='aj5.20180320.154811.offline.mi.mi_bhbf.gdf';
        filename{2}='aj5.20180320.155701.offline.mi.mi_bhbf.gdf';
        filename{3}='aj5.20180320.160549.offline.mi.mi_bhbf.gdf';
        filename{4}='aj5.20180320.162133.online.mi.mi_bhbf.ema.gdf';
        filename{5}='aj5.20180320.162724.online.mi.mi_bhbf.ema.gdf';
        filename{6}='aj5.20180320.163515.online.mi.mi_bhbf.ema.gdf';
        disp('Ilaria data')
    case 'Michael' 
        %Michael
        filename{1}='aj3.20180313.113110.offline.mi.mi_bhbf.gdf';
        filename{2}='aj3.20180313.114118.offline.mi.mi_bhbf.gdf';
        filename{3}='aj3.20180313.114946.offline.mi.mi_bhbf.gdf';
        disp('Mike data')
    case 'Flavio'
        disp('Flavio data')
end
%% Defining event types

typ = {};

typ.FIX = hex2dec('312');
typ.CUEH = hex2dec('305');
typ.CUEF = hex2dec('303');
typ.CONT_FEED = hex2dec('30d');
typ.BOOM_MISS = hex2dec('381');
typ.BOOM_HIT = hex2dec('382');

%% Build event and signal matrix

dur = [];
pos = [];
t = [];
fileNum = [];
signals = [];

file_shift = 0; %Takes account of the sample number in concatenating multiple files

for i=1:size(filename,2)
    if i~=1
        file_shift = file_shift + size(s,1);
    end
    [s,h]=sload(filename{i});
    dur = cat(1,dur,h.EVENT.DUR);
    pos = cat(1,pos,h.EVENT.POS + file_shift);
    t = cat(1,t,h.EVENT.TYP);
    fileNum = cat(1, fileNum, i*ones(length(h.EVENT.DUR),1));
    signals = cat(1,signals, s);
end

bigM = cat(2,dur,pos,t,fileNum);
sampleRate = h.SampleRate;
clear dur t pos fileNum s h i fileshift filename;

signals = signals(:,1:16);

%uncomment to visualize eeg signals
%eegplot(signals') 

%% divide trial by trial and by tasks

[signalsHand indexH] = extractSignalsFromCue(signals, bigM, typ.CUEH);
[signalsFeet indexF] = extractSignalsFromCue(signals, bigM, typ.CUEF);

%% CAR

CARFeet = signalsFeet - mean(signalsFeet,2);
CARHand = signalsHand - mean(signalsHand,2);

%% Grand Average

GrandAvgHand = GrandAvg(CARHand,indexH);
GrandAvgFeet = GrandAvg(CARFeet,indexF);

%% Topovideo

topovideo(GrandAvgHand,sampleRate,chanlocs16)
%% Topoplot

% GrandAvgHand = mean(CarHand,1);
% GrandAvgFeet = mean(CarFeet,1);

figure()
subplot(1,2,1)
topoplot(GrandAvgHand(end,:), chanlocs16,'intsquare','off');
title('CAR both hands');

subplot(1,2,2)
topoplot(GrandAvgFeet(end,:),chanlocs16,'intsquare','off');
title('CAR both feets');

figure()
subplot(1,2,1)
topoplot(mean(GrandAvgHand,1), chanlocs16,'intsquare','off');
title('CAR both hands');

subplot(1,2,2)
topoplot(mean(GrandAvgFeet,1),chanlocs16,'intsquare','off');
title('CAR both feets');



% %% Laplacian
% lapHand = GrandAvgHand - (GrandAvgHand*lap);
% lapFeet = GrandAvgFeet - (GrandAvgFeet*lap);
% 
% figure()
% subplot(1,2,1)
% topoplot(mean(GrandAvgHand,1),chanlocs16,'intsquare','off');
% subplot(1,2,2)
% topoplot(mean(GrandAvgFeet,1),chanlocs16,'intsquare','off');