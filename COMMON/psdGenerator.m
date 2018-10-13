%% getting files of the subject

[ offline_names, online_names ] = getFileNamesFromDir( subject , parent_folder);

%% Extracting signals from files

signals_offline = cell(numel(offline_names),1);
signals_online  = cell(numel(online_names),1);

h_offline   = cell(numel(offline_names),1);
h_online    = cell(numel(online_names),1);

for i = 1:numel(online_names)
    [signals_online{i},  h_online{i}]  = extractSignalsFromFileName(online_names{i}, parent_folder, 'online');
end

for i = 1:numel(offline_names)
    [signals_offline{i}, h_offline{i}] = extractSignalsFromFileName(offline_names{i}, parent_folder, 'offline');
end

sampleRate = h_offline{1}.SampleRate;

%% SPATIAL FILTERING


signals_offline = spatialFilter( signals_offline, sfilter, lap );
signals_online  = spatialFilter( signals_online , sfilter, lap );


%% Power Spectral Density PSD - pwelch

psdParam.subject    = subject;
psdParam.sampleRate = sampleRate;
psdParam.nCh        = length(chanlocs16);
psdParam.duration   = 1;                                %length of windows in seconds
psdParam.shift      = 0.0625;                           %shift in seconds
psdParam.window     = sampleRate*psdParam.duration;     %length of win in samples
psdParam.overlap    = psdParam.shift*sampleRate;        %shift in samples
psdParam.f_interest = 4:2:48;                           %set of frequencies
psdParam.sfilter    = sfilter;
%Mapper from frequency in Hz to index in the psd array
psdParam.f_map = containers.Map(psdParam.f_interest,1:length(psdParam.f_interest));

[PSDoffline, ~, ~] = powerSpectralDensity( signals_offline , psdParam );
[PSDonline , ~, ~] = powerSpectralDensity( signals_online  , psdParam );

%% Generation of flags for PSDdata

[ psdSignalsOffline, flagOffline ] = PSDdataGenerator( PSDoffline, h_offline, psdParam.overlap );
[ psdSignalsOnline,  flagOnline  ] = PSDdataGenerator( PSDonline , h_online , psdParam.overlap );

clear PSDoffline PSDonline i signals_offline signals_online h_offline h_online


%% Saving the data 

psdOfflinestruct.psd = psdSignalsOffline;
psdOfflinestruct.params = psdParam;
psdOfflinestruct.flags = flagOffline;

psdOnlinestruct.psd = psdSignalsOnline;
psdOnlinestruct.params = psdParam;
psdOnlinestruct.flags = flagOnline;

save(fullfile(parent_folder, '\SavedPSD\',[subject,psdParam.sfilter,'_PSDOffline.mat']), 'psdOfflinestruct');
save(fullfile(parent_folder, '\SavedPSD\',[subject,psdParam.sfilter,'_PSDOnline.mat']), 'psdOnlinestruct');
