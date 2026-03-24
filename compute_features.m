function features = compute_features(x, fs, p)
% compute frame-level features like ste, zcr, and pitch strength

    % get frame settings
    frameLen = p.frame_len;
    hopLen   = p.hop_len;
    win      = p.window;

    % total number of frames
    numFrames = floor((length(x) - frameLen) / hopLen) + 1;

    % initialize feature vectors
    ste            = zeros(numFrames, 1);
    zcr            = zeros(numFrames, 1);
    pitch_strength = zeros(numFrames, 1);
    f0             = zeros(numFrames, 1);
    spec_change    = zeros(numFrames, 1);
    time_axis      = zeros(numFrames, 1);

    % store previous magnitude spectrum for spectral change
    prevMag = [];

    % loop through each frame
    for k = 1:numFrames

        % get frame indices
        startIdx = (k - 1) * hopLen + 1;
        endIdx   = startIdx + frameLen - 1;

        % apply window to frame
        frame = x(startIdx:endIdx) .* win;

        % compute time (center of frame)
        time_axis(k) = ((startIdx + endIdx) / 2) / fs;

        % compute short-time energy
        ste(k) = mean(frame .^ 2);

        % compute zero crossing rate
        signs = sign(frame);
        signs(signs == 0) = 1;  % avoid zeros
        zcr(k) = sum(abs(diff(signs))) / (2 * length(frame));

        % compute magnitude spectrum
        mag = abs(fft(frame));
        mag = mag(1:floor(length(mag)/2));

        % compute spectral change from previous frame
        if isempty(prevMag)
            spec_change(k) = 0;
        else
            spec_change(k) = mean((mag - prevMag) .^ 2);
        end
        prevMag = mag;

        % compute autocorrelation for pitch
        r = xcorr(frame, 'coeff');

        % keep only positive lags
        mid = ceil(length(r) / 2);
        r = r(mid:end);

        % check valid lag range
        if p.max_lag <= length(r) && p.min_lag < p.max_lag

            % search for peak in pitch range
            rPitch = r(p.min_lag:p.max_lag);

            [peakVal, peakIdx] = max(rPitch);

            % convert index to lag
            bestLag = peakIdx + p.min_lag - 1;

            % store pitch strength
            pitch_strength(k) = peakVal;

            % compute f0 if valid
            if bestLag > 0
                f0(k) = fs / bestLag;
            end
        end
    end

    % normalize features
    ste_n    = normalize_feature_vector(ste);
    zcr_n    = normalize_feature_vector(zcr);
    spec_n   = normalize_feature_vector(spec_change);
    pitch_n  = normalize_feature_vector(pitch_strength);

    % smooth energy for higher-level structure
    smooth_power = movmean(ste_n, p.syllable_smooth_len);

    % store outputs in struct
    features.ste                = ste_n;
    features.ste_raw            = ste;
    features.zcr                = zcr_n;
    features.zcr_raw            = zcr;
    features.pitch_strength     = pitch_n;
    features.pitch_strength_raw = pitch_strength;
    features.f0                 = f0;
    features.spec_change        = spec_n;
    features.time_axis          = time_axis;
    features.smooth_power       = smooth_power;
    features.num_frames         = numFrames;
end
