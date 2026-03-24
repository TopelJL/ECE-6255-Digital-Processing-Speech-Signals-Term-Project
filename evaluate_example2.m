% evaluate example2.wav against the provided ground truth csv
% run this from the repo root

% get current folder and move there
rootDir = fileparts(mfilename('fullpath'));
cd(rootDir);

% set file paths
wavPath = fullfile(rootDir, 'example_wavs', 'example2.wav');
csvPath = fullfile(rootDir, 'evaluation', 'ground_truth_example2.csv');
resultsDir = fullfile(rootDir, 'results');

% create results folder if it does not exist
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% make sure the wav file exists
if ~isfile(wavPath)
    error('Missing %s — run tools/generate_example2_wav.py first.', wavPath);
end

% make sure the csv file exists
if ~isfile(csvPath)
    error('Missing %s', csvPath);
end

% load audio file
[x, fs, ~] = load_audio_file(wavPath);

% get parameters for this sample rate
p = params(fs);

% compute features and get predicted labels
features = compute_features(x, fs, p);
pred = smooth_labels(classify_frames(features, p), p);

% load ground truth labels
gt = load_ground_truth_csv(csvPath, features.num_frames);

% evaluate performance
m = evaluate_segmentation(pred, gt);

% write metrics to text file
fid = fopen(fullfile(resultsDir, 'metrics_example2.txt'), 'w');
fprintf(fid, 'ECE 6255 — example2.wav frame evaluation\n');
fprintf(fid, 'Frames compared: %d\n', m.num_frames);
fprintf(fid, 'Accuracy: %.2f%%\n', 100 * m.accuracy);
fprintf(fid, '\nConfusion matrix (rows=ground truth, cols=predicted)\n');
fprintf(fid, '                pred_S  pred_V  pred_U\n');

% write each row of confusion matrix
for r = 1:3
    fprintf(fid, 'true %-9s  %5d  %5d  %5d\n', m.class_names{r}, m.confusion(r, :));
end
fclose(fid);

% print results to command window
fprintf('Accuracy (example2): %.2f%%\n', 100 * m.accuracy);
disp('Confusion (rows=true, cols=pred):');
disp(m.confusion);

% plot confusion matrix
fig = figure('Color', 'w', 'Position', [120 120 520 440]);
imagesc(m.confusion);
colorbar;
set(gca, 'XTick', 1:3, 'XTickLabel', m.class_names);
set(gca, 'YTick', 1:3, 'YTickLabel', m.class_names);
xlabel('Predicted');
ylabel('Ground truth');
title('Confusion matrix — example2.wav');

% save confusion matrix figure
try
    exportgraphics(fig, fullfile(resultsDir, 'confusion_matrix_example2.png'), 'Resolution', 150);
catch
    print(fig, fullfile(resultsDir, 'confusion_matrix_example2.png'), '-dpng', '-r150');
end
close(fig);

% save matlab results too
save(fullfile(resultsDir, 'metrics_example2.mat'), 'm', 'pred', 'gt');
