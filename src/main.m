% ===============================================
% ECE 6255 - Digital Processing of Speech Signals
%       Georgia Institute of Technology
%                Team 8, main.m
%
% Last Modified Date: 3/15/2026
% ===============================================

clc;
clear;
close all;

% Select input file
[file, path] = uigetfile('*.wav', 'Select a speech WAV file');
if isequal(file, 0)
    disp('No file selected.');
    return;
end

filePath = fullfile(path, file);

% Load signal
[x, fs, fileName] = load_audio_file(filePath);

% Parameters
params = get_params(fs);

% Feature extraction
features = extract_features(x, fs, params);

% Classification
labels = classify_frames(features, params);
labels = smooth_frame_labels(labels);

% Boundary detection
boundaries = detect_boundaries(labels, features, params, fs);

% Build sample-level segmentation track for plotting
segTrack = build_segmentation_track(length(x), labels, params.hop_len);

% Print results
disp('Low-level boundary times in seconds:');
disp(boundaries.low_times);

disp('Phoneme-like boundary times in seconds:');
disp(boundaries.phoneme_times);

disp('Syllable-like boundary times in seconds:');
disp(boundaries.syllable_times);

disp('Word-like boundary times in seconds:');
disp(boundaries.word_times);

% Plot
plot_segmentation_results(x, fs, features, labels, segTrack, boundaries, fileName);