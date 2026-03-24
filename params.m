function params = params(fs)
% store all parameters used in segmentation

    % --- framing settings (about 25 ms frame, 10 ms hop) ---
    params.frame_dur_sec = 0.025;   % frame length in seconds
    params.hop_dur_sec   = 0.010;   % hop size in seconds

    % convert to samples
    params.frame_len     = max(1, round(params.frame_dur_sec * fs));
    params.hop_len       = max(1, round(params.hop_dur_sec * fs));

    % window for each frame
    params.window        = hamming(params.frame_len, 'periodic');

    % --- pitch range (convert hz to lag values) ---
    params.min_f0 = 60;
    params.max_f0 = 400;

    params.min_lag = max(2, floor(fs / params.max_f0));
    params.max_lag = min(params.frame_len - 1, ceil(fs / params.min_f0));

    % --- thresholds (used for classification) ---
    params.silence_energy_quantile   = 12;   % low energy -> silence
    params.speech_energy_quantile    = 35;   % higher energy -> speech
    params.voicing_peak_min          = 0.28; % min autocorr peak for voiced
    params.zcr_voiced_quantile       = 55;   % lower zcr -> voiced
    params.spec_change_th            = 0.18; % spectral change threshold

    % --- smoothing settings ---
    params.median_filter_frames = 5;
    params.min_segment_frames   = 3;  % remove very short segments
    params.syllable_smooth_len  = 5;

    % --- boundary detection settings ---
    params.min_region_frames   = 4;
    params.min_peak_height     = 0.12;
    params.min_word_gap_sec    = 0.15;
    params.min_phoneme_spacing = 2;
end
