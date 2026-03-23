function params = params(fs)
%PARAMS Centralized parameters for voiced / unvoiced / silence segmentation.
%
%   params = params(fs) returns a struct for sampling rate fs (Hz).
%   Tune fields here or override after the call in main.m.

    % --- Framing (20–30 ms frame, ~10 ms hop) ---
    params.frame_dur_sec = 0.025;   % 25 ms
    params.hop_dur_sec   = 0.010;   % 10 ms
    params.frame_len     = max(1, round(params.frame_dur_sec * fs));
    params.hop_len       = max(1, round(params.hop_dur_sec * fs));
    params.window        = hamming(params.frame_len, 'periodic');

    % --- Pitch search (Hz -> lag samples) ---
    params.min_f0 = 60;
    params.max_f0 = 400;
    params.min_lag = max(2, floor(fs / params.max_f0));
    params.max_lag = min(params.frame_len - 1, ceil(fs / params.min_f0));

    % --- Baseline thresholds (used with adaptive scaling below) ---
    params.silence_energy_quantile   = 12;   % percentile of STE for silence cutoff
    params.speech_energy_quantile    = 35;   % above this: candidate speech
    params.voicing_peak_min          = 0.28; % normalized autocorr peak min for voiced
    params.zcr_voiced_quantile       = 55;   % ZCR below this quantile (speech) -> likelier voiced
    params.spec_change_th            = 0.18;

    % --- Smoothing ---
    params.median_filter_frames = 5;
    params.min_segment_frames   = 3;  % min run length after median (merge short islands)
    params.syllable_smooth_len  = 5;

    % --- Boundary detection (optional higher-level outputs) ---
    params.min_region_frames   = 4;
    params.min_peak_height     = 0.12;
    params.min_word_gap_sec    = 0.15;
    params.min_phoneme_spacing = 2;
end
