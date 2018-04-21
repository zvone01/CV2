% load("Data/data_mat1/data_mat1/0000000000.mat")
% load("Data/data_mat1/data_mat1/0000000000_normal.mat")

function drawn = sample_by_normals(points, normals, n_effective)
    points = points';
    normals = normals';

    n = size(points, 1);
    idc = 1:1:n;
    [normals_azi, normals_ele, ~] = cart2sph(normals(:,1), normals(:,2), normals(:,3));
    normals_sph = cat(2, normals_azi, normals_ele);    
    
    % determine a 2d split of the data according to azimuth and elevation
    n_bins = 5;
    b = discretize(normals_sph, n_bins);
    bins = cell(n_bins^2, 1);

    % assign each point to its respective bin
    for i = 1 : n
        if ~isnan(b(i, 1)) || ~isnan(b(i, 2))
            c = (b(i, 1)-1)*n_bins + (b(i, 2)-1) + 1 ;
            bins{c} = [bins{c}; i];
        end
    end
    
    % sort the bins from smallest to largest
    idc = zeros(size(bins,1), 1);
    for i = 1 : numel(bins)
       idc(i) = size(bins{i}, 1);
    end
    [~, s_i] = sort(idc);
    bins = bins(s_i);
    
    % draw from the smallest bins first, this makes sure we sample points
    % that represent all normal directions present in the surface
    drawn = [];
    for i = 1 : numel(bins)
        n_bin_left = (n_bins^2 + 1) - i;   
        n_needed = n_effective - size(drawn, 1);
        n_per_bin = round(n_needed / n_bin_left);

        if size(bins{i}, 1) < min([n_per_bin, n_needed])
            drawn = [drawn; bins{i}];
        else
            s_idc = randi(size(bins{i}, 1), min([n_per_bin, n_needed]), 1);       
            drawn = [drawn; bins{i}(s_idc, :)];
        end
    end

    assert( size(drawn, 1) == n_effective, "wrong number of draws")
    
end