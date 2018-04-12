function [ InfoEpoch ] = BuildEpoch( EventIds, Pos, Typ, Dur, Sig)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    for i = 1:length(EventIds)    
        InfoEpoch{i,1} = EventIds(i);
        InfoEpoch{i,2} = Typ == EventIds(i);  % indexes
        InfoEpoch{i,3} = Pos(InfoEpoch{i,2}); % Start Pos
        durs = unique(Dur(InfoEpoch{i,2}));
        Duration = min(durs); %choose the minimum duration of the trial
        InfoEpoch{i,4} = InfoEpoch{i,3} + Duration-1; % Stop Pos because MATLAB
                                                      % start from 1
        %Epoching 
        NumTrials = length(InfoEpoch{i,3});
        NumChannels = 16;
        Epoch = zeros(Duration, NumChannels, NumTrials);
        for trId = 1:NumTrials
            cstart = InfoEpoch{i,3}(trId);
            cstop = InfoEpoch{i,4}(trId);
            
            Epoch(:,:, trId) = Sig(cstart:cstop,:);
        end
        disp(['Epoching of eventID ', num2str(EventIds(i)), ' finished!'])
        InfoEpoch{i,5} = Epoch;
    end
    
   


end

