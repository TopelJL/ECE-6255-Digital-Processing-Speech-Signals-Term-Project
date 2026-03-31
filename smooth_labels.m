% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                           smooth_labels.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function labelsOut = smooth_labels(labelsIn, p)
% smooth labels using median filter and short segment merging

    % get median filter size
    w = p.median_filter_frames;

    % make sure filter length is odd
    if mod(w, 2) == 0
        w = w + 1;
    end

    % apply median filter to smooth label sequence
    labelsOut = medfilt1(labelsIn, w);

    % merge segments that are too short
    minRun = max(1, p.min_segment_frames);
    labelsOut = merge_short_runs(labelsOut, minRun);
end

function y = merge_short_runs(x, minRun)
    % make sure input is a column vector
    y = x(:);
    n = length(y);

    % nothing to do for very short input
    if n < 2 || minRun <= 1
        return
    end

    % start at first sample
    i = 1;

    while i <= n

        % find end of current run
        j = i;
        while j < n && y(j+1) == y(i)
            j = j + 1;
        end

        % length of this run
        runLen = j - i + 1;

        % replace short runs with neighbor label
        if runLen < minRun && runLen > 0
            left  = y(max(1, i - 1));
            right = y(min(n, j + 1));

            % if both neighbors match, use that label
            if i > 1 && j < n && left == right
                y(i:j) = left;

            % otherwise use left side if possible
            elseif i > 1
                y(i:j) = left;

            % otherwise use right side
            elseif j < n
                y(i:j) = right;
            end
        end

        % move to next run
        i = j + 1;
    end
end
