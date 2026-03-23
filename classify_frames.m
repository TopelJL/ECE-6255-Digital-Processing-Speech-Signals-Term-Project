function labels = classify_frames(features, p)
%CLASSIFY_FRAMES Voiced / unvoiced / silence using adaptive thresholds.
%
%   labels: 0 = silence, 1 = voiced, 2 = unvoiced
%
%   Adaptive rules (classical DSP, no ML):
%   - Silence: STE below a low percentile of all frames (noise floor aware).
%   - Speech ZCR reference: high percentiles of STE identify "speechy" frames.
%   - Voiced: high pitch_strength in F0 band and ZCR below speech ZCR median-like cutoff.

    n = features.num_frames;
    labels = zeros(n, 1);

    ste = features.ste;
    zcr = features.zcr;
    ps  = features.pitch_strength;

    silence_th = prctile(ste, p.silence_energy_quantile);
    speech_mask = ste > prctile(ste, p.speech_energy_quantile);
    if any(speech_mask)
        zcr_speech = zcr(speech_mask);
        zcr_voiced_max = prctile(zcr_speech, p.zcr_voiced_quantile);
    else
        zcr_voiced_max = 0.35;
    end

    for k = 1:n
        if ste(k) <= silence_th
            labels(k) = 0;
        elseif ps(k) >= p.voicing_peak_min && zcr(k) <= zcr_voiced_max
            labels(k) = 1;
        else
            labels(k) = 2;
        end
    end
end
