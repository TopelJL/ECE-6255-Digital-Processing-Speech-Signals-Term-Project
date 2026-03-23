function gt = load_ground_truth_csv(csvPath, numFrames)
%LOAD_GROUND_TRUTH_CSV Read frame_index,label CSV; return length numFrames vector.

    M = readmatrix(csvPath, 'NumHeaderLines', 1);
    if size(M, 2) < 2
        error('Expected columns: frame_index, label');
    end
    gt = zeros(numFrames, 1);
    for i = 1:size(M, 1)
        k = round(M(i, 1));
        if k >= 1 && k <= numFrames
            gt(k) = M(i, 2);
        end
    end
end
