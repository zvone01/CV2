function [c, T] = normalise(c)
n = size(c, 2); % n_correspondences

% centroid
mx = mean(c(1,:,:), 2);
my = mean(c(2,:,:), 2);

% d-measure
d = mean( sqrt( (c(1,:,:) - repmat(mx,[1, n, 1])).^2 + (c(2,:,:) - repmat(my,[1, n, 1])).^2 ), 2 );

% transformation matrix (tensor)
T = [ ones(1,1,2)*sqrt(2)./d zeros(1,1,2) -mx*sqrt(2)./d ; 
    zeros(1,1,2) ones(1,1,2)*sqrt(2)./d -mx*sqrt(2)./d ; 
    zeros(1,1,2) zeros(1,1,2) ones(1,1,2) ];

% normalise
c(:,:,1) = T(:,:,1)*c(:,:,1);
c(:,:,2) = T(:,:,2)*c(:,:,2);

end