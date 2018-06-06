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
load(fullfile(parent_folder, 'Features', [subject, sfilter, '_support_all_linear.mat']));

PSD = psdOnlinestruct.psd;
flags  = psdOnlinestruct.flags;
params = psdOnlinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%%
classifier = support.classifier;
alpha = 0.94;
selected_features = support.selected_features;

%for i = 1 : length(unique(flags.abstrial(~isnan(flags.abstrial))))
test =  log10(PSD(flags.runs ==1,:,:));
test = reshape(test,size(test,1),size(test,2)*size(test,3));
previous = [0.5,0.5];
feet =[];
hands = [];
for j = 1 : size(test,1)
  
        
        if flags.cues(j)==cueType.FEED_F || flags.cues(j)==cueType.FEED_H  
            if flags.cues(j) == cueType.FEED_F && flags.cues(j-1) ~= cueType.FEED_F
                feet = [feet;j];
            elseif flags.cues(j)==cueType.FEED_H && flags.cues(j-1)~= cueType.FEED_H
                hands = [hands;j];
            end
                     
            [~,posterior(j,:)] = predict(classifier,test(j,selected_features));
            previous = (1-alpha)*posterior(j,:)+ previous *(alpha);
            curr_decision(j,:) = previous;
            
        else
            posterior(j,:) = [0.5,0.5];
            previous = [0.5,0.5];
            curr_decision(j,:) =previous;
        end
        
       
end
thresh = 0.8;
time = [1:size(curr_decision,1)]/32;
figure
plot(time, curr_decision(:,2));
grid on
grid minor
xlabel('Time (s)');
ylabel('Decision'),
hline(thresh,'','Threshold hands');
hline(1-thresh,'','Threshold feet');
vline(hands/32,'r');
vline(feet/32,'b');
%legend('Decision','Hands task','Feet task')

% for i = 1:length(curr_decision)
%     figure
%     time = [1:size(curr_decision{i},1)]/32;
%     plot(time,curr_decision{i}(:,2))
%     hold on
%     plot(time,posterior{i}(:,2))
%     grid on
%     grid minor
%     xlabel('Time (s)')
%     hline(thresh,'','Threshold')
%     legend('Decision','PostProb')
%     if curr_decision{i}(end,2) >thresh
%         hands = hands +1;
%     end
% end