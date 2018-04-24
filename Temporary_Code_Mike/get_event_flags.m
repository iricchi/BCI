function [ flag_event ] = get_event_flags( number_of_events , cue_number,InfoTrials )

row_idx = get_row_from_event(cue_number);

flag_event = [];

for i = 2:number_of_events
    if InfoTrials{3,2}(i)
       if InfoTrials{row_idx,2}(i-1) == InfoTrials{3,2}(i)
       
           flag_event = [flag_event;1];
       else
           flag_event = [flag_event;0];
       end
    end
end

end

