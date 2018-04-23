function [ mean_value ] = mean_cell( cell )
% Compute mean for cell vector

    mean_value = zeros(size(cell{1}));
    
    for i = 1:length(cell)
        mean_value = mean_value + cell{i};
    end
    mean_value = mean_value ./ length(cell);
    
end

