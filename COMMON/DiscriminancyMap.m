clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Ila';
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
    PSD_hand_run{i} = log10(PSDoff(flags.runs == i & (flags.cues == cueType.CUEH |...
        flags.cues == cueType.FEED_H),:,:));
    
    PSD_foot_run{i} = log10(PSDoff(flags.runs == i & (flags.cues == cueType.CUEF |...
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
    
    
end

%% Select feat

fullMat = [];

runNumbers = unique(flags.runs);

figure()
for i = 1:length(unique(flags.runs))
    subplot(2,length(map_reshaped),i);
    colormap jet
    imagesc(map_reshaped{i}')
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    xticklabels(yticks*2+2)
    title(['Run ', num2str(runNumbers(i))])
    fullMat = cat(3,fullMat, map_reshaped{i});
end

meanFeat = mean(fullMat,3);

subplot(2,length(map_reshaped),4);
colormap jet
imagesc(meanFeat')
xlabel('Frequency (Hz)')
ylabel('Channel')
title('Mean Value')
xticklabels(yticks*2+2)

ax = gca;

deviation = 2.5;

suggestedFeats = floor(meanFeat./(deviation*std2(meanFeat)));

subplot(2,length(map_reshaped),5);
colormap jet
imagesc(suggestedFeats')
xlabel('Frequency (Hz)')
ylabel('Channel')
title(['Suggested features: f_i > ', num2str(deviation), '*std_i(f)'])
xticklabels(yticks*2+2)

axes(ax)

[px,py,~] = impixel;

selectedFeats = zeros(size(meanFeat,1),size(meanFeat,2));

if(isempty(px) || isempty(py))
    [r,c]= find(suggestedFeats~=0);
    selectedFeats(sub2ind(size(selectedFeats),r,c)) = 1;
else
    selectedFeats(sub2ind(size(selectedFeats),px',py')) = 1;
end

subplot(2,length(map_reshaped),6);
colormap jet
imagesc(selectedFeats')
xlabel('Frequency (Hz)')
xlim([1, size(PSDoff,2)])
ylabel('Channel')
title('Selected Features')
xticks([5 10 15])
xticklabels({'12','22','32'})

[f, ch] = find(selectedFeats ~= 0);
features.frequencies = (f)*2 +2;
features.channels = (ch);
features.selected = length(f_map)*(ch-1) +f;

save(fullfile(parent_folder, '\Features\',[subject,params.sfilter,'_features.mat']), 'features');

%% Sample extraction

hands = PSDoff((flags.cues == cueType.CUEH | flags.cues == cueType.FEED_H) ,:,:);

feet = PSDoff(flags.cues == cueType.CUEF | flags.cues == cueType.FEED_F ,:,:);


for k = 1:numel(f)
    feature_h(k,:) = log(hands(:,f(k),ch(k)));
    feature_f(k,:) = log(feet(:,f(k),ch(k)));
    
    figure
    histogram(feature_h(k,:))
    hold on
    histogram(feature_f(k,:))
   
    figure
    [m,s] = normfit(feature_h(k,:));
    y = normpdf(feature_h(k,:),m,s);
    plot(feature_h(k,:),y,'.');
    hold on
    [m,s] = normfit(feature_f(k,:));
    y = normpdf(feature_f(k,:),m,s);
    plot(feature_f(k,:),y,'.');
    
end

%[~,~,~,H,F]=canoncorr(zscore(feature_h'),zscore(feature_f(:,1:end-2)'));
% 
% figure
% histogram(H(:,1)')
% hold on
% histogram(F(:,1)')
