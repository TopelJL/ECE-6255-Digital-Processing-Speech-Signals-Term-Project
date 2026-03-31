% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                       classify_frames.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function labels = classify_frames(features, p)
% classify each frame as silence, voiced, or unvoiced using adaptive thresholds

    % number of frames
    n = features.num_frames;

    % initialize labels (0 = silence, 1 = voiced, 2 = unvoiced)
    labels = zeros(n, 1);

    % pull out features for easier use
    ste = features.ste;                 % short-time energy
    zcr = features.zcr;                 % zero crossing rate
    ps  = features.pitch_strength;      % autocorr-based pitch strength

    % compute silence threshold from low energy percentile
    silence_th = prctile(ste, p.silence_energy_quantile);

    % find frames that likely contain speech (higher energy)
    speech_mask = ste > prctile(ste, p.speech_energy_quantile);

    % compute zcr threshold using only speech frames
    if any(speech_mask)

        % get zcr values from speech frames
        zcr_speech = zcr(speech_mask);

        % set max zcr for voiced (adaptive threshold)
        zcr_voiced_max = prctile(zcr_speech, p.zcr_voiced_quantile);
    else
        % fallback value if no speech detected
        zcr_voiced_max = 0.35;
    end

    % loop through each frame and assign label
    for k = 1:n

        % check for silence (very low energy)
        if ste(k) <= silence_th
            labels(k) = 0;

        % check for voiced (periodic + low zcr)
        elseif ps(k) >= p.voicing_peak_min && zcr(k) <= zcr_voiced_max
            labels(k) = 1;

        % otherwise classify as unvoiced
        else
            labels(k) = 2;
        end
    end
end
