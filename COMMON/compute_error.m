function [err] = compute_error(labels, labels_predicted)

    err = length(find(labels ~= labels_predicted))/length(labels);
    
end