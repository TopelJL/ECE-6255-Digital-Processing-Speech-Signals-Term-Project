function segTrack = build_segmentation_track(signalLength, labels, hopLen)
% build segmentation track from frame labels to sample-level labels

    % initialize output vector (one value per sample)
    segTrack = zeros(signalLength, 1);

    % if there are no labels, just return zeros
    if isempty(labels)
        return
    end

    % keep track of last index we fill
    endIdx = 0;

    % loop through each frame label
    for k = 1:length(labels)

        % compute start index for this frame
        startIdx = (k - 1) * hopLen + 1;

        % compute end index, making sure we dont go past signal length
        endIdx = min(startIdx + hopLen - 1, signalLength);

        % fill this section with the current label
        segTrack(startIdx:endIdx) = labels(k);
    end

    % if we didnt reach the end, fill remaining samples with last label
    if endIdx < signalLength
        segTrack(endIdx+1:signalLength) = labels(end);
    end
end
