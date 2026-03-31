% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                     normalize_feature_vector.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function y = normalize_feature_vector(x)
% normalize vector by max absolute value

    % find max absolute value
    maxVal = max(abs(x));

    % scale if not zero
    if maxVal > 0
        y = x / maxVal;
    else
        % if all zeros, just return original
        y = x;
    end
end
