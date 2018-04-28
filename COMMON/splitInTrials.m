function [ events_trialed ] = splitInTrials( events, trial_flags )
% Takes in the concatenated signals of same type events and re arrange them
% adding one extra dimension that accounts for the trial the signal is in:
% example input : fixation windows concatenated: dim[windows, freq, chs]
%                 flags telling which window belongs to which trial
% example output: same signals but one dimension to describe the trial#
%                 the trial length is set as the minimum legth along the
%                 trials, dim[#trials, windows, freq, chs]


    %compute minimum trial lenght to extract them all of the same size
    min_tr_lenght = min(sum(trial_flags(:) == unique(trial_flags)'));

    %fixations_mat dimensions: [n_trial, windows, freq, ch]
    events_trialed = nan(length(unique(trial_flags)),min_tr_lenght, size(events,2), size(events,3));

    array_idx = 0;
    
    for i=unique(trial_flags)'
       array_idx = array_idx + 1;
       idx = find(trial_flags == i);
       events_trialed(array_idx,:,:,:) = events(idx(1:min_tr_lenght),:,:); 
    end


end

