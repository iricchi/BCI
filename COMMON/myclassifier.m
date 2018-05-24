function [curr_decision,curr_rawprobs] = myclassifier(EEG, previous , support)
%EEG is a matrix samples by channels (must be 512 x 16)
%Postprob is two values  between [2 x 1}
%Tic toc to measure time of execution, must be less than 0.0625 s (0.05)


switch support.sfilter
    case 'Lap'
        EEG = laplacian_filter(EEG,support.lapmatrix);
    case 'CAR'
        EEG = CAR(EEG);
end

PSD = pwelch(EEG(:,support.channels), size(EEG,1) ,support.overlap,support.f_interest,support.sampleRate);


% f_map = containers.Map(unique(support.f_interest),1:length(unique(support.f_interest)));
% ch_map = containers.Map(unique(support.channels),1:length(unique(support.channels)));

[~,curr_rawprobs] = predict(support.classifier,diag(PSD)');
curr_decision = support.alpha*curr_rawprobs + previous*(1-support.alpha);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Nested Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [signal_filtered] = laplacian_filter(EEG,lapmatrix)
 
        signal_filtered = zeros(size(EEG,1),size(EEG,2));
        for i = 1:size(EEG,1)
            signal_filtered(i,:) = EEG(i,:)*lapmatrix;
        end
    end
    
    function [signal_filtered] = CAR(EEG)
        signal_filtered = EEG - mean(EEG,2);
    end
end