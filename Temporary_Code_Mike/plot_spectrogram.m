function []  = plot_spectrogram(signal, channel, minmax,freq,shift)
% Plot the spectrogram of the signal for the given channel. Pass signal
% only as 3D matrices [Nwindows x Nfreq x Nchannels)
%If freq is not given it will assume it goes from 4 to 48 with step 2.
%Shift is set by default to 0.0625 seconds
% minmax is a vector [min max]

if  ~exist('freq','var')
    freq = 4:2:48;
    step = 2;
end

if  ~exist('shift','var')
    shift = 0.0625;% in seconds
end

if  ~exist('minmax','var')
    minmax = [min(signal(:)) max(signal(:))];
end

signal = flip(signal,2);
imagesc(log10(signal(:,:,channel)'),log10(minmax));
colormap jet
xlabel('Time (s)')
ylabel('Frequency (Hz)');
xticklabels(xticks*shift)
yticklabels(freq(end) - step*yticks+step)
