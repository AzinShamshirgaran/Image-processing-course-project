close all;
clear all;

length_seconds = 4;
% Sample rate (samples per second).
sample_rate = 48000;
length = length_seconds * sample_rate;

% The frequencies of our two sine waves. Should be able to hear 1000 to 10000 Hz.
frequency1 = 1000;
frequency2 = 5000;

% The actual time samples at which we want to sample a sine wave.
samples = [0:length-1]/sample_rate;

% Append one sine wave after another.
x = cos(2*pi*frequency1 * samples(1:length/2));
x = [x cos(2*pi*frequency2 * samples((length/2)+1:end))];

% Play the sine wave.
sound(x, sample_rate);
% Save it.
audiowrite('two_sines_consec.wav', x, sample_rate);

% Plot the first 100 samples of the sine waves.
figure
plot(samples(1:100),x(1:100));
axis([0 samples(100) -2 2]);

% Compute the 1D DFT.
x_fft = fft(x);

% In debug mode, inspect x_fft.

% Plot the spectrum of the DFT.
figure
plot( abs(x_fft) );

% Now with correctly labeled frequency axis.
figure
plot( [0:size(x_fft,2)-1]/length_seconds, abs(x_fft) );

% The number of time samples to apply DFT to when computing the
% spectrogram.
window_length = 1024;
% The number of time samples the windows should overlap.
window_overlap = 0;

% Compute spectrogram.
[s,w,t,p] = spectrogram(x,window_length,window_overlap,[],sample_rate);
% Display spectrogram.
figure;
spectrogram(x,window_length,window_overlap,[],sample_rate,'yaxis');

% In debug mode, inspect
% s: matrix with the 2D spectrogram (will be complex).
% w: vector with the frequencies spacings of the computed DFT.
% t: vector with the time spacings of the windows.
% p: matrix with the power spectral density (PSD) of spectrogram. This is
% what is diplayed by spectrogram.

% Compute the spectrum of the spectrogram.
s_spectrum = abs(s);

% Let's treat s_spectrum as an image.
fprintf(1,'min(s_spectrum) = %f\n', min(min(s_spectrum)));
fprintf(1,'max(s_spectrum) = %f\n', max(max(s_spectrum)));

% Diplay s_spectrum as an image, scaling values to 0 to 1.
figure;
imshow(s_spectrum, []);

% It is upside-down so invert it.
s_spectrum = s_spectrum( end:-1:1, :);
figure;
imshow(s_spectrum, []);

% Scale values using log. Add eps so don't take log of 0.
s_spectrum_log = log10(s_spectrum + eps);
figure;
imshow(s_spectrum_log, []);

% Scale values to 0 to 1.
s_spectrum_log_scale = (s_spectrum_log - min(min(s_spectrum_log))) / (max(max(s_spectrum_log)) - min(min(s_spectrum_log)));
figure;
imshow(s_spectrum_log_scale);

% Save as png file.
imwrite(s_spectrum_log_scale,'two_sines_consec_spect.png');



