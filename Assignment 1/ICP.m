function [R, t] = ICP(source, target)

load('Data/source.mat');
load('Data/target.mat');

[d, n] = size(source);
source_x = source;
% TO DO: convergence threshold

for i = 1 : 100
       
    [D, I] = pdist2(target', source_x', 'euclidean', 'Smallest', 1);
    target_x = target(:, I);
    
    RMS = sum(vecnorm(source_x - target_x))/sqrt(n);
    
    % determine the centroids of the data clouds
    t_c = sum(target_x, 2)/n;
    s_c = sum(source_x, 2)/n;
    
    % center the data
    target_c = target_x - repmat(t_c, [1, n]);
    source_c = source_x - repmat(s_c, [1, n]);
        
    % get covariance matrix 
    S = source_c*target_c';

    % perform SVD on covariance matrix
    [U, ~, V] = svd(S);
    
    % determine rotation matrix R
    i = det(V*U');
    sig = eye(d);
    sig(d,d) = i;
    R = V*sig*U';
    
    % determine translation vector t
    t = t_c - R*s_c;
    
    % move the point cloud closer to the target
    source_x = R*source_x + repmat(t, [1, n]);
end

% determine the centroids of the data clouds
t_c = sum(target_x, 2)/n;
s_c = sum(source, 2)/n;

% center the data
target_c = target_x - repmat(t_c, [1, n]);
source_c = source - repmat(s_c, [1, n]);

% get covariance matrix 
S = source_c*target_c';

% perform SVD on covariance matrix
[U, ~, V] = svd(S);

% determine rotation matrix R
i = det(V*U');
sig = eye(d);
sig(d,d) = i;
R = V*sig*U';

% determine translation vector t
t = t_c - R*s_c;


end