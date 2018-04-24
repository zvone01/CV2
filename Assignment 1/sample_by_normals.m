function drawn = sample_by_normals(bins, n_effective)
    % sample by normals
    n_bins = size(bins, 1);
    n_needed = n_effective;
    for i = 1 : numel(bins)
        n_bin_left = n_bins + 1 - i;
        n_per_bin = round(n_needed / n_bin_left);
        
        if size(bins{i}, 2) < n_per_bin
            n_needed = n_needed - size(bins{i}, 2);
        else
            bins{i} = bins{i}(randperm(size(bins{i}, 2), n_per_bin));
            n_needed = n_needed - n_per_bin;
        end
    end
    drawn = cell2mat(bins')';
    assert( size(drawn, 1) == n_effective, "wrong number of draws")
end