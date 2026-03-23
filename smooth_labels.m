function labelsOut = smooth_labels(labelsIn, p)
%SMOOTH_LABELS Median filtering + minimum segment duration (milliseconds-class).
%
%   Uses medfilt1 on integer class labels, then merges runs shorter than
%   params.min_segment_frames into neighbors.

    w = p.median_filter_frames;
    if mod(w, 2) == 0
        w = w + 1;
    end
    labelsOut = medfilt1(labelsIn, w);

    minRun = max(1, p.min_segment_frames);
    labelsOut = merge_short_runs(labelsOut, minRun);
end

function y = merge_short_runs(x, minRun)
    y = x(:);
    n = length(y);
    if n < 2 || minRun <= 1
        return
    end
    i = 1;
    while i <= n
        j = i;
        while j < n && y(j+1) == y(i)
            j = j + 1;
        end
        runLen = j - i + 1;
        if runLen < minRun && runLen > 0
            left  = y(max(1, i - 1));
            right = y(min(n, j + 1));
            if i > 1 && j < n && left == right
                y(i:j) = left;
            elseif i > 1
                y(i:j) = left;
            elseif j < n
                y(i:j) = right;
            end
        end
        i = j + 1;
    end
end
