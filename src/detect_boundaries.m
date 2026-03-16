function boundaries = detect_boundaries(labels, features, params, fs)
%DETECT_BOUNDARIES Compute low-level, phoneme-like, syllable-like, and word-like boundaries.

    timeAxis = features.time_axis;
    smoothPower = features.smooth_power;
    specChange = features.spec_change;

    % Low-level candidate boundaries
    labelBoundaryIdx = find(diff(labels) ~= 0) + 1;
    specBoundaryIdx  = find(specChange > params.spec_change_th);
    lowBoundaryIdx   = unique([labelBoundaryIdx; specBoundaryIdx]);
    lowBoundaryTimes = timeAxis(lowBoundaryIdx);

    % Speech regions
    speechMask = labels ~= 0;
    speechDiff = diff([0; speechMask; 0]);
    speechStartIdx = find(speechDiff == 1);
    speechEndIdx   = find(speechDiff == -1) - 1;

    keepRegions = (speechEndIdx - speechStartIdx + 1) >= params.min_region_frames;
    speechStartIdx = speechStartIdx(keepRegions);
    speechEndIdx   = speechEndIdx(keepRegions);

    % Syllable-like boundaries
    syllableBoundaryIdx = [];

    for r = 1:length(speechStartIdx)
        s1 = speechStartIdx(r);
        s2 = speechEndIdx(r);

        localEnv = smoothPower(s1:s2);
        peakDist = max(1, min(6, floor(length(localEnv) / 2)));

        [~, locs] = findpeaks(localEnv, ...
            'MinPeakDistance', peakDist, ...
            'MinPeakHeight', params.min_peak_height);

        peakIdx = s1 + locs - 1;

        if length(peakIdx) >= 2
            for m = 1:length(peakIdx)-1
                leftIdx  = peakIdx(m);
                rightIdx = peakIdx(m+1);

                [~, localMinPos] = min(smoothPower(leftIdx:rightIdx));
                bIdx = leftIdx + localMinPos - 1;
                syllableBoundaryIdx = [syllableBoundaryIdx; bIdx]; %#ok<AGROW>
            end
        end
    end

    syllableBoundaryIdx = unique(syllableBoundaryIdx);
    syllableBoundaryTimes = timeAxis(syllableBoundaryIdx);

    % Phoneme-like boundaries
    phonemeBoundaryIdx = [];

    for r = 1:length(speechStartIdx)
        s1 = speechStartIdx(r);
        s2 = speechEndIdx(r);

        regionBounds = lowBoundaryIdx(lowBoundaryIdx >= s1 & lowBoundaryIdx <= s2);

        if ~isempty(regionBounds)
            kept = regionBounds(1);
            for m = 2:length(regionBounds)
                if regionBounds(m) - kept(end) >= params.min_phoneme_spacing
                    kept = [kept; regionBounds(m)]; %#ok<AGROW>
                end
            end
            phonemeBoundaryIdx = [phonemeBoundaryIdx; kept]; %#ok<AGROW>
        end
    end

    phonemeBoundaryIdx = unique(phonemeBoundaryIdx);
    phonemeBoundaryTimes = timeAxis(phonemeBoundaryIdx);

    % Word-like boundaries
    wordBoundaryIdx = [];

    for r = 1:length(speechStartIdx)-1
        gapFrames = speechStartIdx(r+1) - speechEndIdx(r) - 1;
        gapTime = gapFrames * params.hop_len / fs;

        if gapTime >= params.min_word_gap_sec
            wordBoundaryIdx = [wordBoundaryIdx; speechStartIdx(r+1)]; %#ok<AGROW>
        end
    end

    wordBoundaryIdx = unique(wordBoundaryIdx);
    wordBoundaryTimes = timeAxis(wordBoundaryIdx);

    % Ensure word boundaries are included in phoneme-like boundaries
    phonemeBoundaryIdx = unique([phonemeBoundaryIdx; wordBoundaryIdx]);
    phonemeBoundaryTimes = timeAxis(phonemeBoundaryIdx);

    boundaries.low_idx = lowBoundaryIdx;
    boundaries.low_times = lowBoundaryTimes;

    boundaries.speech_start_idx = speechStartIdx;
    boundaries.speech_end_idx = speechEndIdx;

    boundaries.syllable_idx = syllableBoundaryIdx;
    boundaries.syllable_times = syllableBoundaryTimes;

    boundaries.phoneme_idx = phonemeBoundaryIdx;
    boundaries.phoneme_times = phonemeBoundaryTimes;

    boundaries.word_idx = wordBoundaryIdx;
    boundaries.word_times = wordBoundaryTimes;
end