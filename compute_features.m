function features = compute_features(x, fs, p)
%COMPUTE_FEATURES Short-time STE, ZCR, autocorrelation pitch strength per frame.
%
%   STE: short-time energy (mean squared sample in windowed frame).
%   ZCR: zero-crossing rate.
%   pitch_strength: max normalized autocorrelation in F0 lag range.

    frameLen = p.frame_len;
    hopLen   = p.hop_len;
    win      = p.window;

    numFrames = floor((length(x) - frameLen) / hopLen) + 1;

    ste           = zeros(numFrames, 1);
    zcr           = zeros(numFrames, 1);
    pitch_strength = zeros(numFrames, 1);
    f0            = zeros(numFrames, 1);
    spec_change   = zeros(numFrames, 1);
    time_axis     = zeros(numFrames, 1);

    prevMag = [];

    for k = 1:numFrames
        startIdx = (k - 1) * hopLen + 1;
        endIdx   = startIdx + frameLen - 1;
        frame    = x(startIdx:endIdx) .* win;

        time_axis(k) = ((startIdx + endIdx) / 2) / fs;

        % STE = (1/N) * sum(x_w^2)
        ste(k) = mean(frame .^ 2);

        signs = sign(frame);
        signs(signs == 0) = 1;
        zcr(k) = sum(abs(diff(signs))) / (2 * length(frame));

        mag = abs(fft(frame));
        mag = mag(1:floor(length(mag)/2));
        if isempty(prevMag)
            spec_change(k) = 0;
        else
            spec_change(k) = mean((mag - prevMag) .^ 2);
        end
        prevMag = mag;

        r = xcorr(frame, 'coeff');
        mid = ceil(length(r) / 2);
        r = r(mid:end);

        if p.max_lag <= length(r) && p.min_lag < p.max_lag
            rPitch = r(p.min_lag:p.max_lag);
            [peakVal, peakIdx] = max(rPitch);
            bestLag = peakIdx + p.min_lag - 1;
            pitch_strength(k) = peakVal;
            if bestLag > 0
                f0(k) = fs / bestLag;
            end
        end
    end

    ste_n         = normalize_feature_vector(ste);
    zcr_n         = normalize_feature_vector(zcr);
    spec_n        = normalize_feature_vector(spec_change);
    pitch_n       = normalize_feature_vector(pitch_strength);
    smooth_power  = movmean(ste_n, p.syllable_smooth_len);

    features.ste             = ste_n;
    features.ste_raw         = ste;
    features.zcr             = zcr_n;
    features.zcr_raw         = zcr;
    features.pitch_strength  = pitch_n;
    features.pitch_strength_raw = pitch_strength;
    features.f0              = f0;
    features.spec_change     = spec_n;
    features.time_axis       = time_axis;
    features.smooth_power    = smooth_power;
    features.num_frames      = numFrames;
end
