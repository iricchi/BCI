function [ struct_epoch ] = epoch_struct( session,Align_Event,timebEvent,timeaEvent)

     s=(session.data)'; 
     struct_epoch.fs=session.fs;
     struct_epoch.channels=session.channels;
     struct_epoch.Event_type=session.Event_type(session.Event_type==Align_Event);
     struct_epoch.Event_pos=session.Event_pos(session.Event_type==Align_Event);
     NumTrials=size(struct_epoch.Event_type,1); % because in each trials we'll have the same epoch, considering one is still enough.
     NumChannels=size(s,2);
     cstart=abs((timebEvent*struct_epoch.fs)-struct_epoch.Event_pos-1);%position of the aligned event minus the afterEvent
     cstop=(timeaEvent*struct_epoch.fs)+struct_epoch.Event_pos-1;

     for trId=1:NumTrials
        cstart_=cstart(trId);%position of the aligned event minus the afterEvent
        cstop_=cstop(trId);
        %disp(['continuos feedback for trial' ,num2str( trId), 'start at', num2str( cstart) ,'end at', num2str(cstop)]);
        ContFeed(:,:,trId)=s(cstart_:cstop_,1:NumChannels); %(time-sample, channels,trials)    %extract the continuos feed of the data from the file
    end
    struct_epoch.data=ContFeed;
  end