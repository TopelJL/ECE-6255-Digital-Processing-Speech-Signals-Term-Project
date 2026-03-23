function metrics = evaluate_segmentation(predLabels, gtLabels)
%EVALUATE_SEGMENTATION Frame accuracy and 3x3 confusion (0=silence,1=voiced,2=unvoiced).

    predLabels = predLabels(:);
    gtLabels = gtLabels(:);
    n = min(length(predLabels), length(gtLabels));
    predLabels = predLabels(1:n);
    gtLabels = gtLabels(1:n);

    C = zeros(3, 3);
    for i = 1:n
        gi = gtLabels(i) + 1;
        pi = predLabels(i) + 1;
        if gi >= 1 && gi <= 3 && pi >= 1 && pi <= 3
            C(gi, pi) = C(gi, pi) + 1;
        end
    end

    metrics.accuracy = sum(predLabels == gtLabels) / n;
    metrics.confusion = C;
    metrics.num_frames = n;
    metrics.class_names = {'silence','voiced','unvoiced'};
end
