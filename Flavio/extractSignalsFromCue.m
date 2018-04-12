%cueType is either CUEH or CUEF

function [signalExtracted, indexes] = extractSignalsFromCue(signals, bigM, cueType)
    
    signalExtracted = [];
    indexes = [];
    
    for i=1:size(bigM,1)
        if bigM(i,3) == cueType
            indexes = [indexes ; size(signalExtracted,1)+1];
            signalExtracted = [signalExtracted ; signals(bigM(i,2):bigM(i+1,2) + bigM(i+1,1),:)];
        end
    end
