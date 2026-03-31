% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                       plot_segmentation.m
%   
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function plot_segmentation(x, fs, features, labels, segTrack, boundaries, fileName, resultsDir)

% ===================== Time Axes =====================
t = (0:length(x)-1)/fs;
t_frames = features.time_axis;   % already computed in compute_features

% ===================== Class IDs =====================
SILENCE = 0;
VOICED = 1;
UNVOICED = 2;

% ===================== 1. Waveform =====================
figure;
plot(t, x);
title(['Waveform — ', fileName], 'Interpreter', 'none');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_waveform.png']));

% ===================== 2. Energy =====================
figure;
plot(t_frames, features.ste);
title('Short-Time Energy (normalized)');
xlabel('Time (s)');
ylabel('Norm STE');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_energy.png']));

% ===================== 3. ZCR =====================
figure;
plot(t_frames, features.zcr);
title('Zero-Crossing Rate (normalized)');
xlabel('Time (s)');
ylabel('Norm ZCR');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_zcr.png']));

% ===================== 4. Pitch Strength =====================
figure;
plot(t_frames, features.pitch_strength);
title('Autocorrelation Pitch Strength (normalized)');
xlabel('Time (s)');
ylabel('Strength');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_pitch_strength.png']));

% ===================== 5. F0 (Voiced Only) =====================
f0_plot = features.f0;
f0_plot(labels ~= VOICED) = NaN;

figure;
plot(t_frames, f0_plot);
title('Estimated F0 (Voiced Only)');
xlabel('Time (s)');
ylabel('Hz');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_f0.png']));

% ===================== 6. Segmentation (Line Plot) =====================
figure;
stairs(t_frames, labels, 'LineWidth', 1.5);
ylim([0 2]);
yticks([0 1 2]);
yticklabels({'Silence','Voiced','Unvoiced'});
title('Segmentation (Class Labels)');
xlabel('Time (s)');
ylabel('Class');
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_segmentation_labels.png']));

% ===================== 7. Segmentation (Colored Regions) =====================
figure;
hold on;

for i = 1:length(labels)-1
    if labels(i) == SILENCE
        color = [0.8 0.8 0.8]; % gray
    elseif labels(i) == VOICED
        color = [0.2 0.8 0.2]; % green
    else
        color = [0.9 0.3 0.3]; % red
    end
    
    patch([t_frames(i) t_frames(i+1) t_frames(i+1) t_frames(i)], ...
          [0 0 1 1], color, 'EdgeColor','none');
end

title('Segmentation (Colored Regions)');
xlabel('Time (s)');
yticks([]);
grid on;

saveas(gcf, fullfile(resultsDir, [fileName '_segmentation_colored.png']));

% ===================== 8. Multi-Panel Summary =====================
figure('Position', [50 50 1400 900]);

% Panel 1: Waveform with boundary markers
subplot(4,2,1);
plot(t, x, 'Color', [0.4 0.4 0.4]); hold on;
for k = 1:length(boundaries.word_times)
    xline(boundaries.word_times(k), 'r-', 'LineWidth', 1.5);
end
title('Waveform + Word Boundaries');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Panel 2: Energy envelope
subplot(4,2,2);
plot(t_frames, features.ste, 'b'); hold on;
plot(t_frames, features.smooth_power, 'r', 'LineWidth', 1.2);
title('Short-Time Energy (blue) + Smoothed (red)');
xlabel('Time (s)'); ylabel('Norm STE'); grid on;

% Panel 3: ZCR
subplot(4,2,3);
plot(t_frames, features.zcr, 'Color', [0.0 0.5 0.0]);
title('Zero-Crossing Rate');
xlabel('Time (s)'); ylabel('Norm ZCR'); grid on;

% Panel 4: Pitch strength
subplot(4,2,4);
plot(t_frames, features.pitch_strength, 'Color', [0.6 0.2 0.8]);
title('Autocorrelation Pitch Strength');
xlabel('Time (s)'); ylabel('Strength'); grid on;

% Panel 5: F0 voiced only
subplot(4,2,5);
plot(t_frames, f0_plot, '.', 'MarkerSize', 3);
title('Estimated F0 (Voiced Frames Only)');
xlabel('Time (s)'); ylabel('Hz'); grid on;

% Panel 6: Spectral flux
subplot(4,2,6);
plot(t_frames, features.spec_change, 'Color', [0.8 0.4 0.0]);
title('Spectral Change (Flux)');
xlabel('Time (s)'); ylabel('Norm Flux'); grid on;

% Panel 7: Colored segmentation
subplot(4,2,[7 8]);
hold on;
for i = 1:length(labels)-1
    if labels(i) == SILENCE
        color = [0.8 0.8 0.8];
    elseif labels(i) == VOICED
        color = [0.2 0.8 0.2];
    else
        color = [0.9 0.3 0.3];
    end
    patch([t_frames(i) t_frames(i+1) t_frames(i+1) t_frames(i)], ...
          [0 0 1 1], color, 'EdgeColor','none');
end
% overlay syllable boundaries
for k = 1:length(boundaries.syllable_times)
    xline(boundaries.syllable_times(k), 'b--', 'LineWidth', 0.5);
end
title('V/UV/S Classification (green=voiced, red=unvoiced, gray=silence, blue dashes=syllable)');
xlabel('Time (s)'); yticks([]); grid on;

sgtitle(['Speech Segmentation — ', fileName], 'Interpreter', 'none', 'FontWeight', 'bold');

saveas(gcf, fullfile(resultsDir, [fileName '_segmentation.png']));
savefig(gcf, fullfile(resultsDir, [fileName '_segmentation.fig']));

end