% ============================================================
% ECE 6255 — Speech segmentation (voiced / unvoiced / silence)
% Georgia Institute of Technology
% Team: Jaxon Topel, Adrian Cruz, Michael Ritz
% ============================================================

clc;
clear;
close all;

% get root folder of project
rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir)
    rootDir = pwd;
end

% move to project folder
cd(rootDir);

% make results folder if needed
resultsDir = fullfile(rootDir, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% let user choose a wav file
[file, path] = uigetfile({'*.wav', 'WAV files'}, 'Select a speech WAV file', ...
    fullfile(rootDir, 'example_wavs'));

% stop if no file was selected
if isequal(file, 0)
    disp('No file selected.');
    return
end

% build full file path and load audio
filePath = fullfile(path, file);
[x, fs, fileName] = load_audio_file(filePath);

% get parameters and compute features
p = params(fs);
features = compute_features(x, fs, p);

% classify each frame and smooth the labels
labels = classify_frames(features, p);
labels = smooth_labels(labels, p);

% detect different boundary types
boundaries = detect_boundaries(labels, features, p, fs);

% expand frame labels to sample-level track
segTrack = build_segmentation_track(length(x), labels, p.hop_len);

% display boundary times in command window
disp('Low-level boundary times (s):');
disp(boundaries.low_times');

disp('Phoneme-like boundary times (s):');
disp(boundaries.phoneme_times');

disp('Syllable-like boundary times (s):');
disp(boundaries.syllable_times');

disp('Word-like boundary times (s):');
disp(boundaries.word_times');

% plot and save final segmentation results
plot_segmentation(x, fs, features, labels, segTrack, boundaries, fileName, resultsDir);

% show where results were saved
fprintf('Saved figure under: %s\n', resultsDir);
