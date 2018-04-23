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
filename{1} = 'anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';
filename{2} = 'anonymous.20170613.162331.offline.mi.mi_bhbf.gdf';
filename{3} = 'anonymous.20170613.162934.offline.mi.mi_bhbf.gdf';
%filename{4} = 'anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf'; % this
%is online 

number_of_files = 3;

signals = cell(number_of_files,1);
h = cell(number_of_files,1);

for i = 1 : number_of_files
    
    [s,h{i}] = sload(filename{i});
    signals{i} = s(:,1:end-1); % Let's consider only the 16 channels
    
end
fs = h{1}.SampleRate;

%% Defining event types
FIX = hex2dec('312');
CUEH = hex2dec('305');
CUEF = hex2dec('303');
CONT_FEED = hex2dec('30d');
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');



%% SPATIAL FILTERING
sfilter = 'CAR' ; % Lap, BigLap
signalsF = cell(number_of_files,1);

switch sfilter
    
    case 'CAR'
        
        for i = 1:number_of_files
            signalsF{i} = bsxfun(@minus, signals{i}, mean(signals{i}, 2));
            %signalsF{i} = signals{i} - mean(signals{i},2);
        end

    case 'Lap'
        
        
    case 'BigLap'
        
end

%% Power Spectral Density PSD - pwelch

nCh = length(chanlocs16);

%definition of the windowing properties
duration = 1;
shift = 0.0625;
window = fs*duration;
overlap = shift*fs;
PSD = cell(number_of_files,1);

for i = 1 : number_of_files
   
    start = 1:fs*shift:length(signals{i})-fs*duration;
    stop = duration*fs:fs*shift:length(signals{i}); 
    f_interest = 4:2:48;

    PSD{i} = zeros(length(start),length(f_interest),nCh);

    for j = 1:length(start)    
        [PSD{i}(j,:,:),f] = pwelch(signalsF{i}(start(j):stop(j),:), window,overlap,f_interest,fs);
    end
    
end
%% PSD CONCATENATION

%Conversion of the event sample (in time) to window
position = cell(number_of_files,1);
duration = cell(number_of_files,1);
type = cell(number_of_files,1);

for i = 1 : number_of_files
    
    position{i} = ceil(h{i}.EVENT.POS/32);
    duration{i} = ceil(h{i}.EVENT.DUR/32);
    type{i} = ceil(h{i}.EVENT.TYP);
    
end

%combination 
dur = [];
pos = [];
typ = [];
fileNum = [];
power = [];


for i = 1:number_of_files
   
   dur = [dur; duration{i}];
   pos = [pos; position{i}];
   typ = [typ; type{i}];
   fileNum = [fileNum; i*ones(length(duration{i}),1)];
   power = [power; PSD{i}];
   
  
end
% FARE PLOOOTT 

% CONTROLLARE SQUEEZE

% FARE SPETTROGRAMMA PER CANALE: FREQ IN FUNZIONE DEL TEMPO (SAMPLES/fs)

% plot SPECTRAL DENSITY PER CHANNEL

% EXTRACTION OF CUES AND FIXATION
% NORMALIZE WITH RESPECT TO REST : A - R / R

% GRAND AVERAGE AND TOPOPLOT!!



% %% Build event and signal matrix EEG
% % keep track of the label to the file they come from
% % % take only the offline event so the first 3 files
% % 
% % filenames = {filename1, filename2 , filename3};
% % dur = [];
% % pos = [];
% % typ = [];
% % fileNum = [];
% % signals = [];
% % 
% % for i = 1:length(filenames)
% %    [s, h ] = sload(filenames{i});
% %    dur = [dur; h.EVENT.DUR];
% %    pos = [pos; h.EVENT.POS];
% %    typ = [typ; h.EVENT.TYP];
% %    fileNum = [fileNum; i*ones(length(h.EVENT.DUR),1)];
% %    signals = [signals; s];
% % end
% % 
% % fs = h.EVENT.SampleRate; % the sample rate is equal for every file
% % signals = signals(:,1:end-1); % Let's consider only the 16 channels
% % clear i s h
% 
% % Plot EEG 
% eegplot(signals')
% 
% % Divde the duration by the SAMPLE RATE to have the duration in seconds
% dur_sec = dur/fs ;

%% EXTRACTION


% Start and Stop Position extraction

EventIds = [CUEF, CUEH, CONT_FEED, FIX];


% Build the Start-Stop Position cell array with information about the Event
% Id, start/stop pos and indexes on the respected condition of Type ==
% EventId
InfoTrials = BuildTrialsMike(EventIds, pos,typ, dur, power);

clearvars -except InfoTrials

%% Grand Averages

% A_foot = squeeze(mean(mean_cell(InfoTrials{3,5}),1));
% baseline = InfoTrials{4,5}(1:90);
% R =  squeeze(mean(mean_cell(baseline),1));
% A_hands  = squeeze(mean(mean_cell(InfoTrials{
% ERD_foot = (100*(log10(A_foot) - log10(R)))./ R;
% ERD_hands  =
% imagesc(ERD_foot', [min(ERD_foot(:)),max(ERD_foot(:))])
% 
%% Grand Average

% GrandAvgHand = mean(signalsHand,3);
% GrandAvgFeet = mean(signalsFeet,3);
% 
% figure();
% topoplot(mean(signalsHand,1), chanlocs16);
% figure();
% topoplot(mean(signalsFeet,1), chanlocs16);
% 
% 
