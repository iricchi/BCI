%% Load all data
close all
clear all
clc


load('channel_location_16_10-20_mi.mat')
load('laplacian_16_10-20_mi.mat')
filename = {};
subject = 'Ilaria';
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
    case 'Michael' 
        %Michael
        filename{1}='aj3.20180313.113110.offline.mi.mi_bhbf.gdf';
        filename{2}='aj3.20180313.114118.offline.mi.mi_bhbf.gdf';
        filename{3}='aj3.20180313.114946.offline.mi.mi_bhbf.gdf';
end
%% Defining event types
FIX = hex2dec('312');
CUEH = hex2dec('305');
CUEF = hex2dec('303');
CONT_FEED = hex2dec('30d');
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');

%% Build event and signal matrix

dur = [];
pos = [];
typ = [];
fileNum = [];
signals = [];

file_shift = 0;

for i=1:3
    if i~=1
        file_shift = file_shift + size(s,1);
    end
    [s,h]=sload(filename{i});
    dur = cat(1,dur,h.EVENT.DUR);
    pos = cat(1,pos,h.EVENT.POS + file_shift);
    typ = cat(1,typ,h.EVENT.TYP);
    fileNum = cat(1, fileNum, i*ones(length(h.EVENT.DUR),1));
    signals = cat(1,signals, s);
end

bigM = cat(2,dur,pos,typ,fileNum);
sampleRate = h.SampleRate;
clear dur typ pos fileNum s h i;

signals = signals(:,1:16);

%uncomment to visualize eeg signals
%eegplot(signals') 

%% divide trial by trial and by task

signalsHand = []; %concatenated signals
indexH =[];  %final sample of each trial
signalsFeet = [];
indexF =[];

for i=1:size(bigM,1)
    if bigM(i,3) == CUEH
        signalsHand = cat(1,signalsHand, signals(bigM(i,2):bigM(i+1,2) + bigM(i+1,1),:));
        indexH = cat(1,indexH,size(signalsHand,1));
    elseif bigM(i,3) == CUEF
        signalsFeet = cat(1,signalsFeet, signals(bigM(i,2):bigM(i+1,2) + bigM(i+1,1),:));
        indexF = cat(1,indexF,size(signalsFeet,1));
    end
end

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