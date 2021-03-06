%% Loading data

load(fullfile(parent_folder, 'SavedPSD', [subject, sfilter, '_PSDOffline.mat']));

PSDoff = psdOfflinestruct.psd;
flags  = psdOfflinestruct.flags;
params = psdOfflinestruct.params;

clear psdOfflinestruct

f_map = params.f_map;

%% Compute ERD

feetPSD = PSDoff(flags.cues == cueType.CUEF | flags.cues == cueType.FEED_F,:,:);
handsPSD = PSDoff(flags.cues == cueType.CUEH | flags.cues == cueType.FEED_H,:,:);
baseline = PSDoff(flags.cues == cueType.FIX ,:,:);


%% Compute the mean along all windows and the mean ERD 

mean_base  = squeeze(mean(baseline,1));
mean_feet  = squeeze(mean(feetPSD,1));
mean_hands = squeeze(mean(handsPSD,1));

mean_ERD_feet = computeERD(mean_feet,mean_base);
mean_ERD_hands = computeERD(mean_hands,mean_base);

%% Plot
muband = f_map(8):f_map(12);
muband2 = f_map(12):f_map(14);

betaband = f_map(12):f_map(16);
betaband2 = f_map(16):f_map(20);
betaband3 = f_map(20):f_map(28);

frequency_set = {muband,muband2,betaband,betaband2,betaband3};
f_name = {'8-12','12-14','12-16','16-20','20-28'};

for i = 1 : length(frequency_set)
    
    ERDfeet_f_interest = squeeze(mean(mean_ERD_feet(frequency_set{i},:),1));
    ERDhands_f_interest = squeeze(mean(mean_ERD_hands(frequency_set{i},:),1));
    
    concatenated = [ERDfeet_f_interest;ERDhands_f_interest];
    minimum = min(concatenated(:));
    maximum = max(concatenated(:));
    minmax = [minimum,maximum];
    
    figure('Name',['Topoplot_',params.subject,params.sfilter,'_',f_name{i}],'pos',[0 0 1920 1080]) 
    subplot(1,2,1)
    topoplot(ERDfeet_f_interest,chanlocs16,'maplimits',minmax,'electrodes','labels','plotrad',0.3,'headrad',0.3);
    colorbar
    title('Both feet')
    
    subplot(1,2,2)
    topoplot(ERDhands_f_interest,chanlocs16,'maplimits',minmax,'electrodes','labels','plotrad',0.3,'headrad',0.3);
    colorbar
    title('Both hands')
    
    suptitle([params.subject,' in frequency band ',f_name{i},' Hz'])
    
end
