function bins = prepare_normal_bins(points, normals, n_bins)
    points = points';
    normals = normals';

    n = size(points, 1);
    idc = 1:1:n;
    [normals_azi, normals_ele, ~] = cart2sph(normals(:,1), normals(:,2), normals(:,3));
    normals_sph = cat(2, normals_azi, normals_ele);    
    
    % determine a 2d split of the data according to azimuth and elevation
    b = discretize(normals_sph, n_bins);
    bins_cell = cell(n_bins^2, 1);
    
    % assign each point to its respective bin
    bin = (b(:,1)-1)*n_bins + b(:,2);
    for i = 1 : n_bins^2
       bins{i} = idc(bin==i);
    end
    
    % sort the bins from smallest to largest
    [~, idc] = sort(cellfun(@length, bins));
    bins = bins(idc);
end