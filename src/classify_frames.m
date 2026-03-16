function labels = classify_frames(features, params)
%CLASSIFY_FRAMES Label each frame as silence, voiced, or unvoiced.
%
% labels:
%   0 = silence
%   1 = voiced
%   2 = unvoiced

    numFrames = features.num_frames;
    labels = zeros(numFrames, 1);

    for k = 1:numFrames
        if features.power_level(k) < params.silence_th
            labels(k) = 0;
        elseif features.power_level(k) >= params.voiced_power_th && features.voicing(k) == 1
            labels(k) = 1;
        else
            labels(k) = 2;
        end
    end
end