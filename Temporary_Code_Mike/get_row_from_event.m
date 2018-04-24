function [ row_number ] = get_row_from_event( event_number )
global FIX CUEH CUEF CONT_FEED

if event_number == CUEH
    row_number = 2;
elseif event_number == CUEF
    row_number = 1;
elseif  event_number == FIX
    row_number = 4;
elseif event_number ==CONT_FEED
    row_number = 3;
else
    error('Event number not identified'); 
end


end

