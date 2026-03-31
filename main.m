% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                           main.m
%
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

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

% detect different boundary types (suppress findpeaks warnings)
warning('off', 'signal:findpeaks:largeMinPeakHeight');
boundaries = detect_boundaries(labels, features, p, fs);
warning('on', 'signal:findpeaks:largeMinPeakHeight');

% expand frame labels to sample-level track
segTrack = build_segmentation_track(length(x), labels, p.hop_len);

% =====================================================================
%                    SUMMARY — Numerical Results
% =====================================================================
nFrames   = features.num_frames;
nSilence  = sum(labels == 0);
nVoiced   = sum(labels == 1);
nUnvoiced = sum(labels == 2);
durTotal  = length(x) / fs;
hopSec    = p.hop_len / fs;

fprintf('\n');
fprintf('==============================================================\n');
fprintf('  ECE 6255 Speech Segmentation — Results Summary\n');
fprintf('  File: %s\n', fileName);
fprintf('==============================================================\n');

% --- Signal info ---
fprintf('\n--- Signal ---\n');
fprintf('  Sampling rate       : %d Hz\n', fs);
fprintf('  Duration            : %.2f s  (%d samples)\n', durTotal, length(x));
fprintf('  Frame length        : %d samples (%.1f ms)\n', p.frame_len, p.frame_dur_sec*1000);
fprintf('  Hop size            : %d samples (%.1f ms)\n', p.hop_len, p.hop_dur_sec*1000);
fprintf('  Total frames        : %d\n', nFrames);

% --- Classification breakdown ---
fprintf('\n--- Frame Classification ---\n');
fprintf('  Silence  : %5d frames  (%5.1f%%)  ~%.2f s\n', nSilence,  100*nSilence/nFrames,  nSilence*hopSec);
fprintf('  Voiced   : %5d frames  (%5.1f%%)  ~%.2f s\n', nVoiced,   100*nVoiced/nFrames,   nVoiced*hopSec);
fprintf('  Unvoiced : %5d frames  (%5.1f%%)  ~%.2f s\n', nUnvoiced, 100*nUnvoiced/nFrames, nUnvoiced*hopSec);

% --- Feature statistics (raw values) ---
fprintf('\n--- Feature Statistics (raw, non-normalized) ---\n');

% STE
fprintf('  Short-Time Energy:\n');
fprintf('    Overall    — mean=%.4e  std=%.4e  max=%.4e\n', ...
    mean(features.ste_raw), std(features.ste_raw), max(features.ste_raw));
if nVoiced > 0
    fprintf('    Voiced     — mean=%.4e\n', mean(features.ste_raw(labels==1)));
end
if nUnvoiced > 0
    fprintf('    Unvoiced   — mean=%.4e\n', mean(features.ste_raw(labels==2)));
end
if nSilence > 0
    fprintf('    Silence    — mean=%.4e\n', mean(features.ste_raw(labels==0)));
end

% ZCR
fprintf('  Zero-Crossing Rate:\n');
fprintf('    Overall    — mean=%.4f  std=%.4f\n', mean(features.zcr_raw), std(features.zcr_raw));
if nVoiced > 0
    fprintf('    Voiced     — mean=%.4f\n', mean(features.zcr_raw(labels==1)));
end
if nUnvoiced > 0
    fprintf('    Unvoiced   — mean=%.4f\n', mean(features.zcr_raw(labels==2)));
end
if nSilence > 0
    fprintf('    Silence    — mean=%.4f\n', mean(features.zcr_raw(labels==0)));
end

% Pitch strength
fprintf('  Pitch Strength (autocorrelation peak):\n');
fprintf('    Overall    — mean=%.4f  std=%.4f\n', ...
    mean(features.pitch_strength_raw), std(features.pitch_strength_raw));
if nVoiced > 0
    fprintf('    Voiced     — mean=%.4f\n', mean(features.pitch_strength_raw(labels==1)));
end
if nUnvoiced > 0
    fprintf('    Unvoiced   — mean=%.4f\n', mean(features.pitch_strength_raw(labels==2)));
end

% F0
voicedF0 = features.f0(labels == 1);
voicedF0 = voicedF0(voicedF0 > 0);
if ~isempty(voicedF0)
    fprintf('  Fundamental Frequency (voiced frames only):\n');
    fprintf('    mean=%.1f Hz  std=%.1f Hz  min=%.1f Hz  max=%.1f Hz\n', ...
        mean(voicedF0), std(voicedF0), min(voicedF0), max(voicedF0));
end

% --- Boundary counts ---
fprintf('\n--- Boundary Detection ---\n');
fprintf('  Low-level boundaries      : %d\n', length(boundaries.low_idx));
fprintf('  Phoneme-like boundaries   : %d\n', length(boundaries.phoneme_idx));
fprintf('  Syllable-like boundaries  : %d\n', length(boundaries.syllable_idx));
fprintf('  Word-like boundaries      : %d\n', length(boundaries.word_idx));
fprintf('  Speech regions detected   : %d\n', length(boundaries.speech_start_idx));

% --- Segment run-length stats ---
fprintf('\n--- Segment Duration Statistics ---\n');
diffs = [find(diff(labels) ~= 0); nFrames];
starts = [1; find(diff(labels) ~= 0) + 1];
segLens = diffs - starts + 1;
segLabels = labels(starts);
for cls = [0, 1, 2]
    clsName = {'Silence','Voiced','Unvoiced'};
    lens = segLens(segLabels == cls);
    if ~isempty(lens)
        durMs = lens * hopSec * 1000;
        fprintf('  %s segments: count=%d  mean=%.0f ms  median=%.0f ms  max=%.0f ms\n', ...
            clsName{cls+1}, length(lens), mean(durMs), median(durMs), max(durMs));
    end
end

% --- Word boundary times ---
if ~isempty(boundaries.word_times)
    fprintf('\n--- Word Boundary Times ---\n');
    for k = 1:length(boundaries.word_times)
        fprintf('  Word break %d at %.3f s\n', k, boundaries.word_times(k));
    end
end

fprintf('\n==============================================================\n\n');

% plot and save final segmentation results
plot_segmentation(x, fs, features, labels, segTrack, boundaries, fileName, resultsDir);

% show where results were saved
fprintf('Saved figures under: %s\n', resultsDir);