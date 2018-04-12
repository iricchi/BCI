function [final_avg, t, f] = Spectrogram_function(thisEpoch1, thisEpoch2,num_channel,win,noverlap,freq)

%power_ratio=zeros(251, 32);

    for i=1:size(thisEpoch1.data,3)-1

        [~,f,t,p_baseline] = spectrogram(thisEpoch1.data(:,num_channel,i),win,noverlap,freq,win,'power');
        [~,f,t,p_MI] = spectrogram(thisEpoch2.data(:,num_channel,i),win,noverlap,freq,win,'power');

        power_avg_baseline = mean(p_baseline');

        %power_ratio = power_ratio + p_MI./(power_avg_baseline');
        power_ratio{i} = p_MI./(power_avg_baseline');
    end

    final_avg = sum(cat(3,power_ratio{:}),3)./size(thisEpoch1.data,3);

end