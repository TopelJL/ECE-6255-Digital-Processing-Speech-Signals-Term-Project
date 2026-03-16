function y = normalize_feature_vector(x)
%NORMALIZE_FEATURE_VECTOR Safely normalize a vector to max absolute value 1.

    maxVal = max(abs(x));
    if maxVal > 0
        y = x / maxVal;
    else
        y = x;
    end
end