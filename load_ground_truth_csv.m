function gt = load_ground_truth_csv(csvPath, numFrames)
% load ground truth labels from csv file

    % read csv (skip header row)
    M = readmatrix(csvPath, 'NumHeaderLines', 1);

    % make sure file has at least two columns
    if size(M, 2) < 2
        error('Expected columns: frame_index, label');
    end

    % initialize output vector
    gt = zeros(numFrames, 1);

    % loop through each row in csv
    for i = 1:size(M, 1)

        % get frame index and label
        k = round(M(i, 1));

        % only assign if index is valid
        if k >= 1 && k <= numFrames
            gt(k) = M(i, 2);
        end
    end
end
