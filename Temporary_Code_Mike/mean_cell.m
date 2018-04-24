function [ mean_value ] = mean_cell( cell,flag_presence )
% Compute mean for cell vector
    if flag_presence
        len = length(cell);
    else
        len = length(cell) - 1;
        
    mean_value = zeros(size(cell{1}));
    
    for i = 1:len
        mean_value = mean_value + cell{i};
    end
    mean_value = mean_value ./ length(cell);
    
end

