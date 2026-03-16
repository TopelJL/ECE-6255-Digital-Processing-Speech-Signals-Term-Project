function features = extract_features(x, fs, params)
%EXTRACT_FEATURES Compute frame-based speech features.

    frameLen = params.frame_len;
    hopLen   = params.hop_len;
    win      = params.window;

    numFrames = floor((length(x) - frameLen) / hopLen) + 1;

    energy      = zeros(numFrames, 1);
    powerLevel  = zeros(numFrames, 1);
    zcr         = zeros(numFrames, 1);
    f0          = zeros(numFrames, 1);
    voicing     = zeros(numFrames, 1);
    specChange  = zeros(numFrames, 1);
    timeAxis    = zeros(numFrames, 1);

    prevMag = [];

    for k = 1:numFrames
        startIdx = (k - 1) * hopLen + 1;
        endIdx   = startIdx + frameLen - 1;

        frame = x(startIdx:endIdx);
        frame = frame .* win;

        timeAxis(k) = ((startIdx + endIdx) / 2) / fs;

        % Energy and power
        energy(k) = sum(frame .^ 2);
        powerLevel(k) = mean(frame .^ 2);

        % Zero Crossing Rate with safer sign handling
        signs = sign(frame);
        signs(signs == 0) = 1;
        zcr(k) = sum(abs(diff(signs))) / (2 * length(frame));

        % Spectral change
        mag = abs(fft(frame));
        mag = mag(1:floor(length(mag)/2));

        if isempty(prevMag)
            specChange(k) = 0;
        else
            diffMag = mag - prevMag;
            specChange(k) = mean(diffMag .^ 2);
        end
        prevMag = mag;

        % Pitch / voicing using normalized autocorrelation
        r = xcorr(frame, 'coeff');
        mid = ceil(length(r) / 2);
        r = r(mid:end);

        if params.max_lag <= length(r)
            rPitch = r(params.min_lag:params.max_lag);
            [peakVal, peakIdx] = max(rPitch);
            bestLag = peakIdx + params.min_lag - 1;
            pitchEst = fs / bestLag;

            if peakVal > params.voicing_peak_th && zcr(k) < params.zcr_voiced_th
                f0(k) = pitchEst;
                voicing(k) = 1;
            end
        end
    end

    % Normalize selected features safely
    energy     = normalize_feature_vector(energy);
    powerLevel = normalize_feature_vector(powerLevel);
    zcr        = normalize_feature_vector(zcr);
    specChange = normalize_feature_vector(specChange);

    smoothPower = movmean(powerLevel, params.syllable_smooth_len);

    features.energy      = energy;
    features.power_level = powerLevel;
    features.zcr         = zcr;
    features.f0          = f0;
    features.voicing     = voicing;
    features.spec_change = specChange;
    features.time_axis   = timeAxis;
    features.smooth_power = smoothPower;
    features.num_frames  = numFrames;
end