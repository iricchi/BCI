clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Mike';
sfilter = 'Lap'
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

addpath(genpath(fullfile(parent_folder, 'biosig')));
addpath(genpath(fullfile(parent_folder, 'eeglab_current')));
addpath(genpath(fullfile(parent_folder, 'eeglab13_4_4b')));

load(fullfile(parent_folder, 'VariousData','channel_location_16_10-20_mi.mat'));

%% Loading data

load(fullfile(parent_folder, 'SavedPSD', [subject, '_PSDOffline.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%% Compute ERD

footPSD = PSDoff(flags.cues == cueType.FEED_F,:,:);
handPSD = PSDoff(flags.cues == cueType.FEED_H,:,:);

hands_flags = flags.abstrial( flags.cues == cueType.FEED_H);
foot_flags = flags.abstrial( flags.cues == cueType.FEED_F);

hands_mat = splitInTrials(handPSD, hands_flags);
foot_mat = splitInTrials(footPSD, hands_flags);

avg_hand = squeeze(mean(hands_mat,1));
avg_foot = squeeze(mean(foot_mat,1));
mean_avg_hand = squeeze(mean(avg_hand,1));
mean_avg_foot = squeeze(mean(avg_foot,1));

%%

baseline = (PSDoff(flags.cues == cueType.FIX ,:,:));
mean_base = squeeze(mean(baseline,1));

% 
% ERDfoot = computeERD(footPSD,baseline);
% ERDhand = computeERD(handPSD,baseline);

%Average ERD along all trials

% mean_ERDfoot = squeeze(mean(ERDfoot,1));
% mean_ERDhand = squeeze(mean(ERDhand,1));

mean_foot = (squeeze(mean(footPSD,1)));
mean_hand =(squeeze(mean(handPSD,1)));

mean_ERDfoot = 100*((mean_avg_foot) - (mean_base))./ (mean_base);
mean_ERDhand = 100*((mean_avg_hand) - (mean_base)) ./ (mean_base);
%% Plot
muband = f_map(8):f_map(14);
muband2 = f_map(12):f_map(14);

betaband = f_map(12):f_map(16);
betaband2 = f_map(16):f_map(20);
betaband3 = f_map(20):f_map(28);

frequency_set = {muband,muband2,betaband,betaband2,betaband3};
f_name = {'8-12','12-14','12-16','16-20','20-28'};

for i = 1 : length(frequency_set)
    
    ERDfoot_f_interest = squeeze(mean(mean_ERDfoot(frequency_set{i},:),1));
    ERDhand_f_interest = squeeze(mean(mean_ERDhand(frequency_set{i},:),1));
    
    concatenated = [ERDfoot_f_interest;ERDhand_f_interest];
    minimum = min(concatenated(:));
    maximum = max(concatenated(:));
    minmax = [minimum,maximum];
    
    figure('Name',[params.subject,params.sfilter,f_name{i}]) 
    subplot(1,2,1)
    topoplot(ERDfoot_f_interest,chanlocs16,'maplimits','maxmin','electrodes','labels','plotrad',0.3,'headrad',0.3);
    colorbar
    title('Both Feet')
    
    subplot(1,2,2)
    topoplot(ERDhand_f_interest,chanlocs16,'maplimits','maxmin','electrodes','labels','plotrad',0.3,'headrad',0.3);
    colorbar
    title('Both Hands')
    
    suptitle([params.subject,' in frequency band ',f_name{i},' Hz'])
    
end

saveAllFigures()