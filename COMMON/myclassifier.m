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

PSD = pwelch(EEG, size(EEG,1) ,support.overlap,4:2:48,support.sampleRate);

PSD_reshaped = reshape(PSD,1,size(PSD,1)*size(PSD,2));

[~,curr_rawprobs] = predict(support.classifier,log10(PSD_reshaped(support.selected_features)));
curr_decision = (1-support.alpha)*curr_rawprobs + previous*(support.alpha);

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