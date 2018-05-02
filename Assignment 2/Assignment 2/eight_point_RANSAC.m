function best_Fmat = eight_point_RANSAC(data)

s = 8; % amount of correspondences needed
t = 10; % threshold
N = size(data, 2); % amount of point correspondences
max_iter = N; % maximum allowed number of iterations

% N times, pick 
% to determine a projectivity matrix
bestScore = 0; % initialise 
for i = 1 : 2 % max_iter
    % pick eight random points correspondences that will determine this
    % 'guess' of F
    randomIndices = randperm(N, s);
    x1 = data(1, randomIndices, 1)';
    y1 = data(2, randomIndices, 1)';
    x2 = data(1, randomIndices, 2)';
    y2 = data(2, randomIndices, 2)';
    
    % determine matrix A from point correspondences
    A = [ x1.*x2 x1.*y1 x1 y1.*x2 y1.*y2 y1 x2 y2 ones(8,1) ]; % values are 10e+5, linearly scale down?
    
    % elements of the fundamental matrix can be found on the least eigenvec
    % of A^T*A
    S = A'*A;
    [~, ~, V] = svd(S);
    F_nonsingular = reshape(V(:,9), [3,3])';
    
    % enforce the singularity of F by setting its least singular value to 0
    [U, D, V] = svd(F_nonsingular);
    D(3,3) = 0;
    F = U*D*V';
    
    % check whether F is a 'good guess' by counting inliers
    % determine sampson distances by matrix multiplication
    % points in homogeneous coordinates
    p1 = cat( 1, data(:, :, 1), ones(1, N) );
    p2 = cat( 1, data(:, :, 2), ones(1, N) );
    d = (p1' * F * p2).^2 / ( sum((F' * p1).^2) + sum((F * p2).^2));
    
    % score is the n points closer to each other than threshold value
    score = sum( d < t );
    
    if ( score > bestScore )
        bestScore = score;
        best_Fmat = F;
    end
    
end
end