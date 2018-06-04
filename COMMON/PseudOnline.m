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

load(fullfile(parent_folder, 'SavedPSD', [subject, sfilter, '_PSDOnline_last2.mat']));
load(fullfile(parent_folder, 'Features', [subject, sfilter, '_support_2online_linear.mat']));

PSD = psdOnlinestruct.psd;
flags  = psdOnlinestruct.flags;
params = psdOnlinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%%
classifier = support.classifier;
alpha = support.alpha;
selected_features = support.selected_features;

for i = 1 : length(unique(flags.abstrial))
    test =  PSD(flags.abstrial == i & (flags.cues == cueType.FEED_H | flags.cues==cueType.FEED_F),:,:);
    test = reshape(test,size(test,1),size(test,2)*size(test,3));
    previous = [0.5,0.5];

    for j = 1 : size(test,1)
        [~,posterior{i}(j,:)] = predict(classifier,test(j,selected_features));
    
        previous = (1-alpha)*posterior{i}(j,:)+ previous *(alpha);
        curr_decision{i}(j,:) = previous;
        
    end
end
plot(curr_decision{7}(:,1))
hold on
plot(posterior{7}(:,1))