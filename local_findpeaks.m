function [pks, locs] = local_findpeaks(x, varargin)
%LOCAL_FINDPEAKS Minimal substitute when Signal Processing Toolbox is unavailable.
%   Supports 'MinPeakDistance' and 'MinPeakHeight' like findpeaks (partial).

    p = inputParser;
    addParameter(p, 'MinPeakDistance', 1, @(v) isnumeric(v) && isscalar(v) && v >= 1);
    addParameter(p, 'MinPeakHeight', -inf);
    parse(p, varargin{:});
    minDist = round(p.Results.MinPeakDistance);
    minH = p.Results.MinPeakHeight;

    n = length(x);
    cand = [];
    for i = 2:n-1
        if x(i) > x(i-1) && x(i) >= x(i+1) && x(i) >= minH
            cand(end+1, :) = [x(i), i]; %#ok<AGROW>
        end
    end
    if isempty(cand)
        pks = [];
        locs = [];
        return
    end
    [vals, ord] = sort(cand(:, 1), 'descend');
    idx = cand(ord, 2);
    used = false(n, 1);
    pks = [];
    locs = [];
    for k = 1:length(idx)
        i = idx(k);
        lo = max(1, i - minDist);
        hi = min(n, i + minDist);
        if ~any(used(lo:hi))
            pks(end+1, 1) = vals(k); %#ok<AGROW>
            locs(end+1, 1) = i; %#ok<AGROW>
            used(lo:hi) = true;
        end
    end
    [locs, s] = sort(locs);
    pks = pks(s);
end
