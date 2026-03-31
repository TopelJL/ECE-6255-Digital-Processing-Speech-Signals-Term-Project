% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                        detect_boundaries.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function boundaries = detect_boundaries(labels, features, p, fs)
% detect low-level, phoneme-like, syllable-like, and word-like boundaries

    % get feature vectors we need
    timeAxis = features.time_axis;
    smoothPower = features.smooth_power;
    specChange = features.spec_change;

    % find label changes and strong spectral changes
    labelBoundaryIdx = find(diff(labels) ~= 0) + 1;
    specBoundaryIdx  = find(specChange > p.spec_change_th);

    % combine both for low-level boundaries
    lowBoundaryIdx   = unique([labelBoundaryIdx; specBoundaryIdx]);
    lowBoundaryTimes = timeAxis(lowBoundaryIdx);

    % find start and end of speech regions
    speechMask = labels ~= 0;
    speechDiff = diff([0; speechMask; 0]);
    speechStartIdx = find(speechDiff == 1);
    speechEndIdx   = find(speechDiff == -1) - 1;

    % remove very short speech regions
    keepRegions = (speechEndIdx - speechStartIdx + 1) >= p.min_region_frames;
    speechStartIdx = speechStartIdx(keepRegions);
    speechEndIdx   = speechEndIdx(keepRegions);

    % initialize syllable boundary list
    syllableBoundaryIdx = [];

    % loop through each speech region
    for r = 1:length(speechStartIdx)
        s1 = speechStartIdx(r);
        s2 = speechEndIdx(r);

        % get smoothed energy in this region
        localEnv = smoothPower(s1:s2);

        % choose peak spacing based on region length
        peakDist = max(1, min(6, floor(length(localEnv) / 2)));

        % extract spectral flux for this speech region
        runFlux = specChange(s1:s2);
        runFlux = runFlux(:);

        % set adaptive threshold as high percentile of this region's flux
        thresh = prctile(runFlux(isfinite(runFlux)), 90);

        if isempty(runFlux) || all(~isfinite(runFlux))
            pks = [];
            locs = [];
        else
            validMask = isfinite(runFlux);
            runFluxValid = runFlux(validMask);

            if isempty(runFluxValid)
                pks = [];
                locs = [];
            else
                localMax = max(runFluxValid);

                if ~isfinite(localMax) || localMax <= 0
                    pks = [];
                    locs = [];
                else
                    % keep threshold from exceeding actual data
                    thresh = min(thresh, localMax - eps);

                    if thresh <= 0
                        pks = [];
                        locs = [];
                    else
                        % about 30 ms minimum spacing between peaks
                        minPeakDistFrames = max(1, round(0.03 / (p.hop_len / fs)));

                        [pksValid, locsValid] = findpeaks(runFluxValid, ...
                            'MinPeakHeight', thresh, ...
                            'MinPeakDistance', minPeakDistFrames);

                        % map valid-only indices back to original indices
                        validIdx = find(validMask);
                        locs = validIdx(locsValid);
                        pks  = pksValid;
                    end
                end
            end
        end

        % convert local peak locations to full signal frame indices
        peakIdx = s1 + locs - 1;

        % place syllable boundaries between nearby peaks
        if length(peakIdx) >= 2
            for m = 1:length(peakIdx)-1
                leftIdx  = peakIdx(m);
                rightIdx = peakIdx(m+1);

                % use the local minimum between peaks as the boundary
                [~, localMinPos] = min(smoothPower(leftIdx:rightIdx));
                bIdx = leftIdx + localMinPos - 1;
                syllableBoundaryIdx = [syllableBoundaryIdx; bIdx]; %#ok<AGROW>
            end
        end
    end

    % remove duplicates
    syllableBoundaryIdx = unique(syllableBoundaryIdx);
    syllableBoundaryTimes = timeAxis(syllableBoundaryIdx);

    % initialize phoneme boundary list
    phonemeBoundaryIdx = [];

    % loop through each speech region
    for r = 1:length(speechStartIdx)
        s1 = speechStartIdx(r);
        s2 = speechEndIdx(r);

        % keep only low-level boundaries inside this speech region
        regionBounds = lowBoundaryIdx(lowBoundaryIdx >= s1 & lowBoundaryIdx <= s2);

        if ~isempty(regionBounds)

            % keep the first boundary
            kept = regionBounds(1);

            % only keep boundaries that are spaced far enough apart
            for m = 2:length(regionBounds)
                if regionBounds(m) - kept(end) >= p.min_phoneme_spacing
                    kept = [kept; regionBounds(m)]; %#ok<AGROW>
                end
            end

            % add kept boundaries to phoneme list
            phonemeBoundaryIdx = [phonemeBoundaryIdx; kept]; %#ok<AGROW>
        end
    end

    % remove duplicates
    phonemeBoundaryIdx = unique(phonemeBoundaryIdx);
    phonemeBoundaryTimes = timeAxis(phonemeBoundaryIdx);

    % initialize word boundary list
    wordBoundaryIdx = [];

    % look for large silent gaps between speech regions
    for r = 1:length(speechStartIdx)-1
        gapFrames = speechStartIdx(r+1) - speechEndIdx(r) - 1;
        gapTime = gapFrames * p.hop_len / fs;

        % if the gap is long enough, treat next region as a new word
        if gapTime >= p.min_word_gap_sec
            wordBoundaryIdx = [wordBoundaryIdx; speechStartIdx(r+1)]; %#ok<AGROW>
        end
    end

    % remove duplicates
    wordBoundaryIdx = unique(wordBoundaryIdx);
    wordBoundaryTimes = timeAxis(wordBoundaryIdx);

    % include word boundaries in phoneme-like boundaries too
    phonemeBoundaryIdx = unique([phonemeBoundaryIdx; wordBoundaryIdx]);
    phonemeBoundaryTimes = timeAxis(phonemeBoundaryIdx);

    % store everything in output struct
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