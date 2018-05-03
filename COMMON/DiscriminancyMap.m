clear all
%close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Mike';
sfilter = 'Lap' ;
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

load(fullfile(parent_folder, 'SavedPSD', [subject, sfilter, '_PSDOffline.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;


%% Extraction
for i = 1:length(unique(flags.runs))
    PSD_hand_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.CUEH |...
        flags.cues == cueType.FEED_H),:,:));
    
    PSD_foot_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.CUEF |...
        flags.cues == cueType.FEED_F),:,:));
    
    PSD_flattened_foot{i} = reshape(PSD_foot_run{i},size(PSD_foot_run{i},1),...
        size(PSD_foot_run{i},2)*size(PSD_foot_run{i},3)); %flattens the 3D matrix
    
    PSD_flattened_hand{i} = reshape(PSD_hand_run{i},size(PSD_hand_run{i},1),...
        size(PSD_hand_run{i},2)*size(PSD_hand_run{i},3));
    
    data{i} = [PSD_flattened_foot{i};PSD_flattened_hand{i}];
    label{i} = [ones(length(PSD_flattened_foot{i}),1);...
        2*ones(length(PSD_flattened_hand{i}),1)];
    
    [ranking{i},score{i}] = rankfeat(data{i}, label{i}, 'fisher');
    
    for j = 1 :length(score{i})
        map{i}(ranking{i}(j)) = score{i}(j);
    end
    
    map_reshaped{i} = reshape(map{i}, size(PSD_hand_run{i},2),size(PSD_hand_run{i},3));
    
    figure
    colormap jet
    imagesc(map_reshaped{i}')
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    xticklabels(yticks*2+2)
    
end


%% Select feat

    

