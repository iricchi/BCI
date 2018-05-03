clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Anon';
sfilter = 'Lap'; 
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

load(fullfile(parent_folder, 'SavedPSD', [subject,sfilter, '_PSDOffline.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%% Extract average trial for fixation and cue+cont_feed
fixations = PSDoff(flags.cues == cueType.FIX,:,:);
fixations_flags = flags.abstrial(flags.cues == cueType.FIX);

fixations_mat = splitInTrials(fixations, fixations_flags);
avg_fixation = squeeze(mean(fixations_mat,1));

clear fixations fixations_flags fixations_mat

hands = PSDoff((flags.cues == cueType.CUEH | flags.cues == cueType.FEED_H) ,:,:);
hands_flags = flags.abstrial(flags.cues == cueType.CUEH | flags.cues == cueType.FEED_H);

hands_mat = splitInTrials(hands, hands_flags);
avg_hands = squeeze(mean(hands_mat,1));

clear hands hands_flags hands_mat

feet = PSDoff(flags.cues == cueType.CUEF | flags.cues == cueType.FEED_F ,:,:);
feet_flags = flags.abstrial(flags.cues == cueType.CUEF | flags.cues == cueType.FEED_F);

feet_mat = splitInTrials(feet, feet_flags);
avg_feet = squeeze(mean(feet_mat,1));

clear feet feet_flags feet_mat

%% Concatenation of fixation+hands and fixation+feet

avg_hands_trial = cat(1,avg_fixation,avg_hands);
avg_feet_trial = cat(1,avg_fixation,avg_feet);


%% Spectrogram

%trying to standardize with respect to the fixation
avg_fixation_m   = mean(avg_fixation,1); 
avg_fixation_std =  std(avg_fixation,1);

avg_fixation_n = (avg_fixation - avg_fixation_m)./avg_fixation_std;
avg_hands_n    = (avg_hands    - avg_fixation_m)./avg_fixation_std;
avg_feet_n     = (avg_feet     - avg_fixation_m)./avg_fixation_std;

avg_hands_trial_n = cat(1,avg_fixation_n,avg_hands_n);
avg_feet_trial_n  = cat(1,avg_fixation_n,avg_feet_n );

figure('Name',['Spectrogram',subject,'FeetNormalized'])
subplot(3,5,1);
limits = plot_spectrogram(avg_feet_trial_n, 2 , params, 'logOff');
title(['PSDFeet norm ch: ', num2str(2)]);

for ch = 3:params.nCh
    subplot(3,5,ch-1);
    plot_spectrogram(avg_feet_trial_n, ch, params, 'logOff', limits );
    title(['PSDFeet norm ch: ', num2str(ch)]);
end
suptitle([subject ,' Feet normalized', '(', sfilter, ')'])

figure('Name',['Spectrogram',subject,'HandsNormalized'])

for ch = 2:params.nCh
    subplot(3,5,ch-1);
    plot_spectrogram(avg_hands_trial_n, ch, params,'logOff', limits );
    title(['PSDHands norm ch: ', num2str(ch)]);
end
suptitle([subject ,' Hands normalized', '(', sfilter, ')'])


%plot without normalization

figure('Name',['Spectrogram',subject,'FeetNOTNormalized'])
subplot(3,5,1);
limits = plot_spectrogram(avg_feet_trial, 2 , params, 'logOn');
title(['PSDFeet ch: ', num2str(2)]);

for ch = 3:params.nCh
    subplot(3,5,ch-1);
    plot_spectrogram(avg_feet_trial, ch, params, 'logOn' , limits);
    title(['PSDFeet ch: ', num2str(ch)]);
end
suptitle([subject ,' Feet NOT normalized', '(', sfilter, ')'])

figure('Name',['Spectrogram',subject,'HandsNOTNormalized'])

for ch = 2:params.nCh
    subplot(3,5,ch-1);
    plot_spectrogram(avg_hands_trial, ch, params, 'logOn' , limits);
    title(['PSDHands ch: ', num2str(ch)]);
end
suptitle([subject ,' Hands NOT normalized', '(', sfilter, ')'])

saveAllFigures()