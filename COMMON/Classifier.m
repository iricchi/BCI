clear all
close all
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

%% Loading data

load(fullfile(parent_folder, 'SavedPSD', [subject, sfilter, '_PSDOffline.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;
%% 
for i = 1:length(unique(flags.runs))
    PSD_hand_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.FEED_H),:,:));

    PSD_foot_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.FEED_F),:,:));

    PSD_flattened_foot{i} = reshape(PSD_foot_run{i},size(PSD_foot_run{i},1),...
        size(PSD_foot_run{i},2)*size(PSD_foot_run{i},3)); %flattens the 3D matrix

    PSD_flattened_hand{i} = reshape(PSD_hand_run{i},size(PSD_hand_run{i},1),...
        size(PSD_hand_run{i},2)*size(PSD_hand_run{i},3));

    data{i} = [PSD_flattened_foot{i};PSD_flattened_hand{i}];
    label{i} = [ones(size(PSD_flattened_foot{i},1),1);...
        2*ones(size(PSD_flattened_hand{i},1),1)];
end


%% Loading features selection

load(fullfile(parent_folder, 'Features', [subject, sfilter, '_features.mat']));
%clearvars -except data label f_map features_selected

%% 
data_selected = [];
label_selected = [];
for i = 1:2
    data_selected = [data_selected;data{i}(:,features_selected)];
    label_selected = [label_selected;label{i}];
end

test_selected = data{3}(:,features_selected);

feet = find(label_selected ==1);
hands = find(label_selected ==2);

classifier = fitcdiscr(data_selected,label_selected);
%%

save(fullfile(parent_folder, 'Features', [subject, sfilter, '_classifier.mat']),'classifier');


%%
[prediction,postprob] = predict(classifier,test_selected);

error = length(find(prediction ~= label{3}))/length(label{3});