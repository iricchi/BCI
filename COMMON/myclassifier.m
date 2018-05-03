function [postprob] = myclassifier(EEG,...)
%EEG is a matrix samples by channels (must be 512 x 16)
%Postprob is two values  between [2 x 1}
%Tic toc to measure time of execution, must be less than 0.0625 s (0.05)

