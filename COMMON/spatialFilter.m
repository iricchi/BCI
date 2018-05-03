function [ filtered_signals ] = spatialFilter( signals, sfilter_type, laplacian_matrix )
% Apply spatial filterinfìg

    if ~exist('laplacian_matrix','var') && strcmp(sfilter_type , 'Lap')
        
        error('Laplacian matrix needed')
    end
    
    filtered_signals = cell(numel(signals),1);

    switch sfilter_type
        case 'CAR'
            for i = 1:numel(signals)
                filtered_signals{i} = bsxfun(@minus, signals{i}, mean(signals{i}, 2));
                %signalsF{i} = signals{i} - mean(signals{i},2);
            end

        case 'Lap'
            for i = 1:numel(signals)
                disp(['Filtering run n. : ', i]);
                for j = 1 : length(signals{i})
                    filtered_signals{i}(j,:) = signals{i}(j,:)*laplacian_matrix;
                end
            end
            
        otherwise
            error('No such filter implemented');
       

    end

end

