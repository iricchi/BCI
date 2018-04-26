clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Mike';

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

h_offline   = cell(numel(offline_names),1);
h_online    = cell(numel(online_names),1);

for i = 1:numel(online_names)
    [signals_online{i},  h_online{i}]  = extractSignalsFromFileName(online_names{i}, parent_folder, 'online');
end

for i = 1:numel(offline_names)
    [signals_offline{i}, h_offline{i}] = extractSignalsFromFileName(offline_names{i}, parent_folder, 'offline');
end

sampleRate = h_offline{1}.SampleRate;

%% SPATIAL FILTERING

sfilter = 'CAR' ; % Lap, BigLap

signals_offline = spatialFilter( signals_offline, sfilter );
signals_online  = spatialFilter( signals_online , sfilter );


%% Power Spectral Density PSD - pwelch

psdParam.sampleRate = sampleRate;
psdParam.nCh        = length(chanlocs16);
psdParam.duration   = 1;                                %lenght of windows in seconds
psdParam.shift      = 0.0625;                           %shift in seconds
psdParam.window     = sampleRate*psdParam.duration;     %lenght of win in samples
psdParam.overlap    = psdParam.shift*sampleRate;        %shift in samples
psdParam.f_interest = 4:2:48;                           %set of frequencies

%Mapper from frequency in Hz to index in the psd array
psdParam.f_map = containers.Map(psdParam.f_interest,1:length(psdParam.f_interest));

[PSDoffline, ~, ~] = powerSpectralDensity( signals_offline , psdParam );
[PSDonline , ~, ~] = powerSpectralDensity( signals_online  , psdParam );


%% Generation of flags for PSDdata

[ psdSignalsOffline, flagOffline ] = PSDdataGenerator( PSDoffline, h_offline, psdParam.overlap );
[ psdSignalsOnline,  flagOnline  ] = PSDdataGenerator( PSDonline , h_online , psdParam.overlap );

clear PSDoffline PSDonline i signals_offline signals_online h_offline h_online
