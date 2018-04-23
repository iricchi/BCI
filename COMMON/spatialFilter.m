function [ filtered_signals ] = spatialFilter( signals, sfilter_type )
% Apply spatial filterinfìg

    filtered_signals = cell(numel(signals),1);

    switch sfilter_type
        case 'CAR'
            for i = 1:numel(signals)
                filtered_signals{i} = bsxfun(@minus, signals{i}, mean(signals{i}, 2));
                %signalsF{i} = signals{i} - mean(signals{i},2);
            end

        case 'Lap'

        case 'BigLap'
            
        otherwise
            error('No such filter implemented');
       

    end

end

