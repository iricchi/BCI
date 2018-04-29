function [minmax]  = plot_spectrogram(signal, channel, PSDparams, log, minmax)

% Plot the spectrogram of the signal for the given channel. Pass signal
% only as 3D matrices [Nwindows x Nfreq x Nchannels)
%If freq is not given it will assume it goes from 4 to 48 with step 2.
%Shift is set by default to 0.0625 seconds
% minmax is a vector [min max]

if  ~exist('log','var') || isempty(log)
    log = 'logOn';
end

if  ~exist('minmax','var') || isempty(minmax)
    minmax = [min(signal(:)) max(signal(:))];

end

signal = flip(signal,2);

switch log
    case 'logOn'
        imagesc(log10(signal(:,:,channel)'),log10(minmax));
    case 'logOff'
        imagesc(signal(:,:,channel)',minmax);
    otherwise
        imagesc(log10(signal(:,:,channel)'),log10(minmax));
end

step = floor(mean(diff(PSDparams.f_interest)));

colormap jet
xlabel('Time (s)')
ylabel('Frequency (Hz)');
title(['Spectrogram Average Trial ',PSDparams.subject,' subject with ',PSDparams.sfilter,' applied'])
xticklabels(xticks*PSDparams.shift)
yticklabels(PSDparams.f_interest(end) - step*yticks + step)
