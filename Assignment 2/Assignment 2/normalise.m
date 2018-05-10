function [c, T] = normalise(c)
n = size(c, 2); % n_correspondences

% centroid
mx = mean(c(1,:,:), 2);
my = mean(c(2,:,:), 2);

% d-measure
d = mean( sqrt( (c(1,:,:) - repmat(mx,[1, n, 1])).^2 + (c(2,:,:) - repmat(my,[1, n, 1])).^2 ), 2 );

% transformation matrix (tensor)
T = [ ones(1,1,2)*sqrt(2)./d zeros(1,1,2) -mx*sqrt(2)./d ; 
    zeros(1,1,2) ones(1,1,2)*sqrt(2)./d -my*sqrt(2)./d ; 
    zeros(1,1,2) zeros(1,1,2) ones(1,1,2) ];

% normalise
c(:,:,1) = T(:,:,1)*c(:,:,1);
c(:,:,2) = T(:,:,2)*c(:,:,2);

mx_check = mean(c(1,:,:), 2)
my_check = mean(c(2,:,:), 2)
d_check = mean( sqrt( (c(1,:,:) - repmat(mx_check,[1, n, 1])).^2 + (c(2,:,:) - repmat(my_check,[1, n, 1])).^2 ), 2 )

end