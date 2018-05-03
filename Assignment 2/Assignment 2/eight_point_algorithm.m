function F = eight_point_algorithm(data, s)
% pick eight random point-correspondences that will determine this
% 'guess' of F
N = size(data, 2); % amount of point correspondences
randomIndices = randperm(N, s);

x1 = data(1, randomIndices, 1)';
y1 = data(2, randomIndices, 1)';
x2 = data(1, randomIndices, 2)';
y2 = data(2, randomIndices, 2)';

% determine matrix A from point correspondences
A = [ x1.*x2 x1.*y2 x1 y1.*x2 y1.*y2 y1 x2 y2 ones(s,1) ]; % values are 10e+5, linearly scale down?

% elements of the fundamental matrix can be found on the least eigenvec
% of A^T*A
%S = A'*A;
[~, ~, V] = svd(A);
F_nonsingular = reshape(V(:,9), 3, 3 )';

% enforce the singularity of F by setting its least singular value to 0
[U, D, V] = svd(F_nonsingular);
D(3,3) = 0;
F = U*D*V';
end