function labelsOut = smooth_frame_lables(labelsIn)
%SMOOTH_FRAME_LABELS Remove isolated one-frame label flips.

    labelsOut = labelsIn;

    for k = 2:length(labelsIn)-1
        if labelsIn(k-1) == labelsIn(k+1) && labelsIn(k) ~= labelsIn(k-1)
            labelsOut(k) = labelsIn(k-1);
        end
    end
end