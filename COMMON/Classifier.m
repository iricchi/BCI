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
load(fullfile(parent_folder, 'Features', [subject, sfilter, '_features.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;
%% 
% 
% skipped=0;
% for i = 1:length(unique(flags.runs))
% %     if ((i~=6) && (i~=7))
% %         skipped = skipped +1;
% %         continue
% %     end
%     PSD_hand_run{i-skipped} = log10(PSDoff(flags.runs == i & (flags.cues == cueType.FEED_H),:,:));
% 
%     PSD_foot_run{i-skipped} = log10(PSDoff(flags.runs == i & (flags.cues == cueType.FEED_F),:,:));
% 
%     PSD_flattened_foot{i-skipped} = reshape(PSD_foot_run{i-skipped},size(PSD_foot_run{i-skipped},1),...
%         size(PSD_foot_run{i-skipped},2)*size(PSD_foot_run{i-skipped},3)); %flattens the 3D matrix
% 
%     PSD_flattened_hand{i-skipped} = reshape(PSD_hand_run{i-skipped},size(PSD_hand_run{i-skipped},1),...
%         size(PSD_hand_run{i-skipped},2)*size(PSD_hand_run{i-skipped},3));
% 
%     data{i-skipped} = [PSD_flattened_foot{i-skipped};PSD_flattened_hand{i-skipped}];
%     label{i-skipped} = [ones(size(PSD_flattened_foot{i-skipped},1),1);...
%         2*ones(size(PSD_flattened_hand{i-skipped},1),1)];
% end
% %% Train
% dataset = [data{1}(:,features.selected);data{2}(:,features.selected)];
% labels = [label{1};label{2}];
% 
% classifier = fitcdiscr(dataset,labels,'DiscrimType','diagquadratic');
%  save(fullfile(parent_folder, 'Features', [subject, sfilter, '_classifier.mat']),'classifier');

%%
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
features_selected = features.selected;
%clearvars -except data label f_map features_selected

%% 
data_selected = [];
label_selected = [];
for i = 1:length(unique(flags.runs))-1
    data_selected = [data_selected;data{i}(:,features_selected)];
    label_selected = [label_selected;label{i}];
end

test_selected = data{end}(:,features_selected);

feet = find(label_selected ==1);
hands = find(label_selected ==2);

classifier = fitcdiscr(data_selected,label_selected);
% %% Projection onto canonical space
% 
% m1 = classifier.Mu(1,:);
% m2 = classifier.Mu(2,:);
% 
% w = (classifier.Sigma)\(m1-m2)'; %check the formula
% 
% y = w'*data_selected';
% 
% y_feet  = log10(y(label_selected == 1 ));
% y_hands = log10(y(label_selected == 2 ));
% 
% x = -3:0.001:3;
% figure()
% [m,s] = normfit(y_feet);
% y = normpdf(x,m,s);
% plot(x,y,'b');
% %hold on 
% %histogram(y_feet,30,'Facecolor','b');
% hold on 
% [m,s] = normfit(y_hands);
% y = normpdf(x,m,s);
% plot(x,y,'r');
% %hold on 
% %histogram(y_hands,30,'Facecolor','r');

%%
save(fullfile(parent_folder, 'Features', [subject, sfilter, '_classifier.mat']),'classifier');


%%
[prediction,postprob] = predict(classifier,test_selected);

error = length(find(prediction ~= label{end}))/length(label{end});

%% Rolling crossvalidation 


load(fullfile(parent_folder, 'Features', [subject, sfilter, '_features.mat']));
features_selected = features.selected;

for i = 1:length(unique(flags.runs))
    
    PSD_hand_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.FEED_H),:,:));

    PSD_foot_run{i} = (PSDoff(flags.runs == i & (flags.cues == cueType.FEED_F),:,:));

    PSD_flattened_foot{i} = reshape(PSD_foot_run{i},size(PSD_foot_run{i},1),...
        size(PSD_foot_run{i},2)*size(PSD_foot_run{i},3)); %flattens the 3D matrix

    PSD_flattened_hand{i} = reshape(PSD_hand_run{i},size(PSD_hand_run{i},1),...
        size(PSD_hand_run{i},2)*size(PSD_hand_run{i},3));

    data{i} = [log10(PSD_flattened_foot{i}(:,features_selected));log10(PSD_flattened_hand{i}(:,features_selected))];
    label{i} = [ones(size(PSD_flattened_foot{i},1),1);...
        2*ones(size(PSD_flattened_hand{i},1),1)];
end


%% 

mean_train_error = [];
mean_test_error = [];

classifierType = {'diaglinear', 'diagquadratic', 'linear','pseudoquadratic','Logistic'};

for j = 1:numel(classifierType)
    
    labels_train = [];
    train = [];
    test = [];

    for i = 1 : length(data)-2

        train = [train ; data{i}];    
        labels_train = [labels_train; label{i}];
         
        test = data{i+1};
        labels_test = label{i+1};
        
        
        if ~strcmp(classifierType{j},'Logistic')
            classifier = fitcdiscr(train,labels_train, 'DiscrimType', classifierType{j});
            labels_predicted_test = predict(classifier, test);
            labels_predicted_train = predict(classifier, train);

        else
            B = mnrfit(train,labels_train);
            post_test = mnrval(B, test);
            post_train = mnrval(B, train);
            labels_predicted_test = 1+round(post_test(:,2));
            labels_predicted_train = 1+round(post_train(:,2));

        end
       
        training_err(i,j) = compute_error(labels_train, labels_predicted_train);
        training_err_class(i,j) = classerror(labels_train, labels_predicted_train);
             
        testing_err(i,j) = compute_error(labels_test, labels_predicted_test);
        testing_err_class(i,j) =  classerror(labels_test,labels_predicted_test);
    end
    
    mean_train_error(j) = mean(training_err(:,j),1);
    std_train_error(j) = std(training_err(:,j),1);
    
    mean_train_error_class(j) = mean(training_err_class(:,j),1);
    std_train_error_class(j) = std(training_err_class(:,j),1);
    
    mean_test_error(j) = mean(testing_err(:,j),1);
    std_test_error(j) = std(testing_err(:,j),1);
    
    mean_test_error_class(j) = mean(testing_err_class(:,j),1);
    std_test_error_class(j) = std(testing_err_class(:,j),1);
    
    
    train = [train ; data{i+1}];
    labels_train = [labels_train; label{i+1}];

        
%     labels_predicted_train = predict(classifier, train);
%     training_err(i,j) = compute_error(labels_train, labels_predicted_train);
    
    %validation
    valid = data{i+2};
    labels_valid = label{i+2};

    if(~strcmp(classifierType{j},'Logistic'))
        classifier = fitcdiscr(train,labels_train, 'DiscrimType', classifierType{j});
        [labels_predicted_valid,post_valid] = predict(classifier, valid);
        for_ROC(:,j) = post_valid(:,1);
    else 
        B = mnrfit(train,labels_train);
        post_valid = mnrval(B, valid);
        for_ROC(:,j) = post_valid(:,1);
        
        labels_predicted_valid = 1+round(post_valid(:,2));
    end
    
    valid_err(j) = compute_error(labels_valid, labels_predicted_valid);
    valid_err_class(j) = classerror(labels_valid, labels_predicted_valid);
    
    
end

[~,best_classifier] = min(mean_test_error);

%% Projection onto canonical space
train = [];
labels_train = [];
for i = 1:length(data)
    train = [train;data{i}];
    labels_train =[labels_train; label{i}];
end

classifier = fitcdiscr(train,labels_train, 'DiscrimType', 'Linear');

m1 = classifier.Mu(1,:);
m2 = classifier.Mu(2,:);

w = inv(classifier.Sigma)*(m1-m2)'; %check the formula

y = w'*data_selected';

y_feet  = log10(y(label_selected == 1 ));
y_hands = log10(y(label_selected == 2 ));

x = -3:0.001:3;
figure()
[m,s] = normfit(y_feet);
y = normpdf(x,m,s);
plot(x,y,'b');
%hold on 
%histogram(y_feet,30,'Facecolor','b');
hold on 
[m,s] = normfit(y_hands);
y = normpdf(x,m,s);
plot(x,y,'r');
%hold on 
%histogram(y_hands,30,'Facecolor','r');


%% Plotting the results

figure
h = barwitherr(std_test_error, mean_test_error);
set(gca,'XTickLabel',{'Diaglinear','Linear','DiagQuadratic','Quadratic','Logistic Reg'})
set(h,'FaceColor',[0.5,0.7,0.9])
grid on
grid minor
ylabel('Class Error')
title('Validation Error in Rolling CV')

[p,h] = anova1(testing_err);

%%
figure
[X,Y,T,AUC]=perfcurve(labels_valid,for_ROC(:,1),1);
plot(X,Y,'LineWidth',1.4)
hold on
[X,Y,T,AUC]=perfcurve(labels_valid,for_ROC(:,2),1);
plot(X,Y,'LineWidth',1.4)
[X,Y,T,AUC]=perfcurve(labels_valid,for_ROC(:,3),1);
plot(X,Y,'LineWidth',1.4)
[X,Y,T,AUC]=perfcurve(labels_valid,for_ROC(:,4),1);
plot(X,Y,'LineWidth',1.4)
[X,Y,T,AUC]=perfcurve(labels_valid,for_ROC(:,5),1);
plot(X,Y,'LineWidth',1.4)

legend('Diaglinear','DiagQuadratic','Linear','Quadratic','Logistic')
xlabel('False positive rate') 
ylabel('True positive rate')
title('ROC for various classifier types')
grid on
grid minor
set(gca,'fontsize',16)


