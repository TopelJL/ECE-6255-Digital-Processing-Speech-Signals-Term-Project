function metrics = evaluate_segmentation(predLabels, gtLabels)
% compute accuracy and confusion matrix for segmentation results

    % make sure both inputs are column vectors
    predLabels = predLabels(:);
    gtLabels = gtLabels(:);

    % use the shorter length if they dont match
    n = min(length(predLabels), length(gtLabels));
    predLabels = predLabels(1:n);
    gtLabels = gtLabels(1:n);

    % initialize 3x3 confusion matrix
    % rows = ground truth, cols = predicted
    C = zeros(3, 3);

    % loop through each frame
    for i = 1:n

        % shift labels from 0-2 to 1-3 for indexing
        gi = gtLabels(i) + 1;
        pi = predLabels(i) + 1;

        % make sure indices are valid
        if gi >= 1 && gi <= 3 && pi >= 1 && pi <= 3
            C(gi, pi) = C(gi, pi) + 1;
        end
    end

    % compute overall accuracy
    metrics.accuracy = sum(predLabels == gtLabels) / n;

    % store results
    metrics.confusion = C;
    metrics.num_frames = n;
    metrics.class_names = {'silence','voiced','unvoiced'};
end
