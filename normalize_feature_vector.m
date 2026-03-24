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
