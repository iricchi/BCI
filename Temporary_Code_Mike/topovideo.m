function [  ] = topovideo( signal, sample_rate,channel_loc )
%Make an animated topoplot to visualize the variation of eeg signal during
%event
speedup = 10; %just to try
figure()
%btn = uicontrol('Style', 'pushbutton', 'String', 'STOP','CallBack',@stop);
for i = 1 : speedup: length(signal)
    
    topoplot(signal(i,:),channel_loc);
    title(sprintf('Time = %.1f s', i/sample_rate));
    pause(1/(sample_rate))
   
    clf
    
    
end

end

