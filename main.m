% ============================================================
% ECE 6255 — Speech segmentation (voiced / unvoiced / silence)
% Georgia Institute of Technology
% Team: Jaxon Topel, Adrian Cruz, Michael Ritz
% ============================================================

clc;
clear;
close all;

rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir)
    rootDir = pwd;
end
cd(rootDir);

resultsDir = fullfile(rootDir, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

[file, path] = uigetfile({'*.wav', 'WAV files'}, 'Select a speech WAV file', ...
    fullfile(rootDir, 'example_wavs'));
if isequal(file, 0)
    disp('No file selected.');
    return
end

filePath = fullfile(path, file);
[x, fs, fileName] = load_audio_file(filePath);

p = params(fs);
features = compute_features(x, fs, p);
labels = classify_frames(features, p);
labels = smooth_labels(labels, p);

boundaries = detect_boundaries(labels, features, p, fs);
segTrack = build_segmentation_track(length(x), labels, p.hop_len);

disp('Low-level boundary times (s):');
disp(boundaries.low_times');
disp('Phoneme-like boundary times (s):');
disp(boundaries.phoneme_times');
disp('Syllable-like boundary times (s):');
disp(boundaries.syllable_times');
disp('Word-like boundary times (s):');
disp(boundaries.word_times');

plot_segmentation(x, fs, features, labels, segTrack, boundaries, fileName, resultsDir);
fprintf('Saved figure under: %s\n', resultsDir);
