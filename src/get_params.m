function params = get_params(fs)
%GET_PARAMS Centralized tunable parameters for speech segmentation.

    params.frame_dur_sec = 0.03;   % 30 ms is a better baseline than 50 ms
    params.hop_dur_sec   = 0.01;   % 10 ms
    params.frame_len     = round(params.frame_dur_sec * fs);
    params.hop_len       = round(params.hop_dur_sec * fs);

    params.window = hamming(params.frame_len, 'periodic');

    % Pitch search range
    params.min_f0 = 60;
    params.max_f0 = 400;
    params.min_lag = floor(fs / params.max_f0);
    params.max_lag = ceil(fs / params.min_f0);

    % Classification thresholds
    params.silence_th       = 0.03;
    params.voiced_power_th  = 0.08;
    params.voicing_peak_th  = 0.30;
    params.zcr_voiced_th    = 0.20;
    params.spec_change_th   = 0.18;

    % Region / smoothing parameters
    params.min_region_frames   = 4;
    params.syllable_smooth_len = 5;
    params.min_peak_height     = 0.12;
    params.min_word_gap_sec    = 0.15;
    params.min_phoneme_spacing = 2;
end