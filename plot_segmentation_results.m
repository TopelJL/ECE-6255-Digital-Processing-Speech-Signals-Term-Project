function plot_segmentation_results(x, fs, features, labels, segTrack, boundaries, fileName)
%PLOT_SEGMENTATION_RESULTS Visualize waveform, features, and segmentation.

    t = (0:length(x)-1) / fs;

    figure('Name', ['Speech Segmentation - ' fileName], 'Color', 'w');

    subplot(7,1,1)
    plot(t, x)
    xlabel('Time (s)')
    ylabel('Amp')
    title('Speech Signal')
    grid on
    hold on
    for i = 1:length(boundaries.phoneme_times)
        xline(boundaries.phoneme_times(i), '--')
    end
    hold off

    subplot(7,1,2)
    plot(features.time_axis, features.power_level)
    xlabel('Time (s)')
    ylabel('Power')
    title('Normalized Power Level')
    grid on
    hold on
    for i = 1:length(boundaries.syllable_times)
        xline(boundaries.syllable_times(i), '--')
    end
    hold off

    subplot(7,1,3)
    plot(features.time_axis, features.zcr)
    xlabel('Time (s)')
    ylabel('ZCR')
    title('Zero Crossing Rate')
    grid on

    subplot(7,1,4)
    plot(features.time_axis, features.f0)
    xlabel('Time (s)')
    ylabel('Hz')
    title('Estimated Fundamental Frequency')
    grid on

    subplot(7,1,5)
    plot(features.time_axis, features.spec_change)
    xlabel('Time (s)')
    ylabel('Change')
    title('Spectral Change')
    grid on
    hold on
    for i = 1:length(boundaries.phoneme_times)
        xline(boundaries.phoneme_times(i), '--')
    end
    hold off

    subplot(7,1,6)
    plot(t, segTrack)
    xlabel('Time (s)')
    ylabel('Class')
    title('Voiced / Unvoiced / Silence Segmentation')
    yticks([0 1 2])
    yticklabels({'silence','voiced','unvoiced'})
    grid on
    hold on
    for i = 1:length(boundaries.word_times)
        xline(boundaries.word_times(i), 'k-', 'LineWidth', 1.5)
    end
    hold off

    subplot(7,1,7)
    plot(features.time_axis, features.smooth_power)
    xlabel('Time (s)')
    ylabel('Env')
    title('Smoothed Power Envelope')
    grid on
    hold on
    for i = 1:length(boundaries.syllable_times)
        xline(boundaries.syllable_times(i), '--')
    end
    for i = 1:length(boundaries.word_times)
        xline(boundaries.word_times(i), 'k-', 'LineWidth', 1.5)
    end
    hold off
end