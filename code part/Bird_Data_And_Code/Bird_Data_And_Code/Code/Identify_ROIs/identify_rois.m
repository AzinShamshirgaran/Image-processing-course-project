clear all;
close all;

% root_dir of where to put annotated spectrograms, etc.
root_dir = '..\..\ROIs\';

% Where the computed spectrograms are located.
spectrogram_dir = '..\..\Spectrograms\';

% Where the ROI .csv files are located.
rois_dir = '..\..\ROIs\';

% The .csv file with the info about the ROIs.
rois_info_file = '..\..\ROIs\birds.csv';

% Read the ROI info.
rois_info = readtable(rois_info_file);

n_birds = 5;

% First row is header.
bird_names = rois_info{1:n_birds,{'bird'}};
roi_file = rois_info{1:n_birds,{'roi_file'}};
roi_count = rois_info{1:n_birds,{'roi_count'}};

for i=1:n_birds
    % Read ROI .csv file for this bird.
    roi_csv_file = char(strcat(rois_dir, roi_file(i)));
    bird_rois_info = readtable(roi_csv_file);

    n_rois = roi_count(i);
    
    % Get the recording names so we can retrieve the spectrograms.
    rois_recordings = bird_rois_info{1:n_rois,{'recording'}};
    
    % Get the start and end time and lower and upper frequency bounds for
    % each ROI.
    rois_time_start = bird_rois_info{1:n_rois,{'x1'}};
    rois_time_end = bird_rois_info{1:n_rois,{'x2'}};
    rois_frequency_lower = bird_rois_info{1:n_rois,{'y1'}};
    rois_frequency_upper = bird_rois_info{1:n_rois,{'y2'}};
    
    % Get the ROI IDs.
    roi_ids = bird_rois_info{1:n_rois,{'id'}};
    
    for j=1:n_rois

        % Always get original spectroram.
        recording = char(rois_recordings(j));
        spectrogram = strcat(recording,'.png');
        spectrogram_filename = strcat(spectrogram_dir, spectrogram);
        spectrogram_image = imread(spectrogram_filename);

        % Check to see if this spectrogram has already been marked with an
        % ROI.
        spectrogram_roi = strcat(recording(1:end-4),'.wav.roi.png');
        spectrogram_roi_filename = strcat(root_dir, char(bird_names(i)));
        spectrogram_roi_filename = strcat(spectrogram_roi_filename, '\');
        spectrogram_roi_filename = strcat(spectrogram_roi_filename, spectrogram_roi);

        if exist(spectrogram_roi_filename, 'file') == 2
            % Read already marked up spectrogram.
            spectrogram_roi_image = imread(spectrogram_roi_filename);
        else
            % Otherwise create new roi one.
            spectrogram_filename = strcat(root_dir, char(bird_names(i)));
            spectrogram_filename = strcat(spectrogram_filename, '\');
            spectrogram_filename = strcat(spectrogram_filename, spectrogram);
            spectrogram_roi_image = spectrogram_image;
        end
        
        n_rows = size(spectrogram_image, 1);
        n_cols = size(spectrogram_image, 2);
        
        % Get time and frequency coordinates.
        spectrogram_info = strcat(recording,'_info.txt');
        spectrogram_info_filename = strcat(spectrogram_dir, spectrogram_info);
        
        fileID = fopen(spectrogram_info_filename, 'r');
        time_coords = fscanf(fileID, '%f', [1 n_cols]);
        time_coords = time_coords';
        freq_coords = fscanf(fileID, '%f', [1 n_rows]);
        freq_coords = freq_coords';
        % Reverse.
        freq_coords = freq_coords(end:-1:1);
        fclose(fileID);
        
        % Find pixel bounds of ROI.
        top_left_row = find(freq_coords < rois_frequency_upper(j), 1);
        top_left_row = top_left_row - 1;
        bottom_right_row = find(freq_coords < rois_frequency_lower(j), 1);
        top_left_col = find(time_coords > rois_time_start(j), 1);
        top_left_col = top_left_col - 1;
        bottom_right_col = find(time_coords > rois_time_end(j), 1);
        width = bottom_right_col - top_left_col + 1;
        height = bottom_right_row - top_left_row + 1;
        
        % Draw rectangle.
        spectrogram_roi_image = insertShape(spectrogram_roi_image, 'rectangle', [top_left_col top_left_row width height]);
%        imshow(spectrogram_roi_image);
        
        % Save spectrogram with marked ROIs.
        imwrite(spectrogram_roi_image, spectrogram_roi_filename);
        
        % Extract and save ROI.
        image_roi = spectrogram_image(top_left_row:bottom_right_row, top_left_col:bottom_right_col);
%        imshow(image_roi);
        image_roi_filename = strcat(root_dir, char(bird_names(i)));
        image_roi_filename = strcat(image_roi_filename, '\ROIs\');
        image_roi_filename = strcat(image_roi_filename, char(bird_names(i)));
        image_roi_filename = strcat(image_roi_filename, '_');
        image_roi_filename = strcat(image_roi_filename, num2str(roi_ids(j)));
        image_roi_filename = strcat(image_roi_filename, '.png');
        imwrite(image_roi, image_roi_filename);
        
    end
   
end
