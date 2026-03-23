function fig = plot_segmentation(x, fs, features, labels, segTrack, boundaries, fileName, resultsDir)
%PLOT_SEGMENTATION Waveform, STE, ZCR, pitch strength, class track; save to resultsDir.

    if nargin < 8 || isempty(resultsDir)
        resultsDir = fullfile(fileparts(mfilename('fullpath')), 'results');
    end
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir);
    end

    t = (0:length(x)-1) / fs;
    safeName = regexprep(fileName, '[^\w\-.]+', '_');

    fig = figure('Name', ['Speech Segmentation - ' fileName], 'Color', 'w', 'Position', [80 40 900 720]);

    subplot(6, 1, 1)
    plot(t, x)
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Waveform')
    grid on

    subplot(6, 1, 2)
    plot(features.time_axis, features.ste)
    xlabel('Time (s)')
    ylabel('Norm. STE')
    title('Short-Time Energy (normalized)')
    grid on

    subplot(6, 1, 3)
    plot(features.time_axis, features.zcr)
    xlabel('Time (s)')
    ylabel('Norm. ZCR')
    title('Zero-Crossing Rate (normalized)')
    grid on

    subplot(6, 1, 4)
    plot(features.time_axis, features.pitch_strength)
    xlabel('Time (s)')
    ylabel('Strength')
    title('Autocorrelation pitch strength (normalized)')
    grid on

    subplot(6, 1, 5)
    stem(features.time_axis, features.f0, '.', 'MarkerSize', 4)
    xlabel('Time (s)')
    ylabel('Hz')
    title('Estimated F0 (Hz) where voiced')
    grid on

    subplot(6, 1, 6)
    plot(t, segTrack)
    xlabel('Time (s)')
    ylabel('Class')
    title('Voiced / Unvoiced / Silence')
    yticks([0 1 2])
    yticklabels({'silence','voiced','unvoiced'})
    grid on
    hold on
    for i = 1:length(boundaries.word_times)
        xline(boundaries.word_times(i), 'k-', 'LineWidth', 1.0)
    end
    hold off

    sgtitle(sprintf('ECE 6255 segmentation — %s', fileName), 'Interpreter', 'none')

    pngPath = fullfile(resultsDir, [safeName '_segmentation.png']);
    try
        exportgraphics(fig, pngPath, 'Resolution', 200);
    catch
        print(fig, pngPath, '-dpng', '-r200');
    end

    figPath = fullfile(resultsDir, [safeName '_segmentation.fig']);
    try
        savefig(fig, figPath);
    catch
    end
end
