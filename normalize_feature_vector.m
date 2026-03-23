function y = normalize_feature_vector(x)
%NORMALIZE_FEATURE_VECTOR Scale vector by max absolute value (safe for zeros).

    maxVal = max(abs(x));
    if maxVal > 0
        y = x / maxVal;
    else
        y = x;
    end
end
