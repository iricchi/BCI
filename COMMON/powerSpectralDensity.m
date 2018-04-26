function [ PSD , start, stop ] = powerSpectralDensity( signals, params )

    sampleRate  = params.sampleRate ;
    nCh         = params.nCh;
    duration    = params.duration;
    shift       = params.shift;
    window      = params.window;
    overlap     = params.overlap;
    f_interest  = params.f_interest;
    
    PSD         = cell(numel(signals),1);
    
    start = {};
    stop  = {};
    
    for i = 1 : numel(signals)
       
        start{i} = 1:sampleRate*shift:length(signals{i})-sampleRate*duration;
        stop{i}  =  start{i} + duration*sampleRate; 
            
        PSD{i} = zeros(length(start{i}),length(f_interest),nCh);
    
        for j = 1:length(start{i})    
            [PSD{i}(j,:,:),~] = pwelch(signals{i}(start{i}(j):stop{i}(j),:), window ,overlap,f_interest,sampleRate);
        end
        
    end

end

