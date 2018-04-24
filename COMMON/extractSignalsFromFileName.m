function [ signals, sample_frequency ] = extractSignalsFromFileName( filename, parent_dir, type )
%   
%   type can be 'online' or 'offline'
%
%   parent folder is the folder of the project   
%
%   extract the signals from the selected file, keeping the 16 channels
%   needed

    if (~strcmp(type, 'online') && ~strcmp(type, 'offline'))
        error('Type of file can only be online or offline');
    end
    
    filedir = [parent_dir, '\Signals\' , type, '\', filename];

    if exist(filedir, 'file') ~= 2
        error('file not found');
    end
    
    [s,h] = sload(filedir);
    
    signals = s(:,1:end-1); % Let's consider only the 16 channels

    sample_frequency = h.SampleRate;
    
end

