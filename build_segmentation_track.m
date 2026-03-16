function segTrack = build_segmentation_track(signalLength, labels, hopLen)
%BUILD_SEGMENTATION_TRACK Convert frame labels to sample-level track.

    segTrack = zeros(signalLength, 1);

    for k = 1:length(labels)
        startIdx = (k - 1) * hopLen + 1;
        endIdx = min(startIdx + hopLen - 1, signalLength);
        segTrack(startIdx:endIdx) = labels(k);
    end
end