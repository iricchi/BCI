 function [ filtered_signals ] = spatialFilter( signals, sfilter_type, laplacian_matrix )
% Apply spatial filtering

    if ~exist('laplacian_matrix','var') && strcmp(sfilter_type , 'Lap')
        
        error('Laplacian matrix needed')
    end
    
    filtered_signals = cell(numel(signals),1);

    switch sfilter_type
        case 'CAR'
            for i = 1:numel(signals)
                filtered_signals{i} = bsxfun(@minus, signals{i}, mean(signals{i}, 2));
            end

        case 'Lap'
            for i = 1:numel(signals)
                filtered_signals{i} = signals{i} * laplacian_matrix;
            end
            
        otherwise
            error('No such filter implemented');
       

    end

end

