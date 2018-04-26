function [ psdSignals, flag ] = PSDdataGenerator( PSD, h, overlap )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    global cueType

    psdSignals = [];  %signals form files concatenated in one single struct
    flag.runs         = [];  %flags telling which file we are in
    flag.cues         = [];  %flags telling which window belongs to which cue
    flag.trial        = [];  % ''' the number of the trial inside the file
    flag.abstrial     = [];  % ''' the number of the trial out of all the files

    for i=1:numel(PSD)

        psdSignals = cat(1,psdSignals, PSD{i});
        flag.runs = [flag.runs; i*ones(size(PSD{i},1),1)];

        newpos = ceil( h{i}.EVENT.POS / overlap );
        newdur = ceil( h{i}.EVENT.DUR / overlap );
        flags  = nan(size(PSD{i},1),1);
        trials = nan(size(PSD{i},1),1);

        for k = 1:numel(newpos)

            if( h{i}.EVENT.TYP(k) == cueType.CONT_FEED && h{i}.EVENT.TYP(k-1) == cueType.CUEF)
                type = cueType.FEED_F;
            elseif( h{i}.EVENT.TYP(k) == cueType.CONT_FEED && h{i}.EVENT.TYP(k-1) == cueType.CUEH)
                type = cueType.FEED_H;
            else
                type = h{i}.EVENT.TYP(k);
            end

            flags(newpos(k):newpos(k)+newdur(k)) = type;
        end

        flag.cues = [flag.cues; flags];

        trial_n = 1;

        for j = find(h{i}.EVENT.TYP == cueType.FIX)'
            trials(newpos(j):newpos(j+2)+newdur(j+2)) = trial_n; 
            trial_n = trial_n + 1;
        end    

        flag.trial = [flag.trial; trials];
        flag.abstrial = [flag.abstrial; trials + (i-1)*max(trials)];
    end

end

