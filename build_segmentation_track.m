function segTrack = build_segmentation_track(signalLength, labels, hopLen)
%BUILD_SEGMENTATION_TRACK Expand frame labels to one value per sample.

    segTrack = zeros(signalLength, 1);
    if isempty(labels)
        return
    end
    endIdx = 0;
    for k = 1:length(labels)
        startIdx = (k - 1) * hopLen + 1;
        endIdx = min(startIdx + hopLen - 1, signalLength);
        segTrack(startIdx:endIdx) = labels(k);
    end
    if endIdx < signalLength
        segTrack(endIdx+1:signalLength) = labels(end);
    end
end
