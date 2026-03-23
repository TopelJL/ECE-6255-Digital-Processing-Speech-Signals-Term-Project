%EVALUATE_EXAMPLE2 Quantitative metrics for example_wavs/example2.wav vs packaged CSV.
%   Run from repo root after adding path (same folder as main.m).

rootDir = fileparts(mfilename('fullpath'));
cd(rootDir);

wavPath = fullfile(rootDir, 'example_wavs', 'example2.wav');
csvPath = fullfile(rootDir, 'evaluation', 'ground_truth_example2.csv');
resultsDir = fullfile(rootDir, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

if ~isfile(wavPath)
    error('Missing %s — run tools/generate_example2_wav.py first.', wavPath);
end
if ~isfile(csvPath)
    error('Missing %s', csvPath);
end

[x, fs, ~] = load_audio_file(wavPath);
p = params(fs);
features = compute_features(x, fs, p);
pred = smooth_labels(classify_frames(features, p), p);

gt = load_ground_truth_csv(csvPath, features.num_frames);
m = evaluate_segmentation(pred, gt);

fid = fopen(fullfile(resultsDir, 'metrics_example2.txt'), 'w');
fprintf(fid, 'ECE 6255 — example2.wav frame evaluation\n');
fprintf(fid, 'Frames compared: %d\n', m.num_frames);
fprintf(fid, 'Accuracy: %.2f%%\n', 100 * m.accuracy);
fprintf(fid, '\nConfusion matrix (rows=ground truth, cols=predicted)\n');
fprintf(fid, '                pred_S  pred_V  pred_U\n');
for r = 1:3
    fprintf(fid, 'true %-9s  %5d  %5d  %5d\n', m.class_names{r}, m.confusion(r, :));
end
fclose(fid);

fprintf('Accuracy (example2): %.2f%%\n', 100 * m.accuracy);
disp('Confusion (rows=true, cols=pred):');
disp(m.confusion);

fig = figure('Color', 'w', 'Position', [120 120 520 440]);
imagesc(m.confusion);
colorbar;
set(gca, 'XTick', 1:3, 'XTickLabel', m.class_names);
set(gca, 'YTick', 1:3, 'YTickLabel', m.class_names);
xlabel('Predicted');
ylabel('Ground truth');
title('Confusion matrix — example2.wav');
try
    exportgraphics(fig, fullfile(resultsDir, 'confusion_matrix_example2.png'), 'Resolution', 150);
catch
    print(fig, fullfile(resultsDir, 'confusion_matrix_example2.png'), '-dpng', '-r150');
end
close(fig);

save(fullfile(resultsDir, 'metrics_example2.mat'), 'm', 'pred', 'gt');
