clear all
close all
clc

%% Loading
name= 'Michael';

load(['InfoTrial_',name,'.mat']);

%% Computation

foot_feed = extract_signal(InfoTrials,3);
hand_feed = extract_signal(InfoTrials,2);

A_foot = mean_cell(foot_feed,0);
A_hand = mean_cell(hand_feed,0);
R =  mean_cell(InfoTrials{4,5},0);
A_footish =  mean_cell(InfoTrials{1,5},0);
for_spectrogram = [R;A_footish;A_foot];
minmax = [min(for_spectrogram(:)) max(for_spectrogram(:))];

figure
plot_spectrogram(for_spectrogram,8,minmax);

for i = 1 : 16
    subplot(4,4,i)
    plot_spectrogram(for_spectrogram,i,minmax);
end

%%

mean_A_foot = squeeze(mean(A_foot));
mean_A_hand = squeeze(mean(A_hand));

mean_R = squeeze(mean(R));

mean_ERD_foot = (100*((log10(mean_A_foot) - log10(mean_R))))./ mean_R;
mean_ERD_hand = (100*(log10(mean_A_hand) - log10(mean_R)))./ mean_R;

ERD_foot_interest = mean_ERD_foot(1:5,:);
ERD_hand_interest = mean_ERD_hand(1:5,:);

conc = [ERD_foot_interest;ERD_hand_interest];
minimum = min(conc(:));
maximum = max(conc(:));
figure
imagesc(ERD_foot_interest',[minimum,maximum])
