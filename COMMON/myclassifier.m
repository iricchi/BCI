function [post] = myclassifier(EEG, classifier, sfilter, lapmatrix, selected_features)
%EEG is a matrix samples by channels (must be 512 x 16)
%Postprob is two values  between [2 x 1}
%Tic toc to measure time of execution, must be less than 0.0625 s (0.05)

overlap = 32;
f_interest  = 4:2:48;
sampleRate = 512;

EEG = laplacian_filter(EEG,lapmatrix);
PSD = pwelch(EEG, size(EEG,1) ,overlap,f_interest,sampleRate);

PSD = reshape(PSD,1,size(PSD,1)*size(PSD,2));

[~,postprob] = predict(classifier,PSD(selected_features));
if postprob(1)>0.5
    post = postprob(1);
else
    post = postprob(2);
end

    function [signal_filtered] = laplacian_filter(EEG,lapmatrix)
        signal_filtered = zeros(size(EEG,1),size(EEG,2));
        for i = 1:size(EEG,1)
            signal_filtered(i,:) = EEG(i,:)*lapmatrix;
        end
    end

end