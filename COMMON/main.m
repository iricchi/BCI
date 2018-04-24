clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Mike';

%% Defining event types
FIX = hex2dec('312');
CUEH = hex2dec('305');
CUEF = hex2dec('303');
CONT_FEED = hex2dec('30d');
BOOM_MISS = hex2dec('381');
BOOM_HIT = hex2dec('382');

%% Loading functions
parent_folder = fileparts(pwd);

addpath(genpath([parent_folder, '\biosig']));
addpath(genpath([parent_folder, '\eeglab_current']));
addpath(genpath([parent_folder, '\eeglab13_4_4b']));

load([parent_folder, '\VariousData','\channel_location_16_10-20_mi.mat']);
load([parent_folder, '\VariousData','\laplacian_16_10-20_mi.mat']);
%% getting files of the subject

[ offline_names, online_names ] = getFileNamesFromDir( subject , parent_folder);

%% Extracting signals from files

signals_offline = cell(numel(offline_names),1);
signals_online  = cell(numel(online_names),1);

for i = 1:numel(online_names)
    signals_online{i}  = extractSignalsFromFileName(online_names{i}, parent_folder, 'online');
end

for i = 1:numel(offline_names)
    [signals_offline{i}, sampleRate] = extractSignalsFromFileName(offline_names{i}, parent_folder, 'offline');
end

%% SPATIAL FILTERING

sfilter = 'CAR' ; % Lap, BigLap

signals_offline = spatialFilter( signals_offline, sfilter );
signals_online  = spatialFilter( signals_online , sfilter );


%% Power Spectral Density PSD - pwelch

psdParam.sampleRate = sampleRate;
psdParam.nCh        = length(chanlocs16);
psdParam.duration   = 1;
psdParam.shift      = 0.0625;
psdParam.window     = sampleRate*psdParam.duration;
psdParam.overlap    = psdParam.shift*sampleRate;

PSDoffline = powerSpectralDensity( signals_offline , psdParam );
