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
%% Defining event types
global FIX CUEH CUEF CONT_FEED BOOM_MISS BOOM_HIT

FIX = hex2dec('312');%786
CUEH = hex2dec('305'); %773
CUEF = hex2dec('303'); %771
CONT_FEED = hex2dec('30d'); %781
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');
%% READ FILE

patient_name =  'anonymous';

%ANONYMOUS
% filename{1} = 'anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';
% filename{2} = 'anonymous.20170613.162331.offline.mi.mi_bhbf.gdf';
% filename{3} = 'anonymous.20170613.162934.offline.mi.mi_bhbf.gdf';
% filename{4} = 'anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf'; % this
%is online 

%MICHAEL
filename{1} = 'aj3.20180313.114946.offline.mi.mi_bhbf.gdf';
filename{2} = 'aj3.20180313.114118.offline.mi.mi_bhbf.gdf';
filename{3} = 'aj3.20180313.113110.offline.mi.mi_bhbf.gdf';

%FLAVIO
% filename{1} = 'aj4.20180313.151634.offline.mi.mi_bhbf.gdf';
% filename{2} = 'aj4.20180313.152525.offline.mi.mi_bhbf.gdf';
% filename{3} = 'aj4.20180313.153339.offline.mi.mi_bhbf.gdf';

%ILARIA
% 
% filename{1} = 'aj5.20180320.154811.offline.mi.mi_bhbf.gdf';
% filename{2} = 'aj5.20180320.155701.offline.mi.mi_bhbf.gdf';
% filename{3} = 'aj5.20180320.160549.offline.mi.mi_bhbf.gdf';


number_of_files = 3;

signals = cell(number_of_files,1);
h = cell(number_of_files,1);

for i = 1 : number_of_files
    
    [s,h{i}] = sload(filename{i});
    signals{i} = s(:,1:end-1); % Let's consider only the 16 channels
    
end
fs = h{1}.SampleRate;



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
        
        for i = 1:number_of_files
            signalsF{i} =(lap*signals{i}')';
        end
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


%% EXTRACTION


% Start and Stop Position extraction
%get_feed(InfoTrials,'hands');
EventIds = [CUEF, CUEH, CONT_FEED, FIX];


% Build the Start-Stop Position cell array with information about the Event
% Id, start/stop pos and indexes on the respected condition of Type ==
% EventId
InfoTrials = BuildTrialsMike(EventIds, pos,typ, dur, power);

namefile = (sprintf('InfoTrial_%s.mat',patient_name));

if  ~exist(namefile,'file')
    save(namefile, 'InfoTrials');
end

%clearvars -except InfoTrials lap chanlocs16 power patient_name
%% Grand Averages


foot_feed = extract_signal(InfoTrials,3);
hand_feed = extract_signal(InfoTrials,2);

A_foot = mean_cell(foot_feed,0);
A_hand = mean_cell(hand_feed,0);
R =  mean_cell(InfoTrials{4,5},0);

mean_A_foot = squeeze(mean(A_foot));
mean_A_hand = squeeze(mean(A_hand));

mean_R = squeeze(mean(R));

mean_ERD_foot = 100*((log10(mean_A_foot) - log10(mean_R)))./ (mean_R);
mean_ERD_hand = 100*(log10(mean_A_hand) - log10(mean_R))./ (mean_R);

ERD_foot_interest = mean_ERD_foot(1:5,:);
ERD_hand_interest = mean_ERD_hand(1:5,:);


   

%% Spectrogram

    %% Topoplot
for_topoplotF = squeeze(mean(mean_ERD_foot(5:6,:),1));
for_topoplotH = squeeze(mean(mean_ERD_hand(5:6,:),1));

whole = [for_topoplotF for_topoplotH];
minimum = min(whole(:));
maximum = max(whole(:));


figure
topoplot(for_topoplotF,chanlocs16,'electrodes','labels');
figure
topoplot(for_topoplotH,chanlocs16,'electrodes','labels');

% figure
% topoplot(for_topoplotH - for_topoplotF,chanlocs16,'maplimits','maxmin','electrodes','labels');
% 

