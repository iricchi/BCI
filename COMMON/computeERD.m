function [ERD] = computeERD(signal, baseline)
%Computes the ERD given a series of event and baseline values    
    
    %Adapt the lengths of the signals to be the same
    if length(signal) < length(baseline)
        baseline = baseline(1:length(signal),:,:);
    end
    
    ERD = 100 * (log10(signal) - log10(baseline)) ./ (baseline);
    
end