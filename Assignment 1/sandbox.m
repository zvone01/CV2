a = [1 1 ; 1.1 1.1 ; 1 3 ; 3 1 ; 3 3 ; 2.9 2.9 ; 2.8 3.0 ; 2.9 2.95  ]

n_bins = 2;
b = discretize(a, n_bins)
bins = cell(n_bins^2, 1);

for i = 1 : size(a,1)
    c = (b(i, 1)-1)*n_bins + (b(i, 2)-1) + 1 ;
    bins{c} = [bins{c}; a(i, :)];
end

idc = zeros(size(bins,1), 1);
for i = 1 : numel(bins)
   idc(i) = size(bins{i}, 1);
end
[~, s_i] = sort(idc);
bins = bins(s_i);

n_effective = 5;
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

% bins
% [~, idc] = sort(cellfun(@length, bins));
% idc
% bins = bins(idc)


