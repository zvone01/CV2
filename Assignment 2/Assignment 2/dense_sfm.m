function [motion, shape] = dense_sfm(PointViewMatrix)
% mean of each row
PointViewMatrix(1:2:end,:) = bsxfun(@minus, PointViewMatrix(1:2:end,:), mean(PointViewMatrix(1:2:end,:), 2));
PointViewMatrix(2:2:end,:) = bsxfun(@minus, PointViewMatrix(2:2:end,:), mean(PointViewMatrix(2:2:end,:), 2));

%compute svd
[U W V] = svd(PointViewMatrix);

% compute motion and shape
motion = U(:, 1:3)*sqrt(W(1:3, 1:3)); 
shape = sqrt(W(1:3, 1:3))*V(:, 1:3)';

end