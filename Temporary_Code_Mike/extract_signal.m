function [ signal ] = extract_signal( InfoTrials, column_of_interest )
    
    if (column_of_interest~=2) && (column_of_interest~=3)
        error('Wrong column specified')
    end

    idx = find(cell2mat(InfoTrials{3,5}(1:end-1,column_of_interest)));
    signal = InfoTrials{3,5}(idx,1);
end

