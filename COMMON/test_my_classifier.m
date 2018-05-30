%%
clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Mike';
sfilter = 'Lap';
%% Loading functions
parent_folder = fileparts(pwd);

addpath(genpath([parent_folder, '\biosig']));
addpath(genpath([parent_folder, '\eeglab_current']));
addpath(genpath([parent_folder, '\eeglab13_4_4b']));

load([parent_folder, '\VariousData','\channel_location_16_10-20_mi.mat']);
load([parent_folder, '\VariousData','\laplacian_16_10-20_mi.mat']);

load(fullfile(parent_folder, 'Features', [subject, sfilter, '_features_all.mat']));
% load(fullfile(parent_folder, 'Features', [subject, sfilter, '_classifier_all_diaglinear.mat']));


%% Defining event types
global cueType

cueType.FIX = hex2dec('312');
cueType.CUEH = hex2dec('305');
cueType.CUEF = hex2dec('303');
cueType.CONT_FEED = hex2dec('30d');
cueType.FEED_H = hex2dec('30e');
cueType.FEED_F = hex2dec('30f');
cueType.BOOM_MISS = hex2dec('381');
cueType.BOOM_HIT = hex2dec('382');

%% Preparing the support struct

support.classifier = classifier;
support.f_interest = features.frequencies;
support.channels = features.channels;
support.selected_features = features.selected;
support.alpha = 0.96;


support.lapmatrix = lap;
support.sfilter = 'Lap';
support.sampleRate = 512;
support.overlap = 32;

%% getting files of the subject

[ offline_names, online_names ] = getFileNamesFromDir( subject , parent_folder);


%% Extracting signals from files

signals_offline = cell(numel(offline_names),1);
signals_online  = cell(numel(online_names),1);

h_offline   = cell(numel(offline_names),1);
h_online    = cell(numel(online_names),1);

for i = 1:numel(online_names)
    [signals_online{i},  h_online{i}]  = extractSignalsFromFileName(online_names{i}, parent_folder, 'online');
end

for i = 1:numel(offline_names)
    [signals_offline{i}, h_offline{i}] = extractSignalsFromFileName(offline_names{i}, parent_folder, 'offline');
end

sampleRate = h_offline{1}.SampleRate;

%%
[signals, flag] = PSDdataGenerator( signals_online, h_online, 1 );

signal_interest_hand  = signals(flag.runs == 1 & flag.trial== 15 & flag.cues == cueType.FEED_F,:);

n_windows = ceil(length(signal_interest_hand)/512);
% post = zeros(ceil(length(signal_interest_hand)/512),1);
% duration = zeros(ceil(length(signal_interest_hand)/512),1);
previous = [0.5,0.5];
% decision = zeros(ceil(length(signal_interest_hand)/512),2);
% post = zeros(ceil(length(signal_interest_hand)/512),2);

k = 1;
j=1;
while k < length(signal_interest_hand)-512    
    
    init = tic;
    [previous,post(j,:)]= myclassifier(signal_interest_hand(k:k+511,:),previous,support);
    duration(i)= toc(init);
    
    decision(j,:) = previous;
    j=j+1;
    k = k+32;

end

%%

save(fullfile(parent_folder, '\Features\',[subject,sfilter,'_support.mat']), 'support');
