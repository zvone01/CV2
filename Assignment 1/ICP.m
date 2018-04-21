function [R, t] = ICP(source_raw, target_raw, varargin)
% variable input arguments:
%       'all'; (default)
%       'uniform'; picks n*p points once to consider for ICP
%       'random'; picks n*p different points per iteration
%       p; float controlling the sample size
%       'normals'; samples 
%       source_normals 
%       target_normals
%       n_bins; discretize azimuth and elevation in n bins each
%
% function may be called as such:
% [R, t] = ICP(a, b)
% [R, t] = ICP(a, b, 'random', .1)
% [R, t] = ICP(a, b, 'uniform', .1, 'normals', a_normals, b_normals, 4)

% default settings
% if varargin, some of these will be overwritten
d = size(source_raw, 1);
n = min(size(source_raw, 2), size(target_raw, 2));
n_effective = n;
source_x = source_raw;
target = target_raw; 
sampling = 'all';
p = 1;
sample_by = 'default';

if size(varargin, 2) == 2 || size(varargin,2) == 6
    sampling = varargin{1};
    p = varargin{2};
else
    disp('wrong number of input arguments')
end
if size(varargin, 2) == 6
    sample_by = varargin{3};
    source_normals = varargin{4};
    target_normals = varargin{5};
    n_bins = varargin{6};
end

% initialise variables
RMS_new = 0;
i = 0;
change = 1;
R = eye(d);
t = zeros(d, 1);
n_effective = round(p*n);

% sample points for the uniform sampling case
if strcmp(sampling, 'uniform') 
    if strcmp(sample_by, 'normals')
        s_idc = sample_by_normals(source_raw, source_normals, n_effective)'; 
        t_idc = sample_by_normals(target_raw, target_normals, n_effective)';
    elseif strcmp(sample_by, 'default')
        s_idc = randi(n, n_effective, 1);
        t_idc = randi(n, n_effective, 1);
    end    
    source_x = source_raw(:, s_idc);
    target = target_raw(:, t_idc);
end

if strcmp(sampling, 'random')
    source = source_raw; 
end

while change > 0.001       
    if strcmp(sampling, 'random')
        if strcmp(sample_by, 'normals')
            s_idc = sample_by_normals(source_raw, source_normals, n_effective)'; 
            t_idc = sample_by_normals(target_raw, target_normals, n_effective)';
        elseif strcmp(sample_by, 'default')
            s_idc = randi(n, n_effective, 1);
            t_idc = randi(n, n_effective, 1);
        end    
        source = R*source + repmat(t, [1, size(source, 2)]);
        source_x = source(:, s_idc);
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

if ( strcmp(sampling, 'random') || strcmp(sampling, 'uniform') ) 
    % consider the points in the original pointcloud for which we know the
    % corresponding point in the target cloud
    source = source_raw(:, s_idc);
elseif strcmp(sample_by, 'normals')
    source = source;
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