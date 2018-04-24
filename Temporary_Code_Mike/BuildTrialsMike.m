function [ InfoTrials ] = BuildTrialsMike( EventIds, Pos, Typ, Dur, Sig)

    global CUEH CUEF

    for i = 1:length(EventIds)
        InfoTrials{i,1} = EventIds(i);
        InfoTrials{i,2} = Typ == EventIds(i);  % Flag that tells if the event is the one in the row
        InfoTrials{i,3} = Pos(InfoTrials{i,2}); % Start Pos 
        durs = unique(Dur(InfoTrials{i,2}));
        Duration = min(durs); %choose the minimum duration of the trial
        InfoTrials{i,4} = InfoTrials{i,3} + Duration - 1; % Stop Pos because MATLAB
                                                          % start from 1
        %Signals splitting
        Num_freq  = size(Sig,2);
        NumTrials = length(InfoTrials{i,3});
        NumChannels = 16;
        Trials =cell(NumTrials,1);
        
        for trId = 1:NumTrials
            cstart = InfoTrials{i,3}(trId);
            cstop = InfoTrials{i,4}(trId);
            Trials{trId}(:,:,:) = Sig(cstart:cstop,:,:);
        end
        disp(['Epoching of eventID ', num2str(EventIds(i)), ' finished!'])
        InfoTrials{i,5} = Trials;
    end
    
    flags_hand = get_event_flags(length(InfoTrials{1,2}), CUEH,InfoTrials);
    flags_foot = get_event_flags(length(InfoTrials{1,2}), CUEF,InfoTrials);
    
    InfoTrials{3,5}(:,2) = num2cell(flags_hand);
    InfoTrials{3,5}(:,3) = num2cell(flags_foot);

    InfoTrials{length(EventIds)+1,1} = 'EventID';
    InfoTrials{length(EventIds)+1,2} = 'FlagEvent';
    InfoTrials{length(EventIds)+1,3} = 'StartPosition';
    InfoTrials{length(EventIds)+1,4} = 'StopPosition';
    InfoTrials{length(EventIds)+1,5} = 'Signals';
    
    len = length(InfoTrials{3,5});
    InfoTrials{3,5}(len+1,1) = cellstr('Signal');
    InfoTrials{3,5}(len+1,2) =cellstr('Han1dFlag');
    InfoTrials{3,5}(len+1,3) = cellstr('FootFlag');


end

