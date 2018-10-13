%% Loading functions
parent_folder = fileparts(pwd);

addpath(genpath(fullfile(parent_folder, 'biosig')));
addpath(genpath(fullfile(parent_folder, 'eeglab_current')));
addpath(genpath(fullfile(parent_folder, 'eeglab13_4_4b')));

%% Loading data

load(fullfile(parent_folder, 'SavedPSD', [subject, sfilter, '_PSDOnline.mat']));
load(fullfile(parent_folder, 'Features', [subject, sfilter, '_classifierStruct.mat']));

PSD = psdOnlinestruct.psd;
flags  = psdOnlinestruct.flags;
params = psdOnlinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%%
classifier = classifierStruct.classifier;
alpha = 0.96;
selected_features = classifierStruct.selected_features;

last_run = length(unique(flags.runs));

test =  log10(PSD(flags.runs ==last_run,:,:));
test = reshape(test,size(test,1),size(test,2)*size(test,3));
previous = [0.5,0.5];
feet =[];
hands = [];
for j = 2 : size(test,1)
    
    if flags.cues(j-1) == cueType.FEED_F && flags.cues(j) ~= cueType.FEED_F
        feet = [feet;j];
    elseif flags.cues(j-1)==cueType.FEED_H && flags.cues(j)~= cueType.FEED_H
        hands = [hands;j];
    end
    
    if flags.cues(j) == cueType.FEED_F && flags.cues(j-1) ~= cueType.FEED_F
        feet = [feet;j];
    elseif flags.cues(j)==cueType.FEED_H && flags.cues(j-1)~= cueType.FEED_H
        hands = [hands;j];
    end
    
    if flags.cues(j)==cueType.FEED_F || flags.cues(j)==cueType.FEED_H

        [~,posterior(j,:)] = predict(classifier,test(j,selected_features));
        previous = (1-alpha)*posterior(j,:)+ previous *(alpha);
        curr_decision(j,:) = previous;
        
    else
        posterior(j,:) = [0.5,0.5];
        previous = [0.5,0.5];
        curr_decision(j,:) = previous;
    end
    
    
end

thresh = 0.7;
time = [1:size(curr_decision,1)]/32;
figure
plot(time, curr_decision(:,2),'LineWidth',1.4);
grid on
grid minor
xlabel('Time (s)');
ylabel('Decision'),
hline(thresh,'','Threshold hands');
hline(1-thresh,'','Threshold feet');
vline(hands/32,'r');
vline(feet/32,'b');