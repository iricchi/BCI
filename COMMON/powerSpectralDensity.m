function [ PSD ] = powerSpectralDensity( signals, params )

    sampleRate  = params.sampleRate ;
    nCh         = params.nCh;
    duration    = params.duration;
    shift       = params.shift;
    window      = params.window;
    overlap     = params.overlap;
    
    PSD         = cell(numel(signals),1);
    
    for i = 1 : numel(signals)
       
        start = 1:sampleRate*shift:length(signals{i})-sampleRate*duration;
        stop = duration*sampleRate:sampleRate*shift:length(signals{i}); 
        f_interest = 4:2:48;
    
        PSD{i} = zeros(length(start),length(f_interest),nCh);
    
        for j = 1:length(start)    
            [PSD{i}(j,:,:),~] = pwelch(signals{i}(start(j):stop(j),:), window,overlap,f_interest,sampleRate);
        end
        
    end

end

