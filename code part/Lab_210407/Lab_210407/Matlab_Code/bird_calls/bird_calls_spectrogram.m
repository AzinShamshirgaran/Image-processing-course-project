close all;
clear all;

%audio_file = 'Xeno_Canto_WilsonsWarbler.mp3';
audio_file = 'S2L_170401_Pepperwood_Chapperal-2017-04-01_10-20.wav';

% Read the audio file.
[x sample_rate] = audioread(audio_file);

length = size(x,1);
fprintf(1, 'audio is sampled at %d Hz and has length %f seconds\n', sample_rate, length/sample_rate);

length_seconds = length / sample_rate;

% Play the audio.
sound(x, sample_rate);

% Compute the 1D DFT.
x_fft = fft(x);

% Plot the spectrum of the DFT.
figure
plot( [0:size(x_fft,1)-1]/length_seconds, abs(x_fft) );

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
imwrite(s_spectrum_log_scale,strcat(audio_file,'.png'));



