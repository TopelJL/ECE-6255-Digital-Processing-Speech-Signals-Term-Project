% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                     local_findpeaks.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function [pks, locs] = local_findpeaks(x, varargin)
% simple version of findpeaks if toolbox is not available

    % read optional inputs
    p = inputParser;
    addParameter(p, 'MinPeakDistance', 1, @(v) isnumeric(v) && isscalar(v) && v >= 1);
    addParameter(p, 'MinPeakHeight', -inf);
    parse(p, varargin{:});

    % get parameter values
    minDist = round(p.Results.MinPeakDistance);
    minH = p.Results.MinPeakHeight;

    % length of signal
    n = length(x);

    % store candidate peaks (value, index)
    cand = [];

    % find local peaks
    for i = 2:n-1
        if x(i) > x(i-1) && x(i) >= x(i+1) && x(i) >= minH
            cand(end+1, :) = [x(i), i]; %#ok<AGROW>
        end
    end

    % if no peaks found, return empty
    if isempty(cand)
        pks = [];
        locs = [];
        return
    end

    % sort peaks by height (largest first)
    [vals, ord] = sort(cand(:, 1), 'descend');
    idx = cand(ord, 2);

    % track which indices are already used
    used = false(n, 1);

    pks = [];
    locs = [];

    % enforce minimum peak distance
    for k = 1:length(idx)
        i = idx(k);

        % check neighborhood around this peak
        lo = max(1, i - minDist);
        hi = min(n, i + minDist);

        % keep peak if no nearby peak already selected
        if ~any(used(lo:hi))
            pks(end+1, 1) = vals(k); %#ok<AGROW>
            locs(end+1, 1) = i; %#ok<AGROW>

            % mark region as used
            used(lo:hi) = true;
        end
    end

    % sort peaks back in order of location
    [locs, s] = sort(locs);
    pks = pks(s);
end
