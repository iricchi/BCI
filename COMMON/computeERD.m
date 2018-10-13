function [ERD] = computeERD(signal, baseline)
%Computes the ERD given a series of event and baseline values
% WARNING :Pass only single windows or  mean value of the PSD (23x16 matrix)
% WARNING 2: Do not pass log PSD values

    ERD = 100 * (log10(signal+1) - log10(baseline+1)) ./ log10(baseline+1);
    
end