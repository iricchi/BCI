clear;
close;

addpath(genpath('biosig'));
addpath(genpath('folder_runs'));
addpath(genpath('data'));
addpath(genpath('eeglab13_4_4b'));


load('channel_location_16_10-20_mi');

filename = 's_run1_offlineMIterm_20180703154501.gdf';
[s, h]= sload(filename);



session.fs=h.SampleRate;
session.data=(s)';
session.channels={chanlocs16.labels};
session.Event_type=h.EVENT.TYP;
session.Event_pos=h.EVENT.POS;

%% pwelch
epoch_baseline=epoch_struct(session,200,0,3);
epoch_MI=epoch_struct(session,400,0,3);

for i=1:size(chanlocs16)
   [pwelch_bas_onechannel,freq_1]=pwelch_for_each_channel(i,epoch_baseline,500,epoch_baseline.fs); 
   [pwelch_MI_onechannel,freq_2]=pwelch_for_each_channel(i,epoch_MI,500,epoch_MI.fs); 
   figure
   plot(freq_1,10*log10(pwelch_bas_onechannel),freq_2,10*log10(pwelch_MI_onechannel))
   xlabel('Frequency [Hz]');
   ylabel('Power Spectral Density [dB]');
   title(sprintf('spectral density for channels %s',epoch_baseline.channels{1,i}));
   
end    

%% temporal filtering on the raw data
[b,a]=butter(2,[5 40]/h.SampleRate/2); %bandpass
data_filter=session.data;
for i=1:size(chanlocs16,2)
    data=session.data(i,:);
    data_filter(i,:)=filter(b,a,data);
end 

session_filt=session;
session_filt.data=data_filter;
%session_filt.data(17,:)=zeros(1,length(session_filt.data(2,:)));
filt_epoch_baseline=epoch_struct(session_filt,200,0,3);
filt_epoch_MI=epoch_struct(session_filt,400,-2,8);

for i=1:16
   [filt_pwelch_bas_onechannel,freq]=pwelch_for_each_channel(i,filt_epoch_baseline,500,filt_epoch_baseline.fs); 
   [filt_pwelch_MI_onechannel,freq]=pwelch_for_each_channel(i,filt_epoch_MI,500,filt_epoch_MI.fs); 
   figure
   plot(freq,10*log10(pwelch_bas_onechannel),freq,10*log10(pwelch_MI_onechannel),freq,10*log10(filt_pwelch_bas_onechannel),freq,10*log10(filt_pwelch_MI_onechannel))
   xlabel('Frequency [Hz]');
   ylabel('Power Spectral Density [dB]');
end    

%% spatial filtering on the raw data.CAR
medium_channels=mean(s');
signal_car=zeros(size(s,1),size(s,2));
 for i=1:size(s,1)
    signal_car(i,:)=s(i,:)-medium_channels(1,i);

 end

plot(s(:,9))
hold on
plot(signal_car(:,9)')
title (sprintf('car filter and raw signal for the channel %d',9));
xlabel('CAR signal');
ylabel('raw signal');
%% laplacian filter

load('laplacian_16_10-20_mi.mat');

% for i=1:size(s,2)-1
%     signal_laplacian(:,i)= s(:,i) - lap*s(:,1:16);
% end

signal_laplacian = s(:,1:16)*lap; %change channel and sample rate

subplot(3,1,1)
plot(s(:,9))
subplot(3,1,2)
plot(signal_laplacian(:,9))
subplot(3,1,3)
plot(signal_car(:,9))
  

%% spectrogram

Cyclic_freq=[12:0.1:30];

for i=1:16
    
   [spect_for_one_channel,t, f]=Spectrogram_function(epoch_baseline, epoch_MI, i, epoch_baseline.fs, epoch_baseline.fs-32, Cyclic_freq);
   
  % spect_tot(i,:,:)=spect_for_one_channel;
   
   figure;
   imagesc('XData',t,'YData',f,'CData', 10*log10(spect_for_one_channel)); % in order to put in line the ferquencies and teh time
    %caxis(-5 5)
end

%% topoplot
spect_for_one_channel_top=zeros(16,1);

for i=1:16
  
    [spect_for_one_channel,t, f]=Spectrogram_function(epoch_baseline, epoch_MI, i, epoch_baseline.fs, epoch_baseline.fs-32, Cyclic_freq);
    
         spect_for_one_channel_top(i)=mean(spect_for_one_channel(:,1));
         
   
end
    
    topoplot(spect_for_one_channel_top(1),chanlocs16,'style','both','electrodes','ptslabels','chaninfo', session.channels);