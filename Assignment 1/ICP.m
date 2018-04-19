function [R, t] = ICP(source_raw, target_raw, sampling, p)

% load('Data/source.mat');
% load('Data/target.mat');

[d, n] = size(source_raw);

% initialise variables
RMS_new = 0;
i = 0;
change = 1;
R = eye(d);
t = zeros(d, 1);

if strcmp(sampling, 'all')
    source_x = source_raw;
    target = target_raw; 
    n_effective = n;
end

if strcmp(sampling, 'uniform')
    % select n*p points to consider over all iterations (p<1)
    n_effective = round(p*n);
    s_idc = randi(n, n_effective, 1);
    source_x = source_raw(:, s_idc);
    t_idc = randi(n, n_effective, 1);
    target = target_raw(:, t_idc);
end

if strcmp(sampling, 'random')
    n_effective = round(p*n);
    source = source_raw; 
end

while change > 0.001       
    if strcmp(sampling, 'random')
        % select n*p points to consider per iteration (p<1)        
        s_idc = randi(n, n_effective, 1);
        source = R*source + repmat(t, [1, n]);
        source_x = source(:, s_idc);
        t_idc = randi(n, n_effective, 1);
        target = target_raw(:, t_idc);
    end    
    
    [~, I] = pdist2(target', source_x', 'euclidean', 'Smallest', 1);
    target_x = target(:, I);
    
    % determine the centroids of the data clouds
    t_c = sum(target_x, 2)/n_effective;
    s_c = sum(source_x, 2)/n_effective;
    
    % center the data
    target_c = target_x - repmat(t_c, [1, n_effective]);
    source_c = source_x - repmat(s_c, [1, n_effective]);
        
    % get covariance matrix 
    S = source_c*target_c';

    % perform SVD on covariance matrix
    [U, ~, V] = svd(S);
    
    % determine rotation matrix R
    j = det(V*U');
    sig = eye(d);
    sig(d,d) = j;
    R = V*sig*U';
    
    % determine translation vector t
    t = t_c - R*s_c;
    
    % move the point cloud closer to the target
    source_x = R*source_x + repmat(t, [1, n_effective]);
    
    % determine whether to continue
    i = i + 1;
    RMS_old = RMS_new;
    RMS_new = sum(vecnorm(source_x - target_x))/sqrt(n_effective);
    change = abs(RMS_old - RMS_new)/RMS_new;
end

if strcmp(sampling, 'random') || strcmp(sampling, 'uniform')
    % consider the points in the original pointcloud for which we know the
    % corresponding point in the target cloud
    source = source_raw(:, s_idc);
else
    source = source_raw;
end

% determine the centroids of the data clouds
t_c = sum(target_x, 2)/n_effective;
s_c = sum(source, 2)/n_effective;

% center the data
target_c = target_x - repmat(t_c, [1, n_effective]);
source_c = source - repmat(s_c, [1, n_effective]);

% get covariance matrix 
S = source_c*target_c';

% perform SVD on covariance matrix
[U, ~, V] = svd(S);

% determine rotation matrix R
j = det(V*U');
sig = eye(d);
sig(d,d) = j;
R = V*sig*U';

% determine translation vector t
t = t_c - R*s_c;

disp(['convergence to RMS=', num2str(RMS_new), ' in ', num2str(i), ' iterations'])

end