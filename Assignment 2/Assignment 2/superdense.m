function pvm = superdense(pvm)
    % remove all columns with any NaN in them
    pvm(:, any(isnan(pvm), 1)) = [];
end