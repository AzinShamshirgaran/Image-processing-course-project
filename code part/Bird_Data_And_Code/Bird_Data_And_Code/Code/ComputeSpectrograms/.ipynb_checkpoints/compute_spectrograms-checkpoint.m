clear all;
close all;

% Expect the sampling rate to be the same for all recordings.
sampling_rate_expected = 44100;

% The window size for the spectrogram.
window_size = 1024;

% The window overlap for the spectrogram.
window_overlap = 512;

recording_dir = '..\..\Recordings\';
spectrogram_dir = '..\..\Spectrograms\';

% Write spectrogram parameters.
parameters_filename = strcat(spectrogram_dir, '0_spectrogram_parameters.txt');
fileID = fopen(parameters_filename,'w');
fprintf(fileID, 'sampling rate = %d\n', sampling_rate_expected);
fprintf(fileID, 'window size = %d\n', window_size);
fprintf(fileID, 'window overlap = %d\n', window_overlap);
fprintf(fileID, 'log10 of spectrum\n');
fclose(fileID);

% Get list of recordings.
recording_list = dir(recording_dir);

%fig1 = figure;
%fig2 = figure;
%fig3 = figure;

% First two entries in recording_list are '.' and '..' so start with third.
n_recordings = size(recording_list, 1) - 2;
for i=3:n_recordings + 2
   
    % Read audio file.
    recording_filename = strcat(recording_dir, recording_list(i).name);
    fprintf(1, 'recording %d of %d: about to read %s\n', i-2, n_recordings, recording_list(i).name);
    [x sampling_rate] = audioread(recording_filename);
    
    if sampling_rate ~= sampling_rate_expected
        fprintf(1,'WRONG SAMPLING RATE: expected=%d, recording=%d\n', sampling_rate_expected, sampling_rate);
        return
    end
    
    % Compute the spectrogram.
    [s,w,t,p] = spectrogram(x, window_size, window_overlap, [], sampling_rate );
    
    % s: matrix with the 2D spectrogram (will be complex).
    % w: vector with the frequencies spacings of the computed DFT.
    % t: vector with the time spacings of the windows.
    % p: matrix with the power spectral density (PSD) of spectrogram. This is what is displayed by spectrogram.
    
    % Compute the spectrum of the spectrogram.
    s_spectrum = abs(s);
    
    % It is upside-down so invert it.
    s_spectrum = s_spectrum( end:-1:1, :);
%    figure(fig1);
%    imshow(s_spectrum, []);

    % Scale values using log. Add eps so don't take log of 0.
    s_spectrum_log = log10(s_spectrum + eps);
 %   figure(fig2);
 %   imshow(s_spectrum_log, []);

    % Scale values to 0 to 1.
    s_spectrum_log_scale = (s_spectrum_log - min(min(s_spectrum_log))) / (max(max(s_spectrum_log)) - min(min(s_spectrum_log)));
%    figure(fig1);
%    imshow(s_spectrum_log_scale);

    % Save as png file.
    spectrogram_filename = strcat(spectrogram_dir, recording_list(i).name, '.png')
    imwrite(s_spectrum_log_scale, spectrogram_filename);

    % Save time and frequency indices.
    spectrograminfo_filename = strcat(spectrogram_dir, recording_list(i).name, '_info.txt')
    fileID = fopen(spectrograminfo_filename,'w');
    fprintf(fileID,'%f\n',t);
    fprintf(fileID,'%f\n',w');
    fclose(fileID);
    
%    pause;

end


